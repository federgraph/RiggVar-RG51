﻿unit RiggVar.FZ.Z09_Axis;

interface

{$ifdef fpc}
  {$mode delphi}
{$endif}

uses
  Math,
  BGRABitmapTypes,
  RiggVar.FD.Elements,
  RiggVar.FD.Drawings;

type
  TRggDrawingZ09 = class(TRggDrawing)
  private
    procedure Btn1Click(Sender: TObject);
    procedure Btn2Click(Sender: TObject);
    procedure Btn3Click(Sender: TObject);
    procedure Btn4Click(Sender: TObject);
    procedure Btn5Click(Sender: TObject);
    procedure Btn6Click(Sender: TObject);
    function GetHelpText: string;
  public
    Origin: TRggCircle;
    AX: TRggCircle;
    AY: TRggCircle;
    AZ: TRggCircle;
    HT: TRggLabel;
    constructor Create;
    procedure InitDefaultPos; override;
    procedure InitButtons(BG: TRggButtonGroup); override;
  end;

implementation

{ TRggDrawingZ09 }

procedure TRggDrawingZ09.InitButtons(BG: TRggButtonGroup);
begin
  { Will only be called if Buttons have been created. }
  inherited; { will call Reset }

  BG.Btn1.OnClick := Btn1Click;
  BG.Btn2.OnClick := Btn2Click;
  BG.Btn3.OnClick := Btn3Click;
  BG.Btn4.OnClick := Btn4Click;
  BG.Btn5.OnClick := Btn5Click;
  BG.Btn6.OnClick := Btn6Click;

  BG.Btn1.Caption := '-X';
  BG.Btn2.Caption := '+X';

  BG.Btn3.Caption := '-Y';
  BG.Btn4.Caption := '+Y';

  BG.Btn5.Caption := '-Z';
  BG.Btn6.Caption := '+Z';
end;

procedure TRggDrawingZ09.InitDefaultPos;
var
  ox, oy, oz: single;
begin
  ox := 400;
  oy := 400;
  oz := 0;

  Origin.Center.X := ox;
  Origin.Center.Y := oy;
  Origin.Center.Z := 0;

  AX.Center.X := ox + 200;
  AX.Center.Y := oy;
  AX.Center.Z := oz;

  AY.Center.X := ox;
  AY.Center.Y := oy + 200;
  AY.Center.Z := oz;

  AZ.Center.X := ox;
  AZ.Center.Y := oy;
  AZ.Center.Z := oz + 200;
end;

constructor TRggDrawingZ09.Create;
var
  L: TRggLine;
begin
  inherited;
  Name := 'Z09-Axis';

  { Help Text }

  HT := TRggLabel.Create;
  HT.Caption := 'HelpText';
  HT.Text := GetHelpText;
  HT.StrokeColor := CssTomato;
  HT.IsMemoLabel := True;
  Add(HT);

  { Points }

  AX := TRggCircle.Create;
  AX.Caption := 'X';
  AX.StrokeColor := CssRed;

  AY := TRggCircle.Create;
  AY.Caption := 'Y';
  AY.StrokeColor := CssGreen;

  AZ := TRggCircle.Create;
  AZ.Caption := 'Z';
  AZ.StrokeColor := CssBlue;

  Origin := TRggCircle.Create;
  Origin.Caption := 'Origin';
  Origin.StrokeColor := CssYellow;
  Origin.ShowCaption := False;

  InitDefaultPos;

  { Lines }

  DefaultShowCaption := False;

  L := TRggLine.Create('AX');
  L.StrokeColor := CssRed;
  L.Point1 := Origin;
  L.Point2 := AX;
  Add(L);

  L := TRggLine.Create('AY');
  L.StrokeColor := CssGreen;
  L.Point1 := Origin;
  L.Point2 := AY;
  Add(L);

  L := TRggLine.Create('AZ');
  L.StrokeColor := CssBlue;
  L.Point1 := Origin;
  L.Point2 := AZ;
  Add(L);

  Add(Origin);
  Add(AX);
  Add(AY);
  Add(AZ);

  FixPoint3D := Origin.Center.C;
  WantRotation := True;
  WantSort := True;
end;

procedure TRggDrawingZ09.Btn1Click(Sender: TObject);
begin
  TH.Rotation.X := DegToRad(10);
  TH.Rotation.Y := 0;
  TH.Rotation.Z := 0;
  TH.Draw;
  TH.GetEulerAngles;
end;

procedure TRggDrawingZ09.Btn2Click(Sender: TObject);
begin
  TH.Rotation.X := DegToRad(-10);
  TH.Rotation.Y := 0;
  TH.Rotation.Z := 0;
  TH.Draw;
  TH.GetEulerAngles;
end;

procedure TRggDrawingZ09.Btn3Click(Sender: TObject);
begin
  TH.Rotation.X := 0;
  TH.Rotation.Y := DegToRad(10);
  TH.Rotation.Z:= 0;
  TH.Draw;
  TH.GetEulerAngles;
end;

procedure TRggDrawingZ09.Btn4Click(Sender: TObject);
begin
  TH.Rotation.X := 0;
  TH.Rotation.Y := DegToRad(-10);
  TH.Rotation.Z:= 0;
  TH.Draw;
  TH.GetEulerAngles;
end;

procedure TRggDrawingZ09.Btn5Click(Sender: TObject);
begin
  TH.Rotation.X := 0;
  TH.Rotation.Y := 0;
  TH.Rotation.Z := DegToRad(10);
  TH.Draw;
  TH.GetEulerAngles;
end;

procedure TRggDrawingZ09.Btn6Click(Sender: TObject);
begin
  TH.Rotation.X := 0;
  TH.Rotation.Y := 0;
  TH.Rotation.Z := DegToRad(-10);
  TH.Draw;
  TH.GetEulerAngles;
end;

function TRggDrawingZ09.GetHelpText: string;
begin
  ML.Add('Axis sample for doing rotation tests.');
  ML.Add(' with special buttons Btn1..Btn6 mapped.');
  ML.Add('');
  ML.Add('Toggle layout with key v (vertical) and h.');
  ML.Add('  Vertical layout is better on Surface tablet screen.');

  result := ML.Text;
  ML.Clear;
end;

end.
