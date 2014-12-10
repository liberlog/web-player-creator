
if (navigator.browserLanguage)
var language = navigator.browserLanguage;

/*
Bon pour commencer on va faire une petite détection de la propriété browserLanguage de l'objet navigator et voir si le visiteur ne viens pas avec Internet Explorer.
Pourquoi ? Parce que tout simplement les développeur de chez Micro$oft ont "oubliés" d'implanter une propriété (language pour ne pas la citer) de l'objet navigator pour mettre la leur (qui n'existe donc pas en javascript). Donc il faut (encore) prévoir un cas spécial.
*/

else
var language = navigator.language;


/* write text file */
function readText(afile)
	{
				var reader = new FileReader();
				
				reader.onload = function (e) {  
					var output=e.target.result;
					document.write( output +'<BR>');
                    }
				return true;
	}

