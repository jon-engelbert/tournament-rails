Given(/^following tourneys exist:$/) do |table|
  table.hashes.each do |hash|
    Tourney.create!(hash)
  end
end


Given(/^I am on the Tourneys page$/) do
  visit tourneys_path
end
