class TourneysController < ApplicationController
  before_action :logged_in_user, only: [:new, :edit, :edit_super, :update, :destroy, :create]
  before_action :set_tourney, only: [:show, :edit, :update, :destroy]

  # GET /tourneys
  # GET /tourneys.json
  def index
    @tourneys = Tourney.all
  end

  # GET /tourneys/1
  # GET /tourneys/1.json
  def show
  end

  # GET /tourneys/new
  def new
    @tourney = Tourney.new
    @players = Player.all()
    @entrants = nil
    @players_remaining = Player.all()
    @player_names = Player.pluck(:name)
    @player_emails = Player.pluck(:email)
    @players_remaining_names = @player_names
    @players_remaining_emails = @player_emails
    # puts "******* player_name_list #{@player_names}"
    # puts "******* player_email_list #{@player_emails}"
    # puts "******* players_remaining_names #{@players_remaining_names}"
    @entrant_names = ''
    @entrant_emails = ''
  end

  # GET /tourneys/1/edit
  def edit
    @tourney = Tourney.find(params[:id])
    @entrants = @tourney.players()
    @players_remaining = Player.all() - @entrants
    @player_names = Player.pluck(:name)
    @player_emails = Player.pluck(:email)
    @players_remaining_names = @player_names - @tourney.players().pluck(:name)
    @players_remaining_emails = @player_emails - @tourney.players().pluck(:email)
    @entrant_names = ''
    @entrant_emails = ''
    @entrant_name_list = @tourney.players().pluck(:name)
    @entrant_email_list = @tourney.players().pluck(:email)
    @entrants.each do |entrant|
      @entrant_names += entrant.name
      @entrant_names += "\r\n"
      @entrant_emails += entrant.email
      @entrant_emails += "\r\n"
    end
    # puts "******* entrant_names #{@entrant_names}"
    # puts "******* entrant_emails #{@entrant_emails}"
 end

  # GET /tourneys/1/brackets
  def brackets
    @tourney = Tourney.find(params[:id])
    @players = Player.all()
    match_player_ids = []
    match_records = Match.where(tourney: @tourney.id).where("round <= 0")
    match_records.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
    end

    @entrants_unmatched = []
    @tourney.players.each do |entrant|
      if !match_player_ids.include? entrant.id 
        @entrants_unmatched << entrant
      end
    end

    # @entrants = @tourney.players()
    @matches = []
    @match_records = Match.where(tourney: @tourney.id, round: 0)
    pairs, @bye_player = @tourney.swiss_pairings_initial @entrants_unmatched
    player1, player2 = pairs.transpose
    scores1, scores2, ties = [0] * pairs.size, [0] * pairs.size, [0] * pairs.size
    round = [0] * pairs.size
    if player1.present?
      @match_data = player1.zip(player2, scores1, scores2, ties, round)
      @match_data.each do |data|
        parms = {tourney_id: @tourney.id, player1_id: data[0].id, player2_id: data[1].id, player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5]}
        match = Match.new parms
        match.save
        match.player1_name = data[0].name
        match.player2_name = data[1].name
        @matches << match
      end
    end
    @match_records.each do |match|
      match.player1_name = Player.find_by(id: match.player1_id).name
      match.player2_name = Player.find_by(id: match.player2_id).name
      @matches << match
    end
    # puts "******************* match_count: #{@matches.count}"
    # puts "***************** @match_data: #{player1}"
    # puts "***************** scores1: #{scores1}"
    # puts "***************** matches: #{@matches.inspect}"
    # puts "***************** bye_player: #{@bye_player.inspect}"
    # puts "*****************  entrant player_names #{@player_names}"
    # puts "*****************  entrant player_emails #{@player_emails}"
    # puts "*****************   player_names #{@players.select("name").inspect}"
    # puts "***************** tourney id #{@tourney.id}"
  end

  # GET /standings
  # GET /standings.json
  def standings
    matches = []
    standings = []
    @tourney = Tourney.find(params[:id])
    players = @tourney.players

    match_records = @tourney.matches
    match_records.each do |match|
      matches << match
      puts "match #{match.inspect}"
    end

    player1records = []
    players.each do |player|
      puts "player #{player.inspect}"
      playermatches = matches.select {|match| match.player1_id == player.id}
      playermatchesRev = matches.select {|match| match.player2_id == player.id}
      playermatchesRev.each do |match|
        tempLosses = match.player1_score
        match.player1_score = match.player2_score
        match.player2_score = tempLosses
        playermatches << match
      end
      match_wins = playermatches.count {|match| match.player1_score > match.player2_score}
      match_losses = playermatches.count {|match| match.player1_score < match.player2_score}
      match_ties = playermatches.count {|match| match.player1_score == match.player2_score}
      match_points = 3*match_wins + match_ties
      standing = {player_id: player.id, name: player.name, wins: match_wins, losses: match_losses, ties: match_ties, points: match_points}
      puts "standing #{standing}"
      standings << standing
    end
    @player_standings = standings

    # player1matches = matches   #.select("Player.id as player_id, player.name as name, match.player1_score as wins, match.player2_score as losses, match.ties as ties").order(name: :desc)
    # puts "player1s.inspect #{player1s.inspect}"
    # player2s = Player.select("player.id as player_id, player.name as name, matches.player2_score as wins, matches.player1_score as losses, matches.ties as ties").joins("LEFT OUTER JOIN matches ON player_id= matches.player2_id").order(name: :desc)
    # players = player1s.union(player2s)
    # @player_standings = players.select("player_id as id, name, count(case when wins > losses then 1 end) as match_wins, count(case when wins < losses then 1 end) as match_losses, count(case when wins = losses then 1 end) as match_ties, sum(wins) as game_wins, sum(losses) as game_losses, sum(ties) as game_ties").group_by(:player_id, :name).order(:match_wins)

  end

  # POST /tourneys
  # POST /tourneys.json
  def create
    @tourney = Tourney.new(tourney_params)
    @tourney.user_id = current_user.id

    if @tourney.save
      names = tourney_params[:entrant_names].split("\r\n")
      emails = tourney_params[:entrant_emails].split("\r\n")
      entrants = names.zip(emails)
      puts entrants
      entrants.each do |name, email|
        entrant  = Player.find_by name: name
        if entrant.present?
          begin
            @tourney.players << entrant
          rescue Exception => exc
             logger.error("Message for the log file #{exc.message}")
             flash[:notice] = "Store error message"
          end
        else
          puts "********* name, email: #{name} #{email}"
          entrant = Player.new({name: name, email: email})
          puts "********* entrant #{entrant}"
          entrant.save
          @tourney.players << entrant
        end
      end
      redirect_to @tourney, notice: 'Tourney was successfully created.' 
    else
      render :new 
    end
  end

  # PATCH/PUT /tourneys/1
  # PATCH/PUT /tourneys/1.json
  def update
    respond_to do |format|
      puts "params: #{params.inspect}"
      if @tourney.update(tourney_params)
        #store entrants
        names = tourney_params[:entrant_names].split("\r\n")
        emails = tourney_params[:entrant_emails].split("\r\n")
        entrants = names.zip(emails)
        puts entrants
        entrants.each do |name, email|
          entrant  = Player.find_by name: name
          if entrant.present?
            begin
              @tourney.players << entrant
            rescue Exception => exc
               logger.error("Message for the log file #{exc.message}")
               flash[:notice] = "Store error message"
            end
          else
            entrant = Player.new({name: name, email: email})
            entrant.save
            @tourney.players << entrant
          end
        end
        format.html { redirect_to @tourney, notice: 'Tourney was successfully updated.' }
        format.json { render :show, status: :ok, location: @tourney }
      else
        format.html { render :edit }
        format.json { render json: @tourney.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tourneys/1
  # DELETE /tourneys/1.json
  def destroy
    @tourney.destroy
    respond_to do |format|
      format.html { redirect_to tourneys_url, notice: 'Tourney was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tourney
      @tourney = Tourney.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tourney_params
      params.require(:tourney).permit(:name, :date, :location, :entrant_names, :entrant_emails)
    end

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
