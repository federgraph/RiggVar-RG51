unit RiggVar.FD.Drawing01;

{$ifdef fpc}
  {$mode delphi}
{$endif}

interface

uses
  BGRABitmapTypes,
  RiggVar.FD.Elements,
  RiggVar.FD.Drawings;

type
  TRggDrawingD01 = class(TRggDrawing)
  public
    A0: TRggCircle;
    B0: TRggCircle;
    A: TRggCircle;
    B: TRggCircle;
    constructor Create;
    procedure InitDefaultPos; override;
  end;

implementation

{ TRggDrawingD01 }

procedure TRggDrawingD01.InitDefaultPos;
begin
  A0.Center.X := 100;
  A0.Center.Y := 400;
  A0.Center.Z := 0;

  B0.Center.X := 400;
  B0.Center.Y := 400;
  B0.Center.Z := 0;

  A.Center.X := 100;
  A.Center.Y := 100;
  A.Center.Z := 0;

  B.Center.X := 400;
  B.Center.Y := 100;
  B.Center.Z := 0;
end;

constructor TRggDrawingD01.Create;
var
  L: TRggLine;
begin
  inherited;
  Name := 'D01-Quad';
  WantSort := False;

  A0 := TRggCircle.Create('A0');
  A0.StrokeColor := CssOrangered;

  B0 := TRggCircle.Create('B0');
  B0.StrokeColor := CssBlue;

  A := TRggCircle.Create('A');
  A.StrokeColor := CssOrangered;

  B := TRggCircle.Create('B');
  B.StrokeColor := CssBlue;

  InitDefaultPos;

  L := TRggLine.Create('A0B0');
  L.StrokeColor := CssGray;
  L.Point1 := A0;
  L.Point2 := B0;
  Add(L);

  L := TRggLine.Create('A0A');
  L.StrokeColor := CssRed;
  L.Point1 := A0;
  L.Point2 := A;
  Add(L);

  L := TRggLine.Create('B0B');
  L.StrokeColor := CssBlue;
  L.Point1 := B0;
  L.Point2 := B;
  Add(L);

  L := TRggLine.Create('AB');
  L.StrokeColor := CssLime;
  L.Point1 := A;
  L.Point2 := B;
  Add(L);

  Add(A0);
  Add(B0);
  Add(A);
  Add(B);
end;

end.
