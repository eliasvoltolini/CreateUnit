unit UInterface.Model.Interfaces;

interface

uses
  System.Classes;

type
  iClasse = interface
    ['{CC721662-A264-4152-B561-255AB70E70C5}']
    function AddNome(Nome: String): iClasse;
    function AddAtributo(Nome, Tipo: String): iClasse;

    function Importar(SQL: TStrings): iClasse;
    function Exportar(): Boolean;
  end;

implementation

end.
