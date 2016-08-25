//= require active_admin/base

$(document).on('ready page:load turbolinks:load', function() {
  $('a.lextest').click(function(e) {
    e.stopPropagation();  // prevent Rails UJS click event
    e.preventDefault();

    var action = $(this).data('action');

    ActiveAdmin.modal_dialog(
      "Send 'Retrospective Required' email: ",
      $(this).data('inputs'),
      function(inputs) {
        $("<form>")
          .attr("method", "post")
          .attr("action", action)
        .append(
          $("<input>")
            .attr("name", $('meta[name=csrf-param]').attr('content'))
            .val($('meta[name=csrf-token]').attr('content'))
        ).append(
          $("<input>")
            .attr("name", "inputs")
            .val(JSON.stringify(inputs))
        ).appendTo(document.body)
        .submit()
      })
  })
})
