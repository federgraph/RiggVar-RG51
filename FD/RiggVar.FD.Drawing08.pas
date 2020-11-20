unit RiggVar.FD.Drawing08;

{$ifdef fpc}
  {$mode delphi}
{$endif}

interface

uses
  BGRABitmapTypes,
  RiggVar.FD.Elements,
  RiggVar.FD.Drawings;

type
  TRggDrawingD08 = class(TRggDrawing)
  public
    A: TRggCircle;
    B: TRggCircle;
    C: TRggCircle;
    Alpha: TRggArc;
    constructor Create;
    procedure InitDefaultPos; override;
  end;

implementation

{ TRggDrawingD08 }

procedure TRggDrawingD08.InitDefaultPos;
begin
  A.Center.X := 100;
  A.Center.Y := 400;
  A.Center.Z := 0;

  B.Center.X := 400;
  B.Center.Y := 400;
  B.Center.Z := 0;

  C.Center.X := 200;
  C.Center.Y := 200;
  C.Center.Z := 0;
end;

constructor TRggDrawingD08.Create;
var
  L: TRggLine;
  T: TRggTriangle;
  W: TRggArc;
begin
  inherited;
  Name := 'D08-Arc';

  A := TRggCircle.Create;
  A.Caption := 'A';
  A.StrokeColor := CssOrangered;

  B := TRggCircle.Create;
  B.Caption := 'B';
  B.StrokeColor := CssDodgerblue;

  C := TRggCircle.Create;
  C.Caption := 'C';
  C.StrokeColor := CssAquamarine;

  InitDefaultPos;

  T := TRggTriangle.Create;
  T.Caption := 'ABC';
  T.StrokeColor := CssAqua;
  T.Point1 := A;
  T.Point2 := B;
  T.Point3 := C;
  Add(T);

  L := TRggLine.Create('AB');
  L.StrokeColor := CssBlack;
  L.Point1 := A;
  L.Point2 := B;
  Add(L);

  L := TRggLine.Create('AC');
  L.StrokeColor := CssGray;
  L.Point1 := A;
  L.Point2 := C;
  Add(L);

  L := TRggLine.Create('BC');
  L.StrokeColor := CssGray;
  L.Point1 := B;
  L.Point2 := C;
  Add(L);

  W := TRggArc.Create('Alpha');
  W.StrokeColor := CssRed;
  W.Point1 := C;
  W.Point2 := B;
  W.Point3 := A;
  Add(W);

  W := TRggArc.Create('Beta');
  W.StrokeColor := CssBlue;
  W.Point1 := B;
  W.Point2 := C;
  W.Point3 := A;
  Add(W);

  W := TRggArc.Create('Gamma');
  W.StrokeColor := CssGreen;
  W.Point1 := A;
  W.Point2 := B;
  W.Point3 := C;
  Add(W);

  Add(A);
  Add(B);
  Add(C);
end;

end.
