var minW=500, minH=300, cbaAd=document.getElementsByTagName('body')[0], _w=cbaAd.clientWidth<=0?400:cbaAd.clientWidth, _h=cbaAd.clientHeight<=0?200:cbaAd.clientHeight;
var ok = false;
if (self==top || (_w>minW && _h>minH)) {
	ok = true;
}
if (!ok) {
	var dd = document.getElementById('reklamacba');
	if (dd) {
		dd.parentNode.removeChild(dd);
	}
}
