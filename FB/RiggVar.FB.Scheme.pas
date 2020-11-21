unit RiggVar.FB.Scheme;

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
  BGRABitmap,
  BGRABitmapTypes,
  RiggVar.FB.Color;

type
  TColorScheme = record
  public
    WantBlackText: Boolean;

    Scheme: Integer;
    SchemeDefault: Integer;

    claBackground: TRggColor;
    claToolBtnFill: TRggColor;
    claTouchBtnFill: TRggColor;
    claCornerScrollbar: TRggColor;
    claCornerBtnText: TRggColor;
    claTouchbarText: TRggColor;
    claNull: TRggColor;

    cssBackground: TBGRAPixel;
    cssToolBtnFill: TBGRAPixel;
    cssTouchBtnFill: TBGRAPixel;
    cssCornerScrollbar: TBGRAPixel;
    cssCornerBtnText: TBGRAPixel;
    cssTouchbarText: TBGRAPixel;
    cssNull: TBGRAPixel;

    IsDark: Boolean;

    Dark: Integer;
    Light: Integer;

    constructor Create(cs: Integer);

    procedure BlackText;
    procedure GrayText;
    procedure WhiteText;

    procedure Init(cs: Integer);
  end;

implementation

{ TColorScheme }

procedure TColorScheme.BlackText;
begin
  claToolBtnFill := TRggColors.Gray;
  claTouchBtnFill := TRggColors.Gray;
  claCornerScrollbar := TRggColors.Gray;
  claCornerBtnText:= TRggColors.Blue;

  cssToolBtnFill := CssGray;
  cssTouchBtnFill := CssGray;
  cssCornerScrollbar := CssGray;
  cssCornerBtnText:= CssBlue;
end;

procedure TColorScheme.GrayText;
begin
  claToolBtnFill := TRggColors.Gray;
  claTouchBtnFill := TRggColors.Gray;
  claCornerScrollbar := TRggColors.Gray;
  claCornerBtnText:= TRggColors.Blue;

  cssToolBtnFill := CssGray;
  cssTouchBtnFill := CssGray;
  cssCornerScrollbar := CssGray;
  cssCornerBtnText:= CssBlue;
end;

procedure TColorScheme.WhiteText;
begin
  claToolBtnFill := TRggColors.White;
  claTouchBtnFill := TRggColors.White;
  claCornerScrollbar := TRggColors.Gray;
  claCornerBtnText:= TRggColors.White;

  cssToolBtnFill := CssWhite;
  cssTouchBtnFill := CssWhite;
  cssCornerScrollbar := CssGray;
  cssCornerBtnText:= CssWhite;
end;

constructor TColorScheme.Create(cs: Integer);
begin
  Dark := 5;
  Light := 2;
  WantBlackText := True;

  claTouchbarText := TRggColors.Black;
  claNull := TRggColors.Null;

  cssTouchbarText := CssBlack;
  cssNull := CssWhite;

  SchemeDefault := cs;
  Scheme := SchemeDefault;
  Init(Scheme);
end;

procedure TColorScheme.Init(cs: Integer);
begin
  Scheme := cs;
  IsDark := True;

  case cs of
    1:
    begin
      if WantBlackText then
      begin
        claBackground := TRggColors.Slateblue;
        claToolBtnFill := TRggColors.Gray;
        claTouchBtnFill := TRggColors.Gray;
        claCornerScrollbar := TRggColors.Lightsalmon;
        claCornerBtnText:= TRggColors.Blue;
      end
      else
      begin
        claBackground := TRggColors.Lavender;
        claToolBtnFill := TRggColors.Gray;
        claTouchBtnFill := TRggColors.Gray;
        claCornerScrollbar := TRggColors.Gray;
        claCornerBtnText:= TRggColors.Blue;
      end;
    end;
    2:
    begin
      IsDark := False;
      claBackground := TRggColors.ColorF9F9F9;
      claToolBtnFill := TRggColors.Gray;
      claTouchBtnFill := TRggColors.Gray;
      claCornerScrollbar := TRggColors.Lavender;
      claCornerBtnText:= TRggColors.Blue;
    end;
    3:
    begin
      claBackground := TRggColors.Cornflowerblue;
      claToolBtnFill := TRggColors.White;
      claTouchBtnFill := TRggColors.White;
      claCornerScrollbar := TRggColors.White;
      claCornerBtnText:= TRggColors.Black;
    end;
    4:
    begin
      claBackground := TRggColors.Color372E69;
      claToolBtnFill := TRggColors.White;
      claTouchBtnFill := TRggColors.White;
      claCornerScrollbar := TRggColors.Antiquewhite;
      claCornerBtnText:= TRggColors.Blue;
    end;
    5:
    begin
      claBackground := TRggColors.Color333333;
      claToolBtnFill := TRggColors.White;
      claTouchBtnFill := TRggColors.White;
      claCornerScrollbar := TRggColors.WindowWhite;
      claCornerBtnText:= TRggColors.Blue;
    end;
    6:
    begin
      claBackground := TRggColors.Black;
      claToolBtnFill := TRggColors.White;
      claTouchBtnFill := TRggColors.White;
      claCornerScrollbar := TRggColors.Lightgray;
      claCornerBtnText:= TRggColors.Blue;
    end;
    7:
    begin
      claBackground := TRggColors.Purple;
      claToolBtnFill := TRggColors.Gray;
      claTouchBtnFill := TRggColors.Gray;
      claCornerScrollbar := TRggColors.Lightgoldenrodyellow;
      claCornerBtnText:= TRggColors.Blue;
    end;
  end;

  case cs of
    1:
    begin
      if WantBlackText then
      begin
        cssBackground := CssSlateblue;
        cssToolBtnFill := CssGray;
        cssTouchBtnFill := CssGray;
        cssCornerScrollbar := CssLightsalmon;
        cssCornerBtnText:= CssBlue;
      end
      else
      begin
        cssBackground := CssLavender;
        cssToolBtnFill := CssGray;
        cssTouchBtnFill := CssGray;
        cssCornerScrollbar := CssGray;
        cssCornerBtnText:= CssBlue;
      end;
    end;
    2:
    begin
      IsDark := False;
      cssBackground.FromColor(TRggColors.ColorF9F9F9);
      cssToolBtnFill := CssGray;
      cssTouchBtnFill := CssGray;
      cssCornerScrollbar := CssLavender;
      cssCornerBtnText:= CssBlue;
    end;
    3:
    begin
      cssBackground := CssCornflowerblue;
      cssToolBtnFill := CssWhite;
      cssTouchBtnFill := CssWhite;
      cssCornerScrollbar := CssWhite;
      cssCornerBtnText:= CssBlack;
    end;
    4:
    begin
      cssBackground.FromColor(TRggColors.Color372E69);
      cssToolBtnFill := CssWhite;
      cssTouchBtnFill := CssWhite;
      cssCornerScrollbar := CssAntiquewhite;
      cssCornerBtnText:= CssBlue;
    end;
    5:
    begin
      cssBackground.FromColor(TRggColors.Color333333);
      cssToolBtnFill := CssWhite;
      cssTouchBtnFill := CssWhite;
      cssCornerScrollbar.FromColor(TRggColors.WindowWhite);
      cssCornerBtnText:= CssBlue;
    end;
    6:
    begin
      cssBackground := CssBlack;
      cssToolBtnFill := CssWhite;
      cssTouchBtnFill := CssWhite;
      cssCornerScrollbar := CssLightgray;
      cssCornerBtnText:= CssBlue;
    end;
    7:
    begin
      cssBackground := CssPurple;
      cssToolBtnFill := CssGray;
      cssTouchBtnFill := CssGray;
      cssCornerScrollbar := CssLightgoldenrodyellow;
      cssCornerBtnText:= CssBlue;
    end;
  end;

end;

end.

