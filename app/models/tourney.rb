class Tourney < ActiveRecord::Base
  has_many :matches
  has_many :entrants
  has_many :players, through: :entrants
end
