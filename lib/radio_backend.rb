require 'radio_grabber'

class RadioBackend
  
  Signal.trap('SIGINT') do
    RadioBackend.instance.stop_all
  end
  
  Signal.trap('TERM') do
    RadioBackend.instance.stop_all
  end
  
  class << self
    attr_accessor :instance
  end
  
  attr_accessor :logger
  
  # TODO: make this private??
  def initialize
    @grabbers = {}
    self.logger = Logger.new(STDOUT)
    
    self.class.instance = self
  end
  
  def logger=(logger)
    @logger = logger
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime} [#{severity}]: #{msg}\n"
    end
  end
  
  def start_all
    logger.info "start all grabbers"
    EM.run do
      Station.all.each do |station|
        grabber = RadioGrabber.new(:station => station, :logger => self.logger)
        @grabbers[station.id] = grabber
        grabber.grab # grabbing this station
      end
    end
  end
  
  def stop_all
    EM.next_tick do 
      @grabbers.each do |id, grabber|
        grabber.stop
      end
      EM.stop_event_loop
      logger.info "stopped all grabbers"
    end
  end
  
  private
  
  
end