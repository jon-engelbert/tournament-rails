require 'rails_helper'

RSpec.describe "Tournaments", type: :request do
  describe "GET /tourneys" do
	subject (:tour) {FactoryGirl.build(:tourney)}
    it "works! (now write some real specs)" do
      get tourneys_path
      expect(response).to have_http_status(200)
    end
    it "user can set points for win, bye, tie" do
      user = FactoryGirl.build(:user)
      user.save
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      tour.user_id = user.id
      tour.save
      get edit_tourney_path(tour.id)
      expect(response.body).to include("win")
      expect(response.body).to include("bye")
      expect(response.body).to include("tie")

    end
  end
end
