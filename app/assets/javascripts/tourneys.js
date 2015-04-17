$(document).on ('ready page:load', function() {
  var entrantNames = $('#entrants').data('name');
  var entrantEmails = $('#entrants').data('email');
  var player_name_array = $('#players').data('name');
  var player_email_array = $('#players').data('email');
  $(document).on("ajax:success", "#Edit_scores", function() {
      console.log('file sent!');
    console.log('yep');
    });
  $('#tourney_entrant_names').val(entrantNames);
  $('#tourney_entrant_emails').val(entrantEmails);

  $( "#autocomplete-1" ).autocomplete({
     source: $('#players').data('name')
  });

  $( "#autocomplete-removeentrant" ).autocomplete({
     source: $('#entrants').data('name')
  });

  $("#addButton").click(function (e) {
    e.preventDefault();
    var name = $('#autocomplete-1').val();
    var position = $.inArray(name, player_name_array);
    // var hostAddress= top.location.host.toString();
    if (position >= 0) {
      // find the corresponding email, add it to the list.
      var email = player_email_array[position];
      console.log("email: " + email );
      console.log("name: " + name + " "  + player_name_array[position]);
      console.log("position: " + position);
      $(".hidden-section").hide();
      $("#entrant_name_list").append('<li>' + name + '</li>');
      $("#entrant_email_list").append('<li>' + email + '</li>');
      console.log("player_name_array.length" + player_name_array.length);
      console.log("player_email_array.length" + player_email_array.length);
      player_email_array.splice(position,1);
      player_name_array.splice(position,1);
      console.log("player_name_array.length" + player_name_array.length);
      console.log("player_email_array.length" + player_email_array.length);
      $('#players').data('name', player_name_array);
      $('#players').data('email', player_email_array);
      $("#autocomplete-1").autocomplete( "option", "source", $('#players').data('name'));
      if (!entrantNames) {
        entrantNames = [];
      }
      if (!entrantEmails) {
        entrantEmails = [];
      }
      console.log("entrantNames.length: " + entrantNames.length);
      console.log("entrantEmails.length: " + entrantEmails.length);
      entrantNames.push(name);
      entrantEmails.push(email);
      console.log("entrantNames.length: " + entrantNames.length);
      console.log("entrantEmails.length: " + entrantEmails.length);
      $('#tourney_entrant_names').val(entrantNames);
      $('#tourney_entrant_emails').val(entrantEmails);
      console.log("done with position>=0 in addButton click");
      $("#autocomplete-1").val("");
    } else {
      console.log("in else branch, position <0,  in addButton click");
      // var url = "http://" + hostAddress + $('#newplayerlink').data('link');
      // $(location).attr('href',url);
      $(".hidden-section").show();
      $('#player_name').val(name);
      $('#player_email').val('');
    }
  });
  $("#create_button").click(function (e) {
    e.preventDefault();
    var name = $('#player_name').val();
    var email = $('#player_email').val();
      $("#entrant_name_list").append('<li>' + name + '</li>');
      $("#entrant_email_list").append('<li>' + email + '</li>');
      entrantNames.push(name);
      entrantEmails.push(email);
    // entrantEmails += email + "\r\n";
    $("#tourney_entrant_names").val(entrantNames) ;
    $("#tourney_entrant_emails").val(entrantEmails) ;
    $(".hidden-section").hide();
    $('#entrants').data('name').add(selectedVal);
    $('#entrants').data('email').add(email);
    $("#autocomplete-1").val("");
  });
  $("#cancel_button").click(function (e) {
    e.preventDefault();
    $(".hidden-section").hide();
  });
  $("#removeButton").click(function (e) {
    e.preventDefault();
    var name = $('#autocomplete-removeentrant').val();
    var position = $.inArray(name, $('#entrants').data('name'));
    // var hostAddress= top.location.host.toString();
    if (position >= 0) {
      // find the corresponding email, remove it from the list.
      var email = $('#entrants').data('email')[position];
      var players = $('#players').data('list');
      player_email_array.push(email);
      player_name_array.push(name);
      $('#players').data('name', player_name_array);
      $('#players').data('email', player_email_array);
      $("#autocomplete-1").autocomplete( "option", "source", player_name_array);
 
      entrantNames.splice(position,1);
      entrantEmails.splice(position,1);
      $('#entrants').data('name', entrantNames);
      $('#entrants').data('email', entrantEmails);
      $('#tourney_entrant_names').val(entrantNames);
      $('#tourney_entrant_emails').val(entrantEmails);
      $("#autocomplete-removeentrants").autocomplete( "option", "source", entrantNames);
      $("#entrant_name_list li").eq(position).remove();
      $("#entrant_email_list li").eq(position).remove();
      $("#autocomplete-removeentrant").val("");
    }
  });

  $(".moveToEntrant").click(function(e) 
  {
    var tbFrom = document.getElementById('Players');
    var tbTo = document.getElementById('tourney_entrant_names');
    var arrFrom = new Array(); 
    var arrTo = new Array(); 
    var arrLU = new Array();
    var i;
    console.log("To options: "+ tbTo.options);
    console.log("From options: "+ tbFrom.options);
    for (i = 0; i < tbTo.options.length; i++) 
    {
      arrLU[tbTo.options[i].text] = tbTo.options[i].value;
      arrTo[i] = tbTo.options[i].text;
    }
    var fLength = 0;
    var tLength = arrTo.length;
    for(i = 0; i < tbFrom.options.length; i++) 
    {
      arrLU[tbFrom.options[i].text] = tbFrom.options[i].value;
      if (tbFrom.options[i].selected && tbFrom.options[i].value !== "") 
      {
       arrTo[tLength] = tbFrom.options[i].text;
       tLength++;
      }
      else 
      {
       arrFrom[fLength] = tbFrom.options[i].text;
       fLength++;
      }
    }

    tbFrom.length = 0;
    tbTo.length = 0;
    var ii;

    for(ii = 0; ii < arrFrom.length; ii++) 
    {
      var no = new Option();
      no.value = arrLU[arrFrom[ii]];
      no.text = arrFrom[ii];
      tbFrom[ii] = no;
    }

    for(ii = 0; ii < arrTo.length; ii++) 
    {
      var no2 = new Option();
      no2.value = arrLU[arrTo[ii]];
      no2.text = arrTo[ii];
      tbTo[ii] = no2;
    }
  });

  $(".moveFromEntrant").click(function(e) 
  {
    var tbFrom = document.getElementById('tourney_entrant_names');
    var tbTo = document.getElementById('Players');
    var arrFrom = new Array(); var arrTo = new Array(); 
    var arrLU = new Array();
    var i;
    console.log("To options: "+ tbTo.options);
    console.log("From options: "+ tbFrom.options);
    for (i = 0; i < tbTo.options.length; i++) 
    {
      arrLU[tbTo.options[i].text] = tbTo.options[i].value;
      arrTo[i] = tbTo.options[i].text;
    }
    var fLength = 0;
    var tLength = arrTo.length;
    for(i = 0; i < tbFrom.options.length; i++) 
    {
      arrLU[tbFrom.options[i].text] = tbFrom.options[i].value;
      if (tbFrom.options[i].selected && tbFrom.options[i].value !== "") 
      {
       arrTo[tLength] = tbFrom.options[i].text;
       tLength++;
      }
      else 
      {
       arrFrom[fLength] = tbFrom.options[i].text;
       fLength++;
      }
    }

    tbFrom.length = 0;
    tbTo.length = 0;
    var ii;

    for(ii = 0; ii < arrFrom.length; ii++) 
    {
      var no = new Option();
      no.value = arrLU[arrFrom[ii]];
      no.text = arrFrom[ii];
      tbFrom[ii] = no;
    }

    for(ii = 0; ii < arrTo.length; ii++) 
    {
      var no3 = new Option();
      no3.value = arrLU[arrTo[ii]];
      no3.text = arrTo[ii];
      tbTo[ii] = no3;
    }
  });
  $(".select_before_submit").click(function(e)
  {
    $('#tourney_entrant_names option').each(function () {
      $(this).attr('selected', true);
    });
  });
});
