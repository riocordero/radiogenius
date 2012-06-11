
class SearchController < ApplicationController
  def index
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
           minFontSize = 5
           maxFontSize = 40
           @tag_cloud_hash = Hash.new(0)
           tags.each do |tag| 
               weight = (artist_counts[tag]-minOccurs).to_f/(maxOccurs-minOccurs)
               size = minFontSize + ((maxFontSize-minFontSize)*weight).round
               @tag_cloud_hash[tag] = size if size > 7
           end
       end
  end
end
