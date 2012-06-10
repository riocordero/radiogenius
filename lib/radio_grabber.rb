# monkey patch EM::HttpConnection
HEADER_SEPARATOR = "\r\n"
HEADER_END_SEPARATOR = "\r\n\r\n"

module EventMachine
  class HttpConnection
    def receive_data(data)
      if !defined?(@hacked)
        @hacked = true
        @count = 0
        @total_bytes = 0
        @headers = {}
        @header_buffer = ''
        @headers_done = false
      end
      puts "Received data: #{@count += 1} #{@total_bytes += data.length}"
      begin
        # @p << data
        if !@headers_done
          idx = data.index(HEADER_END_SEPARATOR)
          if idx
            @header_buffer += data[0, idx]
            data = data[(idx + HEADER_END_SEPARATOR.length)..-1]

            @headers_done = true
            @header_buffer.split(HEADER_SEPARATOR).each do |full_header|
              key, value = full_header.split(':').map(&:strip)
              @headers[key] = value
            end
            puts "Parsed headers."
        @headers.each do |k, v|
          puts "#{k} - #{v}"
        end
          else
            @header_buffer += data
          end
        end

        puts "\tHeaders? #{@headers_done}"
        if @headers_done
          @stream.call(data)
        end
      rescue HTTP::Parser::Error => e
        c = @clients.shift
        c.nil? ? unbind(e.message) : c.on_error(e.message)
      end
    end
  end
end


class RadioGrabber
  attr_reader :url

  def initialize(url)
    @url = url
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
        # 'Accept' => '*/*'
      }
    }
  end

  def grab
    EM.run do
      http = EventMachine::HttpRequest.new(url, @conn)
      streamer = Proc.new { |chunk|
        puts "Stream callback hit"
      }
      http.instance_variable_set(:@stream, streamer)
      http = http.get

      http.headers {
        http.response_header.each do |k, v|
          puts "#{k} - #{v}"
        end
        # puts "icy-metaint: #{http.response_header['icy-metaint']}"
      }
    end
  end

end
