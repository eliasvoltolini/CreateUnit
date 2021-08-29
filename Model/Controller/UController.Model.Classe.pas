unit UController.Model.Classe;

interface

uses
  System.SysUtils, UInterface.Model.Interfaces, UEntidade.Model.Classe;

type
  TControllerClasse = class
  public
    constructor Create;
    destructor Destroy; override;

    class function Classe: iClasse;
  end;

implementation

{ TControllerClasse }

constructor TControllerClasse.Create;
begin

end;

destructor TControllerClasse.Destroy;
begin

  inherited;
end;

class function TControllerClasse.Classe: iClasse;
begin
  Result := TClasse.New;
end;

end.
