unit RiggVar.RG.Def;

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

uses
  FPimage,
  BGRABitmap,
  BGRABitmapTypes,
  Graphics;

type
  TSelectedCircle = (
    scC1,
    scC2
  );

  TCircleParam = (
    fpR1,
    fpR2,
    fpM1X,
    fpM1Y,
    fpM1Z,
    fpM2X,
    fpM2Y,
    fpM2Z,
    fpA1,
    fpA2,
    fpE1,
    fpE2
  );

var
  claRumpf: TBGRAPixel;
  claMast: TBGRAPixel;
  claWanten: TBGRAPixel;
  claVorstag: TBGRAPixel;
  claSaling: TBGRAPixel;
  claController: TBGRAPixel;
  claEntspannt: TBGRAPixel;
  claNullStellung: TBGRAPixel;
  claKoppelKurve: TBGRAPixel;
  claGestrichelt: TBGRAPixel;
  claFixPoint: TBGRAPixel;

implementation

initialization
  claMast := CssBlue;
  claWanten := CssRed;
  claVorstag := CssYellow;
  claSaling := CssLime;
  claController := CssAqua;
  claEntspannt := CssGray;
  claNullStellung := CssAqua;
  claKoppelKurve := CssYellow;
  claGestrichelt := CssWhite;
  claFixPoint := CssYellow;

end.
