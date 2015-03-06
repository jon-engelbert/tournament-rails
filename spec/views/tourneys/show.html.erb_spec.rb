require 'rails_helper'

RSpec.describe "tourneys/show", type: :view do
  before(:each) do
    @tourney = assign(:tourney, Tourney.create!(
      :name => "Name",
      :location => "Location"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Location/)
  end
end
