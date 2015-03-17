// $(document).ready ->
// $("#new_match").on("ajax:success", (e, data, status, xhr) ->
//   $("#new_match").append xhr.responseText
// ).on "ajax:error", (e, xhr, status, error) ->
//   $("#new_match").append "<p>ERROR</p>"
$(document).on ('ready page:load', function() {
	$('.editMatchButton').click(function(e) {
		e.preventDefault();
		$("#Edit_scores").show();
		$('#player1_name').val($(this).data('player1name'));
		$('#player2_name').val($(this).data('player2name'));
		$('#player1_wins').val($(this).data('player1wins'));
		$('#player2_wins').val($(this).data('player2wins'));
		$('#ties').val($(this).data('ties'));
		if ($(this).data('round') < 0) {
			$('#round').val(0);
		} else {
			$('#round').val($(this).data('round'));
		}
		// alert("id:"+this.id);
		// $('#match_params').show();
		// $('#score1').val
	})
	$('.cancelEdit').click(function(e) {
		e.preventDefault();
		$("#Edit_scores").hide();
	})
	$("#Edit_scores").on("ajax:success", function (e, data, status, xhr) {
		var match = JSON.parse(xhr.responseText);
		$("#AJAX_Results").append(xhr.responseText);
		$("#score_" + match["player1_name"]+ "_" + match["player2_name"]).val(match["player1_score"]+ " - " + match["player2_score"] + "  (" + match["ties"] + ")");
		$("#AJAX_Results").append("#score_" + match["player1_name"]+ "_" + match["player2_name"]);
		$("#Edit_scores").hide();
	})
	$("#Edit_scores").on("ajax:error", function(e, xhr, status, error) {
		$("#AJAX_Results").append ("<p>ERROR</p>");
		$("#Edit_scores").hide();
	})
	// function editMatch(identifier){
	// 		alert("data-id:"+$(identifier).data('player1name')+", data-option:"+$(identifier).data('player1name'));
	// }
})
