
class PlaysController < ApplicationController
  # GET /plays
  # GET /plays.json
  def index
    if params[:q]
      all_plays = Play.search(params[:q])
    else
      all_plays = Play.all
    end
     
    #plays
    @plays = all_plays.select{|p| p.playing == true}
    
    #find historical plays
    historical_plays = all_plays.reject{|p| p.playing}
    station_counts = historical_plays.inject(Hash.new(0)) { |count_ary, play| count_ary[play.station_id] += 1 ; count_ary }
    station_counts = station_counts.sort {|a,b| b[1] <=> a[1]} 
    station_ids = station_counts.collect{|s| s[0]} #in correct order
    play_ids = @plays.collect{|p| p.station_id} # currently playing ids
    station_ids = (station_ids - play_ids)[0..4] 
    
    #im sure there's a better way to do this in one db call
    #but a string of ids does not preserve order
    #and i don't have time to mess with it at the moment
    @potential_plays = []
    
    #backwards?
    station_ids.each do |id|
      @potential_plays << Station.find(id).plays.last
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @plays }
    end
  end

  # GET /plays/1
  # GET /plays/1.json
  def show
    @play = Play.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @play }
    end
  end

  # GET /plays/new
  # GET /plays/new.json
  def new
    @play = Play.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @play }
    end
  end

  # GET /plays/1/edit
  def edit
    @play = Play.find(params[:id])
  end

  # POST /plays
  # POST /plays.json
  def create
    @play = Play.new(params[:play])

    respond_to do |format|
      if @play.save
        format.html { redirect_to @play, notice: 'Play was successfully created.' }
        format.json { render json: @play, status: :created, location: @play }
      else
        format.html { render action: "new" }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /plays/1
  # PUT /plays/1.json
  def update
    @play = Play.find(params[:id])

    respond_to do |format|
      if @play.update_attributes(params[:play])
        format.html { redirect_to @play, notice: 'Play was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @play.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plays/1
  # DELETE /plays/1.json
  def destroy
    @play = Play.find(params[:id])
    @play.destroy

    respond_to do |format|
      format.html { redirect_to plays_url }
      format.json { head :no_content }
    end
  end
end
