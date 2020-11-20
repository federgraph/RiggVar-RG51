unit RiggVar.FD.Drawing10;

{$ifdef fpc}
  {$mode delphi}
{$endif}

interface

uses
  SysUtils,
  Classes,
  BGRABitmapTypes,
  RiggVar.FD.Elements,
  RiggVar.FD.Drawings;

type
  TRggDrawingD10 = class(TRggDrawing)
  public
    Origin: TRggCircle;
    AX: TRggCircle;
    AY: TRggCircle;
    AZ: TRggCircle;
    constructor Create;
    procedure InitDefaultPos; override;
  end;

implementation

{ TRggDrawingD10 }

procedure TRggDrawingD10.InitDefaultPos;
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

constructor TRggDrawingD10.Create;
var
  L: TRggLine;
begin
  inherited;
  Name := 'D10-Lager';

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

  L := TRggLagerLine.Create('AX');
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

end.
