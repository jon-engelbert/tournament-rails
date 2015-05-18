class SessionsController < ApplicationController
  # def new
  #     authenticate_user!
  # end

  # def login_google
  #   @googleClientId = Rails.application.secrets.GOOGLE_CLIENT_ID
  #   @googleClientSecret = Rails.application.secrets.GOOGLE_CLIENT_SECRET
  #   puts "#*********** about to render login_oauth"
  #   render 'login_oauth'
  # end

  # def login_oauth
  #   @googleClientId = Rails.application.secrets.GOOGLE_CLIENT_ID
  #   @googleClientSecret = Rails.application.secrets.GOOGLE_CLIENT_SECRET
  #   puts "#*********** about to render login_oauth"
  # end

  # def login_facebook
  #   # @fbClientId = Rails.application.secrets.FB_CLIENT_ID
  #   # @fbClientSecret = Rails.application.secrets.FB_CLIENT_SECRET
  #   render file: 'login_oauth'
  # end

  # def auth_failure
  #   flash[:warning] = "authorization failed"
  #   redirect_to root_path
  # end

  # def create
  #   user = User.find_by(email: params[:session][:email].downcase)
  #   if user && user.authenticate(params[:session][:password])
  #     if user.activated?
  #       log_in user
  #       params[:session][:remember_me] == '1' ? remember(user) : forget(user)
  #       redirect_back_or user
  #     else
  #       message  = "Account not activated. "
  #       message += "Check your email for the activation link."
  #       flash[:warning] = message
  #       redirect_to root_url
  #     end
  #   else
  #     flash.now[:danger] = 'Invalid email/password combination'
  #     render 'new'
  #   end
  # end

  # def create_oauth
  # #render text: request.env['omniauth.auth'].to_yaml and return
  #   begin
  #     puts "in Create_oauth controller method"
  #     puts "****** Code: #{params.inspect}"
  #     @user = User.from_omniauth(request.env['omniauth.auth'])
  #     log_in @user
  #     session[:user_id] = @user.id
  #     flash[:success] = "Welcome, #{@user.name}!"
  #   rescue
  #    flash[:warning] = "There was an error while trying to authenticate you..."
  #   end
  #   redirect_to root_path
  # end

#   def auth_google
#   #render text: request.env['omniauth.auth'].to_yaml and return
#     begin
#       puts "in auth_google controller method"
#       puts "******** request.env[omniauth.auth]" + request.env['omniauth.auth'].to_yaml
#       puts "****** Code: #{params.inspect}"
#       puts "****** request: #{request.env.inspect}"
#       @auth = request.env['omniauth.auth']['credentials']
#       @user = User.from_omniauth(request.env['omniauth.auth'])
#       session[:user_id] = @user.id
#       flash[:success] = "Welcome, #{@user.name}!"
#     rescue
#      flash[:warning] = "There was an error while trying to authenticate you..."
#     end
#     redirect_to root_path
#   end

#   def google_connect
#   #render text: request.env['omniauth.auth'].to_yaml and return
#     begin
#       puts "in Create_oauth controller method"
#       puts "****** Code: #{params.inspect}"
#       puts "****** request: #{request.env.inspect}"
#       @auth = request.env['omniauth.auth']['credentials']
#       @user = User.from_omniauth(request.env['omniauth.auth'])
#       session[:user_id] = @user.id
#       flash[:success] = "Welcome, #{@user.name}!"
#     rescue
#      flash[:warning] = "There was an error while trying to authenticate you..."
#     end
#     redirect_to root_path
#   end


  # def create_google
  # end

  def destroy
    puts "############### In Destroy"
    log_out if logged_in?
    redirect_to root_url
  end
end
