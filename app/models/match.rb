class Match < ActiveRecord::Base
  belongs_to :tourney
  attr_accessor :player1_name, :player2_name

  def record_results params
	puts "****************** in record match, params: #{params}"
	begin
	  match = Match.find(player1_id: params['player1id'], player2_id: params['player2id'], tourney_id: params['tourney_id'], round: params['round'])
    rescue Exception =>exc
      logger.error("Message for the log file #{exc.message}")
	end

	player1_score = params[:player1_score]
	player2_score = params[:player2_score]
	ties = params[:ties]
	round = params[:round]
	save
  end

  def swap_player(player1_id, player2_id)
      if (player1_id == player2_id)
        update_attribute(:player1_id, player2_id)
      else
        update_attribute(:player2_id, player2_id)
      end
  end
end
