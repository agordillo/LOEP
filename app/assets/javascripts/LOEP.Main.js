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


	return {
		init 		: init,
		createURL 	: createURL
	};
    
}) (LOEP, jQuery);