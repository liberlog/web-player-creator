function addFlagsOfCountries(url, idElem, pathToFlags){
	var add = new jsAddFlagsOfCountries(url, idElem);
	add.addElem(pathToFlags);
}

function addFlagsOfCountriesAndSpan(url, idParent, idElem, pathToFlags){
	var add = new jsAddFlagsOfCountries(url, idElem);
	add.addSpan(idParent);
	add.addElem(pathToFlags);
}



function jsAddFlagsOfCountries(url, idElem){
	this.setUrl = function(url){
		this.url = url;
	}
	
	this.getUrl = function(){
		return this.url;
	}
	
	this.setIdElem = function(idElem){
		this.idElem = idElem;
	}
	
	this.getIdElem = function(){
		return this.idElem;
	}
	
	var url;
	var idElem;
	
	this.setUrl(url);
	this.setIdElem(idElem);
}

jsAddFlagsOfCountries.prototype.addSpan = function(idElem){
	var parentElem = document.getElementById(idElem);
	var spanTag = document.createElement("span");
	spanTag.setAttribute("id", this.getIdElem());
	parentElem.appendChild(spanTag);
}

jsAddFlagsOfCountries.prototype.addElem = function(pathToFlags){
	var eSpan = document.getElementById(this.getIdElem());
	
	var eA1 = document.createElement("A");
	eA1.setAttribute("class", "flag");
	eA1.setAttribute("href", "#");
	var eImg1 = document.createElement("IMG");
	eImg1.setAttribute("alt", "flag_united_kingdom");
	eImg1.setAttribute("src", pathToFlags+"flag_united_kingdom.png");
	
	var eA2 = document.createElement("A");
	eA2.setAttribute("class", "flag");
	eA2.setAttribute("href", "#");
	var eImg2 = document.createElement("IMG");
	eImg2.setAttribute("alt", "flag_poland");
	eImg2.setAttribute("src", pathToFlags+"flag_poland.png");
	
	if (this.isLanguageEng() == true){
		eImg2.setAttribute("class", "notSelected");
		eA2.setAttribute("href", this.getPageName().substring(0, this.getPageName().lastIndexOf('_'))+".htm");
	}else{
		eImg1.setAttribute("class", "notSelected");
		eA1.setAttribute("href", this.getPageName().substring(0, this.getPageName().lastIndexOf('.'))+"_eng.htm");
	}
	
	
	eA1.appendChild(eImg1);
	eA2.appendChild(eImg2);
	
	eSpan.appendChild(eA1);
	eSpan.appendChild(eA2);
}

jsAddFlagsOfCountries.prototype.isLanguageEng = function(){
	var eng = this.getUrl().substring(this.getUrl().lastIndexOf('_')+1, this.getUrl().lastIndexOf('.'));
	
	if (eng != "eng")
		return false;

	return true;
}

jsAddFlagsOfCountries.prototype.getPageName = function(){
	return this.getUrl().substring(document.location.pathname.lastIndexOf('/')+1);
}
