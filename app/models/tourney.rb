class Tourney < ActiveRecord::Base
  has_many :matches
  has_many :entrants
  has_many :players, through: :entrants
  belongs_to :users
  attr_accessor :entrant_names, :entrant_emails

  def swiss_pairings_initial(players)
    use_bye = players.size % 2 != 0
    player_bye_id = nil
    if use_bye
      bye_player = players.sample
    end
    is_begin_pair = true
    pairs = []
    prev_player = nil
    players.shuffle.each do |player|
      if player != bye_player
        if is_begin_pair
          prev_player = player
          puts "$$$$$$$$$ first #{prev_player.inspect}"
        else
          puts "$$$$$$$$$ first #{prev_player.inspect}"
          pair = [player, prev_player]
          puts "$$$$$$$$$ pair #{pair.inspect}"
          pairs << pair
          puts "$$$$$$$$$ pairs #{pairs.inspect}"
        end
        is_begin_pair = !is_begin_pair
      end
    end
    return pairs, bye_player
  end
end
