unit RiggVar.DT.Profile;

interface

uses
  Graphics,
  BGRABitmap,
  BGRABitmapTypes,
  BGRACanvas2D,
  RiggVar.RG.Types;

type
  TLage = (Hoch, Quer);

  TMastProfile = class
  protected
    FillColor: TBGRAPixel;
    StrokeColor: TBGRAPixel;
    StrokeThickness: single;
  protected
    Lage: TLage;
    OffsetX: single;
    OffsetY: single;
  protected
    SalingZoom1: single;
    SalingZoom2: single;
    SalingZoom3: single;
  protected
    ControllerZoom1: single;
    ControllerZoom2: single;
    ControllerZoom3: single;
  protected
    ProfileOpacity: single;
    ProfileZoom: single;
    WantInner: Boolean;
    WantOuter: Boolean;
    WantLeft: Boolean;
    WantRight: Boolean;
    WantSegmentColor: Boolean;
    procedure InternalDrawProfile3(g: TBGRACanvas2D);
    procedure InternalDrawProfile6(g: TBGRACanvas2D);
  public
    constructor Create;
  end;

implementation

constructor TMastProfile.Create;
begin
  FillColor := CssNavy;
  StrokeColor := CssYellow;
  StrokeThickness := 1.0;

  ControllerZoom1 := 1.0;
  ControllerZoom2 := 0.1;
  ControllerZoom3 := 1.0;

  SalingZoom1 := 5.0;
  SalingZoom2 := 10.0;
  SalingZoom3 := 1.0;

  ProfileZoom := 1.0;
  ProfileOpacity := 1.0;
end;

procedure TMastProfile.InternalDrawProfile3(g: TBGRACanvas2D);

  procedure MetaLINE(x1, y1, x2, y2: single);
  begin
    if Lage = Quer then
    begin
      x1 := x1 * ControllerZoom3 + OffsetX;
      y1 := y1 * ControllerZoom3 + OffsetY;
      x2 := x2 * ControllerZoom3 + OffsetX;
      y2 := y2 * ControllerZoom3 + OffsetY;
      g.beginPath;
      g.moveTo(y1, x1);
      g.lineTo(y2, x2);
      g.closePath;
      g.stroke;
    end
    else if Lage = Hoch then
    begin
      x1 := x1 * SalingZoom3 + OffsetX;
      y1 := y1 * SalingZoom3 + OffsetY;
      x2 := x2 * SalingZoom3 + OffsetX;
      y2 := y2 * SalingZoom3 + OffsetY;
      g.beginPath;
      g.moveTo(x1, y1);
      g.lineTo(x2, y2);
      g.closePath;
      g.stroke;
    end;
  end;

  procedure MetaARC(xm, ym, Radius: single; phi1, phi2: single);
  var
    a1, a2: single;
  begin
    if Lage = Quer then
    begin
      xm := xm * ControllerZoom3 + OffsetX;
      ym := ym * ControllerZoom3 + OffsetY;
      Radius := Radius * ControllerZoom3;
      a1 := (90 - phi1) * pi/180;
      a2 := (90 - phi2) * pi/180;
      g.beginPath;
      g.arc(ym, xm, Radius, a1, a2, true);
      g.stroke;
    end
    else if Lage = Hoch then
    begin
      xm := xm * SalingZoom3 + OffsetX;
      ym := ym * SalingZoom3 + OffsetY;
      Radius := Radius * SalingZoom3;
      a1 := phi1 * pi/180;
      a2 := phi2 * pi/180;
      g.beginPath;
      g.arc(xm, ym, Radius, a1, a2, true);
      g.stroke;
    end;
  end;

begin
{ MetaLINE(    x1,   y1,    x2,     y2); }
  MetaLINE(   4.90,  9.97,  10.44,    5.20);
  MetaLINE(  28.50, 40.70,  28.50,   43.50);
  MetaLINE(   3.50, 13.00,   0.00,   13.00);
  MetaLINE(  11.48,  6.09,   3.50,   13.00);
  MetaLINE(   2.00,  0.00,   5.00,    0.00);
  MetaLINE(  26.00, 31.85,  26.00,   49.00);

  MetaLINE(  -4.85, 10.02, -10.44,    5.20);
  MetaLINE(   0.00, 13.00,  -3.50,   13.00);
  MetaLINE(  -3.50, 13.00, -11.55,    6.04);
  MetaLINE( -28.50, 43.50, -28.50,   40.70);
  MetaLINE(  -5.00,  0.00,  -2.00,    0.00);
  MetaLINE( -26.00, 49.00, -26.00,   31.85);
{ MetaLINE(   0.00, 72.00,   0.00,    0.00); }

{ MetaARC(      xm,    ym,      r,    phi1,    phi2); }
  MetaARC(  -18.50, 40.70,  45.80,  -59.83,  -50.83);
  MetaARC(  -18.50, 40.70,  45.80,  -49.09,  -16.70);
  MetaARC(  -18.50, 40.70,  47.00,  -60.00,    0.00);
  MetaARC(    0.00,  4.30,   7.50,   49.15,   90.00);
  MetaARC(    0.00, 43.50,  28.50,    0.00,   90.00);
  MetaARC(    0.00, 43.50,  27.30,   26.58,   90.00);
  MetaARC(    3.50,  0.00,   1.50,   47.46,  180.00);
  MetaARC(   11.00, 31.85,  15.00,  -16.71,    0.00);
  MetaARC(   11.00, 49.00,  15.00,    0.00,   26.58);

{ MetaARC(      xm,    ym,      r,    phi1,    phi2); }
  MetaARC(  -11.00, 49.00,  15.00,  153.42,  180.00);
  MetaARC(  -11.00, 31.85,  15.00, -180.00, -163.29);
  MetaARC(   -3.50,  0.00,   1.50,    0.00,  132.53);
  MetaARC(    0.00,  4.30,   7.50,   90.00,  130.85);
  MetaARC(    0.00, 43.50,  28.50,   90.00,  180.00);
  MetaARC(    0.00, 43.50,  27.30,   90.00,  153.42);
  MetaARC(   18.50, 40.70,  45.80, -129.17, -120.16);
  MetaARC(   18.50, 40.70,  45.80, -163.29, -130.91);
  MetaARC(   18.50, 40.70,  47.00, -180.00, -120.00);
end;

procedure TMastProfile.InternalDrawProfile6(g: TBGRACanvas2D);

  procedure MetaLINE(x1, y1, x2, y2: single; cla: TBGRAPixel);
  begin
    if WantSegmentColor then
      g.strokeStyle(cla);
    x1 := x1 * ProfileZoom + OffsetX;
    y1 := -y1 * ProfileZoom + OffsetY;
    x2 := x2 * ProfileZoom + OffsetX;
    y2 := -y2 * ProfileZoom + OffsetY;
    g.beginPath;
    g.moveTo(x1, y1);
    g.lineTo(x2, y2);
    g.closePath;
    g.stroke;
  end;

  procedure MetaARC(xm, ym, Radius: single; phi1, phi2: single; cla: TBGRAPixel);
  var
    a1, a2: single;
  begin
    if WantSegmentColor then
      g.strokeStyle(cla);
    xm := xm * ProfileZoom + OffsetX;
    ym := -ym * ProfileZoom + OffsetY;
    Radius := Radius * ProfileZoom;
    a1 := -phi1 * pi/180;
    a2 := -phi2 * pi/180;
    g.beginPath;
    g.arc(xm, ym, Radius, a1, a2, true);
    g.stroke;
  end;

begin

  if WantOuter then
  begin
  MetaLINE(   5.00,  0.00, 2.00, 0.00, CssMagenta);
  MetaARC(  -18.50, 40.70, 47.00, -60.00, 0.00, CssMagenta);
  MetaLINE(  28.50, 40.70, 28.50, 43.50, CssMagenta);
  MetaARC(    0.00, 43.50, 28.50, 0.00, 90.00, CssMagenta);

  MetaARC(    0.00, 43.50, 28.50, 90.00, 180.00, CssAqua);
  MetaLINE( -28.50, 43.50, -28.50, 40.70, CssAqua);
  MetaARC(   18.50, 40.70, 47.00, -180.00, -120.00, CssAqua);
  MetaLINE(  -5.00,  0.00, -2.00, 0.00, CssAqua);

  MetaARC(   -3.50,  0.00, 1.50, 0.00, 132.53, CssLime);
  MetaARC(   18.50, 40.70, 45.80, -129.17, -120.16, CssLime);
  MetaLINE(  -4.85, 10.02, -10.44, 5.20, CssLime);
  MetaARC(    0.00,  4.30, 7.50, 90.00, 130.85, CssLime);

  MetaARC(    0.00,  4.30, 7.50, 49.15, 90.00, CssAqua);
  MetaLINE(   4.90,  9.97, 10.44, 5.20, CssAqua);
  MetaARC(  -18.50, 40.70, 45.80, -59.83, -50.83, CssAqua);
  MetaARC(    3.50,  0.00, 1.50, 47.46, 180.00, CssAqua);
  end;

  if WantInner then
  begin
  { right }
  MetaLINE(    0.0, 13.00, 3.50, 13.00, CssBlue);
  MetaLINE(   3.50, 13.00, 11.48, 6.09, CssBlue);
  MetaARC(  -18.50, 40.70, 45.80, -49.09,  -16.70, CssBlue);
  MetaARC(   11.00, 31.85, 15.00, -16.71,    0.00, CssBlue);
  MetaLINE(  26.00, 31.85, 26.00, 49.00, CssBlue);
  MetaARC(   11.00, 49.00, 15.00, 0.00,   26.58, CssBlue);
  MetaARC(    0.00, 43.50, 27.30, 26.58,   90.00, CssBlue);

  { left }
  MetaARC(    0.00, 43.50, 27.30, 90.00,  153.42, CssRed);
  MetaARC(  -11.00, 49.00, 15.00, 153.42,  180.00, CssRed);
  MetaLINE( -26.00, 49.00, -26.00, 31.85, CssRed);
  MetaARC(  -11.00, 31.85, 15.00, -180.00, -163.29, CssRed);
  MetaARC(   18.50, 40.70, 45.80, -163.29, -130.91, CssRed);
  MetaLINE( -11.55,  6.04, -3.50, 13.00, CssYellow);
  MetaLINE(  -3.50, 13.00, 0.00, 13.00, CssYellow);
  end;

  if WantRight then
  begin
{ MetaLINE(     x1,    y1,     x2,      y2, cla); }
  MetaLINE(   4.90,  9.97,  10.44,    5.20, CssRed);
  MetaLINE(  28.50, 40.70,  28.50,   43.50, CssGreen);
  MetaLINE(   3.50, 13.00,   0.00,   13.00, CssGreen);
  MetaLINE(  11.48,  6.09,   3.50,   13.00, CssYellow);
  MetaLINE(   2.00,  0.00,   5.00,    0.00, CssMagenta);
  MetaLINE(  26.00, 31.85,  26.00,   49.00, CssCyan);
  end;

  if WantLeft then
  begin
  MetaLINE(  -4.85, 10.02, -10.44,    5.20, CssRed);
  MetaLINE(   0.00, 13.00,  -3.50,   13.00, CssGreen);
  MetaLINE(  -3.50, 13.00, -11.55,    6.04, CssBlue);
  MetaLINE( -28.50, 43.50, -28.50,   40.70, CssYellow);
  MetaLINE(  -5.00,  0.00,  -2.00,    0.00, CssMagenta);
  MetaLINE( -26.00, 49.00, -26.00,   31.85, CssCyan);
{ MetaLINE(     0,  72.00,   0.00,    0.00, cla); }
  end;

  if WantRight then
  begin
{ MetaARC(      xm,    ym,      r,    phi1,    phi2); }
  MetaARC(  -18.50, 40.70,  45.80,  -59.83,  -50.83, CssRed);
  MetaARC(  -18.50, 40.70,  45.80,  -49.09,  -16.70, CssGreen);
  MetaARC(  -18.50, 40.70,  47.00,  -60.00,    0.00, CssBlue);
  MetaARC(    0.00,  4.30,   7.50,   49.15,   90.00, CssYellow);
  MetaARC(    0.00, 43.50,  28.50,    0.00,   90.00, CssMagenta);
  MetaARC(    0.00, 43.50,  27.30,   26.58,   90.00, CssCyan);
  MetaARC(    3.50,  0.00,   1.50,   47.46,  180.00, CssLime);
  MetaARC(   11.00, 31.85,  15.00,  -16.71,    0.00, CssOrange);
  MetaARC(   11.00, 49.00,  15.00,    0.00,   26.58, CssTeal);
  end;

  if WantLeft then
  begin
{ MetaARC(     xm,   ym,     r,    phi1,    phi2); }
  MetaARC(  -11.00, 49.00,  15.00,  153.42, 180.00, CssRed);
  MetaARC(  -11.00, 31.85,  15.00, -180.00, -163.29, CssGreen);
  MetaARC(   -3.50,  0.00,   1.50,    0.00,  132.53, CssBlue);
  MetaARC(    0.00,  4.30,   7.50,   90.00,  130.85, CssYellow);
  MetaARC(    0.00, 43.50,  28.50,   90.00, 180.00, CssMagenta);
  MetaARC(    0.00, 43.50,  27.30,   90.00,  153.42, CssCyan);
  MetaARC(   18.50, 40.70,  45.80, -129.17, -120.16, CssLime);
  MetaARC(   18.50, 40.70,  45.80, -163.29, -130.91, CssOrange);
  MetaARC(   18.50, 40.70,  47.00, -180.00, -120.00, CssTeal);
  end;
end;

end.
