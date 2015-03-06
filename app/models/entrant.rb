class Entrant < ActiveRecord::Base
  belongs_to :player
  belongs_to :tourney
end
