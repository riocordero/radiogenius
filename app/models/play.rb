class Play < ActiveRecord::Base
  attr_accessible :artist, :search_blob, :song_title, :started_at, :station_id, :playing

  before_save :build_search_blob

  belongs_to :station

  def self.search(query)
    self.find(:all, :conditions => ['match(search_blob) against (?)', query], :order => 'id DESC')
  end

  def build_search_blob
    self.search_blob = "#{self.artist} - #{self.song_title}"
  end
end
