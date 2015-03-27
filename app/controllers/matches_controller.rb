class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.all
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)

    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: 'Match was successfully created.' }
        format.json { render :show, status: :created, location: @match }
      else
        format.html { render :new }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /matches/swap
  def swap
    player1id, player2id = -1, -1
    error = false
    match1, match2 = nil, nil
    puts "****************** in swap match, params: #{params}"
    player1name = params['player1_swap']
    player2name = params['player2_swap']
    begin
      player1id = Player.find_by(name: player1name).id
      player2id = Player.find_by(name: player2name).id
    rescue Exception => exc
      logger.error("Message for the log file #{exc.message}")
      flash[:notice] = "Swap aborted"
      error = true
    end
    round = params['round']
    tourney_id = params["tourney_swap"]
    if (params['match1_id'] == params['match2_id'])
      logger.error("swap within the same match is not allowed")
      error = true
      flash[:notice] = "Swap aborted"
    end
    begin
      match1 = Match.find_by(id: params['match1_id'])
      match2 = Match.find_by(id: params['match2_id'])
      puts "******************* matches: #{match1.inspect} #{match2.inspect}"
    rescue Exception => exc
      logger.error("match not found: Message for the log file #{exc.message}, #{player1id}, #{player2id}, #{tourney_id}, #{params['round']}")
      flash[:notice] = "Swap aborted"
      error = true
    end
    # respond_to do |format|
    begin
      if not error
        match1.replace_player(player1id, player2id)
        match2.replace_player(player2id, player1id)
      end
    rescue Exception =>exc
      logger.error("Message for the log file #{exc.message}")
      flash[:notice] = "Swap aborted"
      error = true
    end
    response_hash = {}
    response_hash['success'] = !error
    response_hash['player1_name'] = player1name
    response_hash['player2_name'] = player2name
    puts "************** match_hash: #{response_hash.inspect}"
    puts "************** match_hash.to_json: #{response_hash.to_json.inspect}"
    puts "************** request.xhr: #{request.xhr?}"
    # format.json { render :json => response_hash.to_json }
    render json: response_hash.to_json and return if request.xhr?
  end

  # POST /matches/record
  # def self.record # this doesn't work, route not found when class method
  def record
    puts "****************** in record match, params: #{params}"
    record_results params
  end

  def record_results params
    puts "****************** in record match, params: #{params}"
    player1name = params['player1_name']
    player2name = params['player2_name']
    begin
      player1id = Player.find_by(name: player1name).id
      player2id = Player.find_by(name: player2name).id
    rescue Exception => exc
      logger.error("Message for the log file #{exc.message}")
      flash[:notice] = "Store error message"
    end
    begin
      puts "match find : #{player1id}, #{player2id}, #{params['tourney_id']}, #{params['round']}"
      match = Match.find_by(player1_id: player1id, player2_id: player2id, tourney_id: params["tourney_id"], round: params['round'])
    rescue Exception => exc
       puts "match not found: #{player1id}, #{player2id}, #{params['tourney_id']}, #{params['round']}"
   end

    if match.nil?
      begin
        match = Match.find_by(player1_id: player1id, player2_id: player2id, tourney_id: params['tourney_id'], round: -1)
      rescue Exception => exc
       puts "match not found: #{player1id}, #{player2id}, #{params['tourney_id']}, -1}"
      end
    end

    if match.present?
      match.player1_score = params[:player1_score]
      match.player2_score = params[:player2_score]
      match.ties = params[:ties]
      match.round = params[:round]
      match.save
    else
      params['player1_id'] = player1id
      params['player2_id'] = player2id
      params.delete :player1_name
      params.delete :player2_name
      params['match'] = params
      puts "****************** in record match, params: #{match_params}"
      match = Match.create(match_params)
      match.save
   end
    respond_to do |format|
      match_hash = match.as_json
      match_hash['player1_name'] = player1name
      match_hash['player2_name'] = player2name
      format.json { render :json => match_hash.to_json }
    end
  end

  # POST /matches/record_all
  # def self.record # this doesn't work, route not found when class method
  def record_all
    puts "****************** in record_all match, params: #{params}"
    params.each do |match_params| 
      record_results match_params
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to @match, notice: 'Match was successfully updated.' }
        format.json { render :show, status: :ok, location: @match }
      else
        format.html { render :edit }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

# DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url, notice: 'Match was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:player1_id, :player2_id, :tourney_id, :round, :player1_score, :player2_score, :ties)
    end
end
