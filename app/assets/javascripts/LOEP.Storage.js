LOEP.Storage = (function(L,$,undefined){

	var _initialized;

	//Own vars
	var _isLocalStorageSupported;
	
	var init = function(){
		if(!_initialized){
			_isLocalStorageSupported = checkSupport();
			_initialized = true;
		}
	};

	/*
	 * Generic function to store values
	 */
	var add = function(key,value){
		if(!_initialized){
			init();
		}
		if(_isLocalStorageSupported){
			var myObject = {};
			myObject.value = value;
			myObject.version = L.VERSION;
			myObject = JSON.stringify(myObject);
			localStorage.setItem(key,myObject);
			return true;
		} else {
			return false;
		}
	};

	var get = function(key){
		if(!_initialized){
			init();
		}

		if(_isLocalStorageSupported){
			var myObject = localStorage.getItem(key);
			if(typeof myObject === "string"){
				myObject = JSON.parse(myObject);
				if((myObject)&&(myObject.value)){
					return myObject.value;
				}
			}
		}

		return undefined;
	};

	///////////////
	// UTILS
	//////////////

	var checkSupport = function(){
		return (typeof(Storage)!=="undefined");
	}

	var clear = function(){
		localStorage.clear();
	}


	return {
		init				: init,
		add					: add,
		get					: get,
		checkSupport		: checkSupport,
		clear 				: clear
	};
    
}) (LOEP, jQuery);