program CreateUnit;

uses
  Vcl.Forms,
  UFrmPrincipal in 'View\UFrmPrincipal.pas' {FrmPrincipal},
  UInterface.Model.Interfaces in 'Model\Interface\UInterface.Model.Interfaces.pas',
  UEntidade.Model.Classe in 'Model\Entidade\UEntidade.Model.Classe.pas',
  UController.Model.Classe in 'Model\Controller\UController.Model.Classe.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
