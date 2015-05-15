
    // gapi.load('auth2', function() {
    //   auth2 = gapi.auth2.init({
    //     client_id: $('#Data').data('client')
    //   });
    //     // Scopes to request in addition to 'profile' and 'email'
    //     //scope: 'additional_scope'
    // });

  $('#signinButton').click(function() {
  
    auth2.grantOfflineAccess({'redirect_uri': 'postmessage'}).then(signInCallback);

  });

  window.fbAsyncInit = function() {
  FB.init({
    appId      : '438142313021501',
    cookie     : true,  // enable cookies to allow the server to access 
                        // the session
    xfbml      : true,  // parse social plugins on this page
    version    : 'v2.3' // use version 2.2
  });

  };

  // Load the SDK asynchronously
  (function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));

  // Here we run a very simple test of the Graph API after login is
  // successful.  See statusChangeCallback() for when this call is made.
  function sendTokenToServer() {
    var access_token = FB.getAuthResponse()['accessToken'];
    console.log(access_token);
    console.log('Welcome!  Fetching your information.... ');
    FB.api('/me', function(response) {
      console.log('Successful login for: ' + response.name);
      var csrftoken = $('meta[name=csrf-token]').attr('content');

      $.ajaxSetup({
          beforeSend: function(xhr, settings) {
              if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(settings.type) && !this.crossDomain) {
                  xhr.setRequestHeader("X-CSRFToken", csrftoken);
              }
          }
      });
     $.ajax({
      type: 'POST',
      url: '/fbconnect?state={{STATE}}',
      processData: false,
      data: access_token,
      contentType: 'application/octet-stream; charset=utf-8',
      success: function(result) {
        // Handle or verify the server response if necessary.
        if (result) {
          $('#result').html('Login Successful!</br>'+ result + '</br>Redirecting...');
         setTimeout(function() {
          window.location.href = "/catalog";
         }, 4000);
          

      } else {
        $('#result').html('Failed to make a server-side call. Check your configuration and console.');
         }

      }
      
  });


    });
  }

function signInCallbackGoogle(authResult) {
  if (authResult['code']) {
  // console.log("AuthResult: " + JSON.stringify(authResult));
  console.log("AuthResult[code]: " + authResult['code']);
  console.log("AuthResult[access_token]: " + authResult['access_token']);

    // Hide the sign-in button now that the user is authorized, for example:
    $('#signinButton').attr('style', 'display: none');

    $.ajax({
      type: 'POST',
      url: 'connect_google',
      processData: false,
      data: authResult['code'],
      contentType: 'application/octet-stream; charset=utf-8',
      success: function(result) {
        // Handle or verify the server response if necessary.
        if (result) {
          $('#result').html('Login Successful!</br>'+ result + '</br>Redirecting...');
          setTimeout(function() {
            window.location.href = "/";
          }, 4000);
        } else if (authResult['error']) {
          console.log('There was an error: ' + authResult['error']);
        } else {
          $('#result').html('Failed to make a server-side call. Check your configuration and console.');
        }
      }
    }); 
  } 
}


function signInCallbackFB(json) {
  console.log('inside callback fuction');
  console.log(json);
  // authResult = JSON.parse(json);
  authResult = json;
  if (authResult['code']) {
    console.log("code is valid");
    // Hide the sign-in button now that the user is authorized, for example:
    $('#signinButton').attr('style', 'display: none');
      
    var csrftoken = $('meta[name=csrf-token]').attr('content');

    $.ajaxSetup({
        beforeSend: function(xhr, settings) {
            if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(settings.type) && !this.crossDomain) {
                xhr.setRequestHeader("X-CSRFToken", csrftoken);
            }
        }
    });
    // Send the code to the server
    $.ajax({
      type: 'POST',
      url: '/fbconnect?state={{STATE}}',
      processData: false,
      data: authResult['code'],
      contentType: 'application/octet-stream; charset=utf-8',
      success: function(result) {
        // Handle or verify the server response if necessary.
        if (result) {
          $('#result').html('Login Successful!</br>'+ result + '</br>Redirecting...');
          setTimeout(function() {
            window.location.href = "/auth/fb/callback";
          }, 4000);
        } else if (authResult['error']) {
          console.log('There was an error: ' + authResult['error']);
        } else {
          $('#result').html('Failed to make a server-side call. Check your configuration and console.');
        }
      }
    }); 
  }
}
    function signOut() {
        auth2.signOut().then(function() {
            console.log('User signed out.');
        });
    }
