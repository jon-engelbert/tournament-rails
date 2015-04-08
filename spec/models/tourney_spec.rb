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
	context ' initial pairing' do
		let(:user) {FactoryGirl.build_stubbed(:user, email: 'al@jmail.com')}
		subject {FactoryGirl.build_stubbed(:tourney, user_id: user.id)}
		it 'doesnt crash' do
			is_expected.to respond_to :swiss_pairings_initial 
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
				puts player.inspect
				tour.players << player
				i += 1
			end
			puts tour.inspect
		end
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
			pairs, bye_player = tour.swiss_pairings_initial tour.players
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
			pairs, bye_player = tour.swiss_pairings_initial subject.players
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
			standings = tour.generate_standings players
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
			standings = tour.generate_standings players
			player_stand_prev = nil
			standings.each do |player_standing| 
				if player_stand_prev
					puts "player_standing_prev: #{player_stand_prev}"
					puts "player_standing: #{player_standing}"
					expect(player_standing[:win_pct] <= player_stand_prev[:win_pct]).to be_truthy
					expect(player_standing[:win_pct] < player_stand_prev[:win_pct] || player_standing[:game_wins] <= player_stand_prev[:game_wins]).to be_truthy
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
			players = FactoryGirl.build_list(:player, 16)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				tour.players << player
				i += 1
			end
			match_standings, bye_player = tour.brackets
			matches = Match.all
			expect(matches.count).to eq(8)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
			match_standings, bye_player = TourneyService.generate_brackets_next tour.id
			matches = Match.all
			expect(matches.count).to eq(16)
			match_set = Set.new matches
			expect(match_set.count).to eq(16)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
			match_standings, bye_player = TourneyService.generate_brackets_next tour.id
			matches = Match.all
			expect(matches.count).to eq(24)
			match_set = Set.new matches
			expect(match_set.count).to eq(24)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
			match_standings, bye_player = TourneyService.generate_brackets_next tour.id
			matches = Match.all
			expect(matches.count).to eq(32)
			match_set = Set.new matches
			expect(match_set.count).to eq(32)
			matches.each do |match|
				match.update_attribute(:player1_score, 1)
				match.update_attribute(:player2_score, 1)
			end
			match_standings, bye_player = TourneyService.generate_brackets_next tour.id
			matches = Match.all
			expect(matches.count).to eq(40)
			match_set = Set.new matches
			expect(match_set.size).to eq(40)
		end
	end
end