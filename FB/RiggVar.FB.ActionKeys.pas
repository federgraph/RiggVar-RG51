unit RiggVar.FB.ActionKeys;

interface

{$ifdef fpc}
{$mode delphi}
{$endif}

uses
  SysUtils,
  Classes,
  LCLType;

type
  TKeyTestHelper = record
    ML: TStrings;
    Key: Word;
    KeyChar: Char;
    Shift: TShiftState;
    Index: Integer;
    fat: Integer;
  end;

  TFederKeyboard = class
  private
    SL: TStringList;
    KTH: TKeyTestHelper;
    function GetKeys: Boolean;
    procedure GetKey(Name: string; Value: Word);
    procedure TestKey(Name: string; Value: Word; Shift: TShiftState = []);
    procedure TestKeys;
    procedure GetSC(fa: Integer; ML: TStrings);
  public
    TestName: string;
    KeyMapping: Integer;
    function KeyDownAction(
      var Key: Word;
      var KeyChar: Char;
      Shift: TShiftState): Integer; virtual;
    function KeyUpAction(
      var Key: Word;
      var KeyChar: Char;
      Shift: TShiftState): Integer; virtual;

    constructor Create;
    destructor Destroy; override;
    procedure GetShortcuts(fa: Integer; ML: TStrings);
    function GetShortcut(fa: Integer): string;
  end;

implementation

uses
  RiggVar.FB.ActionConst;

type
  TShortcutSet = set of char;

var
  ShortcutSet: TShortcutSet;

{ TFederKeyboard }

function TFederKeyboard.KeyDownAction(var Key: Word; var KeyChar: Char;
  Shift: TShiftState): Integer;
begin
  result := faNoop;
end;

function TFederKeyboard.KeyUpAction(var Key: Word; var KeyChar: Char;
  Shift: TShiftState): Integer;
begin
  result := faNoop;
end;

constructor TFederKeyboard.Create;
begin
  TestName := 'KB';
  SL := TStringList.Create;
end;

destructor TFederKeyboard.Destroy;
begin
  SL.Free;
  inherited;
end;

function TFederKeyboard.GetShortcut(fa: Integer): string;
begin
  result := '';
  if fa <> faNoop then
  begin
    SL.Clear;
    GetSC(fa, SL);
    if SL.Count > 0 then
      result := SL[0];
  end;
end;

procedure TFederKeyboard.GetSC(fa: Integer; ML: TStrings);
var
  c: Char;
begin
  KTH.ML := ML;
  KTH.Key := 0;
  KTH.Shift := [];
  KTH.fat := fa;
  for c in ShortcutSet do
  begin
    KTH.KeyChar := c;
    if GetKeys then
      break;
  end;

  GetKey('vkC', vk_C);
  GetKey('vkD', vk_D);
  GetKey('vkL', vk_L);
  GetKey('vkS', vk_S);
  GetKey('vkO', vk_O);

  GetKey('vkSpace', vk_Space);
  GetKey('vkDelete', vk_Delete);
  GetKey('vkReturn', vk_Return);

  GetKey('vkF1', vk_F1);
  GetKey('vkF2', vk_F2);
  GetKey('vkF3', vk_F3);
  GetKey('vkF4', vk_F4);
  GetKey('vkF5', vk_F5);

  GetKey('vkLeft', vk_Left);
  GetKey('vkRight', vk_Right);
  GetKey('vkUp', vk_Up);
  GetKey('vkDown', vk_Down);

  GetKey('vkNext', vk_Next);
  GetKey('vkPrior', vk_Prior);
  GetKey('vkHome', vk_Home);
  GetKey('vkEscape', vk_Escape);

  KTH.Shift := [ssShift];

  GetKey('Shift + vkLeft', vk_Left);
  GetKey('Shift + vkRight', vk_Right);
  GetKey('Shift + vkUp', vk_Up);
  GetKey('Shift + vkDown', vk_Down);

  GetKey('Shift + vkEscape', vk_Escape);
  GetKey('Shift + vkSpace', vk_Space);
end;

procedure TFederKeyboard.GetShortcuts(fa: Integer; ML: TStrings);
var
  c: Char;
begin
  KTH.ML := ML;
  KTH.Key := 0;
  KTH.Shift := [];
  KTH.fat := fa;
  for c in ShortcutSet do
  begin
    KTH.KeyChar := c;
    TestKeys;
  end;

  TestKey('vkC', vk_C);
  TestKey('vkD', vk_D);
  TestKey('vkL', vk_L);
  TestKey('vkS', vk_S);
  TestKey('vkO', vk_O);

  TestKey('vkSpace', vk_Space);
  TestKey('vkDelete', vk_Delete);
  TestKey('vkReturn', vk_Return);

  TestKey('vkF1', vk_F1);
  TestKey('vkF2', vk_F2);
  TestKey('vkF3', vk_F3);
  TestKey('vkF4', vk_F4);
  TestKey('vkF5', vk_F5);

  TestKey('vkLeft', vk_Left);
  TestKey('vkRight', vk_Right);
  TestKey('vkUp', vk_Up);
  TestKey('vkDown', vk_Down);

  TestKey('vkNext', vk_Next);
  TestKey('vkPrior', vk_Prior);
  TestKey('vkHome', vk_Home);
  TestKey('vkEscape', vk_Escape);

  KTH.Shift := [ssShift];

  TestKey('Shift + vkLeft', vk_Left, KTH.Shift);
  TestKey('Shift + vkRight', vk_Right, KTH.Shift);
  TestKey('Shift + vkUp', vk_Up, KTH.Shift);
  TestKey('Shift + vkDown', vk_Down, KTH.Shift);

  TestKey('Shift + vkEscape', vk_Escape, KTH.Shift);
  TestKey('Shift + vkSpace', vk_Space, KTH.Shift);
end;

procedure TFederKeyboard.TestKeys;
var
  fa2: TFederAction;
  s: string;
begin
  fa2 := KeyUpAction(KTH.Key, KTH.KeyChar, KTH.Shift);
  if KTH.fat = fa2 then
  begin
    s := KTH.KeyChar;
    KTH.ML.Add(TestName + ' ' + s);
  end;
end;

procedure TFederKeyboard.TestKey(Name: string; Value: Word; Shift: TShiftState);
var
  fa2: TFederAction;
begin
  fa2 := KeyUpAction(Value, KTH.KeyChar, Shift);
  if KTH.fat = fa2 then
  begin
    KTH.ML.Add(TestName + ' ' + Name);
  end;
end;

function TFederKeyboard.GetKeys: Boolean;
var
  fa2: TFederAction;
begin
  result := False;
  fa2 := KeyUpAction(KTH.Key, KTH.KeyChar, KTH.Shift);
  if KTH.fat = fa2 then
  begin
    KTH.ML.Add(KTH.KeyChar);
    result := True;
  end;
end;

procedure TFederKeyboard.GetKey(Name: string; Value: Word);
var
  fa2: TFederAction;
begin
  fa2 := KeyUpAction(Value, KTH.KeyChar, []);
  if KTH.fat = fa2 then
  begin
    KTH.ML.Add(Name);
  end;
end;

function GetShortcutSet: TShortcutSet;
var
  cs: TShortcutSet;
begin
  { build a list }
  cs := [];

  cs := cs + ['A'..'Z'];
  cs := cs + ['a'..'z'];
  cs := cs + ['0'..'9'];

  Include(cs, '!');
  Include(cs, '"');
  Include(cs, '§');
  Include(cs, '$');
  Include(cs, '%');
  Include(cs, '&');

  Include(cs, '+');
  Include(cs, '#');
  Include(cs, '*');
  Include(cs, '=');
  Include(cs, '?');

  Include(cs, '/');
  Include(cs, '°');

  Include(cs, '~');
  Include(cs, 'µ');
  Include(cs, '@');
  Include(cs, '€');

  Include(cs, '²');
  Include(cs, '³');

  Include(cs, '^');
  Include(cs, '`');
  Include(cs, '´');
  Include(cs, '''');
  Include(cs, '|');

  Include(cs, 'ß');
  Include(cs, '(');
  Include(cs, ')');
  Include(cs, '[');
  Include(cs, ']');
  Include(cs, '{');
  Include(cs, '}');

  Include(cs, ';');
  Include(cs, ':');
  Include(cs, '_');

  Include(cs, ',');
  Include(cs, '.');
  Include(cs, '-');

  Include(cs, 'ä');
  Include(cs, 'Ä');
  Include(cs, 'ö');
  Include(cs, 'Ö');
  Include(cs, 'ü');
  Include(cs, 'Ü');

  Include(cs, '<');
  Include(cs, '>');

  result := cs;
end;

initialization
  ShortcutSet := GetShortcutSet;

end.
