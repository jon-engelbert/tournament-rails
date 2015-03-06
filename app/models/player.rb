class Player < ActiveRecord::Base
  has_many :entrants
  has_many :tourneys, through: :entrants
end
