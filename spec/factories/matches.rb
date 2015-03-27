FactoryGirl.define do
	factory :match do 
		player1_id -1
		player2_id -1
		tourney_id -1
		round 0
		player1_score 2
		player2_score 1
		ties 1
		bye false
	end
end
