module Helpers

  def test_ip_address
    '127.0.0.1'
  end

  def test_user_password
    '12345678'
  end

  def default_test_user_details
    {
      first_name: 'Tester',
      last_name: 'Person',
      email: 'testuser@agileventures.org',
      password: test_user_password,
      password_confirmation: test_user_password,
    }
  end

  def create_visitor
    @visitor ||= { :email => 'example@example.com',
                   :password => 'changemesomeday',
                   :password_confirmation => 'changemesomeday'}
  end

  def create_test_user(options = {})
    options = default_test_user_details.merge options
    user = User.new(options)
    user.save!
  end

  def create_unconfirmed_user
    create_visitor
    delete_user
    sign_up
    visit destroy_user_session_path
  end

  def create_user
    @user ||= FactoryGirl.create(:user, create_visitor)
    @current_user = @user
  end

  def delete_user
    @user.destroy if @user
    @user = nil
    @current_user = nil
  end

  def sign_up
    delete_user
    visit new_user_registration_path
    within ('#main') do
      fill_in 'user_email', :with => @visitor[:email]
      fill_in 'user_password', :with => @visitor[:password]
      fill_in 'user_password_confirmation', :with => @visitor[:password_confirmation]
      click_button 'Sign up'
    end
  end

  def sign_in
    visit new_user_session_path
    within ('#main') do
      fill_in 'user_email', :with => @visitor[:email]
      fill_in 'user_password', :with => @visitor[:password]
      click_button 'Sign in'
    end
  end

  def all_users
    @all_users = User.all
  end
end
