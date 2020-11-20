unit RggZug3D;

interface

{$ifdef fpc}
{$mode delphi}
{$endif}

uses
  Types,
  SysUtils,
  Classes,
  Graphics,
  BGRABitmap,
  BGRABitmapTypes,
  RggTypes,
  RggZug;

type
  TZug3D = class(TZug3DBase)
  public
    procedure FillZug; override;
    procedure DrawToCanvas(g: TBGRABitmap); override;
    procedure GetPlotList(ML: TStrings); override;
  end;

implementation

uses
  RiggVar.RG.Def;

{ TZug3D }

procedure TZug3D.FillZug;
begin
  with Data do
  begin
    { ZugMastfall }
    ZugMastfall[0].x := xF;
    ZugMastfall[0].y := -yF;
    ZugMastfall[1].x := xM;
    ZugMastfall[1].y := -yM;
    ZugMastfall[2].x := xF0;
    ZugMastfall[2].y := -yF0;

    { ZugRP }
    ZugRP[0].x := xN;
    ZugRP[0].y := -yN;
    ZugRP[1].x := xD0;
    ZugRP[1].y := -yD0;
    ZugRP[2].x := xP0;
    ZugRP[2].y := -yP0;
    ZugRP[3].x := xF0;
    ZugRP[3].y := -yF0;

    { Achsen }
    ZugAchsen[0].x := xN;
    ZugAchsen[0].y := -yN;
    ZugAchsen[1].x := xX;
    ZugAchsen[1].y := -yX;
    ZugAchsen[2].x := xY;
    ZugAchsen[2].y := -yY;
    ZugAchsen[3].x := xZ;
    ZugAchsen[3].y := -yZ;

    { Rumpf }
    ZugRumpf[0].x := xA0;
    ZugRumpf[0].y := -yA0;
    ZugRumpf[1].x := xB0;
    ZugRumpf[1].y := -yB0;
    ZugRumpf[2].x := xC0;
    ZugRumpf[2].y := -yC0;
    ZugRumpf[3].x := xA0;
    ZugRumpf[3].y := -yA0;

    ZugRumpf[4].x := xD0;
    ZugRumpf[4].y := -yD0;
    ZugRumpf[5].x := xB0;
    ZugRumpf[5].y := -yB0;
    ZugRumpf[6].x := xC0;
    ZugRumpf[6].y := -yC0;
    ZugRumpf[7].x := xD0;
    ZugRumpf[7].y := -yD0;

    { Mast }
    ZugMast[0].x := xD0;
    ZugMast[0].y := -yD0;
    ZugMast[1].x := xD;
    ZugMast[1].y := -yD;
    ZugMast[2].x := xC;
    ZugMast[2].y := -yC;
    ZugMast[3].x := xF;
    ZugMast[3].y := -yF;

    { WanteBb }
    ZugWanteBb[0].x := xB0;
    ZugWanteBb[0].y := -yB0;
    ZugWanteBb[1].x := xB;
    ZugWanteBb[1].y := -yB;
    ZugWanteBb[2].x := xC;
    ZugWanteBb[2].y := -yC;

    { WanteStb }
    ZugWanteStb[0].x := xA0;
    ZugWanteStb[0].y := -yA0;
    ZugWanteStb[1].x := xA;
    ZugWanteStb[1].y := -yA;
    ZugWanteStb[2].x := xC;
    ZugWanteStb[2].y := -yC;

    { SalingFS }
    ZugSalingFS[0].x := xA;
    ZugSalingFS[0].y := -yA;
    ZugSalingFS[1].x := xD;
    ZugSalingFS[1].y := -yD;
    ZugSalingFS[2].x := xB;
    ZugSalingFS[2].y := -yB;
    ZugSalingFS[3].x := xA;
    ZugSalingFS[3].y := -yA;

    { SalingDS }
    ZugSalingDS[0].x := xA;
    ZugSalingDS[0].y := -yA;
    ZugSalingDS[1].x := xD;
    ZugSalingDS[1].y := -yD;
    ZugSalingDS[2].x := xB;
    ZugSalingDS[2].y := -yB;

    { Controller }
    ZugController[0].x := xE0;
    ZugController[0].y := -yE0;
    ZugController[1].x := xE;
    ZugController[1].y := -yE;

    { Vorstag }
    ZugVorstag[0].x := xC0;
    ZugVorstag[0].y := -yC0;
    ZugVorstag[1].x := xC;
    ZugVorstag[1].y := -yC;

    { MastKurve }
    ZugMastKurve[BogenMax + 1].x := xF;
    ZugMastKurve[BogenMax + 1].y := -yF;
  end;

    ZugMastKurveD0D := Copy(ZugMastKurve, 0, Props.BogenIndexD + 1);

  ZugMastKurveDC := Copy(
    ZugMastKurve, // string or dynamic array
    Props.BogenIndexD, // start index
    Length(ZugMastKurve) - (Props.BogenIndexD + 1) // count of elements
  );
end;

procedure TZug3D.DrawToCanvas(g: TBGRABitmap);
var
  StrokeColor: TBGRAPixel;
  StrokeThickness: single;

  procedure DrawPoly(P: ArrayOfTPointF);
  begin
    g.DrawPolyLineAntialias(P, StrokeColor, StrokeThickness);
  end;

begin
  { FixPunkt }
  StrokeThickness := 4.0;
  if Props.RiggLED then
    StrokeColor := CssLime
  else
    StrokeColor := CssYellow;
  g.EllipseAntialias(Props.OffsetX, Props.OffsetY,
    TKR, TKR, StrokeColor, StrokeThickness);

  { Koppelkurve }
  if Props.Koppel then
  begin
    StrokeThickness := 1.0;
    StrokeColor := claKoppelKurve;
    DrawPoly(ZugKoppelkurve);
  end;

  { Rumpf }
  StrokeColor := CssGray;
  StrokeThickness := 8.0;
  DrawPoly(ZugRumpf);

  { Saling }
  StrokeThickness := 5;
  if Props.Coloriert then
  begin
  StrokeColor := claSaling;
  if Props.SalingTyp = stFest then
  begin
    StrokeThickness := 1;
    //FillColor := claSaling;
    StrokeThickness := 5;
    DrawPoly(ZugSalingFS);
  end
  else if Props.SalingTyp = stDrehbar then
  begin
    DrawPoly(ZugSalingDS);
  end;
  end
  else
  begin
    StrokeColor := Props.Color;
    StrokeThickness := 1;
    if Props.SalingTyp = stFest then
      DrawPoly(ZugSalingFS)
    else if Props.SalingTyp = stDrehbar then
      DrawPoly(ZugSalingDS);
  end;

  { Mast }
  if Props.Coloriert and Props.Bogen then
  begin
    StrokeColor := CssCornflowerblue;
    StrokeThickness := 12.0;
    DrawPoly(ZugMastKurve);

    StrokeColor := claMast;
    StrokeThickness := 1.0;
    DrawPoly(ZugMastKurve);
  end
  else if Props.Coloriert then
  begin
    StrokeColor := CssCornflowerblue;
    StrokeThickness := 12.0;
    DrawPoly(ZugMast);

    StrokeColor := claMast;
    StrokeThickness := 1.0;
    DrawPoly(ZugMast);
  end
  else
  begin
    StrokeColor := Props.Color;
    StrokeThickness := 1.0;
    DrawPoly(ZugMast);
  end;

  { Controller }
  if Props.ControllerTyp <> ctOhne then
  begin
    StrokeThickness := 10.0;
    StrokeColor := claController;
    DrawPoly(ZugController);
  end;

  StrokeThickness := 2.0;

  { Wante Bb }
  if Props.Coloriert then
  begin
  if Props.Gestrichelt then
    StrokeColor := CssAntiquewhite
  else
    StrokeColor := CssRed;
  end
  else
    StrokeColor := Props.Color;
  DrawPoly(ZugWanteBb);

  { Wante Stb }
  if Props.Coloriert then
  begin
  if Props.Gestrichelt then
    StrokeColor := CssAntiquewhite
  else
    StrokeColor := CssGreen;
  end
  else
    StrokeColor := Props.Color;
  DrawPoly(ZugWanteStb);

  { Vorstag }
  if Props.Coloriert then
  begin
    StrokeThickness := 3.0;
    StrokeColor := claVorstag;
  end
  else
  begin
    StrokeThickness := 1.0;
    StrokeColor := Props.Color;
  end;
  DrawPoly(ZugVorstag);
end;

procedure TZug3D.GetPlotList(ML: TStrings);
  procedure Plot(L: ArrayOfTPointF);
  var
    s: string;
    i: Integer;
  begin
    with ML do
    begin
      s := Format('PU %d %d;', [L[0].x, L[0].y]);
      Add(s);
      for i := 1 to High(L) do
      begin
        s := Format('PD %d %d;', [L[i].x, L[i].y]);
        Add(s);
      end;
    end;
  end;

begin
  with ML do
  begin
    { Rumpf }
    Add('SP 1;');
    Plot(ZugRumpf);
    { Saling }
    if (Props.SalingTyp = stFest) or (Props.SalingTyp = stDrehbar) then
    begin
      Add('SP 2;');
      if Props.SalingTyp = stFest then
        Plot(ZugSalingFS)
      else if Props.SalingTyp = stDrehbar then
        Plot(ZugSalingDS);
    end;
    { Mast }
    Add('SP 3;');
    Plot(ZugMast);
    Add('SP 4;');
    Plot(ZugMastKurve);
    { Controller }
    Add('SP 5;');
    if Props.ControllerTyp <> ctOhne then
      Plot(ZugController);
    { Wanten }
    Add('SP 6;');
    Plot(ZugWanteStb);
    Add('SP 7;');
    Plot(ZugWanteBb);
    { Vorstag }
    Add('SP 8;');
    Plot(ZugVorstag);
  end;
end;

end.
