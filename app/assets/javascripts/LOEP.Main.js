LOEP.Main = (function(L,$,undefined){

	var _initialized;

	var init = function(){
		if(!_initialized){
			LOEP.Storage.init();
			_initialized = true;
		}
	};

	/* Utils */

	var createURL = function(base,objects){
		var url = base;
		$(objects).each(function(index,obj){
			if((typeof obj != "object")||(typeof obj.length != "number")){
				return;
			}

			if(index==0){
				url = url + "?";
			} else {
				url = url + "&";
			}

			url = url + obj[0] + "=";

			$(obj[1]).each(function(index,value){
				if (index!=0){
					url = url + ",";
				}
				url = url + value;
			});
		});

		return url;
	};

	var createNotification = function(type,msg){
		var notificationsWrapper = $("#loep_notifications");
		var notification = _createNotification(msg);
		switch(type){
			case "success":
			case "notice":
				$(notification).addClass("alert-success");
				break;
			case "failure":
			case "alert":
				$(notification).addClass("alert-danger");
				break;
			default:
				break;
		}
		if(typeof notification != "undefined"){
			$(notificationsWrapper).append(notification);
		}
	};

	var cleanNotifications = function(){
		$("#loep_notifications").html("");
	};

	var _createNotification = function(msg){
		return $('<div class="alert alert-dismissable"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'+msg+'</div>');
	};


	return {
		init 				: init,
		createURL 			: createURL,
		createNotification	: createNotification,
		cleanNotifications	: cleanNotifications
	};
    
}) (LOEP, jQuery);