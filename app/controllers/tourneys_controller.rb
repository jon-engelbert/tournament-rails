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
  end

  # GET /tourneys/1/edit
  def edit
  end

  # GET /tourneys/1/edit_super
  def edit_super
    @tourney = Tourney.find(params[:id])
    @players = Player.all()
  end

  # POST /tourneys
  # POST /tourneys.json
  def create
    @tourney = Tourney.new(tourney_params)
    @tourney.owner_id = current_user.id

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
      puts "params"
      puts params.inspect
      if @tourney.update(tourney_params)
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
