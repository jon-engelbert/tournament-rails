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
	$('.closeEdit').click(function(e) {
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
  var player1_name = '';
  var player2_name = '';
  var match1_id = 0;
  var match2_id = 0;
  var drag_id = '';
  var drop_id = '';
  var drag_pos;
    $( ".draggable" ).draggable({
      drag: function( event, ui ) {
        player1_name = $(this).data('playername');  
        match1_id = $(this).data('matchid');  
        drag_id = this.id;
        drag_pos = $(this).position();
        console.log('player_name, match_id, path');
        console.log(player1_name);
        console.log(match1_id);
        console.log(swapmatch_path);
        console.log($('#paths').data('swap'));
      },
      revert : function(event, ui) {
	    // on older version of jQuery use "draggable"
	    // $(this).data("draggable")
	    // on 2.x versions of jQuery use "ui-draggable"
	    // $(this).data("ui-draggable")
	    $(this).data("uiDraggable").originalPosition = {
	        top : 0,
	        left : 0
	    };
	    // return boolean
	    return !event;
	    // that evaluate like this:
	    // return event !== false ? false : true;
	  }
    });
    $( ".droppable" ).droppable({
      drop: function( event, ui ) {
        var fields = this.id.split('_');  
        var player2_name = $(this).data('playername');  
        var match2_id = $(this).data('matchid');  
        drop_id = this.id;
        // $( this )
        //     .addClass( "ui-state-highlight" )
        //     .find( "p" )
        //       .html( this.id );
        $.ajax({
          type: "POST",
          url: swapmatch_path,
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          data: JSON.stringify({ player1_swap: player1_name, player2_swap: player2_name, match1_id: match1_id, match2_id: match2_id }),
          dataType: 'json',
          contentType: 'application/json',
          success: function (data) {
			// var d = JSON.parse(data);
            if (data['success'] === false) {
            	return false;
            }
            console.log("success:" + data);
            console.log("field_drag_id:" + drag_id);
            console.log(player2_name)
            console.log("field_drop_id:" + drop_id);
            console.log(player1_name)
            $("#" + drag_id ).text(player2_name);
            $("#" + drag_id ).attr('playername', player2_name);
            $("#" + drop_id ).text(player1_name);
            $("#" + drop_id ).attr('playername', player1_name);
            $("#" + drag_id ).css({ "position": "relative", "top": 0, "left": 0 });
          },
          error: function (data) {
            alert (data);
            $("#" + drag_id ).css({ "position": "relative", "top": 0, "left": 0 });
            return false;
          }
        })
      }
    });
})
