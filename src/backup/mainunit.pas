unit MainUnit;    //Taschenrechner

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
          cthreads, Unix,
    {$IFDEF LCLCarbon}
            MacOSAll,
    {$ENDIF}
  {$ENDIF}
  {$IFDEF WINDOWS}
          Windows,
  {$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, EditBtn, Menus, FileInfo, Messages, DefaultTranslator;

const
  TOKENMAX = 1024;

resourcestring
  rsDivisionBy0NotPossible = 'Division by 0 not possible';
  rsERROR = 'ERROR';
  rsCalculator = 'Calculator';

type

  { TForm1 }

  // Definition eines Typs für den Aufruf der entsprechenden
  // Operator Funktion in TOper
  TOperator = function(Wert, Operand : Real):String;

  // Operator/Funktions-Definition
  // text = Operator/Funktion string
  // func = Funktion die aufgerufen werden soll
  TOper = record
    text : String;
    func : TOperator;
  end;

  // Rückgabe-Struktur von token()
  TToken = record
    Max  : Integer;
    Tokn : array [0..TOKENMAX] of String;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button8: TButton;
    Button9: TButton;
    ButtonAdd: TButton;
    ButtonSub: TButton;
    ButtonMul: TButton;
    ButtonDiv: TButton;
    ButtonBack: TButton;
    ButtonMemClear: TButton;
    ButtonMemRestore: TButton;
    ButtonMemStore: TButton;
    Button0: TButton;
    ButtonMemAdd: TButton;
    ButtonMemSub: TButton;
    ButtonEqual: TButton;
    ButtonClear: TButton;
    ButtonClearAll: TButton;
    ButtonSign: TButton;
    ButtonSquareRoot: TButton;
    ButtonPercent: TButton;
    ButtonIverse: TButton;
    Button2: TButton;
    Button3: TButton;
    ButtonDot: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    MainMenu1: TMainMenu;
    Memo: TEdit;
    Eingabe: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Panel2: TPanel;
    Resultat: TEdit;
    Status: TLabel;
    Panel1: TPanel;
    procedure ButtonClick(Sender: TObject);
    procedure ButtonClearAllClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonEqualClick(Sender: TObject);
    procedure ButtonMemAddClick(Sender: TObject);
    procedure ButtonMemClearClick(Sender: TObject);
    procedure ButtonMemRestoreClick(Sender: TObject);
    procedure ButtonMemStoreClick(Sender: TObject);
    procedure ButtonMemSubClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    function Berechnen:String;
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  // Berechnungs-Funktionen
  function OperProdukt(Wert, Operand : Real):String;
  function OperQuotient(Wert, Operand : Real):String;
  function OperSumme(Wert, Operand : Real):String;
  function OperDifferenz(Wert, Operand : Real):String;
  function OperChangeSign(Wert, Operand : Real):String;
  function OperRoot(Wert, Operand : Real):String;
  function OperPercent(Wert, Operand : Real):String;
  function OperReciprocal(Wert, Operand : Real):String;
  // Hilfsmittel
  function Token(Depth : Integer; Text, Tok : String): TToken;

var
  Form1: TForm1;
  Version: TFileVersionInfo;
  Oper : array [1..4] of TOper =
        (
              (text : '+'; func : @OperSumme),
              (text : '-'; func : @OperDifferenz),
              (text : '*'; func : @OperProdukt),
              (text : '/'; func : @OperQuotient)
        );
  Func : array [1..4] of TOper =
        (
              (text : '±'; func : @OperChangeSign),
              (text : '√'; func : @OperRoot),
              (text : '%'; func : @OperPercent),
              (text :'1/x';func : @OperReciprocal)
        );

implementation

{$R *.lfm}

{ TForm1 }

//******************************************************************************
//*
//******************************************************************************
function OperProdukt(Wert, Operand : Real):String;
begin
  Result := FloatToStr(Wert*Operand);
end;

//******************************************************************************
//*
//******************************************************************************
function OperQuotient(Wert, Operand : Real):String;
begin
  if (Operand = 0) then begin
    Form1.Status.Caption := rsDivisionBy0NotPossible;
    Result  := rsERROR;
  end else
    Result := FloatToStr(Wert/Operand);
end;

//******************************************************************************
//*
//******************************************************************************
function OperSumme(Wert, Operand : Real):String;
begin
  Result := FloatToStr(Wert+Operand);
end;

//******************************************************************************
//*
//******************************************************************************
function OperDifferenz(Wert, Operand : Real):String;
begin
  Result := FloatToStr(Wert-Operand);
end;

//******************************************************************************
//*
//******************************************************************************
function OperChangeSign(Wert, Operand : Real):String;
begin
  Result := FloatToStr(Wert*(-1));
end;

//******************************************************************************
//*
//******************************************************************************
function OperRoot(Wert, Operand : Real):String;
begin
  Result := FloatToStr(Sqrt(Wert));
end;

//******************************************************************************
//*
//******************************************************************************
function OperPercent(Wert, Operand : Real):String;
begin
  Result := FloatToStr(Wert/100);
end;

//******************************************************************************
//*
//******************************************************************************
function OperReciprocal(Wert, Operand : Real):String;
begin
  Result := FloatToStr(1/Wert);
end;

//******************************************************************************
//* Grundwerte laden
//******************************************************************************
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Versions-Objekt laden
  Version := TFileVersionInfo.Create(nil);
  // Den Programmnamen mit Pfad eintragen
  Version.fileName:=paramstr(0);
  Version.ReadFileInfo;
  // Grundwerte laden
  Eingabe.Text  := '';
  Resultat.Text := '0';
  Memo.Text     := '0';
  Status.Caption:= '';
  // Fensterüberschrift laden
  Form1.Caption := rsCalculator + '  v' + Version.VersionStrings.Values['FileVersion'] + '  ' + Version.VersionStrings.Values['LegalCopyright'];
  // Versions-Objekt freigeben
  Version.Free;
end;

//******************************************************************************
//* Menü : Datei->Beenden
//******************************************************************************
procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  Close;
end;

//******************************************************************************
//* Menü : Hilfe->Über
//******************************************************************************
procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  MessageDlg(Form1.Caption, mtInformation, [mbOK], 0)
end;

//******************************************************************************
//* Berechnen von Eingabe.Text
//******************************************************************************
function TForm1.Berechnen:String;
var
  tok : TToken;
  i, j : Integer;
  Txt : String;
begin
  // Rückgabewert löschen
  Result := '';
  if (Eingabe.Text = '') then Exit;
  // Eingabe in Blöcke aufteilen die durch ein Leerzeichen getrennt sind
  //  i ->         0   1   2
  // '10 / 2' -> [10] [/] [2]
  tok := Token(0,Eingabe.Text,' ');
  // Wurde ein Leerzeichen gefunden
  if (tok.Max > 0) then begin
    // Wenn JA, verarbeite alle Blöcke der Reihe nach
    // i -> aktuelle Block-Nummer
    for i := 0 to tok.Max do begin;
        // Suche nach Operator aus der Liste Oper
        for j := 1 to Length(Oper) do begin
            // Ist das Zeichen eine Operator
            if (tok.Tokn[i] = Oper[j].text) then begin
              // JA, Operator aufrufen
              // Nun muss der Block vorher und nachher als Wert übergeben werden
              // '10 / 2' -> Operator "/" -> 10 DIV 2
              if (tok.Tokn[i-1] <> '') AND (tok.Tokn[i+1] <> '') then begin
                // Das Resultat im nächsten Block ablegen für weitere Berechnung
                tok.Tokn[i+1] := Oper[j].func(StrToFloat(tok.Tokn[i-1]), StrToFloat(tok.Tokn[i+1]));
                // Resultat anzeigen
                Resultat.Text := tok.Tokn[i+1];
                // Schlaufe <for j := 1 to Length(Oper) do begin> abbrechen
                Break;
              end;
            end;
        end;
        // Suche nach Funktion aus der Liste Func
        for j := 1 to Length(Func) do begin
            // Ist das Zeichen eine Funktion
            if (tok.Tokn[i] = Func[j].text) then begin
              // JA, Funktion aufrufen
              // Nun muss der Block vorher als Wert übergeben werden
              // '5 * 25 √' -> Wurzel aus 125
              if (tok.Tokn[i-1] <> '') then begin
                // Das Resultat im nächsten Block ablegen für weitere Berechnung
                tok.Tokn[i+1] := Func[j].func(StrToFloat(tok.Tokn[i-1]), 0);
                // Resultat anzeigen
                Resultat.Text := tok.Tokn[i+1];
                // Schlaufe <for j := 1 to Length(Func) do begin> abbrechen
                Break;
              end;
            end;
        end;
    end;
  end;
end;

//******************************************************************************
//* Hauptfunktion->OnClick für alle Normalen Tasten
//******************************************************************************
procedure TForm1.ButtonClick(Sender: TObject);
var
  But : TButton;
begin
  // Statusmeldung löschen
  Status.Caption := '';
  // Kommt der Aufruf von einem Button ?
  if (Sender is TButton) then begin
    // JA, Button-Objekt laden
    But := (Sender as TButton);
    // Den Text des Buttons zur Eingabe hinzufügen
    Eingabe.Text:=Eingabe.Text+But.Caption;
    // Die Eingabezeile berechnen
    Berechnen;
  end;
end;

//******************************************************************************
//* Taste : C
//******************************************************************************
procedure TForm1.ButtonClearAllClick(Sender: TObject);
begin
  Eingabe.Text:='';
  Resultat.Text:='0';
  Status.Caption := '';
end;

//******************************************************************************
//* Taste : CE
//******************************************************************************
procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  Status.Caption := '';
  if (Eingabe.Text[Length(Eingabe.Text)] = ' ') then
    // Funktion oder Operator gefunden, 3 Zeichen löschen
    Eingabe.Text:=Copy(Eingabe.Text,1,Length(Eingabe.Text)-3)
  else
    // Normales Zeichen gefunden, 1 Zeichen löschen
    Eingabe.Text:=Copy(Eingabe.Text,1,Length(Eingabe.Text)-1);
  Berechnen;
end;

//******************************************************************************
//* Taste : =
//******************************************************************************
procedure TForm1.ButtonEqualClick(Sender: TObject);
begin
  Berechnen;
end;

//******************************************************************************
//* Taste : M+
//******************************************************************************
procedure TForm1.ButtonMemAddClick(Sender: TObject);
begin
  Memo.Text := FloatToStr(StrToFloat(Memo.Text)+StrToFloat(Resultat.Text));
end;

//******************************************************************************
//* Taste : MC
//******************************************************************************
procedure TForm1.ButtonMemClearClick(Sender: TObject);
begin
  Memo.Text := '0';
end;

//******************************************************************************
//* Taste : MR
//******************************************************************************
procedure TForm1.ButtonMemRestoreClick(Sender: TObject);
begin
  Eingabe.Text := Eingabe.Text+Memo.Text;
  Berechnen;
end;

//******************************************************************************
//* Taste : MS
//******************************************************************************
procedure TForm1.ButtonMemStoreClick(Sender: TObject);
begin
  Memo.Text := Resultat.Text;
end;

//******************************************************************************
//* Taste : M-
//******************************************************************************
procedure TForm1.ButtonMemSubClick(Sender: TObject);
begin
  Memo.Text := FloatToStr(StrToFloat(Memo.Text)-StrToFloat(Resultat.Text));
end;

//******************************************************************************
//* Eine Taste auf der Tastatur wurde gedrückt
//******************************************************************************
procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
var
   i : Integer;
   k : Double;
begin
  // Statusmeldung löschen
  Status.Caption := '';
  //HideCaret(Eingabe.Handle);
  // Testen ob die Taste eine Funktion ist
  for i := 1 to Length(Func) do begin
      if (Key = Func[i].text) then begin
         // Es wurde eine Funktion gefunden
         Eingabe.Text:=Eingabe.Text+' '+Key+' ';
      end;
  end;
  // Testen ob die Taste eine Operator ist
  for i := 1 to Length(Oper) do begin
      if (Key = Oper[i].text) then begin
         // Es wurde eine Operator gefunden
         Eingabe.Text:=Eingabe.Text+' '+Key+' ';
      end;
  end;
  // Testen ob es eine Zahl ist
  if (TryStrToFloat(Key,k))then begin
    // Den Text des Buttons zur Eingabe hinzufügen
    Eingabe.Text:=Eingabe.Text+Key;
  end;
  // Testen ob es eine "." ist
  if (Key = '.')then begin
    // Den Text des Buttons zur Eingabe hinzufügen
    Eingabe.Text:=Eingabe.Text+Key;
  end;
  // Ist es die Del-Taste
  if (Key = chr(127)) then begin
    ButtonClearAllClick(Self);
  end;
  // Ist es die BackSpace-Taste
  if (Key = chr(8)) then begin
    ButtonClearClick(Self);
  end;
  // Die Eingabezeile berechnen
  Berechnen;
end;

//******************************************************************************
//  Zerlegen eines Strings in Blöcke anhand eines Zeichens
//  Depth = Interations tiefe / 0->endlos
//  Text  = String zum zerlegen
//  Tok   = Trennzeichen
//  Result= Rückgabewert (siehe TToken)
//******************************************************************************
function Token(Depth : Integer; Text, Tok : String): TToken;
var
  i, j, l, p : Integer;
  TTxt : String;
begin
  for i := 0 to TOKENMAX do begin
    if (Result.Tokn[i] <> '') then
      Result.Tokn[i] := '';
  end;
  if (Length(Text)=0) then
    Exit;
  TTxt := Text;
  j := TOKENMAX-1;
  l := Length(Tok);
  if ((Depth > 0) and (Depth < TOKENMAX-1)) then
    j := Depth - 1;
  for i := 0 to j do begin
    p := Pos(Tok,TTxt);
    if (p > 0) then begin
      Result.Tokn[i+1] := Copy(TTxt,p+l,8192);
      Result.Tokn[i] := Copy(TTxt,1,p-1);
      Result.Tokn[i] := Trim(Result.Tokn[i]);
      TTxt := Result.Tokn[i+1];
    end else
      Break;
  end;
  Result.Max := i;
end;

end.

