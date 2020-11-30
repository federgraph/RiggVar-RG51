unit RggChartGraph;

interface

{$ifdef fpc}
{$mode delphi}
{$endif}

uses
  BGRABitmap,
  BGRABitmapTypes,
  SysUtils,
  Classes,
  Types,
  ExtCtrls,
  RggTypes,
  RggInter,
  RggChartModel;

type
  TRggBox = class
  public
    X: single;
    Y: single;
    Width: single;
    Height: single;
  end;

  TChartGraph = class(TChartModel)
  private
    FImage: TImage; // injected, not owned
    FBitmap: TBGRABitmap; // owned, created in InitBitmap
    procedure InitBitmap;
    procedure SetImage(const Value: TImage);
  private
    Box: TRggBox;
    Raster: Integer;
    Padding: Integer;
    FillColor: TBGRAPixel;
    StrokeColor: TBGRAPixel;
    StrokeThickness: single;
  private
    FScale: single;
    procedure DrawToCanvas(g: TBGRABitmap);
    procedure DrawChart(g: TBGRABitmap);
    procedure DrawLabels(g: TBGRABitmap);
    procedure DrawLegend(g: TBGRABitmap);
  public
    Width: Integer;
    Height: Integer;
    constructor Create(ARigg: IRigg);
    destructor Destroy; override;
    procedure Draw; override;
    property Image: TImage read FImage write SetImage;
  end;

implementation

uses
  RiggVar.App.Main;

{ TChartGraph }

constructor TChartGraph.Create(ARigg: IRigg);
begin
  inherited;

  FScale := MainVar.Scale;

  Width := 650;
  Height := 400;

  Box := TRggBox.Create;
  Box.X := 120;
  Box.Y := 80;
  Box.Width := 500;
  Box.Height := 300;

  Raster := Round(24 * FScale);
  Padding := Round(2 * FScale);

  WantRectangles := True;
  WantTextRect := False;
  WantLegend := True;
end;

destructor TChartGraph.Destroy;
begin
  FBitmap.Free;
  Box.Free;
  inherited;
end;

procedure TChartGraph.InitBitmap;
begin
  if FBitmap <> nil then
  begin
    FBitmap.Free;
  end;
  FBitmap := TBGRABitmap.Create(
    Round(Width * FScale),
    Round(Height * FScale), CssNavy);
  Image.Width := Width;
  Image.Height := Height;
end;

procedure TChartGraph.SetImage(const Value: TImage);
begin
  FImage := Value;
  InitBitmap;
end;

procedure TChartGraph.Draw;
begin
  if (Image <> nil) and (FBitmap <> nil) then
  begin
    DrawToCanvas(FBitmap);
    FBitmap.Draw(Image.Canvas, 0, 0, True);
    Image.Invalidate;
  end;
end;

procedure TChartGraph.DrawToCanvas(g: TBGRABitmap);
begin
  g.FillRect(0, 0, FBitmap.Width, FBitmap.Height, CssNavy, dmSet);
  DrawLegend(g);
  DrawChart(g);
end;

procedure TChartGraph.DrawChart(g: TBGRABitmap);
var
  P: TPointF;
  i, param: Integer;
  Radius: single;
  tempX, tempY: single;
  WantChartPunktX: Boolean;
  LineToPoint: TPointF;
  xrange: single;
  yrange: single;

  function Limit(a: single): single;
  begin
    if a < -32000 then
      a := -32000
    else if a > 32000 then
      a := 32000;
    Result := a;
  end;

  procedure LineTo(x2, y2: single);
  begin
    g.DrawLineAntialias(
      LineToPoint.x, LineToPoint.y,
      x2, y2, StrokeColor, StrokeThickness);
    LineToPoint := PointF(x2, y2);
  end;

  procedure DrawVerticalLine;
  begin
    P.X := Box.X + Limit(tempX);
    P.Y := Box.Y + Limit(tempY);
    LineToPoint := PointF(P.X * FScale, P.Y * FScale);
    P.Y := Box.Y;
    LineTo(P.X * FScale, P.Y * FScale);
  end;

begin
  DrawLabels(g);

  StrokeThickness := 1;
  xrange := XMax - XMin;
  yrange := YMax - YMin;

  { ChartPunktX }
  WantChartPunktX := True;
  if WantChartPunktX then
  begin
    StrokeColor := CssRed;
    tempX := Box.Width * ((ChartPunktX) - Xmin) / xrange;
    tempY := Box.Height;
    DrawVerticalLine;

    StrokeColor := CssSilver;
    tempX := Box.Width * (ChartPunktX - APWidth - Xmin) / xrange;
    DrawVerticalLine;

    tempX := Box.Width * (ChartPunktX + APWidth - Xmin) / xrange;
    DrawVerticalLine;
  end;

  Radius := 3 * FScale;

  for param := 0 to ParamCount-1 do
  begin
    { Kurve }
    StrokeColor := cf[param];
    tempY := Box.Height - Box.Height * (bf[param, 0] - Ymin) / yrange;
    P.X := Box.X;
    P.Y := Box.Y + Round(Limit(tempY));
    LineToPoint.X := Round(P.X * FScale);
    LineToPoint.Y := Round(P.Y * FScale);
    for i := 1 to LNr do
    begin
      tempX := Box.Width * i / LNr;
      tempY := Box.Height - Box.Height * (bf[param, i] - Ymin) / yrange;
      P.X := Box.X + Limit(tempX);
      P.Y := Box.Y + Limit(tempY);
      LineTo(P.X * FScale, P.Y * FScale);
    end;

    if WantRectangles then
    begin
      { Rechtecke }
      StrokeThickness := 1.0;
      StrokeColor := CssWhite;
      FillColor := cf[param];
      for i := 0 to LNr do
      begin
        tempX := Box.Width * i / LNr;
        tempY := Box.Height - Box.Height * (bf[param, i] - Ymin) / yrange;
        P.X := Box.X + Limit(tempX);
        P.Y := Box.Y + Limit(tempY);
        P.X := P.X * FScale;
        P.Y := P.Y * FScale;
        g.FillRectAntialias(
          RectF(P.X - Radius, P.Y - Radius,
                P.X + Radius, P.Y + Radius), FillColor);
      end;
    end;

  end;
end;

procedure TChartGraph.DrawLabels(g: TBGRABitmap);
var
  PosX: single;
  PosY: single;
  s: string;

  procedure TextRect(s: string);
  begin
    g.TextOut(PosX, PosY, s, CssSilver);
  end;

begin
  if not WantLegend then
    Exit;

  StrokeThickness := 1.0;
  StrokeColor := CssSilver;
  g.FontName := 'Consolas';
  g.FontHeight := Round(16 * FScale);

  { Column 1 }
  PosX := Padding;

  { Column 1, Row 1 }
  PosY := Padding;
  s := Format('Xmin..Xmax = %.1f .. %.1f', [Xmin, Xmax]);
  TextRect(s);

  { Column 1, Row 2 }
  PosY := PosY + Raster;
  s := Format('Ymin..Ymax = %.1f .. %.1f', [Ymin, Ymax]);
  TextRect(s);

  { Column 1, Row 3 }
  PosX := 20 * FScale;
  PosY := PosY + Raster;
  s := 'Parameter';
  TextRect(s);

  { Column 2 }
  PosX := 300 * FScale;

  { Column 2, Row 1 }
  PosY := Padding;
  s := XTitle;
  TextRect(s);

  { Column 2, Row 2 }
  PosY := PosY + Raster;
  s := YTitle;
  TextRect(s);

  { Column 2, Row 3 }
  if ParamCount > 1 then
  begin
    PosX := PosX + 15 * FScale;
    PosY := PosY + Raster;
    s := PTitle;
    TextRect(s);
  end;
end;

procedure TChartGraph.DrawLegend(g: TBGRABitmap);
var
  param: Integer;
  PosX, PosY: single;
  s: string;

  procedure TextOut(x, y: single; const s: string);
  begin
    g.TextOut(x, y, s, CssSilver);
  end;

var
  bw, bh: Integer;
  v10, v16, v20, v30: single;
begin
  if not WantLegend then
    Exit;

  if ParamCount < 2 then
    Exit;

  bw := 16;
  bh := 3;

  v10 := 10 * FScale;
  v16 := 16 * FScale;
  v20 := 20 * FScale;
  v30 := 30 * FScale;

  { continue in Colum  1, Row 4 }
  PosX := v20;
  PosY := 3 * Raster + v10;
  FillColor := CssSilver;
  g.FontName := 'Consolas';
  g.FontHeight := Round(16 * FScale);
  for param := 0 to ParamCount-1 do
  begin
    { Bullet }
    StrokeThickness := 1.0 * FScale;
    StrokeColor := CssWhite;
    FillColor := cf[param];
    g.FillRectAntialias(PosX, PosY, PosX + bw, PosY + bh, FillColor);

    { Text }
    FillColor := CssSilver;
    PosY := PosY + v16;
    if Valid then
      s := PText[param]
    else
      s := PColorText[param];
    TextOut(PosX, PosY, s);
    PosY := PosY + v30;
  end;
end;

end.
