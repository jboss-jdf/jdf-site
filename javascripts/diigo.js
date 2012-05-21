function diigo(feedUrl) {
  Date.prototype.monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
  Date.prototype.getUTCMonthName = function() {
    return this.monthNames[this.getUTCMonth()];
  };
  Date.prototype.getUTCShortMonthName = function() {
    return this.getUTCMonthName().substr(0, 3);
  };
  $.jGFeed(feedUrl,
    function(feeds) {
      if (!feeds) {
        return false;
      }
      $.each(feeds.entries, function(idx, entry) {
        entry.source = entry.link.match(/https?:\/\/([^\/]+)/)[1];
        var d = new Date(entry.publishedDate);
        // years are totally wrong
        entry.publishedDateYear = d.getFullYear();
        entry.publishedDateYear = d.getUTCFullYear();
        entry.publishedDateMonth = d.getUTCShortMonthName();
        entry.publishedDateOfMonth = d.getUTCDate();
        if (entry.publishedDateOfMonth < 10) {
          entry.publishedDateOfMonth = '0' + entry.publishedDateOfMonth;
        }
        entry.content = entry.content.replace(/Tags:/, 'tagged as ');
      });
      $('#diigo').html($('#diigo-tmpl').render(feeds.entries));
    }, 15);
}
