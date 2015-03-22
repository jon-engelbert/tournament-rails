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
		subject {FactoryGirl.build_stubbed(:tourney)}
		it "doesn't crash" do
			players = FactoryGirl.build_stubbed_list(:player, 9)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				puts player.inspect
				subject.players << player
				i += 1
			end
			puts subject.inspect
		end
		it "initial matchup, odd number of players" do
			players = FactoryGirl.build_stubbed_list(:player, 9)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				subject.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			pairs, bye_player = subject.swiss_pairings_initial subject.players
			expect(pairs.count).to eq(4)
			expect(bye_player).not_to be_nil
		end
		it "initial matchup, even number of players" do
			players = FactoryGirl.build_stubbed_list(:player, 8)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				subject.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			pairs, bye_player = subject.swiss_pairings_initial subject.players
			expect(pairs.count).to eq(4)
			expect(bye_player).to be_nil
		end
		it "initial brackets, odd number of players" do
			players = FactoryGirl.build_list(:player, 21)
			i = 0
			players.each do |player| 
				player.name = "bob#{i}"
				player.email = "bob#{i}@amail.com"
				subject.players << player
				i += 1
			end
			# matches = FactoryGirl.build_stubbed_list(:match, 4)
			#expect(Player).to receive(:all).and_return players
			# expect(Match).to receive(:where).and_return ActiveRecord::NullRelation
			matches, bye_player = subject.brackets
			puts "******************** pairs: #{matches.inspect}"
			puts "******************** pairs.length: #{matches.length}"
			expect(matches.length).to eq(11)
			expect(bye_player).not_to be_nil
		end
	end

end