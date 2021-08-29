unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Winapi.ShellAPI,
  UController.Model.Classe;

type
  TFrmPrincipal = class(TForm)
    pnBotoes    : TPanel;
    mmSQL       : TMemo;
    btnExecutar : TSpeedButton;
    btnLimpar   : TSpeedButton;
    btnAbrir    : TSpeedButton;
    btnSair     : TSpeedButton;
    procedure btnSairClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnExecutarClick(Sender: TObject);
    procedure btnAbrirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.btnExecutarClick(Sender: TObject);
begin
  with TControllerClasse.Classe do
  begin
    if Importar(mmSQL.Lines).Exportar() then
    begin
      ShowMessage('Arquivo gerado com sucesso!');
      btnLimpar.Click;
    end;
  end;
end;

procedure TFrmPrincipal.btnAbrirClick(Sender: TObject);
begin
  try
    ShellExecute(Application.Handle, PChar('open'), PChar('explorer.exe'),
                 PChar(ExtractFilePath(Application.ExeName) + 'Entidade\'),
                 nil, SW_NORMAL);
  except
  end;
end;

procedure TFrmPrincipal.btnLimparClick(Sender: TObject);
begin
  mmSQL.Clear;
  mmSQL.SetFocus;
end;

procedure TFrmPrincipal.btnSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.
