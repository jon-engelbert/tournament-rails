require 'rails_helper'

RSpec.describe "matches/new", type: :view do
  before(:each) do
    assign(:match, Match.new(
      :player1_id => "",
      :player2_id => "",
      :tourney_id => "",
      :round => "",
      :player1_score => "",
      :player2_score => "",
      :ties => ""
    ))
  end

  it "renders new match form" do
    render

    assert_select "form[action=?][method=?]", matches_path, "post" do

      assert_select "input#match_player1_id[name=?]", "match[player1_id]"

      assert_select "input#match_player2_id[name=?]", "match[player2_id]"

      assert_select "input#match_tourney_id[name=?]", "match[tourney_id]"

      assert_select "input#match_round[name=?]", "match[round]"

      assert_select "input#match_player1_score[name=?]", "match[player1_score]"

      assert_select "input#match_player2_score[name=?]", "match[player2_score]"

      assert_select "input#match_ties[name=?]", "match[ties]"
    end
  end
end
