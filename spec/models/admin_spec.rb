require 'rails_helper'

RSpec.describe Admin, type: :model do
  before do
    @admin = Admin.new(name: "Example User", email: "user@example.com",
    password: "foobar", password_confirmation: "foobar")
  end

  describe "admin model" do
    it "should be valid" do
      assert @admin.valid?
    end

    it "name should be present" do
      @admin.name = "     "
      expect(@admin).to_not be_valid
    end
    it "email should be present" do
      @user.email = "     "
      expect(@admin).to_not be_valid
    end

  end

end
