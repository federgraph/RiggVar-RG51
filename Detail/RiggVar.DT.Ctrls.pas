unit RiggVar.DT.Ctrls;

interface

{$ifdef fpc}
{$mode delphi}
{$endif}

uses
  BGRABitmap,
  BGRABitmapTypes,
  BGRACanvas2D,
  Graphics,
  SysUtils,
  Classes,
  Types,
  ExtCtrls,
  RiggVar.RG.Types,
  RiggVar.DT.Profile;

type
  TFigure = (
    dtTest,
    dtSalingAll,
    dtSalingDetail,
    dtController,
    dtProfileDrawHoch,
    dtProfileDrawQuer,
    dtProfilePathHoch,
    dtProfilePathQuer,
    dtProfileOuter,
    dtProfileInner,
    dtProfileLeft,
    dtProfileRight
  );

  TSalingGraph = class(TMastProfile)
  private
    { Fixed Width and Height }
    FWidth: Integer;
    FHeight: Integer;
    FScale: single;
    function ScaledValue(Value: single): Integer;
    procedure ClearBackground(g: TBGRACanvas2D);
  private
    FImage: TImage; // injected, not owned
    FBitmap: TBGRABitmap; // owned, created in InitBitmap
    FCanvas: TBGRACanvas2D;
    procedure InitBitmap;
    procedure SetImage(const Value: TImage);
  private
    procedure BeginTransform(g: TBGRACanvas2D);
    procedure EndTransform(g: TBGRACanvas2D);
  private
    procedure DrawToCanvas(g: TBGRACanvas2D);
    procedure DrawSalingDetail(g: TBGRACanvas2D);
    procedure DrawController(g: TBGRACanvas2D);
  private
    Figure: TFigure;
    DrawCounter: Integer;
  public
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  public
    BackgroundColor: TBGRAPixel;
    ImageOpacity: single;

    ControllerTyp: TControllerTyp;

    EdgePos: Integer; { Abstand von E0 zur Anschlagkante Deck + Klotzdicke }
    ControllerPos: Integer; { Abstand(iP[ooE0,x], iP[ooE ,x]) in mm }
    ParamXE: double; { Abstand(iP[ooD0,x], iP[ooE,x]) in mm }
    ParamXE0: Integer; { Abstand(iP[ooD0,x], iP[ooE0,x]) in mm }

    SalingA: Integer; { Abstand(iP[ooA,x], iP[ooB,x]) in mm }
    SalingH: Integer; { Abstand Verbindungslinie Salinge zu Hinterkante Mast in mm }
    SalingL: Integer; { Salinglänge in mm - außerhalb berechnen }
    SalingHOffset: Integer; { Abstand Hinterkante Mast zur neutrale Faser in mm }

    WantDebugColor: Boolean;

    constructor Create;
    destructor Destroy; override;

    procedure Draw(f: TFigure);

    property Image: TImage read FImage write SetImage;
  end;

implementation

uses
  RiggVar.App.Main;

constructor TSalingGraph.Create;
begin
  inherited;

  FScale := MainVar.Scale;
  FWidth := 453;
  FHeight := 220;

  BackgroundColor := CssAntiquewhite;
  ImageOpacity := 1.0;

  ControllerTyp := ctDruck;

  { Properties für ControllerGraph in mm }
  EdgePos := 25;
  ControllerPos := 80;
  ParamXE := -20;
  ParamXE0 := 110;

  { Properties für SalingGraph in mm }
  SalingHOffset := 37;
  SalingH := 80;
  SalingA := 800;
  SalingL := 1000;
end;

destructor TSalingGraph.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

function TSalingGraph.ScaledValue(Value: single): Integer;
begin
  result := Round(Value * FScale);
end;

procedure TSalingGraph.InitBitmap;
begin
  if FBitmap <> nil then
  begin
    FBitmap.Free;
  end;
  FBitmap := TBGRABitmap.Create(ScaledValue(Width), ScaledValue(Height), CssNavy);
  Image.Width := Width;
  Image.Height := Height;
  FCanvas := FBitmap.Canvas2D;
end;

procedure TSalingGraph.SetImage(const Value: TImage);
begin
  FImage := Value;
  InitBitmap;
end;

procedure TSalingGraph.DrawSalingDetail(g: TBGRACanvas2D);
var
  SalingX, SalingY: single;
  PosX, PosY: single;
  s: string;
  LineToPoint: TPointF;
  rw: single;

  oy: single;

  otx: single;
  oty: single;
  th: single;

  procedure MoveToLineTo(x1, y1, x2, y2: single);
  begin
    g.beginPath;
    g.moveTo(x1, oy + y1);
    LineToPoint := PointF(x2, oy + y2);
    g.lineTo(LineToPoint);
    g.closePath;
    g.stroke();
  end;

  procedure LineTo(x2, y2: single);
  begin
    g.beginPath;
    g.moveTo(LineToPoint);
    LineToPoint := PointF(x2, oy + y2);
    g.lineTo(LineToPoint);
    g.closePath;
    g.stroke();
  end;

  procedure DrawCircle(cx, cy, radius: single);
  begin
    g.beginPath;
    g.ellipse(cx, cy + oy, radius, radius);
    g.closePath;
    g.fill();
    g.stroke();
  end;

  procedure FillCircle(cx, cy, radius: single);
  begin
    g.beginPath;
    g.ellipse(cx, cy + oy, radius, radius);
    g.closePath;
    g.fill();
  end;

  procedure TextOut(x, y: single; s: string);
  begin
    g.fillText(s, x * FScale, y * FScale);
  end;

begin
  oy := 350;

  g.lineJoinLCL := TPenJoinStyle.pjsRound;
  g.lineCapLCL := TPenEndCap.pecRound;

  { SalingL }
  g.lineWidth := 16.0;
  g.strokeStyle(CssGray);
  MoveToLineTo(-SalingA / 2, 0, 0, -SalingH);
  LineTo(SalingA / 2, 0);

  { SalingH }
  g.lineWidth := 2.0;
  g.strokeStyle(CssAqua);
  MoveToLineTo( 0, -SalingH, 0, 0);

  { SalingH - SalingHOffset }
  SalingY := SalingH - SalingHOffset;
  g.lineWidth := 2.0;
  g.strokeStyle(CssFuchsia);
  MoveToLineTo( -10, -SalingY, -10, 0);

  { SalingA }
  SalingX := (SalingA * 0.5);
  SalingY := SalingH;
  g.lineWidth := 5.0;
  g.strokeStyle(CssAqua);
  MoveToLineTo(-SalingX, 0, SalingX, 0);

  { Wanten als Kreise }
  rw := 10.0;
  g.lineWidth := 2.0;
  g.strokeStyle(CssGray);
  g.fillStyle(CssRed);
  DrawCircle(-SalingX, 0, rw);
  DrawCircle( SalingX, 0, rw);
  rw := 10.0;
  DrawCircle(0, -SalingY, rw);

  { Profilschnitt }
  g.lineWidth := 1.0;
  g.strokeStyle(CssAqua);
  g.fillStyle(CssSilver);
  WantSegmentColor := True;
  WantRight := False;
  WantLeft := False;
  WantOuter := True;
  WantInner := False;
  OffsetX := 0;
  OffsetY := (oy - SalingH + SalingHOffset);
  ProfileZoom := 1.0;
  ProfileOpacity := 0.5;
  InternalDrawProfile6(g);

  { Text }
  g.resetTransform;

  g.fontEmHeight := 17 * FScale;
  otx := 453 / 2;
  oty := 30;
  th := 30;

  g.fillStyle(CssYellow);
  PosX := 180;
  PosY := oty + 0 * th;
  s := Format('SHO = %d mm',[SalingHOffset]);
  TextOut(PosX, PosY, s);

  g.fillStyle(CssLime);
  PosX := otx + 20;
  PosY := oty + 1 * th;
  s := Format('SalingL = %d mm',[SalingL]);
  TextOut(PosX, PosY, s);

  g.fillStyle(CssAqua);
  PosX := 20;
  PosY := oty + 2 * th;
  s := Format('SalingH = %d mm',[SalingH]);
  TextOut(PosX, PosY, s);

  g.fillStyle(CssFuchsia);
  PosX := 100;
  PosY := oty + 4 * th;
  s := Format('SalingH - SHO = %d mm',[SalingH - SalingHOffset]);
  TextOut(PosX, PosY, s);

  g.fillStyle(CssWhite);
  PosX := 150;
  PosY := oty + 5 * th;
  s := Format('SalingA = %d mm',[SalingA]);
  TextOut(PosX, PosY, s);

  g.closePath;;
end;

procedure TSalingGraph.DrawController(g: TBGRACanvas2D);
var
  R: TRectF;
  i: Integer;
  KlotzX1: single;
  KlotzX2: single;
  PosXE0: single;
  StrichX: single;
  PositionXE0: single;
  PositionXE: single;
  ProfilPosMastfuss: single;
  ProfilPosXE: single;
  EdgePosition: single;
  claDeck: TBGRAPixel;

  s: string;

  procedure TextOut(x, y: single; s: string);
  begin
    g.fillText(s, x, y);
  end;

  procedure DrawLine(A, B: TPointF);
  begin
    g.beginPath;
    g.moveTo(A.x, A.y);
    g.lineTo(B.x, B.y);
    g.closePath;
    g.stroke;
  end;

  procedure DrawRect(R: TRectF);
  begin
    g.beginPath;
    g.rect(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    g.stroke;
  end;

  procedure FillRect(R: TRectF);
  begin
    g.beginPath;
    g.rect(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    g.fill;
  end;

  procedure FillRoundRect(R: TRectF; radius: single);
  begin
    g.beginPath;
    g.roundRect(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, radius);
    g.fill;
  end;

begin
  WantDebugColor := False;

  PositionXE0 := 95; { Position der Ablesemarke, Konstante in der Grafik }
  PositionXE := PositionXE0 - ControllerPos; { Position linke Kante Mastklotz }
  ProfilPosMastfuss := PositionXE0 - ParamXE0 - 72; { Position Hinterkante Mastfuss }
  ProfilPosXE := ProfilPosMastfuss + ParamXE; { Position Hinterkante Mast in Höhe Punkt E }
  EdgePosition := PositionXE0-EdgePos + 15; { Abstand Deckanschlag - E0 }

  OffsetX := 0;
  Lage := Quer;

  claDeck := CssCornflowerblue;

  { new window extension: 2 * 100 = -100..100 }

  { Deck Seite Stb }
  g.fillStyle(claDeck);
  R := RectF(-100, -80, 85, -32);
  FillRoundRect(R, 20);

  { Deck Seite Bbd }
  g.fillStyle(claDeck);
  R := RectF(-100, 32, 85, 80);
  FillRoundRect(R, 20);

  { Deck vorn }
  KlotzX1 := EdgePosition - 10 - 5; // EdgePosition - Radius, at least
  KlotzX2 := 100; // or bigger
  R := RectF(KlotzX1, -80, KlotzX2,  80);
  if WantDebugColor then
    g.fillStyle(CssLime)
  else
    g.fillStyle(claDeck);
  FillRect(R);

  { rechter Klotz mit Rundung im Deckausschnitt }
  KlotzX2 := EdgePosition; // Kante Deck vorn !
  KlotzX1 := KlotzX2 - 50; //does not matter much, should just be wide enough
  if WantDebugColor then
    g.fillStyle(CssBeige)
  else
    g.fillStyle(BackgroundColor);
  R := RectF(KlotzX1, -32, KlotzX2,  32);
  FillRoundRect(R, 10);

  { Profil Grau - Mastfuß }
  OffsetY := ProfilPosMastfuss; { OffsetY entspricht OffsetX, da gedreht }
  g.lineWidth := 1.0;
  g.strokeStyle(CssGray);
  InternalDrawProfile3(g);

  { Profil Blau - in Höhe E }
  OffsetY := ProfilPosXE;
  g.lineWidth := 2.0;
  g.strokeStyle(CssAqua);
  InternalDrawProfile3(g);

  { Only show Controller when used }
  if ControllerTyp <> ctOhne then
  begin
    { linker Klotz }
    KlotzX1 := PositionXE;
    KlotzX2 := KlotzX1 + 15;
    R := RectF(KlotzX1, -40, KlotzX2,  40);
    g.lineWidth := 3.0;
    g.strokeStyle(CssGray);
    DrawRect(R);
    g.fillStyle(CssAqua);
    FillRect(R);

    { Maßband Hintergrund }
    PosXE0 := PositionXE0;
    R := RectF(KlotzX1, -7, PosXE0 + 10, 7);
    g.lineWidth := 3.0;
    g.strokeStyle(CssRed);
    DrawRect(R);
    g.fillStyle(CssGray);
    FillRect(R);

    { Teilung }
    StrichX := KlotzX1;
    g.lineWidth := 1.0;
    g.strokeStyle(CssWhite);
    for i := 1 to 20 do
    begin
      StrichX := StrichX + 10;
      DrawLine(PointF(StrichX, -5), PointF(StrichX, 5));
    end;

    { Hintergrund für Teilung Text}
    PosXE0 := PositionXE0;
    R := RectF(KlotzX1, -2, PosXE0 + 10, 3.5);
    g.fillStyle(CssGray);
    FillRect(R);

    { Ablesemarke (Rechteck) an Stelle EO }
    g.lineWidth := 2.0;
    g.strokeStyle(CssYellow);
    R := RectF(PosXE0 - 2, -6, PosXE0 + 2, 6);
    DrawRect(R);

    { Teilung-Text }
    g.fontEmHeight := 7;
    g.lineWidth := 0.2;
    g.fillStyle(CssYellow);
    g.textAlignLCL := TAlignment.taCenter;
    StrichX := KlotzX1;
    for i := 1 to 20 do
    begin
      s := IntToStr(i);
      StrichX := StrichX + 10;
      TextOut(StrichX, 3, s);
    end;

    { Ablesemarke-Text }
    g.fillStyle(CssYellow);
    TextOut(PosXE0, -16, 'E0');
    TextOut(0, 40, 'Ablesemarke an Position E0 + Offset');
    g.closePath;
  end;
end;

procedure TSalingGraph.BeginTransform(g: TBGRACanvas2D);
var
  w: single;
  h: single;
  Extent: single;
  NewExtent: single;
  PaintboxZoom: single;
  OriginX: single;
  OriginY: single;
  Zoom: single;
begin
  w := Width * FScale;
  h := Height * FScale;

  OriginX := 0.5 * w;
  OriginY := 0.5 * h;

  Extent := 72; // Profile = 72 mm hoch

  case Figure of
    //dtTest:
    //begin
    //  NewExtent := 2 * 500;
    //  OriginY := -250;
    //end;

    dtProfileOuter:
    begin
      NewExtent := w;
      OriginY := h;
    end;

    dtProfileDrawHoch:
    begin
      Zoom := 0.9;
      NewExtent := Extent * w / h;
      NewExtent := NewExtent / Zoom;
      OriginY := 0;
    end;

    dtProfileDrawQuer:
    begin
      Zoom := 0.5;
      NewExtent := Extent / Zoom;
      OriginX := 0.25 * w;
    end;

    dtProfilePathHoch:
    begin
      NewExtent := Extent * w / h;
      OriginY := 0;
    end;

    dtProfilePathQuer:
    begin
      Zoom := 0.5;
      NewExtent := Extent / Zoom;
    end;

    dtSalingDetail:
    begin
      NewExtent := 2 * 500;
      OriginY := 0;
    end;

    //dtSalingAll:
    //begin
    //  NewExtent := 2 * 500;
    //  OriginY := 20;
    //end;

    dtController:
    begin
      NewExtent := 2 * 100;
      OriginY := 0.25 * w;
    end;

    else
    begin
      NewExtent := w;
      OriginY := 0;
    end;
  end;

  PaintboxZoom := w / NewExtent;

  g.resetTransform;
  g.translate(OriginX, OriginY);
  g.scale(PaintboxZoom, PaintboxZoom);
end;

procedure TSalingGraph.EndTransform(g: TBGRACanvas2D);
begin
  g.resetTransform;
end;

procedure TSalingGraph.DrawToCanvas(g: TBGRACanvas2D);
begin
  Inc(DrawCounter);
  ClearBackground(g);
  BeginTransform(g);
  try
    case Figure of
      dtTest: ;
      dtSalingAll: ;
      dtSalingDetail: DrawSalingDetail(g);
      dtController: DrawController(g);

      dtProfileOuter:
      begin
        StrokeThickness := 1.0;
        StrokeColor := CssRed;
        FillColor := CssSilver;
        WantSegmentColor := False;
        WantRight := False;
        WantLeft := False;
        WantOuter := True;
        WantInner := False;
        OffsetX := 0;
        OffsetY := -10;
        ProfileZoom := 2.5;
        ProfileOpacity := 1.0;
        //InternalDrawProfile6(g);
      end;
      dtProfileInner: ;
      dtProfileLeft: ;
      dtProfileRight: ;

      dtProfileDrawHoch:
      begin
        StrokeThickness := 1.0;
        StrokeColor := CssGreen;
        //ProfileDraw(g, Hoch, 0.5);
      end;
      dtProfileDrawQuer:
      begin
        StrokeThickness := 1.0;
        StrokeColor := CssCornflowerblue;
        //ProfileDraw(g, Quer, 1.0);
      end;
      dtProfilePathHoch:
      begin
        StrokeThickness := 0.5;
        StrokeColor := CssCrimson;
        //ProfilePath(g, Hoch, 1.0);
      end;
      dtProfilePathQuer:
      begin
        StrokeThickness := 0.5;
        StrokeColor := CssOrange;
        //ProfilePath(g, Quer, 1.0);
      end;
    end;
  finally
    EndTransform(g);
  end;
end;

procedure TSalingGraph.Draw(f: TFigure);
begin
  if (Image <> nil) and (FBitmap <> nil) then
  begin
    Figure := f;
    DrawToCanvas(FCanvas);
    FBitmap.Draw(Image.Canvas, 0, 0, True);
    Image.Invalidate;
  end;
end;

procedure TSalingGraph.ClearBackground(g: TBGRACanvas2D);
begin
  if Image = nil then
  begin
    g.clearRect(0, 0, Width * FScale, Height * FScale);
  end
  else
  begin
    FillColor := BackgroundColor;
    g.fillStyle(BackGroundColor);
    g.fillRect(0, 0, Width * FScale, Height * FScale);
  end;
end;

end.

