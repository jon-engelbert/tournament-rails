require 'rails_helper'

RSpec.describe "Tournaments", type: :request do
  describe "GET /tourneys" do
	subject (:tour) {FactoryGirl.build(:tourney)}
    it "works! (now write some real specs)" do
      get tourneys_path
      expect(response).to have_http_status(200)
    end
    it "delete link is available for the creator" do
      user = FactoryGirl.build(:user)
      user.save
      tour.user_id = user.id
      get tourneys_path
      
    end
  end
end
