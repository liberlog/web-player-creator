unit webplayer_strings;

{$IFDEF FPC}
  {$mode Delphi}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils;

resourcestring
  gs_WebPlayer_Back = 'Retour' ;
  gs_WebPlayer_Delete_File = 'Effacer le fichier';
  gs_WebPlayer_Delete_Files_confirm_in_each_directory = ' et ses sous-répertoires';
  gs_WebPlayer_Delete_Files_confirm = 'Confirmez-vous l''effacement de ces fichiers dans le répertoire @ARG@ARG : '+#10+'@ARG?';
  gs_WebPlayer_ErrorFiles = 'Erreur : Aucune source dans le répertoire ';
  gs_WebPlayer_ErrorThemes = 'Erreur : Aucun thème dans le répertoire ';
  gs_WebPlayer_ExportMoreThan5Chars =
    'Le chemin d''exportation web doit faire plus de 5 caractères.';
  gs_WebPlayer_Home = 'Accueil';
  gs_WebPlayer_Downloads = 'Télécharger';
  gs_WebPlayer_Welcome = 'Bienvenue !';
  gs_WebPlayer_Phase = 'Étape : ' ;
  gs_WebPlayer_Finished = 'Fini' ;
  gs_WebPlayer_Generating = 'Génération de la liste. ';
  gs_WebPlayer_Language = 'Français';
  gs_WebPlayer_FORM_CAPTION = 'Générer une playlist statique en HTML 5' ;

  gs_WebPlayer_cantConnect = 'Impossible de se connecter à la base : ';
  gs_WebPlayer_cantCreateATree = 'Impossible de créer l''arbre : ';
  gs_WebPlayer_cantSaveTree = 'Impossible de sauver l''arbre ici : ';
  gs_WebPlayer_cantSaveFile = 'Impossible de sauver le fichier ici : ';
  gs_WebPlayer_cantCreateImage = 'Impossible de manipuler cette image : ';
  gs_WebPlayer_cantOpenData = 'Impossible d''ouvrir les données sur ';
  gs_WebPlayer_cantOpenFile = 'Impossible d''ouvrir le fichier ici : ';
  gs_WebPlayer_cantUseData = 'Impossible d''utiliser les données sur ';
  gs_WebPlayer_cantCreateHere = 'Impossible de sauver ici : ';
  gs_WebPlayer_cantCreateContact = 'Impossible de sauver la fiche de contact ici : ';
  gs_WebPlayer_DownloadGedcom = 'Téléchargez mon Gedcom ici.';
  gs_WebPlayer_CreatedBy = 'Créé par';
  gs_WebPlayer_Please_Restart = 'Succès de la mise à jour !'+#10+' Veuillez redémarrer...';
  gs_WebPlayer_StartUpdate = 'Une mise à jour de la base est nécessaire à partir de ce script :'+#10;
  gs_WebPlayer_FileName_NotACopy = '-original';
  gs_WebPlayer_Unset_Stats = 'Veuillez désactiver les statistiques dans l''onglet "Global".';

implementation

end.


