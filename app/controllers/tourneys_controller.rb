class TourneysController < ApplicationController
  before_action :logged_in_user, only: [:edit, :edit_super, :update, :destroy]
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
    @player_names = ''
  end

  # GET /tourneys/1/edit
  def edit
    @tourney = Tourney.find(params[:id])
    @players = Player.all()
    @entrants = @tourney.players()
    @player_names = ''
    @entrants.each do |entrant|
      @player_names += entrant.name
      @player_names += "\r\n"
    end
    puts "*****************  entrant player_names #{@player_names}"
    puts "*****************   player_names #{@players.select("name").inspect}"
  end

  # GET /tourneys/1/edit_super
  def edit_super
    @tourney = Tourney.find(params[:id])
    @players = Player.all()
    @entrants = @tourney.players()
    @player_names = ''
    @entrants.each do |entrant|
      @player_names += "\r\n" if @player_names.present?
      @player_names = entrant.name
    end
    puts "*****************  player_names #{@player_names}"
  end

  # POST /tourneys
  # POST /tourneys.json
  def create
    @tourney = Tourney.new(tourney_params)
    @tourney.user_id = current_user.id

    respond_to do |format|
      if @tourney.save
        format.html { redirect_to @tourney, notice: 'Tourney was successfully created.' }
        format.json { render :show, status: :created, location: @tourney }
      else
        format.html { render :new }
        format.json { render json: @tourney.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tourneys/1
  # PATCH/PUT /tourneys/1.json
  def update
    respond_to do |format|
      puts "params: #{params.inspect}"
      if @tourney.update(tourney_params)
        #store entrants
        entrants = tourney_params[:player_names].split("\r\n")
        puts entrants
        entrants.each do |entrant_name|
          entrant  = Player.find_by name: entrant_name
          if entrant.present?
            begin
              @tourney.players << entrant
            rescue Exception => exc
               logger.error("Message for the log file #{exc.message}")
               flash[:notice] = "Store error message"
            end
          else
            error_msg = "Player #{entrant_name} not found: add this player first"
            flash[:error] = error_msg
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
      params.require(:tourney).permit(:name, :date, :location, :player_names)
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
