require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
    password: "foobar", password_confirmation: "foobar")
  end

  describe "user model" do
    it "should be valid" do
      assert @user.valid?
    end

    it "name should be present" do
      @user.name = "     "
      expect(@user).to_not be_valid
    end
    it "email should be present" do
      @user.email = "     "
      expect(@user).to_not be_valid
    end

  end

end
