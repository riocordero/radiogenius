class SearchController < ApplicationController
  
  def index
    set_meta_tags(:title => "the world's smartest radio search engine",
                  :description => "Find your song...now! We search the world's best internet radio stations for artists and songs that are currently playing.", 
                  :keywords => ['radio', 'music', 'music search engine', 'radio search engine', 'internet radio', 'free music', 'streaming music', 'shoutcast', 'mp3', 'top 40', 'winamp'])
    
    @hide_search = true

    #try to make the tag cloud
    current_plays = Play.find(:all, :conditions=>"playing=true")
    artist_counts = current_plays.inject(Hash.new(0)) { |count_ary, play| count_ary[play.artist] += 1 ; count_ary }

    tags = artist_counts.collect{|k,v| k}
    if tags.length > 0
      tags_by_count = artist_counts.sort{|a,b| b[1] <=> a[1]}
      maxOccurs = tags_by_count.first[1]
      minOccurs = tags_by_count.last[1]

      # Get relative size for each of the tags and store it in a hash
      minFontSize = 15
      maxFontSize = 40
      @tag_cloud_hash = Hash.new(0)
      tags.each do |tag| 
        weight = (artist_counts[tag]-minOccurs).to_f/((maxOccurs-minOccurs)+1)
        size = minFontSize + ((maxFontSize-minFontSize)*weight).round
        @tag_cloud_hash[tag] = size # if size > 10
      end
    end
  end
end
