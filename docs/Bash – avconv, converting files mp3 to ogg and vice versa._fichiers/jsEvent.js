function addEventListner(ev, fun, objId){
	var obj = document.getElementById(objId);
	if (obj.addEventListener) {
		obj.addEventListener(ev, fun, false);
	} else if (obj.attachEvent)  { //ie
		obj.attachEvent("on"+ev, fun);
	} 
}