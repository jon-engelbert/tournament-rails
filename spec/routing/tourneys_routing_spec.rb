require "rails_helper"

RSpec.describe TourneysController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/tourneys").to route_to("tourneys#index")
    end

    it "routes to #new" do
      expect(:get => "/tourneys/new").to route_to("tourneys#new")
    end

    it "routes to #show" do
      expect(:get => "/tourneys/1").to route_to("tourneys#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/tourneys/1/edit").to route_to("tourneys#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/tourneys").to route_to("tourneys#create")
    end

    it "routes to #update" do
      expect(:put => "/tourneys/1").to route_to("tourneys#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/tourneys/1").to route_to("tourneys#destroy", :id => "1")
    end

  end
end
