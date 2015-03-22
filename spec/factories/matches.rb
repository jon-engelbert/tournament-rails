FactoryGirl.define do
	factory :match do 
		player1
		player2
		tourney
		round 0
		player1_score 2
		player2_score 1
		ties 1
		bye false
	end
end
