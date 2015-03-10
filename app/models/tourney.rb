class Tourney < ActiveRecord::Base
  has_many :matches
  has_many :entrants
  has_many :players, through: :entrants
  belongs_to :users
  attr_accessor :player_names
end
