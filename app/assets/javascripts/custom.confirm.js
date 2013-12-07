$.rails.allowAction = function(link) {
  if (!link.attr('data-confirm')) {
   return true;
  }
  $.rails.showConfirmDialog(link);
  return false;
};

$.rails.confirmed = function(link) {
  link.removeAttr('data-confirm');
  return link.trigger('click.rails');
};

$.rails.showConfirmDialog = function(link){
  var html, message;
  message = link.attr('data-confirm');
  html = '<div id="dialog" title="Basic dialog"><p>'+message+'</p></div>';
  $(html).dialog({
      resizable: false,
      // Not specified height = height auto
      // height: 300,
      modal: true,
      dialogClass: 'noTitleStuff',
      open: function() {
        //Fix bug introduced on JQuery UI 1.10.3
        $(this).closest(".ui-dialog")
        .find(".ui-dialog-titlebar-close")
        .removeClass("ui-dialog-titlebar-close")
        .addClass("ui-icon-closethick-wrapper")
        .html("<span class='ui-button-icon-primary ui-icon ui-icon-closethick'></span>");
      },
      buttons: {
        "Ok": function() {
          $( this ).dialog( "close" );
          return $.rails.confirmed(link);
        },
        Cancel: function() {
          $( this ).dialog( "close" );
        }
      }
    });
};

$(document).on('click', '[promptOkAlertDialog="true"]', function(event){
  var link = $(event.target);
  var message = $(link).attr('data-confirm');
  html = '<div id="dialog" title="Basic dialog"><p>'+message+'</p></div>';
   $(html).dialog({
      resizable: false,
      modal: true,
      dialogClass: 'noTitleStuff',
      buttons: {
        "Ok": function() {
          $( this ).dialog( "close" );
        }
      }
    });
});
      

