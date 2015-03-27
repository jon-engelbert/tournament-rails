require 'spec_helper'
require 'rails_helper'

describe Tourney, type: :model do 
	context 'replace player' do
		let(:user) {FactoryGirl.build_stubbed(:user, email: 'al@jmail.com')}
		let(:tourney) {FactoryGirl.build(:tourney)}
		let(:players) {FactoryGirl.build_list(:player, 3)}
		let(:match) {FactoryGirl.build(:match, tourney_id: tourney.id, player1_id: players[0].id, player2_id: players[1].id)}
		it 'has an initial match with first two players' do
			expect(match.player1_id).to eq(players[0].id)
			expect(match.player2_id).to eq(players[1].id)
		end
		it 'do nothing when the player is the same' do
			match.replace_player(players[0].id, players[0].id)
			expect(match.player1_id).to eq(players[0].id)
		end
		it 'replace player0 when requested' do
			match.replace_player(players[0].id, players[2].id)
			expect(match.player1_id).to eq(players[2].id)
			expect(match.player2_id).to eq(players[1].id)
		end
		it 'replace player1 when requested' do
			match.replace_player(players[1].id, players[2].id)
			expect(match.player1_id).to eq(players[0].id)
			expect(match.player2_id).to eq(players[2].id)
		end
	end
end