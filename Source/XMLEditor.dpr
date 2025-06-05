program XMLEditor;

uses
  Vcl.Forms,
  XML.MainForm in 'XML.MainForm.pas' {MainForm},
  XML.MainViewController in 'XML.MainViewController.pas',
  XML.MainModel in 'XML.MainModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
