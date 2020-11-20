unit RggTrimmTabGraph;

interface

uses
  {$ifdef fpc}
    LCLType,
  {$else}
    Winapi.Windows,
  {$endif}
  SysUtils,
  Types,
  Graphics,
  ExtCtrls,
  RggTypes,
  RggTrimmTab;

type

  { TTrimmTabGraph }

  TTrimmTabGraph = class
  private
    FScale: single;
    Margin: Integer;
    BackgroundColor: TColor;
    Width: Integer;
    Height: Integer;
    FImage: TImage;
    FBitmap: TBitmap;
    function Scale(Value: Integer): Integer;
    procedure SetImage(const Value: TImage);
    procedure InitBitmap;
    procedure PaintBackGround(g: TCanvas);
    procedure DrawGraph(g: TCanvas);
    procedure DrawText(g: TCanvas);
  public
    Model: TTrimmTabGraphModel;

    constructor Create;
    destructor Destroy; override;

    procedure Draw;
    property Image: TImage read FImage write SetImage;
  end;

implementation

uses
  RiggVar.App.Main;

constructor TTrimmTabGraph.Create;
begin
  FScale := MainVar.Scale;
  Margin := Scale(5);
  BackgroundColor := clWhite;

  Width := 319; // unscaled value
  Height := 158; // unscaled value

  Model := TTrimmTabGraphModel.Create;
end;

destructor TTrimmTabGraph.Destroy;
begin
  FBitmap.Free;
  Model.Free;
  inherited;
end;

procedure TTrimmTabGraph.PaintBackGround(g: TCanvas);
var
  R: TRect;
begin
  R := Rect(0, 0, Image.Width, Image.Height);
  g.Brush.Color := BackgroundColor;
  g.FillRect(R);
end;

procedure TTrimmTabGraph.DrawGraph(g: TCanvas);
var
  P: TPoint;
  R: TRect;
  i, RadiusX, RadiusY: Integer;
  tempX, tempY: double;
  W, H: Integer;

  function Limit(a: double): double;
  begin
    if a < -32000 then
      a := -32000
    else if a > 32000 then
      a := 32000;
    result := a;
  end;

  procedure DrawR;
  begin
    g.Rectangle(
      P.X - RadiusX,
      H - P.Y - RadiusY,
      P.X + RadiusX,
      H - P.Y + RadiusY);
  end;
begin
  W := Scale(Width);
  H := Scale(Height);

  { Radius }
  R.Left := 0;
  R.Top := 0;
  R.Bottom := Scale(4);
  R.Right := R.Bottom;
  RadiusX := R.Right - R.Left;
  RadiusY := R.Bottom - R.Top;

  { Kurve }
  g.Pen.Color := clBlue;
  case Model.TabellenTyp of
    itKonstante:
      begin
        tempY := H * (Model.x1 / Model.EndwertKraft);
        P.Y := Round(Limit(tempY));
        g.MoveTo(0, H - P.Y);
        g.LineTo(W, H - P.Y);
      end;
    itGerade:
      begin
        g.MoveTo(0, H);
        g.LineTo(W, 0);
      end;
    itParabel, itBezier:
      begin
        g.MoveTo(0, H);
        for i := 0 to 100 do
        begin
          P.X := Round(Limit(W * Model.LineDataX[i]));
          P.Y := Round(Limit(H * Model.LineDataY[i]));
          g.LineTo(P.X, H - P.Y);
        end;
      end;
  end;

  { Rechtecke }
  g.Pen.Color := clBlack;
  g.Brush.Color := clYellow;
  g.Brush.Style := bsSolid;
  for i := 1 to Model.PunkteAnzahl do
  begin
    tempX := W * Model.Kurve[i].Y / Model.EndwertWeg;
    tempY := H * Model.Kurve[i].X / Model.EndwertKraft;
    P.X := Round(Limit(tempX));
    P.Y := Round(Limit(tempY));
    DrawR;
  end;

  g.Pen.Color := clBlack;
  g.Brush.Color := clRed;
  g.Brush.Style := bsSolid;

  if Model.TabellenTyp > itGerade then
  begin
    tempX := W * Model.y1 / Model.EndwertWeg;
    tempY := H * Model.x1 / Model.EndwertKraft;
    P.X := Round(Limit(tempX));
    P.Y := Round(Limit(tempY));
    DrawR;
  end;

  P := Point(0, 0);
  DrawR;

  tempX := W * Model.y2 / Model.EndwertWeg;
  tempY := H * Model.x2 / Model.EndwertKraft;
  P.X := Round(Limit(tempX));
  P.Y := Round(Limit(tempY));
  DrawR;
end;


procedure TTrimmTabGraph.DrawText(g: TCanvas);
var
  PosX, PosY: Integer;
  s: string;
begin
  g.Brush.Style := bsClear;
  PosX := Margin;
  PosY := Margin;
  g.TextOut(PosX, PosY, 'Kraft [N]');

  g.Font.Color := clBlack;
  PosY := PosY + Scale(20);
  s := Format('(%d ... %d)', [0, Model.EndwertKraft]);
  g.TextOut(PosX, PosY, s);

  PosX := Width - Margin  - Scale(100);
  PosY := Height - Margin - Scale(20);
  g.TextOut(PosX, PosY, 'Weg [mm]');

  g.Font.Color := clBlack;
  PosY := PosY - Scale(20);
  s := Format('(%d ... %d)', [0, Model.EndwertWeg]);
  g.TextOut(PosX, PosY, s);

  g.Brush.Style := bsSolid;
  g.Brush.Color := clBtnFace;
end;

function TTrimmTabGraph.Scale(Value: Integer): Integer;
begin
  result := Round(Value * FScale);
end;

procedure TTrimmTabGraph.SetImage(const Value: TImage);
begin
  FImage := Value;
  InitBitmap;
end;

procedure TTrimmTabGraph.InitBitmap;
begin
  if FBitmap <> nil then
  begin
    FBitmap.Free;
  end;
  FBitmap := TBitmap.Create;
  FBitmap.Width := Scale(Width);
  FBitmap.Height := Scale(Height);
  Image.Width := Width;
  Image.Height := Height;
end;

procedure TTrimmTabGraph.Draw;
begin
  if Image = nil then
    Exit;

  PaintBackground(FBitmap.Canvas);

  DrawGraph(FBitmap.Canvas);
  DrawText(FBitmap.Canvas);

  Image.Canvas.CopyMode := cmSrcCopy;
  Image.Canvas.Draw(0, 0, FBitmap);
end;

end.
