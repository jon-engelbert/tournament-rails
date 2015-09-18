require 'spec_helper'
require 'rails_helper'

describe Tourney, type: :model do 
	context '#save' do
		let(:user) {FactoryGirl.build_stubbed(:user, email: 'al@jmail.com')}
		subject {FactoryGirl.build_stubbed(:tourney)}
		it 'test rspec works' do
			expect(true).to be_truthy
		end	
		it 'user should be valid' do
			expect(user).to be_valid
		end
		it 'should be valid' do
			expect(subject).to be_valid
			subject.user_id = user.id
		end
	end
	describe 'initial pairings implementation' do
		subject (:tour) {FactoryGirl.build_stubbed(:tourney)}
		it "doesn't crash" do
			players = FactoryGirl.build_stubbed_list(:player, 9)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
\		end
		it "initial matchup, odd number of players" do
			players = FactoryGirl.build_stubbed_list(:player, 9)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			bracket_mgr = BracketManager.new tour
			pairs, bye_player = bracket_mgr.swiss_pairings_initial tour.players
			expect(pairs.count).to eq(4)
			expect(bye_player).not_to be_nil
		end
		it "initial matchup, even number of players" do
			players = FactoryGirl.build_stubbed_list(:player, 8)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			bracket_mgr = BracketManager.new tour
			pairs, bye_player = bracket_mgr.swiss_pairings_initial subject.players
			expect(pairs.count).to eq(4)
			expect(bye_player).to be_nil
		end
		it "initial brackets, odd number of players" do
			players = FactoryGirl.build_list(:player, 21)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			#expect(Player).to receive(:all).and_return players
			# expect(Match).to receive(:where).and_return ActiveRecord::NullRelation
			matches, bye_player = tour.brackets
			puts "******************** pairs: #{matches.inspect}"
			puts "******************** pairs.length: #{matches.length}"
			expect(matches.length).to eq(11)
			expect(bye_player).not_to be_nil
		end
		it "initial standings, odd number of players" do
			players = FactoryGirl.build_list(:player, 21)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			#expect(Player).to receive(:all).and_return players
			# expect(Match).to receive(:where).and_return ActiveRecord::NullRelation
			match_standings, bye_player = tour.brackets
			matches = Match.all
			matches.each do |match|
				match.update_attribute(:player1_score, 2)
				match.update_attribute(:player2_score, 1)
			end
			standings = tour.generate_standings
			expect(standings.length).to eq(21)
		end
		it "standings should order player with better record first" do
			players = FactoryGirl.build_list(:player, 20)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			#expect(Player).to receive(:all).and_return players
			# expect(Match).to receive(:where).and_return ActiveRecord::NullRelation
			match_standings, bye_player = tour.brackets
			matches = Match.all
			match_no = 0
			matches.each do |match|
				match.update_attribute(:player1_score, match_no * 2 )
				match.update_attribute(:player2_score, match_no)
				match_no += 1
			end
			standings = tour.generate_standings 
			player_stand_prev = nil
			standings.each do |player_standing| 
				if player_stand_prev
					puts "player_standing_prev: #{player_stand_prev}"
					puts "player_standing: #{player_standing}"
					expect(player_standing[:match_points] <= player_stand_prev[:match_points]).to be_truthy
					expect(player_standing[:match_points] < player_stand_prev[:match_points] || player_standing[:opponents_match_pct] <= player_stand_prev[:opponents_match_pct]).to be_truthy
				end
				player_stand_prev = player_standing
			end

		end
	end
	describe "... after initial pairing" do
		subject (:tour) {FactoryGirl.build(:tourney)}
		it "add a player to play against the bye player" do
			bye_player = FactoryGirl.build(:player)
			bye_player.name = "bob"
			bye_player.save
			tour.players << bye_player
			matches, bye_player = tour.brackets
			expect(matches[0].bye).to be_truthy
			expect(matches.length).to eq(1)
			bye_player = FactoryGirl.build(:player)
			bye_player.name = "bob"
			tour.players << bye_player
			matches, bye_player = tour.brackets
			expect(matches[0].bye).to be_falsy
			expect(matches.length).to eq(1)
		end
		it "don't repeat previous matchup if possible" do
			tour.save
			players = FactoryGirl.build_list(:player, 8)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			tourney = tour
			bracket_manager = BracketManager.new tourney
			match_standings, bye_player = tour.brackets
			matches = Match.all
			expect(matches.count).to eq(4)
			match_set = Match.matchup_sets(matches)
			puts "********* match_set: #{match_set.inspect}"
			expect(match_set.count).to eq(4)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 2 * 0.1 # match_set.count / 3
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(8)
			match_set = Match.matchup_sets(matches)
			puts "********* match_set: #{match_set.inspect}"
			expect(match_set.count).to eq(8)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 3 * 0.1 # match_set.count / 3
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(12)
			match_set = Match.matchup_sets(matches)
			expect(match_set.count).to eq(12)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 4 * 0.1 #  match_set.count / 3
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(16)
			match_set = Match.matchup_sets(matches)
			expect(match_set.count).to eq(16)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 5 * 0.1 #  match_set.count / 3
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(20)
			match_set = Match.matchup_sets(matches)
			expect(match_set.size).to eq(20)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 6 * 0.1 #  match_set.count / 3
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(24)
			match_set = Match.matchup_sets(matches)
			expect(match_set.size).to eq(24)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 7 * 0.1 # match_set.count / 2
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(28)
			match_set = Match.matchup_sets(matches)
			expect(match_set.size).to eq(28)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
      		good_enough_penalty = 8 * 0.1 # match_set.count / 2
			match_standings, bye_player = bracket_manager.generate_brackets_next  good_enough_penalty
			matches = Match.all
			expect(matches.count).to eq(32)
			match_set = Match.matchup_sets(matches)
			expect(match_set.size).not_to eq(32)
		end
	end
end