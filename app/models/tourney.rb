class Tourney < ActiveRecord::Base
  has_many :matches
  has_many :entrants
  has_many :players, through: :entrants
  belongs_to :users
  attr_accessor :entrant_names, :entrant_emails



  def generate_standings
    rank_manager = RankManager.new(self)
    rank_manager.generate_standings
  end

  def brackets 
    bracket_manager = BracketManager.new(self)
    bracket_manager.generate_brackets
  end

end
