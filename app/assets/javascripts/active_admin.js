//= require active_admin/base

$(document).on('ready page:load turbolinks:load', function() {
  var subject, cc, body

  $('a.lextest').click(function(e) {
    e.stopPropagation();  // prevent Rails UJS click event
    e.preventDefault();

    var action = $(this).data('action');
    subject = $(this).data('subject');
    cc = $(this).data('cc')
    body = $(this).data('body');

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
  });

  $('body').on('modal_dialog:before_open', function(e, form) {
    $(form).find("input[name=CC]").val(cc);
    $(form).find("input[name=Subject]").val(subject);
    $(form).find("textarea[name=Body]").val(body).attr('rows', '20');
  });
})
