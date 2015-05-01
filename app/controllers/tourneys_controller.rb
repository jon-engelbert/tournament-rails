#require 'tourney_service.rb'

class TourneysController < ApplicationController
  before_action :logged_in_user, only: [:new, :edit, :edit_super, :update, :destroy, :create]
  before_action :set_tourney, only: [:show, :edit, :update, :destroy]

  # GET /tourneys
  # GET /tourneys.json
  def index
    puts "current_user: #{current_user.inspect}"
    @curr_user = current_user
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
    @entrant_names = []
    @entrant_emails = []
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
    puts "******* entrant_name_list #{@entrant_name_list.inspect}"
    puts "******* entrant_names #{@entrant_names}"
    puts "******* entrant_emails #{@entrant_emails}"
    puts "******* players_remaining_names #{@players_remaining_names}"
  end

  # GET /tourneys/1/brackets_next
  def brackets_next
    # in response to user clicking on "generate next round".
    # if current round is complete, then proceed.
    @tourney = Tourney.find(params[:id])
    bracket_manager = BracketManager.new(@tourney)
    max_round = Match.where(tourney_id: params[:id]).maximum(:round)
    max_round = 0 if max_round.nil?
    good_enough_penalty = max_round * 0.1 # Match.count / 3
    bracket_manager.generate_brackets_next good_enough_penalty
    @matches, @bye_player = @tourney.brackets
    @max_round = Match.where(tourney: params[:id]).maximum(:round)
    @max_round = 0 if @max_round.nil?
    render :brackets
  end

  # GET /tourneys/1/brackets
  def brackets
    @tourney = Tourney.find(params[:id])
    @matches, @bye_player = @tourney.brackets
    @max_round = Match.where(tourney: params[:id]).maximum(:round)
    @max_round = 0 if @max_round.nil?
    puts "***************** tourney: #{@tourney.inspect}"
    puts "**************** matches: #{@matches.inspect}"
    puts "**************** max_round: #{@max_round}"
    puts "**************** bye_player: #{@bye_player}"
  end


  # GET /standings
  # GET /standings.json

  def standings
    @tourney = Tourney.find(params[:id])
    @player_standings = @tourney.generate_standings
  end

  # POST /tourneys
  # POST /tourneys.json
  def create
    @tourney = Tourney.new(tourney_params)
    @tourney.user_id = current_user.id

    if @tourney.save
      names = tourney_params[:entrant_names]
      puts names
      names.each do |name|
        entrant  = Player.find_by name: name
        if entrant.present?
          begin
            @tourney.players << entrant
          rescue Exception => exc
             logger.error("Message for the log file #{exc.message}")
             flash[:notice] = "Store error message"
          end
        # else
        #   puts "********* name, email: #{name} #{email}"
        #   entrant = Player.new({name: name, email: email})
        #   puts "********* entrant #{entrant}"
        #   entrant.save
        #   @tourney.players << entrant
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
      puts "***************** tourney_params: #{tourney_params.inspect}"
      puts "***************** @tourney.players #{@tourney.players}"
      if @tourney.update(tourney_params)
        #store entrants
        puts "*************** entrant_names: #{tourney_params[:entrant_names]}"
        # emails = tourney_params[:entrant_emails].split(",")
        names = tourney_params[:entrant_names]
        puts names
        #add un-found entrants
        names.each do |name|
          entrant  = Player.find_by name: name
          if entrant.present?
            puts "*********** entrant.present #{name}"
            if !@tourney.players.include? entrant
              @tourney.players << entrant
            end
          # else
          #   entrant = Player.new({name: name, email: email})
          #   entrant.save
          #   @tourney.players << entrant
            # @tourney.entrants << entrant
          end
        end
        @tourney.entrants.each do |entrant|
          begin
            player = Player.find(entrant.player_id)
          rescue Exception => exc
             logger.error("Message for the log file #{exc.message}")
             flash[:notice] = "Store error message"
          end
          entrant_name = player.present? ? player.name : ""
          puts "********************* tourney_player, name: #{entrant.inspect}, #{entrant_name}"
          if !names.include?(entrant_name)
            puts "**************** about to remove: #{entrant_name}"
            entrant.delete
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
      params.require(:tourney).permit(:name, :date, :location, :points_win, :points_tie, :points_bye, :entrant_names => [])
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
