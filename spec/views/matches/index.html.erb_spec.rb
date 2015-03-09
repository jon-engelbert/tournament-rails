require 'rails_helper'

RSpec.describe "matches/index", type: :view do
  before(:each) do
    assign(:matches, [
      Match.create!(
        :player1_id => "",
        :player2_id => "",
        :tourney_id => "",
        :round => "",
        :player1_score => "",
        :player2_score => "",
        :ties => ""
      ),
      Match.create!(
        :player1_id => "",
        :player2_id => "",
        :tourney_id => "",
        :round => "",
        :player1_score => "",
        :player2_score => "",
        :ties => ""
      )
    ])
  end

  it "renders a list of matches" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 14
  end
end
