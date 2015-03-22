FactoryGirl.define do
	factory :tourney do 
		name "mtg1"
		date {1.year.from_now}
	 	location "Ann Arbor"
	 	# created_at {DateTime.now}
	 	# updated_at {DateTime.now}
	 	points_win 3
	 	points_tie 1
	 	points_bye 3
  		# association :user, factory: :user, strategy: :build
	end 
end