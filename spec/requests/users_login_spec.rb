require 'rails_helper'

RSpec.describe "UsersLogin", type: :request do
  describe "GET /users_login" do
    it "login with invalid information" do
        get login_path
        expect(response).to render_template('sessions/new')
        post login_path, session: { email: "", password: "" }
        expect(response).to render_template 'sessions/new'
        expect(flash).not_to be_empty
        get root_path
        expect(flash).to be_empty
    end
  end
end
