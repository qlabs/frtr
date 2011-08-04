// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Utility methods used on multiple pages
function show_message(text){
  $('#flash_message').css("visibility", "visible");
  $('#flash_message').html(text);
  $('#flash_message').fadeIn(500, function(){
    setTimeout("hide_message()",5000);
  });
}

function hide_message(){
  $('#flash_message').fadeOut(500);
}

function show_warning(text){
  $('#flash_warning').css("visibility", "visible");
  $('#flash_warning').html(text);
  $('#flash_warning').fadeIn(500, function(){
    setTimeout("hide_warning()",5000);
  });
}

function hide_warning(){
  $('#flash_warning').fadeOut(500);
}



// Methods used on the record video page (/username)

function record_state(){
  $('#step_1').addClass("highlighted_instruction");
  $('#step_2').removeClass("highlighted_instruction");
  $('#step_3').removeClass("highlighted_instruction");
}

function publish_state(){
  $('#step_1').removeClass("highlighted_instruction");
  $('#step_2').addClass("highlighted_instruction");
  $('#step_3').removeClass("highlighted_instruction");
}

function tweet_state(){
  $('#step_1').removeClass("highlighted_instruction");
  $('#step_2').removeClass("highlighted_instruction");
  $('#step_3').addClass("highlighted_instruction");
}

function video_published(session_data){
  create_new_video(session_data["video_uid"],session_data['user_uid']);

}

function create_new_video(video_uid, user_uid){
  $.ajax({
      url: "/videos",
      dataType:'json',
      data: "video_uid="+video_uid+"&user_uid="+user_uid,
      type:"POST",
      success: function(data) {
        if (data["success"]){
          hide_recorder();
          display_tweet_textarea(data["short_url"]);
        }else{
          alert("Failure when creating new video!");
        }
      },
    error: function(){alert("error!")}
    });
}


function tweet_video(){
  
  user_uid =Framey.getRecorder("recorder").getSessionData()["user_uid"]
  video_uid =Framey.getRecorder("recorder").getSessionData()["video_uid"]

  $.ajax({
      url: "/videos/tweet",
      dataType:'json',
      data: "user_uid="+user_uid+"&text="+$("#twitter_text").val()+"&video_uid="+video_uid+"&follow_frttr="+$('#follow_frttr').is(':checked'),
      type:"POST",
      success: function(data) {
        if (data["success"]){
          // get the video name from the recorder
          new_video();
          show_message("Your video was tweeted")
          record_state(); 
        }else{
          show_warning("Failure tweeting video, try again!")
        }
      }
    });
}

function delete_video(video_uid){
  $.ajax({
      url: "/videos/"+video_uid,
      dataType:'json',
      type:"DELETE",
      success: function(data) {
        if (data["success"]){
          // get the video name from the recorder
          show_message("Your video was deleted.");
          $("#video_"+video_uid).hide();
        }else{
          show_warning("Error deleting video, please try again");
        }
      }
    });
}


function new_video(){
  record_state();
  $.ajax({
      url: "/users/new_video",
      dataType:'json',
      type:"GET", 
      success: function (data){
        reset_content(data);
      }
    });
}

function reset_content(data){
  $('#framey_post').hide();
  show_recorder();

  Framey.setSessionData('recorder', "video_uid", data['video_uid']);
  
}

function display_tweet_textarea(short_url){
  $('#framey_post').show();
  $('#twitter_text').val("Look at what I recorded with @frtr_me "+short_url);
  $('#twitter_text').simplyCountable({
  		counter: '#counter',
          countType: 'characters',
          maxCount: 140,
          countDirection: 'up',
          strictMax: true
  		  }); 
}

function show_recorder(){
  $('#recorder').css("height", "340px");
  $('#recorder').css("width", "340px");
}

function hide_recorder(){
  $('#recorder').css("height", "1px");
  $('#recorder').css("width", "1px");
}

function prepare_recorder_page(){
  hide_warning();
  hide_message();

  record_state();

  $('#twitter_text').simplyCountable({
  		counter: '#counter',
          countType: 'characters',
          maxCount: 140,
          countDirection: 'up',
          strictMax: true
  		  });
  $('#framey_post').hide();

  Framey.observe("stopClicked", function(session_data){
    publish_state();
  });  
  
  Framey.observe("deleteClicked", function(session_data){
    alert("deleteClicked");
    record_state();
  });
  
  Framey.observe("publishFailed", function(session_data){
    record_state();
  });  
    
  
  Framey.observe("publishSucceeded", function(session_data){
      video_published(session_data);
      tweet_state();
    });
}

function like_video(name){

  $.ajax({
      url: "/videos/"+name+"/like",
      dataType:'json',
      type:"get",
      success: function(data) {
        $("#like_count_"+name).html(data["like_count"]);
        $("#like_video_link").hide();
      }
    });  
}



// Methods fo the videos show page

function update_share_url(){
  url = "http://twitter.com/share?via=frtr_me&text="+$('#twitter_reply_text').val();
  $("#send_tweet_link").attr("href",encodeURI(url));
}

function prepare_view_page(){
  $('#twitter_reply_text').simplyCountable({
  		counter: '#reply_counter',
          countType: 'characters',
          maxCount: 100,
          countDirection: 'up',
          strictMax: true
  		  });

  // intitalize share button url
  update_share_url();
  
  $('#twitter_reply_text').keyup(function (){
    update_share_url();
    });
}

function repositionContentContainer() {
  // this routine is a complete hack to work around the flash "Allow" button bug
  if ( $("#frtr_body").length > 0 ) {

    //Adjust the #content left-margin, since by default it likely isn't an int
    setLeftMargin();
    //If the User resizes the window, adjust the #content left-margin
    $(window).bind("resize", function() { setLeftMargin(); });
  }
}

function setLeftMargin() {
  var newWindowWidth = $(window).width();
  var mainWellWidth = $("#frtr_body").width();
  // create an integer based left_offset number
  var left_offset = parseInt((newWindowWidth - mainWellWidth)/2.0);
  if (left_offset < 0) { left_offset = 0; }
  $("#frtr_body").css("margin-left", left_offset);
}



$(document).ready(function() {
  prepare_recorder_page();

  prepare_view_page();
  
  // used to iniialize the JS that creates a popup window
	$(".popupwindow").popupwindow();
	
	// This is a work around to enable the flash allow button to work on the recorder
	// The issue is that when setting margin to auto the flash object sometimes is set on
	// a decimal pixel which does not allow the user to click "allow" in firefox
	repositionContentContainer();
	
});
