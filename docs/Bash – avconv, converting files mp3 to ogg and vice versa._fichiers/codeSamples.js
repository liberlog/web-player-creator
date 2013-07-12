function printObject(idObject, pageName)
{
	var eleRef = document.getElementById(idObject);
	var text = eleRef.innerHTML;
	
	var refEnt =/\n/gi;
	text = text.replace(refEnt, '<br>');
	var pageUrl = 'about:blank';
	var printWindow = window.open(pageUrl, 'pageName', 'left=50000,top=50000,width=0,height=0');
	
	printWindow.document.write(text);
	printWindow.document.close();
	printWindow.focus();
	printWindow.print();
	printWindow.close();
}

// FF, O: numberTag - numer tagu na stronie, który ma być zaznaczony
// IE: idObject - id elementu, które ma być zaznaczone
function selectCode(tagName, idObject, numberTag){
	if (typeof window.getSelection == 'function')
		selectOnFirefoxOpera(tagName, numberTag);
	else if (typeof window.selection)
		selectOnIE(idObject);
	else {
		window.alert("Twoja przeglądarka nie umożliwia zaznaczenia tekstu przy użyciu javascript i DOM.");
	} 
}

function selectOnIE(idObject){
	var elem = document.getElementById(idObject); 
	var range = document.body.createTextRange(); 

	range.moveToElementText(elem); 
	range.select(); 
}

function selectOnFirefoxOpera(tagName, numberTag){
	var textSelect = document.getElementsByTagName(tagName);
	var sel = window.getSelection();
	if(sel.rangeCount > 0) 
		sel.removeAllRanges();
		
	var r = document.createRange();
	r.selectNode(textSelect[numberTag]);
	sel.addRange(r);
}