﻿unit RiggVar.FZ.Z05_TestRigg;

(*
-
-     F
-    * * *
-   *   *   G
-  *     * *   *
- E - - - H - - - I
-  *     * *         *
-   *   *   *           *
-    * *     *             *
-     D-------A---------------B
-              *
-              (C) federgraph.de
-
*)

{$ifdef fpc}
  {$mode delphi}
{$endif}

interface

uses
  BGRABitmap,
  BGRABitmapTypes,
  RiggVar.RG.Types,
  RiggVar.FD.Point,
  RiggVar.FD.Elements,
  RiggVar.FD.Drawings;

type
  TRggDrawingZ05 = class(TRggDrawing)
  private
    A0B0: TRggLine;
    A0C0: TRggLine;
    B0C0: TRggLine;
    A0D0: TRggLine;

    B0D0: TRggLine;
    C0D0: TRggLine;

    A0A: TRggLine;
    B0B: TRggLine;
    C0C: TRggLine;

    CF: TRggLine;

    AC: TRggLine;
    BC: TRggLine;

    AB: TRggLine;
    AD: TRggLine;
    BD: TRggLine;

    HT: TRggLabel;
    function GetHelpText: string;
  public
    A0, A: TRggCircle;
    B0, B: TRggCircle;
    C0, C: TRggCircle;
    D0, D: TRggCircle;
    F: TRggCircle;

    D0D: TRggLine;
    DC: TRggLine;

    rP_D0: TPoint3D;
    OffsetX: single;
    OffsetY: single;
    InitialZoom: single;

    OffsetXDefault: single;
    OffsetYDefault: single;
    InitialZoomDefault: single;

    constructor Create;
    procedure InitDefaultPos; override;
    procedure Load;
    procedure GoDark; override;
    procedure GoLight; override;
  end;

implementation

{ TRggDrawingZ05 }

procedure TRggDrawingZ05.InitDefaultPos;
var
  ox, oy, g: single;
begin
  ox := 100;
  oy := 700;
  g := 3.0;

  A0.Center.X := ox + 30 * g;
  A0.Center.Y := oy - 40 * g;
  A0.Center.Z := -40 * g;

  B0.Center.X := ox + 30 * g;
  B0.Center.Y := oy - 40 * g;
  B0.Center.Z := 40 * g;

  C0.Center.X := ox + 150 * g;
  C0.Center.Y := oy - 40 * g;
  C0.Center.z := 0;

  D0.Center.X := ox + 80 * g;
  D0.Center.Y := oy - 10 * g;
  D0.Center.z := 0;

  A.Center.X := ox + 10 * g;
  A.Center.Y := oy - 100 * g;
  A.Center.Z := -30 * g;

  B.Center.X := ox + 10 * g;
  B.Center.Y := oy - 100 * g;
  B.Center.Z := 30 * g;

  C.Center.X := ox + 30 * g;
  C.Center.Y := oy - 160 * g;
  C.Center.z := 0;

  D.Center.X := ox + 50 * g;
  D.Center.Y := oy - 100 * g;
  D.Center.Z := 0;

  F.Center.X := ox + 10 * g;
  F.Center.Y := oy - 220 * g;
  F.Center.Z := 0;
end;

constructor TRggDrawingZ05.Create;
var
  L: TRggLine;
begin
  inherited;
  Name := 'Z05-Test-Rigg';

  OffsetXDefault := 400;
  OffsetYDefault := 640;
  InitialZoomDefault := 0.09;

  OffsetX := OffsetXDefault;
  OffsetY := OffsetYDefault;
  InitialZoom := InitialZoomDefault;

  DefaultShowCaption := True;

  { Help Text }

  HT := TRggLabel.Create;
  HT.Caption := 'HelpText';
  HT.Text := GetHelpText;
  HT.StrokeColor := CssTomato;
  HT.IsMemoLabel := True;
  HT.Position.X := 400;
  Add(HT);

  { Points }

  A0 := TRggCircle.Create('A0');
  A0.StrokeColor := CssRed;

  B0 := TRggCircle.Create('B0');
  B0.StrokeColor := CssGreen;

  C0 := TRggCircle.Create('C0');
  C0.StrokeColor := CssYellow;

  D0 := TRggCircle.Create('D0');
  D0.StrokeColor := CssBlue;

  A := TRggCircle.Create('A');
  A.StrokeColor := CssRed;

  B := TRggCircle.Create('B');
  B.StrokeColor := CssGreen;

  C := TRggCircle.Create('C');
  C.StrokeColor := CssYellow;

  D := TRggCircle.Create('D');
  D.StrokeColor := CssBlue;

  F := TRggCircle.Create('F');
  F.StrokeColor := CssGray;

  InitDefaultPos;

  { Lines }

  DefaultShowCaption := False;

  L := TRggLine.Create('A0B0');
  L.StrokeColor := CssGray;
  L.Point1 := A0;
  L.Point2 := B0;
  Add(L);
  A0B0 := L;

  L := TRggLine.Create('A0C0');
  L.StrokeColor := CssGray;
  L.Point1 := A0;
  L.Point2 := C0;
  Add(L);
  A0C0 := L;

  L := TRggLine.Create('B0C0');
  L.StrokeColor := CssGray;
  L.Point1 := B0;
  L.Point2 := C0;
  Add(L);
  B0C0 := L;

  { --- }

  L := TRggLine.Create('A0D0');
  L.StrokeColor := CssBlack;
  L.Point1 := A0;
  L.Point2 := D0;
  Add(L);
  A0D0 := L;

  L := TRggLine.Create('B0D0');
  L.StrokeColor := CssBlack;
  L.Point1 := B0;
  L.Point2 := D0;
  Add(L);
  B0D0 := L;

  L := TRggLine.Create('C0D0');
  L.StrokeColor := CssBlack;
  L.Point1 := C0;
  L.Point2 := D0;
  Add(L);
  C0D0 := L;

  { --- }

  L := TRggLine.Create('A0A');
  L.StrokeColor := CssRed;
  L.Point1 := A0;
  L.Point2 := A;
  Add(L);
  A0A := L;

  L := TRggLine.Create('B0B');
  L.StrokeColor := CssGreen;
  L.Point1 := B0;
  L.Point2 := B;
  Add(L);
  B0B := L;

  L := TRggLine.Create('C0C');
  L.StrokeColor := CssYellow;
  L.Point1 := C0;
  L.Point2 := C;
  Add(L);
  C0C := L;

  L := TRggLine.Create('D0D');
  L.StrokeColor := CssBlue;
  L.Point1 := D0;
  L.Point2 := D;
  Add(L);
  D0D := L;

  { --- }

  L := TRggLine.Create('AC');
  L.StrokeColor := CssRed;
  L.Point1 := A;
  L.Point2 := C;
  Add(L);
  AC := L;

  L := TRggLine.Create('BC');
  L.StrokeColor := CssGreen;
  L.Point1 := B;
  L.Point2 := C;
  Add(L);
  BC := L;

  L := TRggLine.Create('DC');
  L.StrokeColor := CssBlue;
  L.Point1 := D;
  L.Point2 := C;
  Add(L);
  DC := L;

  { --- }

  L := TRggLine.Create('AB');
  L.StrokeColor := CssLime;
  L.Point1 := A;
  L.Point2 := B;
  Add(L);
  AB := L;

  L := TRggLine.Create('AD');
  L.StrokeColor := CssLime;
  L.Point1 := A;
  L.Point2 := D;
  Add(L);
  AD := L;

  L := TRggLine.Create('BD');
  L.StrokeColor := CssLime;
  L.Point1 := B;
  L.Point2 := D;
  Add(L);
  BD := L;

  L := TRggLine.Create('CF');
  L.StrokeColor := CssGray;
  L.Point1 := C;
  L.Point2 := F;
  Add(L);
  CF := L;

  Add(A0);
  Add(B0);
  Add(C0);
  Add(D0);

  Add(A);
  Add(B);
  Add(C);
  Add(D);

  Add(F);

  FixPoint3D := D.Center.C;
  WantRotation := True;
  WantSort := True;

  Load;

  DefaultElement := D;
end;

procedure TRggDrawingZ05.Load;
var
  cr: TRggCircle;
begin
  try
    cr := A0;
    cr.Center.X := 235.42;
    cr.Center.Y := 552.60;
    cr.Center.Z := -164.01;

    cr := B0;
    cr.Center.X := 142.15;
    cr.Center.Y := 589.33;
    cr.Center.Z := 54.05;

    cr := C0;
    cr.Center.X := 520.27;
    cr.Center.Y := 606.96;
    cr.Center.Z := 80.73;

    cr := D0;
    cr.Center.X := 323.92;
    cr.Center.Y := 674.45;
    cr.Center.Z := -14.62;

    cr := A;
    cr.Center.X := 174.48;
    cr.Center.Y := 374.22;
    cr.Center.Z := -127.01;

    cr := B;
    cr.Center.X := 104.53;
    cr.Center.Y := 401.77;
    cr.Center.Z := 36.54;

    cr := C;
    cr.Center.X := 200.72;
    cr.Center.Y := 217.03;
    cr.Center.Z := 9.74;

    cr := D;
    cr.Center.X := 250.00;
    cr.Center.Y := 400.00;
    cr.Center.Z := 0.00;

    cr := F;
    cr.Center.X := 151.44;
    cr.Center.Y := 34.07;
    cr.Center.Z := 19.49;
  except
  end;
end;

procedure TRggDrawingZ05.GoLight;
begin
  inherited;
  A0.StrokeColor := CssRed;
  B0.StrokeColor := CssGreen;
  C0.StrokeColor := CssYellow;
  D0.StrokeColor := CssBlue;

  A.StrokeColor := CssRed;
  B.StrokeColor := CssGreen;
  C.StrokeColor := CssYellow;
  D.StrokeColor := CssBlue;

  F.StrokeColor := CssGray;

  A0B0.StrokeColor := CssGray;
  A0C0.StrokeColor := CssGray;
  B0C0.StrokeColor := CssGray;
  A0D0.StrokeColor := CssGray;

  B0D0.StrokeColor := CssBlack;
  C0D0.StrokeColor := CssBlack;

  A0A.StrokeColor := CssRed;
  B0B.StrokeColor := CssGreen;
  C0C.StrokeColor := CssYellow;
  D0D.StrokeColor := CssBlue;

  AC.StrokeColor := CssRed;
  BC.StrokeColor := CssGreen;

  DC.StrokeColor := CssBlue;

  AB.StrokeColor := CssLime;
  AD.StrokeColor := CssLime;
  BD.StrokeColor := CssLime;

  CF.StrokeColor := CssDodgerblue;
end;

procedure TRggDrawingZ05.GoDark;
begin
  inherited;
  A0.StrokeColor := CssRed;
  B0.StrokeColor := CssGreen;
  C0.StrokeColor := CssYellow;
  D0.StrokeColor := CssBlue;

  A.StrokeColor := CssRed;
  B.StrokeColor := CssGreen;
  C.StrokeColor := CssYellow;
  D.StrokeColor := CssDodgerblue;

  F.StrokeColor := CssGray;

  A0B0.StrokeColor := CssGray;
  A0C0.StrokeColor := CssGray;
  B0C0.StrokeColor := CssGray;

  A0D0.StrokeColor := CssCyan;
  B0D0.StrokeColor := CssCyan;
  C0D0.StrokeColor := CssCyan;

  A0A.StrokeColor := CssRed;
  B0B.StrokeColor := CssGreen;
  C0C.StrokeColor := CssYellow;
  D0D.StrokeColor := CssDodgerblue;

  AC.StrokeColor := CssRed;
  BC.StrokeColor := CssGreen;

  DC.StrokeColor := CssDodgerblue;

  AB.StrokeColor := CssLime;
  AD.StrokeColor := CssLime;
  BD.StrokeColor := CssLime;

  CF.StrokeColor := CssCyan;
end;

function TRggDrawingZ05.GetHelpText: string;
begin
  ML.Add('Test-Rigg');
  ML.Add('');
  ML.Add('  WantRotation := True;');
  ML.Add('  WantSort := True;');
  ML.Add('');
  ML.Add('  FixPoint3D := D.Center.C;');
  ML.Add('  DefaultElement := D;');

  result := ML.Text;
  ML.Clear;
end;

end.
