require 'rails_helper'

RSpec.describe "Tourneys", type: :request do
  describe "GET /tourneys" do
    it "works! (now write some real specs)" do
      get tourneys_path
      expect(response).to have_http_status(200)
    end
  end
end
