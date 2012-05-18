function getVideo(url) {
  var oEmbedEndpoint = 'http://vimeo.com/api/oembed.json'
  var oEmbedCallback = 'switchVideo';
  $.getScript(oEmbedEndpoint + '?url=' + url + '&width=504&height=280&callback=' + oEmbedCallback);
}

function setupGallery(videos) {

  // Load the first video
  getVideo(videos[0].url);

  // Add the videos to the gallery
  for (var i = 0; i < videos.length; i++) {
    var html = '<li><a href="' + videos[i].url + '"><img src="' + videos[i].thumbnail_medium + '" class="thumb" />';
    html += '<p>' + videos[i].title + '</p></a></li>';
    $('#thumbs ul').append(html);
  }

  // Switch to the video when a thumbnail is clicked
  $('#thumbs a').click(function(event) {
    event.preventDefault();
    getVideo(this.href);
    return false;
  });
}

function switchVideo(video) {
  $('#embed').html(unescape(video.html));
}

 
function vimeo(source) { 
  var apiEndpoint = 'http://vimeo.com/api/v2/';
  var videosCallback = 'setupGallery';

  // Get the user's videos
  $(document).ready(function() {
    $.getScript(apiEndpoint + source + '/videos.json?callback=' + videosCallback);
  });

}
