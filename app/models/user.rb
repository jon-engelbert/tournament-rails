class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  has_many :tourneys
  attr_accessor :login
  # attr_accessor :remember_token, :activation_token, :reset_token
  # before_save :downcase_email
  # validates :name,  presence: true, length: { maximum: 50 }
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
  # validates :email, length: { maximum: 255 },
  #   format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  # has_secure_password
  # validates :password, length: { minimum: 6 }


  alias :devise_valid_password? :valid_password?

  def valid_password?(password)
    puts "@@@@@@@@@@@@@ in valid_password"
    puts "password: #{password}"
    puts "encrypted_password: #{encrypted_password}"
    is_valid = super(password)
    if !is_valid && encrypted_password.blank?
      logger.info "User #{email} is using the old password hashing method, updating attribute."
      self.password = password
      is_valid = true
    end
    is_valid
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end
  # def self.from_omniauth(auth)
  #   find_by_provider_and_uid(auth["provider"], auth["uid"]) || create_with_omniauth(auth)
  # end

  def self.create_with_omniauth(auth)
    puts "****!!!!!! in create_with_omniauth"
    user = User.new
    user.provider = auth["provider"]
    user.uid = auth["uid"]
    user.name = auth["info"]["name"]
    # user.email = 'doh@not.com'
    # user.password = "not_valid"
    user.save
    puts "****!!!!!! user3: #{user.inspect}"
    user
  end

  private
  # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

end
