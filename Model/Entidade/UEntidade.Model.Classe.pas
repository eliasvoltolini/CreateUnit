unit UEntidade.Model.Classe;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, UInterface.Model.Interfaces;

type
  TClasse = class(TInterfacedObject, iClasse)
  private
    FDir     : String;
    FNome    : String;
    FCampos  : TStringList;
    FTipos   : TStringList;
    FArquivo : TStringList;

    function RetornaTipo(Texto: String): String;

    /// <summary>Nome da Entidade</summary>
    function AddNome(Nome: String): iClasse;
    /// <summary>Atributos da Entidade</summary>
    function AddAtributo(Nome, Tipo: String): iClasse;
    /// <summary>Carregar SQL nos Campos</summary>
    function Importar(SQL: TStrings): iClasse;
    /// <summary>Gerar arquivo .pas</summary>
    function Exportar(): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    class function New: iClasse;
  end;

implementation

{ TClasse }

const
  CNT_ARQUIVO        = 'U%s.pas';
  CNT_UNIT           = 'Unit U%s;' + #13#10;
  CNT_INTERFACE      = 'interface' + #13#10;
  CNT_TYPE           = 'type';
  CNT_CLASS          = '  T%s = class';
  CNT_PRIVATE        = '  private';
  CNT_ATRIBUTO       = '    F%s : %s;';
  CNT_PUBLIC         = #13#10 + '  public';
  CNT_PROPERTY       = '    property %s : %s read F%s write F%s;';
  CNT_END_TYPE       = #13#10 + '  end;' + #13#10;
  CNT_IMPLEMENTATION = 'implementation' + #13#10;
  CNT_END_UNIT       = 'end.';

constructor TClasse.Create;
begin
  FCampos  := TStringList.Create;
  FTipos   := TStringList.Create;
  FArquivo := TStringList.Create;
  FDir     := ExtractFilePath(Application.ExeName) + 'Entidade\';

  if not DirectoryExists(FDir) then
    CreateDir(FDir);
end;

destructor TClasse.Destroy;
begin
  FArquivo.Free;
  FCampos.Free;
  FTipos.Free;
  inherited;
end;

class function TClasse.New: iClasse;
begin
  Result := Self.Create;
end;

function TClasse.AddNome(Nome: String): iClasse;
begin
  Result := Self;
  Nome   := UpperCase(Nome[1]) + LowerCase(Copy(Nome, 2, Length(Nome)));
  FNome  := Nome;
end;

function TClasse.AddAtributo(Nome, Tipo: String): iClasse;
begin
  Result := Self;
  Nome   := UpperCase(Nome[1]) + LowerCase(Copy(Nome, 2, Length(Nome)));
  Tipo   := UpperCase(Tipo[1]) + LowerCase(Copy(Tipo, 2, Length(Tipo)));

  FCampos.Add(Nome);
  FTipos.Add(Tipo);
end;

function TClasse.Importar(SQL: TStrings): iClasse;
var
  sNome   : String;
  sCampo  : String;
  sTipo   : String;
  i, iPos : Integer;
begin
  Result := Self;

  if Pos('CREATE TABLE', SQL.Text) = 0 then
    raise Exception.Create('Erro na estrutura SQL');

  try
    for i := 0 to Pred(SQL.Count) do
    begin
      if (Pos('PRIMARY KEY', SQL.Strings[i]) > 0) Or
         (Pos('UNIQUE KEY', SQL.Strings[i])  > 0) Or
         (Pos('CONSTRAINT', SQL.Strings[i])  > 0) Or
         (Pos('ENGINE', SQL.Strings[i])      > 0) Or
         (Pos('KEY', SQL.Strings[i])         > 0) then Break;

      iPos := Pos('CREATE TABLE', SQL.Strings[i]);
      if iPos > 0 then
      begin
        iPos  := iPos + 14;

        sNome := Copy(SQL.Strings[i], iPos, Length(SQL.Strings[i]));
        sNome := Trim(StringReplace(sNome, '` (', '', [rfReplaceAll]));

        AddNome(sNome);
      end;

      iPos := Pos('  `', SQL.Strings[i]);
      if iPos > 0 then
      begin
        iPos   := 4;

        sCampo := Trim(Copy(SQL.Strings[i], iPos, Length(SQL.Strings[i])));
        sCampo := Trim(Copy(sCampo, 1, Pos('`', sCampo)));
        sCampo := Trim(StringReplace(sCampo, '`', '', [rfReplaceAll]));
        sTipo  := RetornaTipo(SQL.Strings[i]);

        AddAtributo(sCampo, sTipo);
      end;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create('TClasse.Importar=' + E.Message);
    end;
  end;
end;

function TClasse.Exportar: Boolean;
var
  sArquivo : String;
  i        : Integer;
begin
  sArquivo := Format(CNT_ARQUIVO, [FNome]);

  if FNome = EmptyStr then
    raise Exception.Create('Erro na estrutura SQL');

  if FileExists(FDir + sArquivo) then
    DeleteFile(FDir + sArquivo);

  try
    with FArquivo do
    begin
      Add( Format(CNT_UNIT, [FNome]) );
      Add( CNT_INTERFACE );
      Add( CNT_TYPE );
      Add( Format(CNT_CLASS, [FNome]) );
      Add( CNT_PRIVATE );

      for i := 0 to Pred(FCampos.Count) do
        Add( Format(CNT_ATRIBUTO, [FCampos.Strings[i], FTipos.Strings[i]]) );

      Add( CNT_PUBLIC );

      for i := 0 to Pred(FCampos.Count) do
        Add( Format(CNT_PROPERTY, [FCampos.Strings[i], FTipos.Strings[i],
                                   FCampos.Strings[i], FCampos.Strings[i]]) );

      Add( CNT_END_TYPE );
      Add( CNT_IMPLEMENTATION );
      Add( CNT_END_UNIT );
    end;

    FArquivo.SaveToFile(FDir + sArquivo);
    Result := True;
  except
    on E: Exception do
    begin
      raise Exception.Create('TClasse.Exportar=' + E.Message);
    end;
  end;
end;

function TClasse.RetornaTipo(Texto: String): String;
begin
  if Pos('int', Texto)           > 0 then Result := 'Integer'
  else if Pos('text', Texto)     > 0 then Result := 'AnsiString'
  else if Pos('varchar', Texto)  > 0 then Result := 'String'
  else if Pos('char', Texto)     > 0 then Result := 'Char'
  else if Pos('date', Texto)     > 0 then Result := 'TDate'
  else if Pos('time', Texto)     > 0 then Result := 'TTime'
  else if Pos('datetime', Texto) > 0 then Result := 'TDateTime'
  else if Pos('double', Texto)   > 0 then Result := 'Currency'
  else if Pos('float', Texto)    > 0 then Result := 'Double'
  else if Pos('enum', Texto)     > 0 then Result := 'Boolean';
end;

end.
