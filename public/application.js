Event.observe(document, 'dom:loaded', function() {
  var output = $('output_window');
  if (!output) return;
  new Ajax.PeriodicalUpdater(output, window.location.href + '/poll', {
    method: 'post',
    frequency: 2
  });
});