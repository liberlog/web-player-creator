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
  functions_html, JvXPCheckCtrls, Spin, U_OnFormInfoIni,
  U_ExtImage, u_buttons_appli, IBSQL, U_ExtFileCopy, u_traducefile,
  JvXPButtons, IniFiles, TFlatEditUnit,TFlatGaugeUnit,
  u_extabscopy, IBCustomDataSet, Grids, FileCtrl,
  ImagingComponents, JvXPCore, TFlatComboBoxUnit, TFlatMemoUnit,
  u_buttons_defs, u_extsearchedit, TFlatCheckBoxUnit;

{$IFNDEF FPC}
const
  gVer_WebPlayer : T_Version = ( Component : 'Application WebPlayerCreator' ;
                                             FileUnit : 'U_WebPlayer' ;
                                             Owner : 'Matthieu Giroux' ;
                                             Comment : 'Créateur de player HTNL statique.' ;
                                             BugsStory : '1.0.1.0 : File sorting.' + 1#13#10
                                                       + '1.0.0.0 : Jquery playlist version.' + 1#13#10
                                                       + '0.9.9.0 : First published version'  ;
                                             UnitType : CST_TYPE_UNITE_APPLI ;
                                             Major : 1 ; Minor : 0 ; Release : 1 ; Build : 0 );
{$ENDIF}

const CST_WebPlayer = 'PlayerCreator' ;
      CST_WebPlayer_WithLicense = CST_WebPlayer + ' GPL ';
      CST_AUTHOR = 'Matthieu GIROUX';
      CST_INDEX = 'index';
      CST_INDEX_FILE = CST_INDEX+'file';
      CST_SUBDIR_EXPORT = 'List'+DirectorySeparator;
      CST_SUBDIR_FILES = 'Files' + DirectorySeparator;
      CST_SUBDIR_CLASSES = 'Classes' + DirectorySeparator;
      CST_SUBDIR_THEMES = 'Themes' + DirectorySeparator;
      CST_EXTENSION_PNG = 'png';
      CST_EXTENSION_OGG = 'ogg';
      CST_EXTENSION_MP3 = 'mp3';
      CST_EXTENSION_WMA = 'wma';

type

  { TF_WebPlayer }

  TF_WebPlayer = class(TForm)
    bt_gen: TFWExport;
    cb_Files: TComboBox;
    cb_Themes: TComboBox;
    ch_OGG: TJvXPCheckbox;
    ch_WMA: TJvXPCheckbox;
    de_indexdir: TDirectoryEdit;
    ed_Author: TEdit;
    ed_IndexName: TEdit;
    FileCopy: TExtFileCopy;
    ds_Individu: TDatasource;
    FileIniCopy: TExtFileCopy;
    fne_export: TFileNameEdit;
    fne_import: TFileNameEdit;
    FWClose1: TFWClose;
    FWEraseImage: TFWErase;
    bt_export: TFWExport;
    bt_see: TFWSearch;
    IBQ_Individu: TIBQuery;
    ch_MP3: TJvXPCheckbox;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label44: TLabel;
    Label6: TLabel;
    lb_Comments: TLabel;
    lb_Images: TLabel;
    L_thema: TLabel;
    me_Bottom: TMemo;
    me_Description: TMemo;
    OnFormInfoIni: TOnFormInfoIni;
    OpenDialog: TOpenDialog;
    pa_options: TPanel;
    pb_ProgressInd: TFlatGauge;
    spSkinPanel1: TPanel;
    procedure bt_exportClick(Sender: TObject);
    procedure bt_genClick(Sender: TObject);
    procedure bt_seeClick(Sender: TObject);
    procedure fne_ExportAcceptFileName(Sender: TObject; var Value: String);
    procedure fne_importAcceptFileName(Sender: TObject; var Value: String);
    procedure fne_importChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
    procedure DoAfterInit(const ab_Ini: Boolean=True);
    procedure p_AddFiles ( const as_Source, as_artist : String ; var astl_files : TStringList; const ai_eraseBegin : Integer; var astl_temp1 : TStringList ; var ab_first : Boolean );
    procedure p_AddToCombo(const acb_combo: TComboBox; const as_Base: String;
      const ab_SetIndex: Boolean=True);
    procedure p_CreateAHtmlFile(const astl_Destination: TStrings;
      const as_BeginingFile, as_Describe, as_Title, as_LittleTitle, as_LongTitle: string;
      const as_Subdir: string = '';
      const as_ExtFile: string = CST_EXTENSION_HTML;
      const as_BeforeHTML: string = ''; const astl_Body : TStringList = nil );
    procedure p_genHtmlHome;
    procedure p_IncProgressInd;
    procedure p_Setcomments(const as_Comment: String);
  public
    { Déclarations publiques }
  end;

var
  F_WebPlayer: TF_WebPlayer;
  gb_Generate : boolean = False;
  gs_RootPathForExport,
  gs_Root : String ;


implementation

uses  fonctions_init,
  functions_html_tree,
{$IFNDEF FPC}
  webplayer_strings_delphi,
{$ELSE}
  webplayer_strings, strutils,
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

procedure TF_WebPlayer.p_AddFiles ( const as_Source, as_artist : String ; var astl_files : TStringList; const ai_eraseBegin : Integer; var astl_temp1 : TStringList; var ab_first : Boolean );
var li_Error, li_EndExt : Integer ;
    ls_Source ,
    ls_FileName ,
    ls_FileNameLower ,
    ls_destination  : String;
    lsr_AttrSource      : Tsearchrec;
    lb_first : Boolean;
    lstl_temp2 : TStringList ;
    procedure p_addFile( const ab_add : Boolean; const as_Ext : String );
    var ls_FileWithoutExt : String;
        li_pos : Integer;
    begin
      li_pos := PosEx ( '.'+as_Ext, ls_FileNameLower, li_EndExt );
      if ab_add and ( li_pos > 0 )
       then
         Begin
           p_LoadStringList ( astl_temp1, gs_Root, CST_INDEX_FILE+CST_EXTENSION_HTML );
           ls_FileWithoutExt := copy ( ls_Source, 1, PosEx ( '.'+as_Ext, ls_Source, length ( ls_Source ) - 4 ) - 1 );
           if FileExistsUTF8(ls_FileWithoutExt+'.'+CST_EXTENSION_PNG)
            Then p_ReplaceLanguageString(astl_temp1,'SourcePoster',copy ( ls_Source, ai_eraseBegin, PosEx ( '.'+as_Ext, ls_Source, length ( ls_Source ) - 4 ) - ai_eraseBegin )+'.'+CST_EXTENSION_PNG,[rfReplaceAll])
            else if FileExistsUTF8(ls_FileWithoutExt+'.'+CST_EXTENSION_JPEG)
             Then p_ReplaceLanguageString(astl_temp1,'SourcePoster',copy ( ls_Source, ai_eraseBegin, PosEx ( '.'+as_Ext, ls_Source, length ( ls_Source ) - 4 ) - ai_eraseBegin )+'.'+CST_EXTENSION_JPEG,[rfReplaceAll])
             Else p_ReplaceLanguageString(astl_temp1,'SourcePoster','',[rfReplaceAll]);
           if FileExistsUTF8(ls_FileWithoutExt+'.'+CST_EXTENSION_OGG)
            Then p_ReplaceLanguageString(astl_temp1,'SourceOGG',copy ( ls_Source, ai_eraseBegin, PosEx ( '.'+as_Ext, ls_Source, length ( ls_Source ) - 4 ) - ai_eraseBegin )+'.'+CST_EXTENSION_OGG,[rfReplaceAll])
            Else p_ReplaceLanguageString(astl_temp1,'SourceOGG','',[rfReplaceAll]);
           if FileExistsUTF8(ls_FileWithoutExt+'.'+CST_EXTENSION_MP3)
            Then p_ReplaceLanguageString(astl_temp1,'SourceMP3',copy ( ls_Source, ai_eraseBegin, PosEx ( '.'+as_Ext, ls_Source, length ( ls_Source ) - 4 ) - ai_eraseBegin )+'.'+CST_EXTENSION_MP3,[rfReplaceAll])
            Else p_ReplaceLanguageString(astl_temp1,'SourceMP3','',[rfReplaceAll]);
           if FileExistsUTF8(ls_FileWithoutExt+'.'+CST_EXTENSION_WMA)
            Then p_ReplaceLanguageString(astl_temp1,'SourceWMA',copy ( ls_Source, ai_eraseBegin, PosEx ( '.'+as_Ext, ls_Source, length ( ls_Source ) - 4 ) - ai_eraseBegin )+'.'+CST_EXTENSION_WMA,[rfReplaceAll])
            Else p_ReplaceLanguageString(astl_temp1,'SourceWMA','',[rfReplaceAll]);
           p_ReplaceLanguageString(astl_temp1,'SourceArtist',as_artist,[rfReplaceAll]);
           p_ReplaceLanguageString(astl_temp1,'SourceTitle',copy(ls_FileName,1,li_pos-1),[rfReplaceAll]);
           p_ReplaceLanguageString(astl_temp1,'Source',copy(ls_Source,ai_eraseBegin,length(ls_Source)-ai_eraseBegin+1),[rfReplaceAll]);
           p_ReplaceLanguageString(astl_temp1,'Type','audio/'+as_Ext,[rfReplaceAll]);
           if not ab_first Then
             astl_files.Add(',');
           astl_files.AddStrings(astl_temp1);
           ab_first:=False;
         end;

    end;

begin
  astl_temp1.Clear ;
  lstl_temp2 := TStringList.Create;
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
            if as_artist > '' Then
              ls_FileName := as_artist + ' - ' + ls_FileName;
            p_AddFiles ( ls_Source, ls_FileName, astl_files, ai_eraseBegin, astl_temp1, ab_first );
          End
        Else
          if FileExistsUTF8 ( ls_Source ) Then
            Begin
               ls_FileNameLower := LowerCase(ls_FileName);
               li_EndExt := Length(ls_FileName)-4;
               p_addFile( ch_OGG.Checked, CST_EXTENSION_OGG );
               p_addFile( ch_MP3.Checked, CST_EXTENSION_MP3 );
               p_addFile( ch_WMA.Checked, CST_EXTENSION_WMA );
            End;
        lstl_temp2.Delete(0);
      End ;
    end;
  finally
    lstl_temp2.Free;
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

// procedure TF_WebPlayer.bt_genClick
// Main Web Site Generation
procedure TF_WebPlayer.bt_genClick(Sender: TObject);
begin
  if gb_Generate then
    Exit;
  //  verifying
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
  if FileExistsUTF8(de_indexdir.Directory+DirectorySeparator+ed_IndexName.Text+CST_EXTENSION_HTML)
  and ( MessageDlg(gs_WebPlayer_Delete_File,fs_RemplaceMsg(gs_WebPlayer_Delete_File_confirm,
                   [de_indexdir.Directory+DirectorySeparator+ed_IndexName.Text+CST_EXTENSION_HTML]),
                   mtConfirmation,mbYesNo,0) = mrNo) Then
    Exit;
  if (cb_Themes.ItemIndex = -1) then
    cb_Themes.ItemIndex := 0;
  if (cb_Files.ItemIndex = -1) then
    cb_Files.ItemIndex := 0;
  gs_RootPathForExport := de_indexdir.{$IFDEF FPC}Directory{$ELSE}Text{$ENDIF} + DirectorySeparator;
  with FileCopy do
   try
    FileOptions:=FileOptions-[cpDestinationIsFile];
    if DirectoryExistsUTF8(GetAppConfigDir(False)+DirectorySeparator + CST_SUBDIR_THEMES +DirectorySeparator+cb_Themes.Text)
     Then Source := GetAppConfigDir(False)+DirectorySeparator + CST_SUBDIR_THEMES +DirectorySeparator+cb_Themes.Text
     Else Source := gs_Root + CST_SUBDIR_THEMES+cb_Themes.Text;
    Destination := gs_RootPathForExport;
    CopySourceToDestination;
    Source := gs_Root + CST_SUBDIR_CLASSES;
    CopySourceToDestination;
  finally
    FileOptions:=FileOptions+[cpDestinationIsFile];
   end;
  gs_html_source_file := CST_SUBDIR_FILES + DirectorySeparator + cb_files.Items[cb_files.ItemIndex]+DirectorySeparator;
  // going to work for a time : freezing options to protect work and options
  pa_options.Enabled:=False;
  try // starting work
    p_CreateKeyWords;
    gb_Generate := True;
    pb_ProgressInd.Progress := 0;
    p_genHtmlHome;
  finally
    pa_options.Enabled:=True;
    gb_Generate := False;
    p_Setcomments ( gs_WebPlayer_Finished ); // advert for user
  end;
end;

procedure TF_WebPlayer.bt_seeClick(Sender: TObject);
begin
  p_OpenFileOrDirectory(de_indexdir.Directory);
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

// procedure TF_WebPlayer.p_IncProgressInd
// increments specialized progress bar
procedure TF_WebPlayer.p_IncProgressInd;
begin
  pb_ProgressInd.Progress := pb_ProgressInd.Progress + 1; // growing
  Application.ProcessMessages;
end;


// procedure TF_WebPlayer.p_genHtmlHome
// Default HTML page
procedure TF_WebPlayer.p_genHtmlHome;
var
  lstl_Temp1,
  lstl_HTMLHome: TStringList;
  ls_destination: string;
  ls_Images: string;
  li_Count: integer;
  lb_first : boolean;

begin
  p_Setcomments (( gs_WebPlayer_Home )); // advert for user
  lstl_HTMLHome := TStringList.Create;
  try
    p_ClearKeyWords;
    pb_ProgressInd.Progress := 0; // initing not needed user value
    lstl_Temp1:=TStringList.Create;
    lb_first := True;
    try
      p_AddFiles ( de_indexdir.Directory, '', lstl_HTMLHome, Length(de_indexdir.Directory)+2,lstl_Temp1, lb_first);
    finally
      lstl_Temp1.Free;
    end;
    p_CreateAHtmlFile(lstl_HTMLHome, CST_INDEX, me_Description.Lines.Text,
      gs_WebPlayer_Home , gs_WebPlayer_Home, '', '');
    // saving the page
    ls_destination := gs_RootPathForExport + ed_IndexName.Text +
      CST_EXTENSION_HTML;
    try
      lstl_HTMLHome.SaveToFile(ls_destination);
    except
      On E: Exception do
      begin
        ShowMessage(gs_WebPlayer_Phase + gs_WebPlayer_Home + #13#10 + #13#10 + fs_getCorrectString ( gs_WebPlayer_cantCreateHere ) + ls_destination + CST_ENDOFLINE + E.Message);
        Abort;
      end;
    end;
  finally
    lstl_HTMLHome.Free;
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
  as_Describe, as_Title, as_LittleTitle, as_LongTitle: string;
  const as_Subdir: string = '';
  const as_ExtFile: string =
  CST_EXTENSION_HTML;
  const as_BeforeHTML: string = ''; const astl_Body : TStringList = nil );
begin
  if not assigned ( gstl_HeadKeyWords ) Then
    Abort;       // can quit while creating
  p_CreateHTMLFile(nil, astl_Destination, '',
    gs_Root, as_Describe, gstl_HeadKeyWords.Text, 'Lazarus Web Player - ' +
    as_Title, as_LongTitle, as_BeginingFile + '1' + as_ExtFile, as_BeginingFile + '2' +
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

