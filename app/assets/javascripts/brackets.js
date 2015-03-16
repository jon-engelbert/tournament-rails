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
		$('#round').val($(this).data('round'));
		// alert("id:"+this.id);
		// $('#match_params').show();
		// $('#score1').val
	})
	$('.cancelEdit').click(function(e) {
		e.preventDefault();
		$("#Edit_scores").hide();
	})
	$("#new_match").on("ajax:success", function (e, data, status, xhr) {
		$("#new_match").append(xhr.responseText);
		$("#Edit_scores").hide();
	})
	$("#new_match").on("ajax:error", function(e, xhr, status, error) {
		$("#new_match").append ("<p>ERROR</p>");
		$("#Edit_scores").hide();
	})
	// function editMatch(identifier){
	// 		alert("data-id:"+$(identifier).data('player1name')+", data-option:"+$(identifier).data('player1name'));
	// }
})
