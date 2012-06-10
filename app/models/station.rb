class Station < ActiveRecord::Base
  attr_accessible :name, :url, :stream_type
end
