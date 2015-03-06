json.array!(@matches) do |match|
  json.extract! match, :id, :player1_id, :player2_id, :tourney_id, :round, :player1_score, :player2_score, :ties
  json.url match_url(match, format: :json)
end
