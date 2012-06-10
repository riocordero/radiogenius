class Play < ActiveRecord::Base
  attr_accessible :artist, :search_blob, :song_title, :start_time
end
