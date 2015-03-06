json.array!(@tourneys) do |tourney|
  json.extract! tourney, :id, :name, :date, :location
  json.url tourney_url(tourney, format: :json)
end
