# monkey patch EM::HttpConnection
module EventMachine
  class HttpConnection
    def receive_data(data)
      begin
        if !defined?(@hack)
          data.gsub!("ICY", "HTTP/1.1") # hack to change ICY to HTTP/1.1 so HTTP::Parser don't freak out
          @hack = true
        end 
        @p << data
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
      :proxy => {
        :host => '127.0.0.1',    # proxy address
        :port => 8888,           # proxy port
      },
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
      http = EventMachine::HttpRequest.new(url, @conn).get(@options)
      
      http.errback {
        puts http.error
      }

      http.headers {
        puts "icy-metaint: #{http.response_header['icy-metaint']}"
      }

      http.stream { |chunk|
        puts chunk
      }

    end
  end
  
end