Event.observe(document, 'dom:loaded', function() {
  var output = $('output_window');
  var build_container = $('build') || $('last_build');
  var build_container_blockquote = build_container.down('blockquote');
  if (!output) return;

  new PeriodicalExecuter(
      function(){
        new Ajax.Request(
          window.location.href + '/poll', {
            onSuccess: function(response) {
              var build = response.responseJSON;
              output.update(build.output);
              build_container.down('h1').update(build.build_message);
              build_container_blockquote.down('p').update(build.commit_message);
              build_container_blockquote.down('p.meta span.who').update(build.who);
              build_container_blockquote.down('p.meta span.when').update(build.when);
              build_container_blockquote.down('p.meta span.what').update(build.what);
              build_container.className = build.status;
            }
          })},
      2 );
});
