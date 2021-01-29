unit RiggVar.FD.Chart;

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

interface

{$ifdef fpc}
{$mode delphi}
{$endif}

uses
  Types,
  Graphics,
  BGRABitmap,
  BGRABitmapTypes,
  RiggVar.FD.Elements;

type
  TRggBox = record
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
  end;

  TRggChart = class(TRggElement)
  protected
    FIntervalCount: Integer;
  public
    Poly: array of single;

    Box: TRggBox;

    Xmin: single;
    Xmax: single;
    Ymin: single;
    Ymax: single;

    ChartPunktX: single;

    WantChartPunktX: Boolean;
    WantRectangles: Boolean;
    WantCurve: Boolean;

    PointRadius: Integer;
    CurveOpacity: single;

    constructor Create(AIntervalCount: Integer = 20);
    procedure Draw(g: TBGRABitmap); override;

    procedure InitDefault;

    procedure LookForYMinMax;
    property IntervalCount: Integer read FIntervalCount;
  end;

implementation

{ TRggChart }

procedure TRggChart.LookForYMinMax;
var
  i: Integer;
  t: single;
begin
  Ymax := Poly[0];
  Ymin := Ymax;
  for i := 0 to FIntervalCount do
  begin
    t := Poly[i];
    if t > Ymax then
      Ymax := t;
    if t < Ymin then
      Ymin := t;
  end;
end;

constructor TRggChart.Create(AIntervalCount: Integer = 20);
begin
  inherited Create;
  TypeName := 'Chart';
  IndentItem := True;

  FIntervalCount := 1;
  if AIntervalCount > FIntervalCount then
    FIntervalCount := AIntervalCount;

  SetLength(Poly, FIntervalCount + 1);

  Box.X := 0;
  Box.Y := 0;
  Box.Width := 800;
  Box.Height := 800;

  PointRadius := 3;

  WantCurve := True;
end;

procedure TRggChart.Draw(g: TBGRABitmap);
var
  P: TPointF;
  i: Integer;
  tempX: single;
  tempY: single;

  ox, oy: single;

  function Limit(a: single): single;
  begin
    if a < -32000 then
      a := -32000
    else if a > 32000 then
      a := 32000;
    Result := a;
  end;

begin
  ox := Box.X + Drawing.FaxPoint3D.X;
  oy := Box.Y + Drawing.FaxPoint3D.Y;

  if WantCurve then
  begin
    tempY := Box.Height - Box.Height * (Poly[0] - Ymin) / (Ymax - Ymin);
    P.X := ox;
    P.Y := oy + Limit(tempY);
    LineToPoint := P;
    for i := 1 to FIntervalCount do
    begin
      tempX := Box.Width * i / FIntervalCount;
      tempY := Box.Height - Box.Height * (Poly[i] - Ymin) / (Ymax - Ymin);
      P.X := ox + Limit(tempX);
      P.Y := oy + Limit(tempY);
      LineTo(g, P);
    end;
  end;

  if WantRectangles then
  begin
    for i := 0 to FIntervalCount do
    begin
      tempX := Box.Width * i / FIntervalCount;
      tempY := Box.Height - Box.Height * (Poly[i] - Ymin) / (Ymax - Ymin);
      P.X := ox + Limit(tempX);
      P.Y := oy + Limit(tempY);
      g.RectangleAntialias(
        P.X - PointRadius,
        P.Y - PointRadius,
        P.X + PointRadius,
        P.Y + PointRadius,
        CssWhite, 1.0, StrokeColor);
    end;
  end;

  if WantChartPunktX then
  begin
    tempX := Box.Width * ((ChartPunktX) - Xmin) / (XMax - Xmin);
    tempY := Box.Height;
    P.X := ox + Round(Limit(tempX));
    P.Y := oy + Round(Limit(tempY));
    g.RectangleAntialias(
      P.X - PointRadius,
      P.Y - PointRadius,
      P.X + PointRadius,
      P.Y + PointRadius,
      CssWhite, 1.0, StrokeColor);
  end;

end;

procedure TRggChart.InitDefault;
var
  i: Integer;
begin
  for i := 0 to FIntervalCount do
  begin
    Poly[i] := sin(i / FIntervalCount * 2 * Pi);
  end;
  LookForYMinMax;
end;

end.
