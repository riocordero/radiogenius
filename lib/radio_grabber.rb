# Try running: RadioGrabber.new(:url => "http://u12b.di.fm:80/di_vocaltrance").grab
HEADER_SEPARATOR = "\r\n"
HEADER_END_SEPARATOR = "\r\n\r\n"

module EventMachine
  # monkey patch EM::HttpConnection
  class HttpConnection
    attr_accessor :headers

    def receive_data(data)
      if !defined?(@hacked)
        @hacked = true
        @headers = {}
        @header_buffer = ''
        @header_status = :none
      end
      begin
        if @header_status == :none
          idx = data.index(HEADER_END_SEPARATOR)
          if idx
            @header_buffer += data[0, idx]
            data = data[(idx + HEADER_END_SEPARATOR.length)..-1]
            @header_status = :read
            # puts @header_buffer.inspect
            # puts '========================================'
            # puts data
            @header_buffer.split(HEADER_SEPARATOR).each do |full_header|
              key, value = full_header.split(':').map(&:strip)
              @headers[key] = value
            end
            # @headers.each do |k, v|
            #   puts "#{k} - #{v}"
            # end
          else
            @header_buffer += data
          end
        end
        if @header_status == :read
          client.parse_response_header(@headers, [1,0], 200)
          @header_status = :done
        end
        if @header_status == :done
          @stream.call(data)
        end
      rescue HTTP::Parser::Error => e
        c = @clients.shift
        c.nil? ? unbind(e.message) : c.on_error(e.message)
      end
    end
  end
end

# module EventMachine
#   class HttpConnection
#     def post_init
#       @clients = []
#       @pending = []
# 
#       @p = Http::Parser.new
#       @p.header_value_type = :mixed
#       @p.on_headers_complete = proc do |h|
#         client.parse_response_header(h, @p.http_version, @p.status_code)
#         @header_completed = true
#         :reset if client.req.no_body?
#       end
# 
#       @p.on_body = proc do |b|
#         client.on_body_data(b)
#       end
# 
#       @p.on_message_complete = proc do
#         if not client.continue?
#           c = @clients.shift
#           c.state = :finished
#           c.on_request_complete
#         end
#       end
#     end
#         
#     def receive_data(data)
#       begin
#         if !defined?(@hack)
#           @hack = true
#           data.gsub!("ICY 200 OK", "HTTP/1.1 200 OK\r\nTransfer-Encoding:chunked")
#         end
#         if defined?(@header_completed) 
#           puts data
#           raise 'error'
#         else
#           @p << data
#         end
#       rescue HTTP::Parser::Error => e
#         c = @clients.shift
#         c.nil? ? unbind(e.message) : c.on_error(e.message)
#       end
#     end
#   end
# end

class RadioGrabber
  attr_reader :url
  attr_reader :station
  attr_reader :logger
  # attr_reader :metadata_interval

  def initialize(options = {})
    if options[:url]
      @url = options[:url]
    elsif options[:station]
      @station = options[:station]
      @url = station.url
    end
    @logger = options[:logger] || Logger.new(STDOUT)
    @conn = {
      :connect_timeout => '5',
      :inactivity_timeout => '10',
      # :proxy => {
      #   :host => '127.0.0.1',    # proxy address
      #   :port => 8888,           # proxy port
      # },
    }
    @options = {
      :redirects => 5,           # follow 3XX redirects up to depth 5
      :keepalive => true,
      :head => {
        "Icy-MetaData" => "1",
        "Accept" => "*/*",
      }
    }
  end

  def grab
    EM.run do
      @http = EventMachine::HttpRequest.new(url, @conn)
      # count = 0
      # bytes = 0
      # streamMetadataIndex = nil
      # bits = 'n/a'
      streamer = Proc.new { |chunk|
        begin
          listen_for_metadata(chunk)
        # rescue e
        #   logger.error "error steam failed: #{e.inspect}"
        # ensure
        #   retry_on_error
        end
        # byte_array = chunk.bytes.to_a
        # idx = chunk.index('StreamTitle')
        # if idx
        #   size = byte_array[idx-1]
        #   puts "size => #{size}"
        #   puts "metadata => #{byte_array[idx, idx+size]}"
        #   puts "#{@count + idx} ==>", chunk
        #   # new_bits = chunk.match(/StreamTitle='([^']*?)'/)[1]
        #   # bits = new_bits if new_bits.length > 0
        #   # streamMetadataIndex = bytes + idx
        # end
        # bytes += chunk.length
        # 
        # STDOUT.print "\rStream callback hit #{count += 1} (#{bytes}B total) - last stream metadata '#{bits}'@#{streamMetadataIndex}"
      }
      @http.instance_variable_set(:@stream, streamer)
      @http = @http.get(@options)

      @http.headers {
        @running = true
        if station
          logger.info "connection to station: #{station.id} - #{station.name}"
        else
          logger.info "connection to url: #{url}"
        end
        # http.response_header.each do |k, v|
        #   puts "#{k} - #{v}"
        # end
        
        # @metadata_interval = http.response_header['icy-metaint']
        # puts "interval: #{metadata_interval}"
        # puts "icy-metaint: #{http.response_header['icy-metaint']}"
      }
      
      @http.errback {
        if station
          logger.error "error grabbing station: #{station.id}"
        else
          logger.error "error grabbing url: #{url}"
        end
        @running = false
        retry_on_error
      }
    end
  end
  
  def stop
    if station
      logger.info "stopped grabber for station: #{station.id} - #{station.name}"
    else
      logger.info "stopped grabber for url: #{url}"
    end
    @http.unbind("stop")
    @running = false
  end
  
  def running?
    @running
  end
  
  protected
  def listen_for_metadata(data)
    # TODO: use byte count to actually do this correctly... 
    matcher = /StreamTitle=(?<metadata>[^;]+)/.match(data)
    if matcher
      blob = matcher[:metadata]
      unless blob.blank?
        # clean the begin quote and end quote characters
        if blob[0] =~ /[\'\"]/ && blob[blob.size-1] =~ /[\'\"]/
          blob = blob[1..blob.size-2]
        end
        metadata = blob.split(/\s-\s/)
        artist = metadata[0] ? metadata[0].strip : nil
        song = metadata[1] ? metadata[1].strip : nil
        if station && artist && song
          last = station.plays.last
          if last.nil? || last.artist != artist || last.song_title != song 
            # only create new entry when the song and artist have changed
            Play.transaction do
              station.plays << Play.new(:started_at => Time.now, :artist => artist, :song_title => song, :playing => true)
              if last
                last.playing = false
                last.save
              end
            end
          end
        elsif station
          logger.warn "no artist or song for station #{station.id} '#{blob}'"
        else
          logger.debug blob
        end
      end
    end
  end
  
  def retry_on_error
    EM::Timer.new(5) do
      logger.info "retrying station: #{station.id}" if station
      grab # we try to grab again after 5 seconds
    end
  end
  
end
