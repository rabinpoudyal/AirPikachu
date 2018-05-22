class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable
         
  devise :omniauthable, omniauth_providers: %i[facebook]

  validates :fullname, presence: true, length: { maximum: 50, minimum: 3 }

  def self.from_omniauth(auth)
  	user = User.find(email: auth.info.email).first 
  	if user 
  		return user 
  	else
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.email = auth.info.email
			user.password = Devise.friendly_token[0,20]
			user.fullname = auth.info.name   # assuming the user model has a name
			user.image = auth.info.image # assuming the user model has an image
			user.uid = auth.info.uid
			user.provider = auth.info.provider
			# If you are using confirmable and the provider(s) you use validate emails, 
			# uncomment the line below to skip the confirmation emails.
			user.skip_confirmation!
		end
	end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

end
