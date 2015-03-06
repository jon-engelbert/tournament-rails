json.array!(@players) do |player|
  json.extract! player, :id, :name, :email
  json.url player_url(player, format: :json)
end
