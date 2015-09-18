require 'rails_helper'

  # Logs in a test user.
 #  def log_in_as(user, options = {})
 #    password    = options[:password]    || 'password'
 #    remember_me = options[:remember_me] || '1'
	# post login_path, session: { email:       user.email,
	#                           password:    password,
	#                           remember_me: remember_me }
	# session[:user_id] = user.id
 #  end

RSpec.feature "TournamentUsers", type: :feature do
  subject (:tour) {FactoryGirl.build(:tourney)}
  it "delete link is not available for the tournament that a different user created" do
      user = FactoryGirl.build(:user)
      user.save
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      tour.save
      puts "user_id: #{user.id}"
      puts "tourney user_id: #{tour.user_id}"
      visit tourneys_path
      expect(page).to have_text("mtg1")
      expect(page).to have_text("Brackets")
      expect(page).not_to have_text("Destroy")
  end
  it "delete link is available for the tournament that the current user created" do
      user = FactoryGirl.build(:user)
      user.save
      tour.user_id = user.id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      tour.save
      puts "user_id: #{user.id}"
      puts "tourney user_id: #{tour.user_id}"
      visit tourneys_path
      expect(page).to have_text("mtg1")
      expect(page).to have_text("Brackets")
      expect(page).to have_text("Destroy")
  end
end
