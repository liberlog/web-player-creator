program WebPlayerCreator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, u_webplayer, webplayer_strings, lazextbuttons, lazextcomponents,
  lazextcopy, lazextcomponentsimg, lazextinit, ibexpress, JvXPBarLaz, exthtml,
  lazflatstyle;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TF_WebPlayer,F_WebPlayer);
  Application.Run;
end.

