class Match < ActiveRecord::Base
  belongs_to :tourney
  attr_accessor :player1_name, :player2_name

  def record_results params
	puts "****************** in record match, params: #{params}"
	begin
	  match = Match.find(player2id: player1id, player2id: player2id, tourney_id: params['tourney_id'], round: params['round'])
	rescue Exception => exc
	end

	player1_score = params[:player1_score]
	player2_score = params[:player2_score]
	ties = params[:ties]
	round = params[:round]
	save
  end
end
