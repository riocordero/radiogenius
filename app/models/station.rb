class Station < ActiveRecord::Base
  attr_accessible :name, :url, :stream_type

  has_many :plays

  def streamable_url
    uri = URI.parse(url)
    if /([0-9])+\.([0-9])+\.([0-9])+\.([0-9])+/.match uri.host
      return "#{url}/;mp3"
    else
      return url
    end
  end
  
  def current
    self.plays.select{|p| p.playing==true}[0]
  end
end
