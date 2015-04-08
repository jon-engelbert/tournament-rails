class Match < ActiveRecord::Base
  belongs_to :tourney
  attr_accessor :player1_name, :player2_name

  def record_results params
  	puts "****************** in record match, params: #{params}"
  	begin
  	  match = Match.find(id: params[:match_id])
      rescue Exception =>exc
        logger.error("Message for the log file #{exc.message}")
  	end

  	player1_score = params[:player1_score]
  	player2_score = params[:player2_score]
  	ties = params[:ties]
  	round = params[:round]
  	save
  end

  def self.matchups matches
    match_p1 = matches.map(&:player1_id)
    match_p2 = matches.map(&:player2_id)
    match_ups = []
    if match_p1.present? 
      match_ups = match_p1.zip(match_p2)
    end
  end

  def self.matchup_sets matches
    match_ups = matchups matches
    matchup_sets = Set.new
    if match_ups.present? 
      match_ups.each do |p1, p2|
        if (p1 >= p2)
          matchup_sets.add([p1, p2])
        else
          matchup_sets.add([p2, p1])
        end
      end
    end
    matchup_sets
  end

  def replace_player(player_old, player_new)
  # player_old should be the same as either player1_id or player2_id
  # replace the id that 'is the same' with player_2.
  # Params:
  # +player_old+:: the id of the player that is to be swapped out
  # +player_new+:: the id of the player that is to be swapped in

      if (player1_id == player_new) && (player2_id == player_new)
        logger.error("swap failed, new same as existing")
      elsif (player1_id != player_old) && (player2_id != player_old)
        logger.error("swap failed, neither existing player matches 'old' swap index")
      elsif (player1_id == player_old)
        update_attribute(:player1_id, player_new)
      elsif (player2_id == player_old)
        update_attribute(:player2_id, player_new)
      else
        logger.error("swap failed, no match.")
      end
  end
end
