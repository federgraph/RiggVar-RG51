unit RggDiagram;

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
  RggChartModel;

type
  TRggBox = class
  public
    X: single;
    Y: single;
    Width: single;
    Height: single;
  end;

  { like the Graph part in ChartGraph, with CharModel injected }
  TRggDiagram = class
  private
    CM: TChartModel; // injected via constructor, not owned
    FImage: TImage; // injected via property, not owned
    FBitmap: TBGRABitmap; // owned, created in InitBitmap

    Box: TRggBox;
    Raster: Integer;
    Padding: Integer;
    FillColor: TBGRAPixel;
    StrokeColor: TBGRAPixel;
    StrokeThickness: single;

    Width: Integer;
    Height: Integer;
    FScale: single;

    procedure InitBitmap;
    procedure SetImage(const Value: TImage);
    procedure DrawToCanvas(g: TBGRABitmap);
    procedure DrawChart(g: TBGRABitmap);
    procedure DrawLabels(g: TBGRABitmap);
    procedure DrawLegend(g: TBGRABitmap);
  public
    constructor Create(Model: TChartModel);
    destructor Destroy; override;
    procedure Draw(Sender: TObject);
    property Image: TImage read FImage write SetImage;
  end;

implementation

uses
  RiggVar.App.Main;

{ TChartGraph }

constructor TRggDiagram.Create(Model: TChartModel);
begin
  CM := Model;

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

  CM.WantRectangles := True;
  CM.WantTextRect := False;
  CM.WantLegend := True;
end;

destructor TRggDiagram.Destroy;
begin
  FBitmap.Free;
  Box.Free;
  inherited;
end;

procedure TRggDiagram.InitBitmap;
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

procedure TRggDiagram.SetImage(const Value: TImage);
begin
  FImage := Value;
  InitBitmap;
end;

procedure TRggDiagram.Draw(Sender: TObject);
begin
  if (Image <> nil) and (FBitmap <> nil) then
  begin
    DrawToCanvas(FBitmap);
    FBitmap.Draw(Image.Canvas, 0, 0, True);
    Image.Invalidate;
  end;
end;

procedure TRggDiagram.DrawToCanvas(g: TBGRABitmap);
begin
  if g = nil then
    Exit;

  g.FillRect(0, 0, FBitmap.Width, FBitmap.Height, CssNavy, dmSet);
  DrawLegend(g);
  DrawChart(g);
end;

procedure TRggDiagram.DrawChart(g: TBGRABitmap);
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

  xrange := CM.XMax- CM.XMin;
  yrange := CM.YMax- CM.YMin;

  { ChartPunktX }
  WantChartPunktX := True;
  if WantChartPunktX then
  begin
    StrokeColor := CssRed;
    tempX := Box.Width * ((CM.ChartPunktX) - CM.Xmin) / xrange;
    tempY := Box.Height;
    DrawVerticalLine;

    StrokeColor := CssSilver;
    tempX := Box.Width * (CM.ChartPunktX - CM.APWidth - CM.Xmin) / xrange;
    DrawVerticalLine;

    tempX := Box.Width * (CM.ChartPunktX + CM.APWidth - CM.Xmin) / xrange;
    DrawVerticalLine;
  end;

  Radius := 3 * FScale;

  for param := 0 to CM.ParamCount - 1 do
  begin
    { Kurve }
    StrokeColor := CM.cf[param];
    tempY := Box.Height - Box.Height * (CM.bf[param, 0] - CM.Ymin) / yrange;
    P.X := Box.X;
    P.Y := Box.Y + Round(Limit(tempY));
    LineToPoint.X := Round(P.X * FScale);
    LineToPoint.Y := Round(P.Y * FScale);
    for i := 1 to LNr do
    begin
      tempX := Box.Width * i / LNr;
      tempY := Box.Height - Box.Height * (CM.bf[param, i] - CM.Ymin) / yrange;
      P.X := Box.X + Limit(tempX);
      P.Y := Box.Y + Limit(tempY);
      LineTo(P.X * FScale, P.Y * FScale);
    end;

    if CM.WantRectangles then
    begin
      { Rechtecke }
      StrokeThickness := 1.0;
      StrokeColor := CssWhite;
      FillColor := CM.cf[param];
      for i := 0 to LNr do
      begin
        tempX := Box.Width * i / LNr;
        tempY := Box.Height - Box.Height * (CM.bf[param, i] - CM.Ymin) / yrange;
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

procedure TRggDiagram.DrawLabels(g: TBGRABitmap);
var
  PosX: single;
  PosY: single;
  s: string;

  procedure TextRect(s: string);
  begin
    g.TextOut(PosX, PosY, s, CssSilver);
  end;

begin
  if not CM.WantLegend then
    Exit;

  StrokeThickness := 1.0;
  StrokeColor := CssSilver;
  g.FontName := 'Consolas';
  g.FontHeight := Round(16 * FScale);

  { Column 1 }
  PosX := Padding;

  { Column 1, Row 1 }
  PosY := Padding;
  s := Format('Xmin..Xmax = %.1f .. %.1f', [CM.Xmin, CM.Xmax]);
  TextRect(s);

  { Column 1, Row 2 }
  PosY := PosY + Raster;
  s := Format('Ymin..Ymax = %.1f .. %.1f', [CM.Ymin, CM.Ymax]);
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
  s := CM.XTitle;
  TextRect(s);

  { Column 2, Row 2 }
  PosY := PosY + Raster;
  s := CM.YTitle;
  TextRect(s);

  { Column 2, Row 3 }
  if CM.ParamCount > 1 then
  begin
    PosX := PosX + 15 * FScale;
    PosY := PosY + Raster;
    s := CM.PTitle;
    TextRect(s);
  end;
end;

procedure TRggDiagram.DrawLegend(g: TBGRABitmap);
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
  if not CM.WantLegend then
    Exit;

  if CM.ParamCount < 2 then
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
    FillColor := CM.cf[param];
    g.FillRectAntialias(PosX, PosY, PosX + bw, PosY + bh, FillColor);

    { Text }
    FillColor := CssSilver;
    PosY := PosY + v16;
    if CM.Valid then
      s := CM.PText[param]
    else
      s := CM.PColorText[param];
    TextOut(PosX, PosY, s);
    PosY := PosY + v30;
  end;
end;

end.
