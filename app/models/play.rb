class Play < ActiveRecord::Base
  attr_accessible :artist, :search_blob, :song_title, :start_time, :station_id

  before_save :build_search_blob

  belongs_to :station

  def self.search(query)
    self.find(:all, :conditions => ['match(search_blob) against (?)', query])
  end

  def build_search_blob
    self.search_blob = "#{self.artist} - #{self.song_title}"
  end
end
