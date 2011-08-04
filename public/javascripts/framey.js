/***********************************************************************************************
* framey.js                   The Framey javascript client library. (See http://framey.com/docs)
* 5/3/11                                                                          Shaun Salzberg
*
* Requirements:
*    - swfobject.js
*
* Usage:
*
* If you plan to use the Framey.renderRecorder function, you must first do:
*
*     Framey.configure({
*         api_key: "[YOUR API KEY]",
*         timestamp: "[REQUEST SIGNATURE EXPIRATION DATE]",
*         signature: "[SERVER SIDE GENERATED REQUEST SIGNATURE USING timestamp]"
*     })
*
* To render the Framey recorder, first create a div to contain it, then do:
*
*     Framey.renderRecorder(yourDivId,{
*         id: "[FLASH EMBED OBJECT ID]",       // optional, "the_"+yourDivId by default
*         max_time: [MAX RECORDING TIME],      // optional, 30 by default
*         session_data: [HASH OF CUSTOM DATA]  // optional
*     })
*
* To render the Framey player, first create a div to contain it, then do:
*
*     Framey.renderPlayer(yourDivId,{
*         id: "[FLASH EMBED OBJECT ID]",               // optional, "the_"+yourDivId by default
*         video_url: "[URL TO VIDEO FLV]",             // required
*         thumbnail_url: "[URL TO VIDEO THUMBNAIL]",   // required
*         progress_bar_color: "[PROGRESS BAR COLOR]",  // optional, "0x000000" by default
*         volume_bar_color: "[VOLUME BAR COLOR]",      // optional, "0x000000" by default
*     })
*
* The Framey video recorder also calls javascript functions when certain events happen. To
* listen to one of these events, do:
*
*    Framey.observe(theEvent,myCallbackFunction)
*
* theEvent can be one of:
*    "recordClicked"     // fired when the record button or the "Delete & Re-Record" button is clicked
*    "reviewClicked"     // fired when the "Review" button is clicked
*    "deleteClicked"     // fired when the "Delete & Re-Record" button is clicked
*    "stopClicked"       // fired when the stop recording button is clicked
*    "publishClicked"    // fired when the publish button is clicked
*    "publishSucceeded"  // fired after the publish button is clicked, if the publish succeeds
*    "publishFailed"    //  fired if there was an error publishing the video. 
*
* When myCallbackFunction is called, it is passed a hash of data, which is the same session_data
* that you passed in when embedding the recorder.
*
* To stop observing an event, do:
*
*    Framey.stopObserving(theEvent,myCallbackFunction)
*
***********************************************************************************************/


var Framey = {}

Framey.api_host = "http://framey.com"

// FOR THE USER TO SET
Framey.api_key = "" 
Framey.timestamp = ""
Framey.signature = ""

Framey.configure = function(configs) {
	Framey.api_host = configs["api_host"];
	Framey.api_key = configs["api_key"];
	Framey.timestamp = configs["timestamp"];
	Framey.signature = configs["signature"];
}

Framey.renderRecorder = function(divId,opts) {
	if( !opts ) opts = {};
	if( !opts["session_data"] )
		opts["session_data"] = "";
	if( !opts["max_time"] )
		opts["max_time"] = 30;
	if( !opts["run_env"] )
		opts["run_env"] = "production"
	if( !opts["id"] )
		opts["id"] = "the_"+divId;
	
	var flashvars = {
  	api_key: Framey.api_key,
  	signature: Framey.signature,
  	time_stamp: Framey.timestamp,
  	session_data: opts["session_data"],
  	run_env: opts["run_env"],
  	max_time: opts["max_time"]
  };
  var params = {
    'allowscriptaccess': 'always',
    "wmode": "transparent"
  };
  var attributes = {
    'id': opts["id"],
    'name': opts["id"]
  };
  swfobject.embedSWF(Framey.api_host + "/recorder.swf", divId, "340", "340", "8", "", flashvars, params, attributes);
}

Framey.renderPlayer = function(divId,opts) {
	if( !opts ) opts = {};
	if( !opts["progress_bar_color"] )
		opts["progress_bar_color"] = "0x000000";
	if( !opts["volume_bar_color"] )
		opts["volume_bar_color"] = "0x000000";
	if( !opts["id"] )
		opts["id"] = "the_"+divId;
					
	var flashvars = {
    'video_url': opts["video_url"],
    'thumbnail_url': opts["thumbnail_url"],
    "progress_bar_color": opts["progress_bar_color"],
    "volume_bar_color": opts["volume_bar_color"]
  };

  var params = {
    'allowfullscreen': 'true',
    'allowscriptaccess': 'always',
    "wmode": "transparent"
  };

  var attributes = {
    'id': opts["id"],
    'name': opts["id"]
  };

  swfobject.embedSWF(Framey.api_host + "/player.swf", divId, '340', '290', '9', 'false', flashvars, params, attributes);
}

Framey.getRecorder = function(id) {   
  var isIE = navigator.appName.indexOf("Microsoft") != -1;   
  return (isIE) ? window[id] : document[id];  
}

Framey.setAllSessionData = function(id,data) {
	var f = Framey.getRecorder(id);
	return f.setAllSessionData(data);
}

Framey.setSessionData = function(id,key,value) {
	var f = Framey.getRecorder(id);
	return f.setSessionData(key,value);
}

Framey.callbacks = {};

Framey.observe = function(which,callback) {
	if( !Framey.callbacks[which] )
		Framey.callbacks[which] = [];
	Framey.callbacks[which].push(callback)
}

Framey.stopObserving = function(which,callback) {
	if( !Framey.callbacks[which] )
		Framey.callbacks[which] = [];
	
	var newCallbacks = [];
	for( i = 0; i < Framey.callbacks[which].length; i++ ) {
		if( Framey.callbacks[which][i] != callback )
			newCallbacks.push(callback)
	}
	
	Framey.callbacks[which] = newCallbacks;
}

Framey.fire = function(which,data) {
	if( !Framey.callbacks[which] )
		Framey.callbacks[which] = [];
		
	for( i = 0; i < Framey.callbacks[which].length; i++ ) {
		Framey.callbacks[which][i](data);
	}
}

Framey.recordClicked = function(data) {
  Framey.fire("recordClicked",data)
}
Framey.reviewClicked = function(data) {
  Framey.fire("reviewClicked",data)
}
Framey.deleteClicked = function(data) {
  Framey.fire("deleteClicked",data)
}
Framey.stopClicked = function(data) {
  Framey.fire("stopClicked",data)
}
Framey.publishClicked = function(data) {
  Framey.fire("publishClicked",data)
}
Framey.publishSucceeded = function(data) {
  Framey.fire("publishSucceeded",data)
}
Framey.publishFailed = function(data) {
  Framey.fire("publishFailed",data)
}
