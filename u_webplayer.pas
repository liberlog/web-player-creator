unit u_webplayer;

{$IFDEF FPC}
{$R *.lfm}
{$mode objfpc}{$H+}
{$ELSE}
{$DEFINE WINDOWS}
{$R *.dfm}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
// AncestroWeb
// Plugin libre de création d'un site web généalogique statique en HTML et PHP
// Pour Freelogy et Ancestrologie
// Licence : LGPL
// LIBERLOG 2011
// Auteur : Matthieu GIROUX
// Descriptions
// Création d'un arbre complet, d'une page de contact en PHP, de fiches, etc.
// Historique
// 1.1.4.1 : Gestion de versions
// 1.1.4.0 : Plus de TIBSQL, copie de l'archive originale fonctionnel, moins de bugs
// 1.1.3.1 : Professions dans la fiche de l'individu, Possibilité de descendre son arbre familial
// 1.1.1.2 : Plus de tests
// 1.1.1.1 : Métiers et âges
// 1.0.0.0 : Intégration dans Freelogy
// 0.9.9.0 : première version publiée
////////////////////////////////////////////////////////////////////////////////

interface

uses
{$ifdef unix}
  BaseUnix,
{$endif}

{$IFNDEF FPC}
  Mask,  rxToolEdit, JvExControls,
{$ELSE}
  lazutf8classes,
  LCLIntf, LCLType, EditBtn,FileUtil,
{$ENDIF}
  fonctions_string,
{$ifdef windows}
  Windows,
{$endif}
{$IFDEF WIN32}
  Registry,
{$ENDIF}
{$IFNDEF FPC}
  fonctions_version,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, DB,
  IBQuery, DBCtrls, ExtCtrls, Buttons, ComCtrls, DBGrids,
  functions_html, ExtJvXPCheckCtrls, Spin, U_OnFormInfoIni,
  U_ExtImage, u_buttons_appli, IBSQL, U_ExtFileCopy, u_traducefile,
  ExtJvXPButtons, IniFiles,
  u_extabscopy, IBCustomDataSet, Grids, FileCtrl,
  BGRABitmap, JvXPCore,
  u_buttons_defs, u_extsearchedit;

{$IFNDEF FPC}
const
  gVer_WebPlayer : T_Version = ( Component : 'Application WebPlayerCreator' ;
                                             FileUnit : 'U_WebPlayer' ;
                                             Owner : 'Matthieu Giroux' ;
                                             Comment : 'Créateur de player HTNL statique.' ;
                                             BugsStory : '1.0.6.1 : Testing with Extended 1.8.' + 1#13#10
                                                       + '1.0.6.0 : More explicit title.' + 1#13#10
                                                       + '1.0.5.1 : correct progress.' + 1#13#10
                                                       + '1.0.5.0 : optionnal ... button.' + 1#13#10
                                                       + '1.0.4.0 : Describe.' + 1#13#10
                                                       + '1.0.3.0 : HTML Images.' + 1#13#10
                                                       + '1.0.2.0 : Directory view.' + 1#13#10
                                                       + '1.0.1.0 : File sorting.' + 1#13#10
                                                       + '1.0.0.0 : Jquery playlist version.' + 1#13#10
                                                       + '0.9.9.0 : First published version'  ;
                                             UnitType : CST_TYPE_UNITE_APPLI ;
                                             Major : 1 ; Minor : 0 ; Release : 6 ; Build : 0 );
{$ENDIF}

const CST_WebPlayer = 'PlayerCreator' ;
      CST_WebPlayer_WithLicense = CST_WebPlayer + ' GPL ';
      CST_AUTHOR = 'Matthieu GIROUX';
      CST_DOWNLOAD = 'download';
      CST_DOWNLOAD_FILE = CST_DOWNLOAD+'file';
      CST_INDEX = 'index';
      CST_INDEX_FILE = CST_INDEX+'file';
      CST_INDEX_BODY = CST_INDEX+'body';
      CST_INDEX_BUTTON = CST_INDEX+'button';
      CST_INDEX_DIR  = CST_INDEX+'dir';
      CST_SUBDIR_EXPORT = 'List'+DirectorySeparator;
      CST_SUBDIR_FILES = 'Files' + DirectorySeparator;
      CST_SUBDIR_CLASSES = 'Classes' + DirectorySeparator;
      CST_SUBDIR_THEMES = 'Themes' + DirectorySeparator;
      CST_DESCRIBE = 'Describe';
      CST_EXTENSION_PNG_MINI = 'png';
      CST_EXTENSION_OGG_MINI = 'ogg';
      CST_EXTENSION_MP3_MINI = 'mp3';
      CST_EXTENSION_WMA_MINI = 'wma';
      CST_EXTENSION_ZIP_MINI = 'zip';
      CST_EXTENSION_TXT_MINI = 'txt';
      CST_EXTENSION_7Z_MINI   = '7z';
      CST_EXTENSION_JS_MINI   = 'js';
      CST_EXTENSION_PNG = '.'+CST_EXTENSION_PNG_MINI;
      CST_EXTENSION_OGG = '.'+CST_EXTENSION_OGG_MINI;
      CST_EXTENSION_MP3 = '.'+CST_EXTENSION_MP3_MINI;
      CST_EXTENSION_WMA = '.'+CST_EXTENSION_WMA_MINI;
      CST_EXTENSION_ZIP = '.'+CST_EXTENSION_ZIP_MINI;
      CST_EXTENSION_TXT = '.'+CST_EXTENSION_TXT_MINI;
      CST_EXTENSION_7Z  = '.'+CST_EXTENSION_7Z_MINI;
      CST_EXTENSION_JS  = '.'+CST_EXTENSION_JS_MINI;
      CST_SCRIPT_FILE   = 'conversion';

type

  { TF_WebPlayer }

  TF_WebPlayer = class(TForm)
    bt_gen: TFWExport;
    bt_Unindex: TFWDelete;
    bt_lighter: TFWDelete;
    cb_Files: TComboBox;
    cb_Themes: TComboBox;
    ch_dirconvert: TJvXPCheckbox;
    ch_downloads: TJvXPCheckbox;
    ch_convert: TJvXPCheckbox;
    ch_Names64: TJvXPCheckbox;
    ch_OGG: TJvXPCheckbox;
    ch_WMA: TJvXPCheckbox;
    ch_IndexAll: TJvXPCheckbox;
    ch_ZIP: TJvXPCheckbox;
    ch_TXT: TJvXPCheckbox;
    ch_7ZIP: TJvXPCheckbox;
    de_indexdir: TDirectoryEdit;
    de_convertdir: TDirectoryEdit;
    ed_Author: TEdit;
    ed_IndexName: TEdit;
    ed_DownLoadName: TEdit;
    ed_TXTName: TEdit;
    FileCopy: TExtFileCopy;
    ds_Individu: TDatasource;
    FileIniCopy: TExtFileCopy;
    fne_export: TFileNameEdit;
    fne_import: TFileNameEdit;
    FWClose1: TFWClose;
    bt_export: TFWExport;
    bt_see: TFWSearch;
    IBQ_Individu: TIBQuery;
    ch_MP3: TJvXPCheckbox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label6: TLabel;
    lb_Comments: TLabel;
    lb_Images: TLabel;
    L_thema: TLabel;
    me_Bottom: TMemo;
    me_Description: TMemo;
    OnFormInfoIni: TOnFormInfoIni;
    OpenDialog: TOpenDialog;
    pa_options: TPanel;
    pb_Progress: TProgressBar;
    spSkinPanel1: TPanel;
    sp_Mp3Quality: TSpinEdit;
    procedure bt_exportClick(Sender: TObject);
    procedure bt_genClick(Sender: TObject);
    procedure bt_lighterClick(Sender: TObject);
    procedure bt_seeClick(Sender: TObject);
    procedure bt_UnindexClick(Sender: TObject);
    procedure fne_ExportAcceptFileName(Sender: TObject; var Value: String);
    procedure fne_importAcceptFileName(Sender: TObject; var Value: String);
    procedure fne_importChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
    procedure DoAfterInit(const ab_Ini: Boolean=True);
    function fb_DeleteOrNot(const as_ThemaSource : String; astl_ListFiles: TStrings): Boolean;
    function fstl_CreateListToDelete ( const as_ThemaSource : String ): TStringListUTF8;
    procedure p_AddFiles ( const as_Source, as_artist, as_subdirForward : String ;
                           const astl_files : TStrings;
                           const ai_eraseBegin, ai_Level : Integer;
                           const astl_DirListAudio, astl_temp1,
                                 astl_downloads, astl_downloadsafter , astl_Processes : TStrings;
                           var   ab_first, ab_foundAudio : Boolean;
                           const ab_Root : Boolean ; var ab_downloadReally, ab_TextOneLanguage : Boolean;
                           var   as_BackDirText : String);
    procedure p_AddToCombo(const acb_combo: TComboBox; const as_Base: String;
      const ab_SetIndex: Boolean=True);
    procedure p_CreateAHtmlFile(const astl_Destination: TStrings;
      const as_BeginingFile, as_Describe, as_file, as_Title, as_LittleTitle, as_LongTitle: string;
      const as_Subdir: string = '';
      const as_ExtFile: string = CST_EXTENSION_HTML;
      const as_BeforeHTML: string = ''; const astl_Body : TStrings = nil );
    procedure p_genHtmlHome ( const as_directory, as_subdirForward, as_artist, as_backDirText : String;
                              const ab_TextOneLanguage, ab_Root : Boolean );
    function  fb_genUnGenPrepare( var as_ThemaSource : String ):Boolean;
    procedure p_IncProgress;
    procedure p_Setcomments(const as_Comment: String);
    procedure p_Unfat(const as_directory: String);
    procedure p_Unindex(const as_directory: String;const astl_List1ToUnindex : TStrings);
  public
    { Déclarations publiques }
  end;

var
  F_WebPlayer: TF_WebPlayer;
  gb_Generate : boolean = False;
  gs_RootPathForExport : String;


implementation

uses  fonctions_init,
  functions_html_tree,
{$IFDEF FPC}
  webplayer_strings, strutils,
{$ELSE}
  webplayer_strings_delphi,
{$ENDIF}
{$IFDEF WIN32}
//  windirs,
{$ENDIF}
  fonctions_system,
  fonctions_dbcomponents,
  fonctions_db,
  fonctions_languages,
  fonctions_images,
  fonctions_components,
  fonctions_file;


var lw_CurrentYear  : Word = 0;
    ldt_100YearData : TDateTime = 0;


// function GetCurrentYear
// Get Current Year
function GetCurrentYear: word;
var
  d,m,y: word;
begin
  if lw_CurrentYear = 0 Then
    DecodeDate(Now, lw_CurrentYear, m, d);
  Result := lw_CurrentYear;
end;

// function Get100YearDated
// Get now - 100 Year
function Get100YearDated: TDateTime;
var
  d,m,y: word;
begin
  if ldt_100YearData = 0 Then
    ldt_100YearData := EncodeDate(GetCurrentYear-100,1,1);
  Result:=ldt_100YearData;
end;

// procedure TF_WebPlayer.fne_ExportAcceptFileName
// Exporting ini on filename's accept
procedure TF_WebPlayer.fne_ExportAcceptFileName(Sender: TObject;
  var Value: String);
begin
  bt_exportClick(bt_export);
end;

const CST_CONVERTED = '-converted';

function fb_FileExitsExt ( const as_FileWithoutExt, as_extMini : String ): Boolean;
Begin
  Result:=FileExistsUTF8(as_FileWithoutExt+as_extMini) or FileExistsUTF8(as_FileWithoutExt+UpperCase(as_extMini));
end;

function fb_FileExitsExtVar ( const as_FileWithoutExt : String ; var as_extMini : String ): Boolean;
Begin
  Result:=FileExistsUTF8(as_FileWithoutExt+as_extMini);
  if not Result Then
   Begin
    Result := FileExistsUTF8(as_FileWithoutExt+UpperCase(as_extMini));
    if Result Then
     as_extMini:=UpperCase(as_extMini);
   end;
end;

procedure TF_WebPlayer.p_AddFiles ( const as_Source, as_artist, as_subdirForward : String ;
                                    const astl_files : TStrings;
                                    const ai_eraseBegin, ai_Level : Integer;
                                    const astl_DirListAudio, astl_temp1,
                                          astl_downloads, astl_downloadsafter, astl_Processes : TStrings;
                                    var   ab_first, ab_foundAudio : Boolean;
                                    const ab_Root : Boolean ; var ab_downloadReally, ab_TextOneLanguage : Boolean;
                                    var  as_BackDirText : String );
var li_EndExt : Integer ;
    ls_Source ,
    ls_SourceConvert ,
    ls_DirHtml ,
    ls_FileName ,
    ls_FileNameLower ,
    ls_destination  : String;
    lsr_AttrSource      : Tsearchrec;
    lb_TextOneLanguage,
    lb_first : Boolean;
    li_pos : Integer;
    ls_BackDirText:String;
    lstl_temp2 : TStringListUTF8 ;

    // mini ls_source
    procedure p_MiniSource;
    Begin
      {$IFDEF WINDOWS}
      ls_Source := copy(fs_RemplaceChar(StringReplace(ls_Source,'"','\"',[rfReplaceAll]),DirectorySeparator,'/'),ai_eraseBegin,length(ls_Source)-ai_eraseBegin+1);
      {$ELSE}
      ls_Source := copy(StringReplace(ls_Source,'"','\"',[rfReplaceAll]),ai_eraseBegin,length(ls_Source)-ai_eraseBegin+1);
      {$ENDIF}

    end;

    // replace string for a line of music
    procedure p_replaceAllCase ( const ai_pos : Integer ; const as_Ext : String );
     Begin
       p_ReplaceLanguageString(astl_temp1,'Source',ls_Source,[rfReplaceAll]);
       p_ReplaceLanguageString(astl_temp1,'SourceTitle',copy(StringReplace(ls_FileName,'_',' ',[rfReplaceAll]),1,ai_pos-1),[rfReplaceAll]);
       p_ReplaceLanguageString(astl_temp1,'Type','audio/'+as_Ext,[rfReplaceAll]);
     end;

    // Add a download to music download list
    procedure p_addDownload ( const astl_downloadList : TStrings ; const ai_pos : Integer ; const as_Ext : String ); overload;
    Begin
      p_LoadStringList ( astl_temp1,  CST_DOWNLOAD_FILE+CST_EXTENSION_HTML );
      p_replaceAllCase ( ai_pos, as_Ext );
      if as_artist > ''
       Then p_ReplaceLanguageString(astl_temp1,'SourceArtist',' - '+as_artist,[rfReplaceAll])
       Else p_ReplaceLanguageString(astl_temp1,'SourceArtist','',[rfReplaceAll]);
      astl_downloadList.AddStrings(astl_temp1);
    end;

    const CST_documentwrite = 'document.write("';

    // Add a download to music download list
    procedure p_addText ( const as_filename : String ); overload;
    var lstl_Text : TStringList;
    Begin
      lstl_Text:=TStringList.Create;
      try
        lstl_Text.LoadFromFile(as_filename);
        lstl_Text.Text:=CST_documentwrite+StringReplace(fs_html_Lines(lstl_Text.Text,''),'"','\"',[rfReplaceAll])+'");';
        lstl_Text.SaveToFile(as_filename+CST_EXTENSION_JS);
        as_BackDirText:='';
      finally
        lstl_Text.Destroy;
      end;
    end;
                {
    // Add a download to music download list
    procedure p_addOldText ( const as_filename : String ); overload;
    var lstl_Text : TStringList;
        ls_file : String;
    Begin
      ls_file :=copy(as_filename,1,Length(as_filename)-3);
      if FileExistsUTF8(ls_file) Then Exit;
      lstl_Text:=TStringList.Create;
      try
        lstl_Text.LoadFromFile(as_filename);
        lstl_Text.Text:=StringReplace(StringReplace(lstl_Text.Text,'\"','"',[rfReplaceAll]),'<BR>',CST_ENDOFLINE,[rfReplaceAll]);
        lstl_Text[0]:=copy (lstl_Text[0],length(CST_documentwrite)+1,Length(lstl_Text[0]));
        lstl_Text[lstl_Text.count-1]:=copy (lstl_Text[lstl_Text.count-1],1,Length([lstl_Text.count-1])-3);
        if pos ('http://fr.wikipedia.org',lstl_Text[lstl_Text.count-1])>0 Then
         lstl_Text[lstl_Text.count-1]:='http://fr.wikipedia.org';
        if pos ('http://fr.wikipedia.org',lstl_Text[lstl_Text.count-2])>0 Then
         lstl_Text[lstl_Text.count-2]:='http://fr.wikipedia.org';
        lstl_Text.SaveToFile(ls_file);
      finally
        lstl_Text.Destroy;
      end;
    end;
                }
    // Add a archive download to archive download list
    procedure p_addDownload ( const astl_downloadList : TStrings ; const as_Ext : String ); overload;
    var li_pos : Integer;
    Begin
      li_pos := PosEx ( as_Ext, ls_FileNameLower, li_EndExt );
      if li_pos = 0 Then Exit;
      ab_downloadReally := True;
      p_LoadStringList ( astl_temp1,  CST_DOWNLOAD_FILE+CST_EXTENSION_HTML );
      p_MiniSource;
      p_replaceAllCase ( li_pos, as_Ext );
      if as_artist > ''
       Then p_ReplaceLanguageString(astl_temp1,'SourceArtist',' - '+as_artist,[rfReplaceAll])
       Else p_ReplaceLanguageString(astl_temp1,'SourceArtist','',[rfReplaceAll]);
      astl_downloadList.AddStrings(astl_temp1);
    end;

    procedure p_addFile( const ab_add : Boolean; const as_Ext : String );
    var ls_FileWithoutExt     ,
        ls_FileNameWithoutExt : String;
        li_pos : Integer;
    procedure p_AddExt ( as_ext : String; const as_jplayerLabelFile : String );
    var ls_source64:String;
    Begin
      if ch_Names64.Checked
        Then ls_source64 := copy ( ls_FileNameWithoutExt, 1, 60 )
        Else ls_source64 := ls_FileNameWithoutExt;
      if fb_FileExitsExtVar(ls_FileWithoutExt,as_ext)
       Then p_ReplaceLanguageString(astl_temp1,as_jplayerLabelFile,ls_DirHtml+ls_source64 +as_ext,[rfReplaceAll])
       Else if fb_FileExitsExtVar(ls_FileWithoutExt+CST_CONVERTED,as_ext)
       Then p_ReplaceLanguageString(astl_temp1,as_jplayerLabelFile,ls_DirHtml+ls_source64 +CST_CONVERTED+as_ext,[rfReplaceAll])
       Else if ch_dirconvert.Checked and fb_FileExitsExtVar(ls_SourceConvert+ls_FileNameWithoutExt,as_ext)
       Then p_ReplaceLanguageString(astl_temp1,as_jplayerLabelFile,ls_SourceConvert+ls_FileNameWithoutExt+CST_CONVERTED+as_ext,[rfReplaceAll])
       Else p_ReplaceLanguageString(astl_temp1,as_jplayerLabelFile,'',[rfReplaceAll]);
    end;

    function fs_MiniPath ( const as_path : String ) : String;
    Begin
      if ai_eraseBegin>length ( as_path )-5
       Then Result:='../'+ExtractFileName(as_path)
       Else Result := copy ( as_path, ai_eraseBegin, length ( as_path ) - ai_eraseBegin + 1 );
    end;

    function fb_ReplaceImgExt ( const as_image : String ; const as_extension : String ) : Boolean;
    Begin
      Result := FileExistsUTF8(as_image+as_extension);
      if Result
       Then
        Begin
         {$IFDEF WINDOWS}
         p_ReplaceLanguageString(astl_temp1,'SourcePoster',fs_RemplaceChar(fs_MiniPath (as_image)+as_extension,DirectorySeparator,'/'),[rfReplaceAll]);
         {$ELSE}
         p_ReplaceLanguageString(astl_temp1,'SourcePoster',fs_MiniPath (as_image)+as_extension,[rfReplaceAll]);
         {$ENDIF}
         Exit
        end;
      //WriteLn(fs_MiniPath (as_image)+as_extension+ ' '+as_image+as_extension);
    end;

    function fb_ReplaceImg ( const as_image : String ) : Boolean;
    Begin
      Result := fb_ReplaceImgExt ( as_image,CST_EXTENSION_PNG) or
                fb_ReplaceImgExt ( as_image,CST_EXTENSION_JPEG) or
                fb_ReplaceImgExt ( as_image,CST_EXTENSION_GIF);
    End;
    begin
      li_pos := PosEx ( as_Ext, ls_FileNameLower, li_EndExt );
      if ab_add and ( li_pos > 0 )
      and ( pos ( CST_CONVERTED, ls_FileName ) = 0 )
       then
         Begin
           if ( ai_Level > 1 ) Then
             ab_foundAudio:=True;
           //get the file without extension to filter with extension
           ls_FileWithoutExt := copy ( ls_Source, 1, PosEx ( '.', ls_Source, length ( ls_Source ) - 4 ) - 1 );
           ls_FileNameWithoutExt:=ExtractFileName(ls_FileWithoutExt);
           p_MiniSource;
           ls_DirHtml := {$IFDEF WINDOWS}fs_RemplaceChar({$ENDIF}copy( ls_Source,1,Length(ls_Source)-Length(ls_FileNameWithoutExt)-4 ){$IFDEF WINDOWS},DirectorySeparator,'/'){$ENDIF};
           if ch_downloads.Checked Then
             p_addDownload ( astl_downloadsAfter, li_pos, as_Ext );
           p_LoadStringList ( astl_temp1,  CST_INDEX_FILE+CST_EXTENSION_HTML );
           //ShowMessage(as_Source+CST_EXTENSION_PNG+ls_DirHtml +CST_EXTENSION_JPEG+as_Source+DirectorySeparator+as_parent +CST_EXTENSION_JPEG);
           if not fb_ReplaceImg (ls_FileWithoutExt)
            Then if not fb_ReplaceImg (ExcludeTrailingBackslash(as_Source))
             Then if not fb_ReplaceImg(as_Source+ExtractDirName (as_Source ))
              Then
               Begin
                p_ReplaceLanguageString(astl_temp1,'SourcePoster','',[rfReplaceAll]);
               end;
           if ch_convert.Checked
           and ab_Root Then
            Begin
             if  fb_FileExitsExt(ls_FileWithoutExt,CST_EXTENSION_MP3)
             and not fb_FileExitsExt(ls_FileWithoutExt,CST_EXTENSION_OGG)
             and not fb_FileExitsExt(ls_FileWithoutExt+CST_CONVERTED,CST_EXTENSION_OGG)
             and ch_dirconvert.Checked and not fb_FileExitsExt(ls_SourceConvert+ls_FileNameWithoutExt,CST_EXTENSION_OGG)
              Then
              Begin
                if ch_dirconvert.Checked
                 Then
                  Begin
                   fb_CreateDirectoryStructure(ls_SourceConvert);
                   astl_Processes.add ('avconv -i "'+StringReplace(ls_Source,'"','\"',[rfReplaceAll])+'" "'
                                                 +StringReplace(ls_SourceConvert+ls_FileNameWithoutExt+CST_EXTENSION_OGG,'"','\"',[rfReplaceAll])+'"');
                  end
                 else
                  astl_Processes.add ('avconv -i "'+StringReplace(ls_Source,'"','\"',[rfReplaceAll])+'" "'
                                                +StringReplace(ls_FileWithoutExt+CST_CONVERTED+CST_EXTENSION_OGG,'"','\"',[rfReplaceAll])+'"');
              end;
            end;
           p_AddExt (CST_EXTENSION_OGG,'SourceOGG');
           if ab_Root
           and ch_convert.Checked
           and fb_FileExitsExt(ls_FileWithoutExt,CST_EXTENSION_OGG)
           and not fb_FileExitsExt(ls_FileWithoutExt,CST_EXTENSION_MP3)
           and not fb_FileExitsExt(ls_FileWithoutExt+CST_CONVERTED,CST_EXTENSION_MP3)
            Then
             Begin
              astl_Processes.add ('avconv -i "'+StringReplace(ls_FileWithoutExt+CST_EXTENSION_OGG,'"','\"',[rfReplaceAll])+'" -c:a libmp3lame -q:a '+IntToStr(sp_Mp3Quality.Value)+' "'
                                             +StringReplace(ls_FileWithoutExt+CST_CONVERTED+CST_EXTENSION_MP3,'"','\"',[rfReplaceAll])+'"');
            end;
           p_AddExt (CST_EXTENSION_MP3,'SourceMP3');
           p_AddExt (CST_EXTENSION_WMA,'SourceWMA');
           p_replaceAllCase(li_pos,as_Ext);
           p_ReplaceLanguageString(astl_temp1,'SourceArtist',as_artist,[rfReplaceAll]);
           if not ab_first Then
             astl_files.Add(',');
           astl_files.AddStrings(astl_temp1);
           ab_first:=False;
         end;

    end;

begin
  if ch_dirconvert.Checked then
   Begin
    if ( de_convertdir.Directory = '' )
     Then ch_dirconvert.Checked:=False
     Else
       Begin
        if ( pos ( de_convertdir.Directory, as_Source ) > 0 )
         Then Exit;
        ls_SourceConvert:=AppendPathDelim(AppendPathDelim(de_convertdir.Directory)+copy(as_Source,Length(AppendPathDelim(de_indexdir.Directory))+1,Length(as_Source)));
       end;
   end
   else ls_SourceConvert := '';
  astl_temp1.Clear ;
  lstl_temp2 := TStringListUTF8.Create;
  try
   if fb_FindFiles ( lstl_temp2, as_Source, True, True, True, '*' ) Then
    Begin
     lstl_temp2.Sort;
     while lstl_temp2.count > 0 do
      Begin
        ls_Source := lstl_temp2.Strings [ 0 ];
        FindFirstUTF8( ls_Source,faanyfile,lsr_AttrSource);
        ls_FileName := lsr_AttrSource.Name ;
        FindCloseUTF8(lsr_AttrSource);
        if DirectoryExistsUTF8 ( ls_Source ) Then
          Begin
            p_addKeyWord(ls_FileName);
            if as_artist > ''
             Then ls_DirHtml := as_artist + ' - ' + ls_FileName
             Else ls_DirHtml := '';
            if ( ai_Level = 1 ) Then
              ab_foundAudio:=False;
            ls_BackDirText:=as_BackDirText+'../';
            lb_TextOneLanguage:=False;
        //    if ls_FileName='Bach'
           //  then ShowMessage(ls_BackDirText+' '+as_BackDirText);
            p_AddFiles ( ls_Source, ls_DirHtml, as_subdirForward+'../', astl_files, ai_eraseBegin, ai_Level + 1, astl_DirListAudio, astl_temp1, astl_downloads, astl_downloadsafter, astl_Processes, ab_first, ab_foundAudio, ab_Root, ab_downloadReally, lb_TextOneLanguage, ls_BackDirText );
            if  ab_foundAudio
            and ( ai_Level = 1 ) // p_genHtmlHome will recall this recursive function
            and ch_IndexAll.Checked Then
             Begin
              p_genHtmlHome ( ls_Source+DirectorySeparator, as_subdirForward+'../', ls_FileName, ls_BackDirText, lb_TextOneLanguage, False );
              astl_DirListAudio.Add(ls_Source);
             end;
            if  ab_Root
            and ( ai_Level = 1 )
             Then
              p_IncProgress;
          End
        Else
          if FileExistsUTF8 ( ls_Source ) Then
            Begin
               ls_FileNameLower := LowerCase(ls_FileName);
               li_EndExt := Length(ls_FileName)-4;
               p_addFile( ch_OGG.Checked, CST_EXTENSION_OGG );

               p_addFile( ch_MP3.Checked, CST_EXTENSION_MP3 );
               p_addFile( ch_WMA.Checked, CST_EXTENSION_WMA );
              if ch_TXT.Checked Then
               Begin
                if ( ls_FileNameLower = ed_TXTName.Text + CST_EXTENSION_TXT )
                 Then ab_TextOneLanguage := True;
                if (pos ( CST_EXTENSION_TXT  , ls_FileNameLower ) >= li_EndExt)
                and (pos ( ed_TXTName.Text+'.', ls_FileNameLower ) = 1 ) Then
                  p_addText ( ls_Source );
               end;
{              if (pos ( CST_EXTENSION_TXT+CST_EXTENSION_JS  , ls_FileNameLower ) >= li_EndExt-3)
              and (pos ( ed_TXTName.Text+'.', ls_FileNameLower ) = 1 ) Then
                p_addOldText ( ls_Source );}
              if ch_ZIP.Checked
              and (pos ( CST_EXTENSION_ZIP, ls_FileNameLower ) >= li_EndExt) Then
                p_addDownload ( astl_downloads, CST_EXTENSION_ZIP);
              if ch_7ZIP.Checked
              and (pos ( CST_EXTENSION_7Z, ls_FileNameLower ) > li_EndExt) Then
                p_addDownload ( astl_downloads, CST_EXTENSION_7Z);
            End;
        lstl_temp2.Delete(0);
      End ;
    end;
  finally
    lstl_temp2.Destroy;
  end;
End ;


procedure TF_WebPlayer.fne_importChange(Sender: TObject);
var as_text : String;
Begin
  as_text := fne_import.{$IFDEF FPC}Filename{$ELSE}Text{$ENDIF};
  fne_importAcceptFileName ( sender, as_text );
End;
// procedure TF_WebPlayer.fne_importAcceptFileName
// Importing ini on filename's accept
procedure TF_WebPlayer.fne_importAcceptFileName(Sender: TObject;
  var Value: String);
var ls_FileImport : String;
begin
  ls_FileImport := {$IFDEF FPC}Value{$ELSE}fne_import.Text{$ENDIF};
  if not DirectoryExistsUTF8(ls_FileImport) { *Converted from DirectoryExists*  }
    and FileExistsUTF8(ls_FileImport) { *Converted from FileExists*  } Then
  Begin
    FIniFile.Free;
    FIniFile:=nil;
    try
      FIniFile:=TIniFile.Create(ls_FileImport);
      FIniFile.Free;
      FIniFile:=nil;
      f_GetMainMemIniFile(nil,nil,nil,False,CST_WebPlayer);
      OnFormInfoIni.p_ExecuteEcriture(Self);
    Except
      On E:Exception do
        ShowMessage(fs_getCorrectString ( gs_WebPlayer_cantOpenFile ) +CST_ENDOFLINE+e.Message);
    end;
  end;
end;

// procedure TF_WebPlayer.FormClose
// Freeing on close
procedure TF_WebPlayer.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
end;
function TF_WebPlayer.fb_genUnGenPrepare( var as_ThemaSource : String ):Boolean;
begin
  //  verifying
  Result:=False;
  if length(de_indexdir.Directory) < 6 then
  begin
    ShowMessage(fs_getCorrectString ( gs_WebPlayer_ExportMoreThan5Chars));
    Exit;
  end;
  if (cb_Files.Items.Count = 0) then
  begin
    ShowMessage(fs_getCorrectString ( gs_WebPlayer_ErrorFiles ) + gs_Root + CST_SUBDIR_FILES);
    Exit;
  end;
  if (cb_Themes.Items.Count = 0) then
  begin
    ShowMessage(fs_getCorrectString ( gs_WEBPlayer_ErrorThemes ) + gs_Root + CST_SUBDIR_THEMES);
    Exit;
  end;
  Result:=True;
  gs_RootPathForExport := de_indexdir.{$IFDEF FPC}Directory{$ELSE}Text{$ENDIF} + DirectorySeparator;
  if DirectoryExistsUTF8(GetAppConfigDir(False)+DirectorySeparator + CST_SUBDIR_THEMES +DirectorySeparator+cb_Themes.Text)
   Then as_ThemaSource  := GetAppConfigDir(False)+DirectorySeparator + CST_SUBDIR_THEMES +DirectorySeparator+cb_Themes.Text
   Else as_ThemaSource  := gs_Root + CST_SUBDIR_THEMES+cb_Themes.Text;

end;

// procedure TF_WebPlayer.bt_genClick
// Main Web Site Generation
procedure TF_WebPlayer.bt_genClick(Sender: TObject);
var ls_Source, ls_ToAdd : String;
    lstl_DirFiles : TStringList;
begin
  if gb_Generate then
    Exit;
  ed_TXTName.Text:=LowerCase(ed_TXTName.Text);
  if not fb_genUnGenPrepare ( ls_Source )
   Then Exit;
  if ch_IndexAll.Checked
   Then ls_ToAdd := gs_WebPlayer_Delete_File
   Else ls_ToAdd := '';
  if (   FileExistsUTF8(de_indexdir.Directory+DirectorySeparator+ed_IndexName.Text+CST_EXTENSION_HTML)
      or ch_IndexAll.Checked)
  and not fb_DeleteOrNot (ls_Source,nil) Then
    Exit;
  pb_Progress.Position := 0;
  lstl_DirFiles := TStringList.Create;
  try
    fb_FindFiles(lstl_DirFiles,gs_RootPathForExport,False,True);
    pb_Progress.Max:=lstl_DirFiles.count;
  finally
  end;
  if (cb_Themes.ItemIndex = -1) then
    cb_Themes.ItemIndex := 0;
  if (cb_Files.ItemIndex = -1) then
    cb_Files.ItemIndex := 0;
  with FileCopy do
   try
    FileOptions:=FileOptions-[cpDestinationIsFile];
    FilesOptions:=FilesOptions-[cpCopyAll];
    Source := ls_Source;
    Destination := gs_RootPathForExport;
    CopySourceToDestination;
    Source := gs_Root + CST_SUBDIR_CLASSES;
    CopySourceToDestination;
  finally
    FileOptions:=FileOptions+[cpDestinationIsFile];
    FilesOptions:=FilesOptions+[cpCopyAll];
   end;
  gs_html_source_file := CST_SUBDIR_FILES + DirectorySeparator + cb_files.Items[cb_files.ItemIndex]+DirectorySeparator;
  // going to work for a time : freezing options to protect work and options
  pa_options.Enabled:=False;
  try // starting work
    p_CreateKeyWords;
    gb_Generate := True;
    p_genHtmlHome ( gs_RootPathForExport, '', '', '', False, True );
  finally
    pa_options.Enabled:=True;
    gb_Generate := False;
    p_Setcomments ( gs_WebPlayer_Finished ); // advert for user
  end;
end;

procedure TF_WebPlayer.bt_lighterClick(Sender: TObject);
begin
  gs_RootPathForExport:=de_indexdir.Directory+DirectorySeparator;
  if MessageDlg(gs_WebPlayer_Delete_File,fs_RemplaceMsg(gs_WebPlayer_Delete_Files_confirm_ending,
                    [CST_CONVERTED,gs_RootPathForExport,gs_WebPlayer_Delete_Files_confirm_in_each_directory]),
                    mtConfirmation,mbYesNo,0) = mrYes
   then
    p_Unfat(gs_RootPathForExport);
end;

procedure TF_WebPlayer.bt_seeClick(Sender: TObject);
begin
  p_OpenFileOrDirectory(de_indexdir.Directory);
end;

function TF_WebPlayer.fb_DeleteOrNot (  const as_ThemaSource : String; astl_ListFiles : TStrings ):Boolean;
var ls_ToAdd : String;
    lb_DestroyList : boolean;
begin
  Result := False;
  if ch_IndexAll.Checked
   Then ls_ToAdd := gs_WebPlayer_Delete_Files_confirm_in_each_directory
   Else ls_ToAdd := '';
  if astl_ListFiles = nil Then
   Begin
    astl_ListFiles:=fstl_CreateListToDelete ( as_ThemaSource );
    lb_DestroyList := True;
   End
  Else
   lb_DestroyList := False;
  if ch_TXT.Checked Then
   astl_ListFiles.Add(ed_TXTName.Text+'.*'+CST_EXTENSION_TXT+CST_EXTENSION_JS);
  try
    Result := MessageDlg(gs_WebPlayer_Delete_File,fs_RemplaceMsg(gs_WebPlayer_Delete_Files_confirm,
                    [gs_RootPathForExport,ls_ToAdd,astl_ListFiles.Text]),
                    mtConfirmation,mbYesNo,0) = mrYes;
  Finally
    if lb_DestroyList Then
     astl_ListFiles.Destroy;
  end;

end;

function TF_WebPlayer.fstl_CreateListToDelete ( const as_ThemaSource : String ): TStringListUTF8 ;
var lstl_List2 : TStringListUTF8;
Begin
  Result     := TStringListUTF8.Create;
  lstl_List2 := TStringListUTF8.Create;
  try
   fb_FindFiles(Result,gs_Root+CST_SUBDIR_CLASSES,True,False);
   fb_FindFiles(lstl_List2,as_ThemaSource,True,False);
   Result.Insert(0,ed_IndexName.Text+CST_EXTENSION_HTML);
   Result.Insert(0,ed_DownLoadName.Text+CST_EXTENSION_HTML);
   Result.AddStrings(lstl_List2);
  finally
    lstl_List2.Destroy;
  end;

end;

procedure TF_WebPlayer.bt_UnindexClick(Sender: TObject);
var lstl_List : TStringListUTF8;
    ls_ThemaSource : String;
begin
  if gb_Generate
  or fb_genUnGenPrepare(ls_ThemaSource)
   then
    Exit;
  gb_Generate := True;
  lstl_List := fstl_CreateListToDelete ( ls_ThemaSource );
  try
   if fb_DeleteOrNot ( ls_ThemaSource, lstl_List ) Then
     p_Unindex(gs_RootPathForExport,lstl_List);
  finally
    lstl_List.Destroy;
    gb_Generate := False;
  end;
end;

procedure TF_WebPlayer.p_Unindex(const as_directory : String;const astl_List1ToUnindex : TStrings);
var lstl_FilesToVerify : TStringListUTF8;
begin
  lstl_FilesToVerify := TStringListUTF8.Create;
  try
    fb_FindFiles(lstl_FilesToVerify,as_directory,True,True,False);
    while lstl_FilesToVerify.Count>0 do
     try
      if DirectoryExistsUTF8(as_directory+lstl_FilesToVerify[0])
       Then
        p_Unindex(as_directory+lstl_FilesToVerify[0]+DirectorySeparator,astl_List1ToUnindex)
       Else
        Begin
         if (astl_List1ToUnindex.IndexOf(lstl_FilesToVerify[0]) > -1)
         or  (  ch_TXT.Checked and (pos(ed_TXTName.Text+'.',lstl_FilesToVerify[0])=1)
                and (pos ( CST_EXTENSION_TXT+CST_EXTENSION_JS,lstl_FilesToVerify[0])>0))
          Then
            DeleteFileUTF8(as_directory+lstl_FilesToVerify[0])
        end;
     finally
      lstl_FilesToVerify.Delete(0);
     end;
  finally
    lstl_FilesToVerify.Destroy;
  end;
end;

procedure TF_WebPlayer.p_Unfat(const as_directory : String);
var lstl_FilesToVerify : TStringListUTF8;
begin
  lstl_FilesToVerify := TStringListUTF8.Create;
  try
    fb_FindFiles(lstl_FilesToVerify,as_directory,True,True,False);
    while lstl_FilesToVerify.Count>0 do
     try
      if DirectoryExistsUTF8(as_directory+lstl_FilesToVerify[0])
       Then
        p_Unfat(as_directory+lstl_FilesToVerify[0]+DirectorySeparator)
       Else
        Begin
         if pos ( CST_CONVERTED, lstl_FilesToVerify[0] ) > Length(lstl_FilesToVerify[0])- Length(CST_CONVERTED) - 4
          Then
            DeleteFileUTF8(as_directory+lstl_FilesToVerify[0])
        end;
     finally
      lstl_FilesToVerify.Delete(0);
     end;
  finally
    lstl_FilesToVerify.Destroy;
  end;
end;

// procedure TF_WebPlayer.bt_exportClick
// Export ini click event
procedure TF_WebPlayer.bt_exportClick(Sender: TObject);
begin
  f_GetMainMemIniFile(nil,nil,nil,False,CST_WebPlayer);
  OnFormInfoIni.p_ExecuteEcriture(Self);
  if fb_iniWriteFile(FIniFile,True)
   Then
     try
       FileIniCopy.Destination:=fne_Export.FileName;
       FileIniCopy.Source:=FIniFile.FileName;
       FileIniCopy.CopySourceToDestination;
     Except
       On E:Exception do
         ShowMessage(fs_getCorrectString ( gs_WebPlayer_cantSaveFile )+CST_ENDOFLINE+e.Message);
     end;
end;

// procedure TF_WebPlayer.p_AddABase
// add and set a database
procedure TF_WebPlayer.p_AddToCombo ( const acb_combo : TComboBox; const as_Base : String ; const ab_SetIndex :Boolean = True);
var li_i : Integer;
    lb_found : Boolean;
Begin
  lb_found:=False;
  for li_i := 0 to acb_combo.Items.Count - 1 do
    if acb_combo.Items [ li_i ] = as_Base Then
      Begin
        lb_found:=True;
        if ab_SetIndex Then
          acb_combo.ItemIndex:=li_i;
        Break;
      end;
  if not lb_found  then
    Begin
      acb_combo.Items.Add(as_Base);
      if ab_SetIndex Then
        acb_combo.ItemIndex:=acb_combo.Items.Count-1;
    end;
End;

// procedure TF_WebPlayer.p_IncProgress
// increments specialized progress bar
procedure TF_WebPlayer.p_IncProgress;
begin
  with pb_Progress do
    Position := Position + 1; // growing
  Application.ProcessMessages;
end;


procedure p_saveFile ( const astl_HTML : TStrings; const as_Phase, as_filePath : String );
Begin
  p_SaveStrings(astl_HTML,as_filePath,as_Phase + #13#10 + #13#10 + fs_getCorrectString ( gs_WebPlayer_cantCreateHere ) + as_filePath );
End;

// procedure TF_WebPlayer.p_genHtmlHome
// Default HTML page
procedure TF_WebPlayer.p_genHtmlHome ( const as_directory, as_subdirForward, as_artist, as_backDirText : String;
                                       const ab_TextOneLanguage, ab_Root : Boolean );
var
  lstl_Temp1,
  lstl_HTMLHome,lstl_HTMLBody,lstl_HTMLDownloads,
  lstl_DirList,lstl_DirLine,lstl_ListDirAudio,
  lstl_downloadsAfter, lstl_processes : TStringListUTF8;
  ls_destination,ls_htmlpath: string;
  ls_Images,ls_BackDirText: string;
  li_Count, li_PathToDelete: integer;
  lb_first, lb_foundaudio, lb_TextOneLanguage, lb_downloadReally : boolean;
  procedure p_addRoot;
  var ls_IndexDir, ls_subdir : String ;
  Begin
    // load html file of button
    p_LoadStringList(lstl_HTMLDownloads,CST_INDEX_BUTTON+CST_EXTENSION_HTML);
    ls_IndexDir := copy ( as_directory, 1, Length(as_directory) - 1 );
    ls_subdir := '';
    repeat    // back to previous dir
      AppendStr ( ls_subdir, '../' );
      ls_IndexDir := ExtractSubDir ( ls_IndexDir );
    until (pos ( DirectorySeparator, ls_IndexDir ) = 0) or FileExistsUTF8(ls_IndexDir+DirectorySeparator+ed_IndexName.Text+CST_EXTENSION_HTML);
    //create button
    p_ReplaceLanguageString(lstl_HTMLDownloads,'Link',ls_subdir+ed_IndexName.Text+CST_EXTENSION_HTML,[rfReplaceAll]);
    p_ReplaceLanguageString(lstl_HTMLDownloads,'Caption',gs_WebPlayer_Back,[rfReplaceAll]);
  End;
begin
  p_Setcomments (( gs_WebPlayer_Home )); // advert for user
  lstl_HTMLHome     := TStringListUTF8.Create;
  lstl_HTMLBody     := TStringListUTF8.Create;
  lstl_ListDirAudio := TStringListUTF8.Create;
  lstl_processes    := TStringListUTF8.Create;
  lstl_HTMLDownloads := TStringListUTF8.Create;
  lstl_Temp1         := TStringListUTF8.Create;
  p_LoadStringList ( lstl_HTMLBody, CST_INDEX_BUTTON+CST_EXTENSION_HTML );
  p_ReplaceLanguageString(lstl_HTMLBody,'Link',ed_IndexName.Text+CST_EXTENSION_HTML,[rfReplaceAll]);
  p_ReplaceLanguageString(lstl_HTMLBody,'Caption',gs_WebPlayer_Back,[rfReplaceAll]);
  lstl_HTMLDownloads.AddStrings(lstl_HTMLBody);
  lstl_HTMLBody.clear;
  lb_downloadReally  := False;
  lb_TextOneLanguage := False;
  if ab_Root
  and ch_convert.Checked Then
   lstl_processes := TStringListUTF8.Create;
  // every found music can be downloaded
  if ch_downloads.Checked
    Then lstl_downloadsAfter := TStringListUTF8.Create;
  try
    p_ClearKeyWords;
    lb_first := True;
    li_PathToDelete := Length(as_directory)+1;
    try
      lb_foundaudio := False;
      ls_BackDirText:='';
      p_AddFiles ( as_directory, as_artist, as_subdirForward, lstl_HTMLHome, li_PathToDelete,1,lstl_ListDirAudio,lstl_Temp1,lstl_HTMLDownloads,lstl_downloadsAfter, lstl_processes, lb_first, lb_foundaudio, ab_Root, lb_downloadReally, lb_TextOneLanguage, ls_BackDirText );
    finally
      lstl_Temp1.Free;
    end;
    p_LoadStringList ( lstl_HTMLBody, CST_INDEX_BODY+CST_EXTENSION_HTML );
   if ch_downloads.Checked or lb_downloadReally Then
    Begin  // download and back link
      if ch_downloads.Checked
        Then lstl_HTMLDownloads.AddStrings(lstl_downloadsAfter);
      p_CreateAHtmlFile(lstl_HTMLDownloads, CST_DOWNLOAD, me_Description.Lines.Text,
         ExtractDirName(as_directory),
         as_artist + ' - ' + gs_WebPlayer_Downloads , gs_WebPlayer_Downloads, '', '');
      p_ReplaceLanguageString(lstl_HTMLDownloads,'SubDir',as_subdirForward,[rfReplaceAll]);
      p_saveFile(lstl_HTMLDownloads,gs_WebPlayer_Phase + gs_WebPlayer_Downloads,as_directory + ed_DownLoadName.Text + CST_EXTENSION_HTML);
      p_LoadStringList ( lstl_HTMLDownloads, CST_INDEX_BUTTON+CST_EXTENSION_HTML );
      p_ReplaceLanguageString(lstl_HTMLDownloads,'Link',ed_DownLoadName.Text+CST_EXTENSION_HTML,[rfReplaceAll]);
      p_ReplaceLanguageString(lstl_HTMLDownloads,'Caption',gs_WebPlayer_Downloads,[rfReplaceAll]);
      //adding download button to index
      p_ReplaceLanguageString(lstl_HTMLBody,'ButtonsToAdd',lstl_HTMLDownloads.Text+#10+'[ButtonsToAdd]',[rfReplaceAll]);
    End;
   //adding
   if as_subdirForward > '' Then
    Begin
     p_addRoot;
     p_ReplaceLanguageString(lstl_HTMLBody,'ButtonsToAdd',lstl_HTMLDownloads.Text+'[ButtonsToAdd]',[rfReplaceAll]);
    end;
    if lstl_ListDirAudio.Count>0 Then
      Begin
       lstl_DirList := TStringListUTF8.Create;
       lstl_DirLine := TStringListUTF8.Create;
        try
          while lstl_ListDirAudio.Count > 0  do
           Begin
            p_LoadStringList(lstl_DirLine,CST_INDEX_DIR+CST_EXTENSION_HTML);
            ls_destination:=lstl_ListDirAudio[0];
            ls_destination:=copy ( ls_destination, li_PathToDelete, Length(ls_destination)-li_PathToDelete+1 );
            {$IFDEF WINDOWS}
            p_ReplaceLanguageString(lstl_DirLine,'Directory','./'+StringReplace(StringReplace(ls_destination+DirectorySeparator+ed_IndexName.Text+CST_EXTENSION_HTML,DirectorySeparator,'/',[rfReplaceAll]),'"','\"',[rfReplaceAll]),[rfReplaceAll]);
            {$ELSE}
            p_ReplaceLanguageString(lstl_DirLine,'Directory','./'+StringReplace(ls_destination+DirectorySeparator+ed_IndexName.Text+CST_EXTENSION_HTML,'"','\"',[rfReplaceAll]),[rfReplaceAll]);
            {$ENDIF}
            p_ReplaceLanguageString(lstl_DirLine,'Caption',StringReplace(ls_destination,DirectorySeparator,' - ',[rfReplaceAll]),[rfReplaceAll]);
            lstl_DirList.AddStrings(lstl_DirLine);
            lstl_ListDirAudio.Delete(0);
           end;

          p_ReplaceLanguageString(lstl_HTMLBody,'DirList','<ul>'+StringReplace(StringReplace(lstl_DirList.Text,'"','\"',[rfReplaceAll]),#10,'\n',[rfReplaceAll])+'</ul>',[rfReplaceAll]);
        finally
          lstl_DirList.Free;
          lstl_DirLine.Free;
        end;
        p_LoadStringList ( lstl_HTMLDownloads, CST_INDEX_BUTTON+CST_EXTENSION_HTML );
        p_ReplaceLanguageString(lstl_HTMLDownloads,'Link','#" onclick="DirectoriesShowHide();',[rfReplaceAll]);
        p_ReplaceLanguageString(lstl_HTMLDownloads,'Caption','...',[rfReplaceAll]);
        p_ReplaceLanguageString(lstl_HTMLBody,'ButtonsToAdd',lstl_HTMLDownloads.Text,[rfReplaceAll]);
      end
     else
      Begin
        p_ReplaceLanguageString(lstl_HTMLBody,'DirList','',[rfReplaceAll]);
        p_ReplaceLanguageString(lstl_HTMLBody,'ButtonsToAdd','',[rfReplaceAll]);
      end;
    if ch_txt.checked
     Then
      Begin
       if as_directory=''
        Then ls_htmlpath:='/'
        else ls_htmlpath:=copy(as_directory,Length(AppendPathDelim(de_indexdir.Directory)),Length(as_directory));
       if ab_TextOneLanguage Then   // unique language text file
         p_ReplaceLanguageString(lstl_HTMLBody,CST_DESCRIBE,CST_ENDOFLINE
           +'<script type="text/javascript">includeJS( "'+as_backDirText+ed_txtName.Text+CST_EXTENSION_TXT+CST_EXTENSION_JS+'");'+CST_ENDOFLINE
           +'</script>'+CST_ENDOFLINE+fs_html_Lines(me_Description.Text ))
        else
         p_ReplaceLanguageString(lstl_HTMLBody,CST_DESCRIBE,CST_ENDOFLINE
           +'<script type="text/javascript">includeJS( "'+as_backDirText+ed_txtName.Text+'."+language+"'+CST_EXTENSION_TXT+CST_EXTENSION_JS+'");'+CST_ENDOFLINE
           +'</script>'+CST_ENDOFLINE+fs_html_Lines(me_Description.Text ))
      end
      else p_ReplaceLanguageString(lstl_HTMLBody,CST_DESCRIBE,fs_html_Lines(me_Description.Text ));
    lstl_HTMLHome.AddStrings(lstl_HTMLBody);
    lstl_HTMLBody.Clear;
    p_CreateAHtmlFile(lstl_HTMLHome, CST_INDEX, me_Description.Text,
      ExtractDirName(as_directory),
      as_artist , gs_WebPlayer_Home, '', '');
    p_ReplaceLanguageString(lstl_HTMLHome,'SubDir',as_subdirForward,[rfReplaceAll]);
    // saving the page
    p_saveFile(lstl_HTMLHome,gs_WebPlayer_Phase + ' - ' + gs_WebPlayer_Home,as_directory + ed_IndexName.Text + CST_EXTENSION_HTML);
    if ab_Root
    and ch_convert.Checked Then
      if (lstl_processes.Count > 0) Then
       Begin
        p_saveFile(lstl_processes,gs_WebPlayer_Phase + ' - ' + gs_WebPlayer_Convert,as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT);
        if MessageDlg(gs_WebPlayer_Convert,fs_RemplaceMsg(gs_WebPlayer_Script_will_be_executed,[as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT]),
                      mtConfirmation,mbYesNo,0) = mrYes Then
         Begin
          p_Setcomments(fs_RemplaceMsg(gs_WebPlayer_Convert,[CST_EXTENSION_MP3]));
          {$IFDEF WINDOWS}
          fs_ExecuteProcess('"'+StringReplace(as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT,'"','\"',[rfReplaceAll])+'"','',False)
          {$ELSE}
          fs_ExecuteProcess('sh','"'+StringReplace(as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT,'"','\"',[rfReplaceAll])+'"',False)
          {$ENDIF}
         End;
       end
       else if FileExistsUTF8(as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT) then
       if MessageDlg(gs_WebPlayer_Delete_File,fs_RemplaceMsg(gs_WebPlayer_Delete_File_confirm,[as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT]),mtConfirmation,mbYesNo,0) = mrYes
        Then
         DeleteFileUTF8(as_directory + CST_SCRIPT_FILE + CST_EXTENSION_SCRIPT);
  finally
    lstl_HTMLHome    .Destroy;
    lstl_HTMLBody    .Destroy;
    lstl_ListDirAudio.Destroy;
    if ch_downloads.Checked
      Then lstl_downloadsAfter.Destroy;
    lstl_HTMLDownloads.Destroy;
    if ab_Root
    and ch_convert.Checked Then
     lstl_processes.Destroy;
  end;
end;

// procedure TF_WebPlayer.p_Setcomments
// infos for user
procedure TF_WebPlayer.p_Setcomments (const as_Comment : String);
Begin
  if as_Comment = ''
    Then lb_Comments.Caption:= ''
    Else lb_Comments.Caption:= fs_getCorrectString ( gs_WebPlayer_Generating ) + as_Comment;

end;

// procedure TF_WebPlayer.p_CreateAHtmlFile
// Creating a HTML page from parameters
procedure TF_WebPlayer.p_CreateAHtmlFile(const astl_Destination: TStrings;
  const as_BeginingFile,
  as_Describe, as_file, as_Title, as_LittleTitle, as_LongTitle: string;
  const as_Subdir: string = '';
  const as_ExtFile: string =
  CST_EXTENSION_HTML;
  const as_BeforeHTML: string = ''; const astl_Body : TStrings = nil );
var ls_title : String;
begin
  if not assigned ( gstl_HeadKeyWords ) Then
    Abort;       // can quit while creating
  if as_Title = ''
   Then ls_title := 'Lazarus Web Player'
   else ls_title := 'Lazarus Web Player - '+as_Title;
  p_CreateHTMLFile(nil, astl_Destination, '',
     as_Describe,
     gstl_HeadKeyWords.Text, ls_Title,
    as_LongTitle, as_BeginingFile + '1' + as_ExtFile, as_BeginingFile + '2' +
    as_ExtFile, as_BeginingFile + '3' + as_ExtFile, as_BeginingFile +
    '4' + as_ExtFile, as_Subdir, as_BeforeHTML, gs_WebPlayer_Language, astl_Body, False );
end;


// procedure TF_WebPlayer.DoAfterInit
// initing components and ini
procedure TF_WebPlayer.DoAfterInit( const ab_Ini : Boolean = True );
begin
  {$IFNDEF FPC}
  de_indexdir.InitialDir:=GetWindir(CSIDL_DESKTOPDIRECTORY);
  {$ENDIF}

  // Reading ini
  if not ab_Ini Then
    Exit;
  f_GetMainMemIniFile(nil,nil,nil,False,CST_WebPlayer);
  OnFormInfoIni.p_ExecuteLecture(Self);
end;

// procedure TF_WebPlayer.FormCreate
// initializing software and form
procedure TF_WebPlayer.FormCreate(Sender: TObject);
var ls_Path : String ;
Begin
  gs_Root:=ExtractFileDir(Application.ExeName)+DirectorySeparator;
  AppendStr(gs_Root,CST_WebPlayer+DirectorySeparator);//pas dans plugins pour l'exe

  ls_Path:=GetAppConfigDir(False) + DirectorySeparator + CST_SUBDIR_THEMES;
  try
    cb_Themes.Items.Clear;
    fb_FindFiles(cb_Themes.Items, gs_Root + CST_SUBDIR_THEMES, False);
    if not DirectoryExistsUTF8(ls_Path)
     Then
      fb_CreateDirectoryStructure(ls_Path);
    fb_FindFiles(cb_Themes.Items, ls_Path, False);

  except

  end;

  try
    cb_Files.Items.Clear;
    fb_FindFiles(cb_Files.Items, gs_Root + CST_SUBDIR_FILES, False);
  except

  end;

  // ici mettre la taille initiale car avec les skins, les fenetres se resize
  Width := 640;
  Height := 400;
  Caption := fs_getCorrectString(CST_WebPlayer_WithLicense+' : '+gs_WebPlayer_FORM_CAPTION);
  OnFormInfoIni.p_ExecuteLecture(Self);
end;



{$IFNDEF FPC}
initialization
  p_ConcatVersion ( gVer_WebPlayer );
{$ENDIF}
end.

