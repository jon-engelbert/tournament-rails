$(document).on ('ready page:load', function() {
  var swapmatch_path = $('#paths').data('swap');
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
	$("#Swap").on("ajax:success", function (e, data, status, xhr) {
		var match = JSON.parse(xhr.responseText);
		$("#AJAX_Results").append(xhr.responseText);
		$("#drag_" + match["player1_name"]+ "_" + match["player2_name"]).val(match["player1_score"]+ " - " + match["player2_score"] + "  (" + match["ties"] + ")");
		$("#AJAX_Results").append("#score_" + match["player1_name"]+ "_" + match["player2_name"]);
	})
	$("#Swap").on("ajax:error", function(e, xhr, status, error) {
		$("#AJAX_Results").append ("<p>ERROR</p>");
	})
  var player1_name = '';
  var match1_id = 0;
    $( ".draggable" ).draggable({
      drag: function( event, ui ) {
        player1_name = $(this).data('playername');  
        match1_id = $(this).data('matchid');  
        console.log('player_name, match_id, path');
        console.log(player1_name);
        console.log(match1_id);
        console.log(swapmatch_path);
        console.log($('#paths').data('swap'));
      }
    });
    $( ".droppable" ).droppable({
      drop: function( event, ui ) {
        var fields = this.id.split('_');  
        var player2_name = $(this).data('playername');  
        var match2_id = $(this).data('matchid');  
        $( this )
            .addClass( "ui-state-highlight" )
            .find( "p" )
              .html( this.id );
        $.ajax({
          type: "POST",
          url: swapmatch_path,
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          data: JSON.stringify({ player1_swap: player1_name, player2_swap: player2_name, match1_id: match1_id, match2_id: match2_id }),
          dataType: 'json',
          contentType: 'application/json',
          success: function (data) {
            alert (data);
            return false;
          },
          error: function (data) {
            alert (data);
            return false;
          }
        })
      }
    });
	// $( ".draggable" ).draggable();
 //    $( ".droppable" ).droppable({
 //      drop: function( event, ui ) {
 //        $( this )
 //          .addClass( "ui-state-highlight" )
 //          .find( "p" )
 //            .html( this.id );
 //      var fields = this.id.split('_');     
 //      $('#player1_swap').val(fields[0]);
 //      $('#player2_swap').val(fields[1]);
 //      $('#round').val(fields[2]);
 //      }
 //    });

	// function editMatch(identifier){
	// 		alert("data-id:"+$(identifier).data('player1name')+", data-option:"+$(identifier).data('player1name'));
	// }
})
