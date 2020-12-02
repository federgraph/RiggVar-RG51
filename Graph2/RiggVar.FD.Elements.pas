unit RiggVar.FD.Elements;

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
  SysUtils,
  Classes,
  Types,
  RggSchnittKK,
  RggTypes,
  BGRABitmap,
  BGRABitmapTypes,
  RiggVar.FD.Point,
  RiggVar.FB.Color,
  LCLType,
  Math,
  Graphics;

type
  TRggColorScheme = record
    TextColor: TBGRAPixel;
    BackgroundColor: TBGRAPixel;
    LabelColor: TBGRAPixel;
    procedure GoDark;
    procedure GoLight;
  end;

  TLineSegmentCompareCase = (
    ccNone,
    ccNil,
    ccHardcodedAbove,
    ccHardcodedBelow,
    ccParallel,
    ccTotallyAbove,
    ccTotallyBelow,
    ccTotallySame,
    ccCommonNone,
    ccCommonAbove,
    ccCommonBelow,
    ccCommonSame,
    ccAbove,
    ccBelow,
    ccSame,
    ccUnknown
  );

  TDisplayItemType = (
    diLine,
    diPolyLine,
    diEllipse
  );

  TBemerkungGG = (
    g1Vertical,
    g2Vertical,
    ggParallel,
    ggOK
  );

  TRggPoint3D = record
    function Rotate(const AAngle: Single): TRggPoint3D;
    function Angle(const APoint: TRggPoint3D): single;
    function Length: single;
    function Normalize: TRggPoint3D;
    function Distance(const APoint: TRggPoint3D): single;
    class function Zero: TRggPoint3D; static;

    class operator Add(const APoint1, APoint2: TRggPoint3D): TRggPoint3D;
    class operator Subtract(const APoint1, APoint2: TRggPoint3D): TRggPoint3D;
    class operator Implicit(const APoint: TPoint): TRggPoint3D; inline;
    class operator Implicit(const APoint: TRggPoint3D): TPoint; inline;

    case Integer of
      0: (X: single;
          Y: single;
          Z: single;);
      1: (C: TPoint3D);
      2: (P: TPointF;
          T: single;);
  end;

  TRggPoly = array of TRggPoint3D;

  TRggDrawingBase = class
  public
    WantRotation: Boolean;
    WheelFlag: Boolean;
    InplaceFlag: Boolean;
    ViewpointFlag: Boolean;
    FixPoint3D: TPoint3D;
    Colors: TRggColorScheme;
    IsDark: Boolean;
    FaxPoint3D: TRggPoint3D;
    class var
      WantOffset: Boolean;
    procedure Reset; virtual; abstract;
    procedure Transform(M: TMatrix3D); virtual; abstract;
  end;

  { TRggElement }

  TRggElement = class
  private
    FStrokeColor: TBGRAPixel;
    FStrokeThickness: single;
    procedure SetStrokeColor(const Value: TBGRAPixel);
    procedure SetStrokeThickness(const Value: single);
  protected
    TypeName: string;
    TextCenter: TPointF;
    TextAngle: single;
    TextRadius: single;
    WantTextRect: Boolean;
    Temp1: TRggPoint3D;
    Temp2: TRggPoint3D;
    Temp3: TRggPoint3D;
    LineToPoint: TPointF;
    procedure TextOut(g: TBGRABitmap; s: string; c: TBGRAPixel);
    procedure TextOutLeading(g: TBGRABitmap; s: string; c: TBGRAPixel);
    procedure MoveTo(p: TPointF);
    procedure LineTo(g: TBGRABitmap; p: TPointF);
    procedure PolyLine(g:TBGRABitmap; p: ArrayOfTPointF);
  public
    Caption: string;
    ShowCaption: Boolean;
    SpecialDraw: Boolean;
    Painted: Boolean;
    IsComputed: Boolean;
    Visible: Boolean;
    Drawing: TRggDrawingBase;

    constructor Create;

    function GetListCaption: string; virtual;
    procedure GetInfo(ML: TStrings); virtual;
    function GetValid: Boolean; virtual;

    procedure Transform; virtual;
    procedure Draw(g: TBGRABitmap); virtual;

    procedure Param1(Delta: single); virtual;
    procedure Param2(Delta: single); virtual;
    procedure Param3(Delta: single); virtual;

    procedure Param7(Delta: single);
    procedure Param8(Delta: single);

    property StrokeThickness: single read FStrokeThickness write SetStrokeThickness;
    property StrokeColor: TBGRAPixel read FStrokeColor write SetStrokeColor;
  end;

  TRggLabel = class(TRggElement)
  public
    Position: TPointF;
    Text: string;
    IsMemoLabel: Boolean;
    constructor Create;
    function GetListCaption: string; override;
    procedure Draw(g: TBGRABitmap); override;
  end;

  TRggParam = class(TRggElement)
  private
    FOriginalValue: single;
    FValue: single;
    FScale: single;
    FBaseValue: single;
    procedure SetValue(const Value: single);
    function GetRelativeValue: single;
    procedure SetScale(const Value: single);
    procedure SetBaseValue(const Value: single);
  public
    StartPoint: TPointF;
    Text: string;
    constructor Create;
    procedure Save;
    procedure Reset;
    procedure Param1(Delta: single); override;
    procedure Draw(g: TBGRABitmap); override;
    property Value: single read FValue write SetValue;
    property BaseValue: single read FBaseValue write SetBaseValue;
    property OriginalValue: single read FOriginalValue;
    property RelativeValue: single read GetRelativeValue;
    property Scale: single read FScale write SetScale;
  end;

  TRggCircle = class(TRggElement)
  private
    FRadius: single;
    procedure SetRadius(const Value: single);
  protected
    property Radius: single read FRadius write SetRadius;
  public
    OriginalCenter: TRggPoint3D;
    Center: TRggPoint3D;
    class var
      Matrix: TMatrix3D;

    constructor Create; overload;
    constructor Create(ACaption: string); overload;

    procedure Save;
    procedure Reset;
    procedure Transform; override;
    procedure TransformI;
    procedure WriteCode(ML: TStrings);

    procedure Draw(g: TBGRABitmap); override;

    procedure Param1(Delta: single); override;
    procedure Param2(Delta: single); override;
    procedure Param3(Delta: single); override;

    procedure Param1I(Delta: single);
    procedure Param2I(Delta: single);

    function IsEqual(B: TRggCircle): Boolean;
    function CompareZ(Q: TRggCircle): Integer;

    class function Compare(const Left, Right: TRggCircle): Integer;
  end;

  TRggBigCircle = class(TRggCircle)
  public
    constructor Create(ACaption: string = '');
    procedure Draw(g: TBGRABitmap); override;
    procedure Param3(Delta: single); override;
    property Radius;
  end;

  TRggFixpointCircle = class(TRggCircle)
  public
    constructor Create(ACaption: string = '');
    procedure Draw(g: TBGRABitmap); override;
  end;

  TRggBigArc = class(TRggElement)
  private
    FSweepAngle: single;
    procedure SetSweepAngle(const Value: single);
  public
    Point1: TRggCircle;
    Point2: TRggCircle;

    constructor Create(ACaption: string = '');

    procedure GetInfo(ML: TStrings); override;
    function GetValid: Boolean; override;

    procedure Draw(g: TBGRABitmap); override;

    procedure Param1(Delta: single); override;

    property SweepAngle: single read FSweepAngle write SetSweepAngle;
  end;

  TRggLine = class(TRggElement)
  private
    function GetLength: single;
  public
    Point1: TRggCircle;
    Point2: TRggCircle;

    Bemerkung: TLineSegmentCompareCase;

    constructor Create(ACaption: string = '');

    procedure GetInfo(ML: TStrings); override;
    function GetValid: Boolean; override;

    procedure Draw(g: TBGRABitmap); override;
    procedure Param1(Delta: single); override;
    procedure Param2(Delta: single); override;
    function V2: TPointF;
    function V3: TPoint3D;

    function IsSame(Other: TRggLine): Boolean;
    function IsTotallyAbove(Other: TRggLine): Boolean;
    function IsTotallyBelow(Other: TRggLine): Boolean;
    function ComputeSPZ(SP: TPoint3D): single;
    procedure ReportData(ML: TStrings);

    class var
    CounterLeftNil: Integer;
    CounterRightNil: Integer;
    CounterHardCodedAbove: Integer;
    CounterHardCodedBelow: Integer;
    CounterSame: Integer;
    CounterTotallyAbove: Integer;
    CounterTotallyBelow: Integer;
    CounterCommon: Integer;
    CounterParallel: Integer;
    CounterSPZ: Integer;
    CounterZero: Integer;

    class procedure ResetCounter;
    class function CounterSum: Integer;
    class function Compare(const Left, Right: TRggLine): Integer;

    property LineLength: single read GetLength;
  end;

  TRggRotaLine = class(TRggLine)
  public
    constructor Create(ACaption: string = '');
    procedure Param1(Delta: single); override;
    procedure Param2(Delta: single); override;
  end;

  TRggLagerLine = class(TRggLine)
  private
    procedure DrawLager(g: TBGRABitmap; P: TPointF; FestLager: Boolean);
  public
    procedure Draw(g: TBGRABitmap); override;
  end;

  TRggPolyLine = class(TRggLine)
  private
    FCount: Integer;
  protected
    TransformedPoly: ArrayOfTPointF;
    procedure DrawText(g: TBGRABitmap);
  public
    Poly: ArrayOfTPointF;
    ShowPoly: Boolean;
    constructor Create(ACaption: string = ''); overload;
    constructor Create(ACaption: string; ACount: Integer); overload;
    procedure Draw(g: TBGRABitmap); override;
    property Count: Integer read FCount;
  end;

  TRggPolyCurve = class(TRggElement)
  private
    FCount: Integer;
  protected
    TransformedPoly: ArrayOfTPointF;
    procedure DrawText(g: TBGRABitmap);
  public
    Poly: ArrayOfTPointF;
    constructor Create(ACaption: string; ACount: Integer); overload;
    procedure Draw(g: TBGRABitmap); override;
    property Count: Integer read FCount;
  end;

  TRggPolyLine3D = class(TRggPolyLine)
  private
    procedure UpdateCount;
  public
    RggPoly: TRggPoly;
    WantRotation: Boolean;
    constructor Create(ACaption: string; ACount: Integer);
    procedure Transform; override;
    procedure Draw(g: TBGRABitmap); override;
    procedure Reset;
  end;

  TRggFederLine = class(TRggPolyLine)
  private
    function RotateDegrees(ov: TPoint3D; wi: single): TPoint3D;
  public
    constructor Create(ACaption: string = '');
    procedure Draw(g: TBGRABitmap); override;
  end;

  TRggTriangle = class(TRggElement)
  private
    Poly: ArrayOfTPointF;
  public
    Point1: TRggCircle;
    Point2: TRggCircle;
    Point3: TRggCircle;
    constructor Create;
    procedure GetInfo(ML: TStrings); override;
    function GetValid: Boolean; override;
    procedure Draw(g: TBGRABitmap); override;
  end;

  TRggArc = class(TRggElement)
  private
    FTextRadiusFactor: single;
    FRadius: single;
    RadiusF: TPointF;
    procedure SetRadius(const Value: single);
    function GetSweepAngle: single;
  public
    Point1: TRggCircle; // injected
    Point2: TRggCircle;
    Point3: TRggCircle;
    constructor Create(ACaption: string);
    procedure GetInfo(ML: TStrings); override;
    function GetValid: Boolean; override;
    procedure Param1(Delta: single); override;
    procedure Param2(Delta: single); override;
    procedure Draw(g: TBGRABitmap); override;
    property Radius: single read FRadius write SetRadius;
    property SweepAngle: single read GetSweepAngle;
  end;

  TRggLinePair = record
    L1: TRggLine;
    L2: TRggLine;
    SP: TPoint3D;
    function SchnittGG: Boolean;
    function HasCommonPoint: Boolean;
    function CompareCommon: Integer;
    function IsParallel: Boolean;
    function CompareSPZ: Integer;
    procedure ReportData(ML: TStrings);
    function CompareVV(v1, v2: TPoint3D): Integer;
  end;

  TSchnittKKCircleLL = class(TRggCircle)
  public
    Radius1: single;
    Radius2: single;
    L1: TRggLine;
    L2: TRggLine;
    SchnittKK: TSchnittKK;
    Counter: Integer;
    constructor Create(ACaption: string = '');
    destructor Destroy; override;
    procedure GetInfo(ML: TStrings); override;
    function GetValid: Boolean; override;
    procedure Param1(Delta: single); override;
    procedure Param2(Delta: single); override;
    procedure Compute;
    procedure InitRadius;
  end;

  TSchnittKKCircle = class(TRggCircle)
  private
    R1: single;
    R2: single;
    S1: TPoint3D;
    S2: TPoint3D;
    sv: Boolean;
    NeedCalc: Boolean;
    Bem: TBemerkungKK;
    procedure ComputeInternal;
    function GetBem: TBemerkungKK;
    function GetBemerkung: string;
    function Vorhanden: Boolean;
    function GetL1: single;
    function GetL2: single;
  public
    Radius1: single;
    Radius2: single;
    MP1: TRggCircle;
    MP2: TRggCircle;
    Counter: Integer;
    WantS2: Boolean;
    constructor Create(ACaption: string = '');
    procedure GetInfo(ML: TStrings); override;
    function GetValid: Boolean; override;
    procedure Param1(Delta: single); override;
    procedure Param2(Delta: single); override;
    procedure Compute;
    procedure InitRadius;
    procedure Draw(g: TBGRABitmap); override;
    property Status: TBemerkungKK read GetBem;
    property Bemerkung: string read GetBemerkung;
    property SPVorhanden: Boolean read Vorhanden;
    property L1: single read GetL1;
    property L2: single read GetL2;
  end;

var
  GlobalShowCaption: Boolean = False;
  DefaultShowCaption: Boolean = False;

const
  RggPoint3DZero: TRggPoint3D = (X: 0; Y: 0; Z: 0);

implementation

const
  Eps = 0.0001;
  DefaultTextAngle: single = 45 * PI / 180;
  DefaultTextRadius: single = 30.0;

{ TRggPoint3D }

class operator TRggPoint3D.Add(const APoint1, APoint2: TRggPoint3D): TRggPoint3D;
begin
  Result.X := APoint1.X + APoint2.X;
  Result.Y := APoint1.Y + APoint2.Y;
  Result.Z := APoint1.Z + APoint2.Z;
end;

class operator TRggPoint3D.Subtract(const APoint1, APoint2: TRggPoint3D): TRggPoint3D;
begin
  Result.X := APoint1.X - APoint2.X;
  Result.Y := APoint1.Y - APoint2.Y;
  Result.Z := APoint1.Z - APoint2.Z;
end;

function TRggPoint3D.Length: Single;
begin
  result := C.Length;
end;

function TRggPoint3D.Normalize: TRggPoint3D;
begin
  C := C.Normalize;
  result := self;
end;

function TRggPoint3D.Rotate(const AAngle: Single): TRggPoint3D;
var
  Sine, Cosine: Single;
begin
  Sine := sin(AAngle);
  Cosine := cos(AAngle);
  Result.X := X * Cosine - Y * Sine;
  Result.Y := X * Sine + Y * Cosine;
end;

function TRggPoint3D.Angle(const APoint: TRggPoint3D): single;
begin
  Result := Arctan2(Self.Y - APoint.Y, Self.X - APoint.X);
end;

function TRggPoint3D.Distance(const APoint: TRggPoint3D): single;
begin
  Result := (Self - APoint).Length;
end;

class function TRggPoint3D.Zero: TRggPoint3D;
begin
  result.C := TPoint3D.Zero;
end;

class operator TRggPoint3D.Implicit(const APoint: TPoint): TRggPoint3D;
begin
  result.X := APoint.X;
  result.Y := APoint.Y;
  result.Z := 0;
end;

class operator TRggPoint3D.Implicit(const APoint: TRggPoint3D): TPoint;
begin
  result.X := Round(APoint.X);
  result.Y := Round(APoint.Y);
end;

{ TRggElement }

constructor TRggElement.Create;
begin
  Visible := True;
  FStrokeThickness := 3;
  FStrokeColor := CssRed;
  TypeName := 'Element';
  TextRadius := DefaultTextRadius;
  TextAngle := DefaultTextAngle;
end;

procedure TRggElement.GetInfo(ML: TStrings);
begin
  if Caption = '' then
    ML.Add('Element has no Caption');
end;

function TRggElement.GetValid: Boolean;
begin
  result := Caption <> '';
end;

function TRggElement.GetListCaption: string;
begin
  result := TypeName + ' ' + Caption;
  if IsComputed then
    result := '-- ' + result;
end;

procedure TRggElement.Param1(Delta: single);
begin

end;

procedure TRggElement.Param2(Delta: single);
begin

end;

procedure TRggElement.Param3(Delta: single);
begin

end;

//procedure TRggElement.SetOpacity(const Value: single);
//begin
//  FOpacity := Value;
//end;

procedure TRggElement.SetStrokeColor(const Value: TBGRAPixel);
begin
  FStrokeColor := Value;
end;

//procedure TRggElement.SetStrokeDash(const Value: TStrokeDash);
//begin
//  FStrokeDash := Value;
//end;

procedure TRggElement.SetStrokeThickness(const Value: single);
begin
  FStrokeThickness := Value;
end;

procedure TRggElement.TextOut(g: TBGRABitmap; s: string; c: TBGRAPixel);
var
  x, y: single;
begin
  x := TextCenter.X + TextRadius * cos(TextAngle);
  y := TextCenter.Y + TextRadius * sin(TextAngle);
  g.FontName := 'Consolas';
  g.FontHeight := 16;
  g.TextOut(x, y, s, c);
end;

procedure TRggElement.TextOutLeading(g: TBGRABitmap; s: string; c: TBGRAPixel);
begin
  TextOut(g, s, c);
end;

procedure TRggElement.MoveTo(p: TPointF);
begin
  LineToPoint := p;
end;

procedure TRggElement.LineTo(g: TBGRABitmap; p: TPointF);
begin
  g.DrawLineAntialias(
    LineToPoint.x, LineToPoint.y,
    p.X, p.Y, StrokeColor, StrokeThickness);
  LineToPoint := p;
end;

procedure TRggElement.PolyLine(g: TBGRABitmap; p: ArrayOfTPointF);
begin
  g.DrawPolyLineAntialias(p, StrokeColor, StrokeThickness);
end;

procedure TRggElement.Transform;
begin

end;

procedure TRggElement.Param7(Delta: single);
begin
  TextAngle := TextAngle + DegToRad(Delta);
end;

procedure TRggElement.Param8(Delta: single);
begin
  TextRadius := TextRadius + Delta;
end;

procedure TRggElement.Draw(g: TBGRABitmap);
begin
  TextOut(g, Caption, Drawing.Colors.TextColor);
end;

{ TRggCircle }

constructor TRggCircle.Create;
begin
  inherited;
  Matrix := Matrix3DIdentity;
  TypeName := 'Circle';
  StrokeThickness := 2;
  FRadius := 10;
  Center.X := 100;
  Center.Y := 100;
  ShowCaption := DefaultShowCaption;
end;

constructor TRggCircle.Create(ACaption: string);
begin
  Create;
  Caption := ACaption;
end;

procedure TRggCircle.Draw(g: TBGRABitmap);
begin
  if not Visible then
    Exit;

  Temp1 := Center + Drawing.FaxPoint3D;

  g.EllipseAntialias(Temp1.X, Temp1.Y,
  Radius, Radius, StrokeColor, 1.0, Drawing.Colors.BackgroundColor);

  g.EllipseAntialias(Temp1.X, Temp1.Y,
  Radius, Radius, StrokeColor, StrokeThickness);

  if ShowCaption or GlobalShowCaption then
  begin
    TextCenter := Temp1.P;
    TextOut(g, Caption, Drawing.Colors.TextColor);
  end;
end;

procedure TRggCircle.Param1(Delta: single);
begin
  OriginalCenter.X := OriginalCenter.X + Delta;
  Center := OriginalCenter;
end;

procedure TRggCircle.Param2(Delta: single);
begin
  OriginalCenter.Y := OriginalCenter.Y + Delta;
  Center := OriginalCenter;
end;

procedure TRggCircle.Param1I(Delta: single);
begin
  Center.X := Center.X + Delta;
  OriginalCenter := Center;
end;

procedure TRggCircle.Param2I(Delta: single);
begin
  Center.Y := Center.Y + Delta;
  OriginalCenter := Center;
end;

procedure TRggCircle.Param3(Delta: single);
begin
  OriginalCenter.Z := OriginalCenter.Z + Delta;
  Center := OriginalCenter;
end;

procedure TRggCircle.Reset;
begin
  Center := OriginalCenter;
  TextAngle := DefaultTextAngle;
  TextRadius := DefaultTextRadius;
end;

procedure TRggCircle.Save;
begin
  OriginalCenter := Center;
end;

procedure TRggCircle.SetRadius(const Value: single);
begin
  FRadius := Value;
end;

procedure TRggCircle.Transform;
begin
  Center.C := Center.C * Matrix;
end;

procedure TRggCircle.TransformI;
begin
  OriginalCenter.C := OriginalCenter.C * Matrix;
end;

procedure TRggCircle.WriteCode(ML: TStrings);
begin
  ML.Add(Format('cr := Find(''%s'');', [Caption]));
  ML.Add(Format('cr.Center.X := %.2f;', [Center.X]));
  ML.Add(Format('cr.Center.Y := %.2f;', [Center.Y]));
  ML.Add(Format('cr.Center.Z := %.2f;', [Center.Z]));

  if TextAngle <> DefaultTextAngle then
    ML.Add(Format('cr.TextAngle := %.2f;', [RadToDeg(TextAngle)]));
  if TextRadius <> DefaultTextRadius then
    ML.Add(Format('cr.TextRadius := %.2f;', [TextRadius]));

  ML.Add('');
end;

function TRggCircle.IsEqual(B: TRggCircle): Boolean;
begin
  result := Center.C = B.Center.C;
end;

function TRggCircle.CompareZ(Q: TRggCircle): Integer;
begin
  if Center.Z > Q.Center.Z then
    result := 1
  else if Center.Z < Q.Center.Z then
    result := -1
  else
    result := 0;
end;

class function TRggCircle.Compare(const Left, Right: TRggCircle): Integer;
begin
  result := Left.CompareZ(Right);
end;

{ TRggLine }

constructor TRggLine.Create(ACaption: string);
begin
  inherited Create;
  TypeName := 'Line';
  Caption := ACaption;
  ShowCaption := DefaultShowCaption;
end;

procedure TRggLine.GetInfo(ML: TStrings);
begin
  inherited;
  if Point1 = nil then
    ML.Add(Caption + '.Point1 = nil');
  if Point2 = nil then
    ML.Add(Caption + '.Point2 = nil');
end;

function TRggLine.GetValid: Boolean;
begin
  result := inherited;
  result := result and (Point1 <> nil);
  result := result and (Point2 <> nil);
end;

procedure TRggLine.Draw(g: TBGRABitmap);
begin
  if not Visible then
    Exit;

  Temp1 := Point1.Center + Drawing.FaxPoint3D;
  Temp2 := Point2.Center + Drawing.FaxPoint3D;

  MoveTo(Temp1.P);
  LineTo(g, Temp2.P);

  if ShowCaption or GlobalShowCaption then
  begin
    TextCenter := Temp1.P + (Temp2.P - Temp1.P) * 0.5;
    TextOut(g, Caption, Drawing.Colors.TextColor);
  end;
end;

function TRggLine.GetLength: single;
begin
  result := (Point2.Center - Point1.Center).Length;
end;

procedure TRggLine.Param1(Delta: single);
var
  u, v: TPointF;
begin
  { change length of line element, change Point2 }
  u := V2 * (1 + Delta / 100);
  v := Point1.Center.P + u;

  Point2.OriginalCenter.P := v;
  Point2.Center := Point2.OriginalCenter;
end;

procedure TRggLine.Param2(Delta: single);
var
  alpha: single;
  temp: TRggPoint3D;
begin
  { rotate line around Point2 }
  alpha := DegToRad(-Delta / 5);

  temp := Point2.Center;
  temp.C := Point2.Center.C - Point1.Center.C;
  Point2.OriginalCenter.P := Point1.Center.P + temp.Rotate(alpha).P;
  Point2.Center := Point2.OriginalCenter;
end;

function TRggLine.V2: TPointF;
begin
  result := Point2.Center.P - Point1.Center.P;
end;

function TRggLine.V3: TPoint3D;
begin
  result := Point2.Center.C - Point1.Center.C;
end;

function TRggLine.IsTotallyAbove(Other: TRggLine): Boolean;
begin
  result :=
    (Point1.Center.Z > Other.Point1.Center.Z) and
    (Point1.Center.Z > Other.Point2.Center.Z) and
    (Point2.Center.Z > Other.Point1.Center.Z) and
    (Point2.Center.Z > Other.Point2.Center.Z);
end;

function TRggLine.IsTotallyBelow(Other: TRggLine): Boolean;
begin
  result :=
    (Point1.Center.Z < Other.Point1.Center.Z) and
    (Point1.Center.Z < Other.Point2.Center.Z) and
    (Point2.Center.Z < Other.Point1.Center.Z) and
    (Point2.Center.Z < Other.Point2.Center.Z);
end;

function TRggLine.IsSame(Other: TRggLine): Boolean;
begin
  result := False;
  if Point1.IsEqual(Other.Point1) and Point2.IsEqual(Other.Point2) then
    result := True
  else if Point1.IsEqual(Other.Point2) and Point2.IsEqual(Other.Point1) then
    result := True;
end;

function TRggLine.ComputeSPZ(SP: TPoint3D): single;
var
  vSP: TPoint3D;
  vAB: TPoint3D;

  vABxy: TPoint3D;
  vSPxy: TPoint3D;
  lengthABxy, lengthSPxy: double;
  RatioSPtoAB, g: double;
begin
  result := (Point1.Center.Z + Point2.Center.Z) / 2;

  vSP := SP - Point1.Center.C;
  vAB := Point2.Center.C - Point1.Center.C;

  vABxy := Point3D(vAB.X, vAB.Y, 0);
  lengthABxy := vABxy.Length;

  vSPxy := Point3D(vSP.X, vSP.Y, 0);
  lengthSPxy := vSPxy.Length;

  if lengthABxy < Eps then
  begin
    Exit;
  end;

  RatioSPtoAB := lengthSPxy / lengthABxy;

  g := RatioSPtoAB;

  if Sign(vAB.X) <> Sign(vSP.X) then
    g := -RatioSPtoAB;

  if Abs(g) > 10000 then
  begin
    { does not come in here }
    result := Point1.Center.Z;
    Exit;
  end;

  result := Point1.Center.Z + g * vAB.Z;
end;

procedure TRggLine.ReportData(ML: TStrings);
  procedure AddPoint(LN, PN: string; P: TPoint3D);
  begin
    ML.Add(Format('%s [%s] = (%.2f, %.2f, %.2f)', [PN, LN, P.X, P.Y, P.Z]));
  end;
begin
  AddPoint(Caption, 'A', Point1.Center.C);
  AddPoint(Caption, 'B', Point2.Center.C);
end;

class procedure TRggLine.ResetCounter;
begin
  CounterLeftNil := 0;
  CounterRightNil := 0;
  CounterHardcodedAbove := 0;
  CounterHardcodedBelow := 0;
  CounterSame := 0;
  CounterTotallyAbove := 0;
  CounterTotallyBelow := 0;
  CounterCommon := 0;
  CounterParallel := 0;
  CounterSPZ := 0;
  CounterZero := 0;
end;

class function TRggLine.CounterSum: Integer;
begin
  result :=
    CounterLeftNil +
    CounterRightNil +
    CounterHardCodedAbove +
    CounterHardCodedBelow +
    CounterSame +
    CounterTotallyAbove +
    CounterTotallyBelow +
    CounterCommon +
    CounterParallel +
    CounterSPZ;
end;

class function TRggLine.Compare(const Left, Right: TRggLine): Integer;
var
  LP: TRggLinePair;
  r: Integer;
begin
  if Left = nil then
  begin
    Left.Bemerkung := ccNil;
    Inc(CounterLeftNil);
    result := 0;
    Exit;
  end;

  if Right = nil then
  begin
    Left.Bemerkung := ccNil;
    Inc(CounterRightNil);
    result := 0;
    Exit;
  end;

  LP.SP := TPoint3D.Zero;
  LP.L1 := Left;
  LP.L2 := Right;

  if False then

  else if LP.L1.IsSame(LP.L2) then
  begin
    Inc(CounterSame);
    Left.Bemerkung := ccTotallySame;
    r := 0;
    Dec(CounterZero); // compensate for Inc below
  end

  else if LP.L1.IsTotallyAbove(LP.L2) then
  begin
    Inc(CounterTotallyAbove);
    Left.Bemerkung := ccTotallyAbove;
    r := 1;
  end

  else if LP.L1.IsTotallyBelow(LP.L2) then
  begin
    Inc(CounterTotallyBelow);
    Left.Bemerkung := ccTotallyBelow;
    r := -1;
  end

  else if LP.HasCommonPoint then
  begin
    Inc(CounterCommon);
    r := LP.CompareCommon;
    case r of
      0: Left.Bemerkung := ccCommonSame;
      1: Left.Bemerkung := ccCommonAbove;
      -1: Left.Bemerkung := ccCommonBelow;
      else
        Left.Bemerkung := ccCommonNone;
    end;
  end

  { As a side effect, this call to IsParallel will set SP }
  else if LP.IsParallel then
  begin
    Inc(CounterParallel);
    Left.Bemerkung := ccParallel;
    r := 0;
  end

  else
  begin
    Inc(CounterSPZ);
    r := LP.CompareSPZ;
    case r of
      0: Left.Bemerkung := ccSame;
      1: Left.Bemerkung := ccAbove;
      -1: Left.Bemerkung := ccBelow;
      else
        Left.Bemerkung := ccNone;
    end;
  end;

  if r = 0 then
  begin
    Inc(CounterZero);
  end;

  result := r;
end;

{ TRggTriangle }

procedure TRggTriangle.GetInfo(ML: TStrings);
begin
  inherited;
  if Point1 = nil then
    ML.Add(Caption + '.Point1 = nil');
  if Point2 = nil then
    ML.Add(Caption + '.Point2 = nil');
  if Point3 = nil then
    ML.Add(Caption + '.Point3 = nil');
end;

function TRggTriangle.GetValid: Boolean;
begin
  result := inherited;
  result := result and (Point1 <> nil);
  result := result and (Point2 <> nil);
  result := result and (Point3 <> nil);
end;

constructor TRggTriangle.Create;
begin
  inherited;
  TypeName := 'Triangle';
  SetLength(Poly, 3);
end;

procedure TRggTriangle.Draw(g: TBGRABitmap);
begin
  Poly[0].X := Point1.Center.X + Drawing.FaxPoint3D.X;
  Poly[0].Y := Point1.Center.Y + Drawing.FaxPoint3D.Y;

  Poly[1].X := Point2.Center.X + Drawing.FaxPoint3D.X;
  Poly[1].Y := Point2.Center.Y + Drawing.FaxPoint3D.Y;

  Poly[2].X := Point3.Center.X + Drawing.FaxPoint3D.X;
  Poly[2].Y := Point3.Center.Y + Drawing.FaxPoint3D.Y;

  g.DrawPolygonAntialias(Poly, StrokeColor, StrokeThickness, StrokeColor);
end;

{ TRggArc }

function TRggArc.GetValid: Boolean;
begin
  result := inherited;
  result := result and (Point1 <> nil);
  result := result and (Point2 <> nil);
  result := result and (Point3 <> nil);
end;

constructor TRggArc.Create(ACaption: string);
begin
  inherited Create;
  FTextRadiusFactor := 1.2;
  Caption := ACaption;
  TypeName := 'Arc';
  Radius := 50;
  StrokeThickness := 2;
  ShowCaption := True;
end;

procedure TRggArc.Draw(g: TBGRABitmap);
var
  Angle2, Angle3: single;
  startAngle: single;
  sweepAngle: single;
  s: string;
  arcData: ArrayOfTPointF;
  sa, ea, ta: single;
begin
  Temp1 := Point1.Center + Drawing.FaxPoint3D;
  Temp2 := Point2.Center + Drawing.FaxPoint3D;
  Temp3 := Point3.Center + Drawing.FaxPoint3D;

  Angle2 := Temp2.Angle(Temp1);
  Angle3 := Temp3.Angle(Temp1);

  startAngle := Angle3;
  sweepAngle := Angle2 - Angle3;

  sa := startAngle;
  ea := startAngle + sweepAngle;

  if sa < -pi then
    sa := sa + 2 * pi;
  if sa > pi then
    sa := sa - 2 * pi;

  if ea < -pi then
    ea := ea + 2 * pi;
  if ea > pi then
    ea := ea - 2 * pi;

  if ea > sa then
  begin
    ta := ea;
    ea := sa;
    sa := ta;
  end;

  s := Caption;

  arcData := g.ComputeArcRad(
    Temp1.X, Temp1.Y,
    Radius, Radius,
    -sa, -ea);

  g.DrawPolyLineAntialias(arcData, StrokeColor, StrokeThickness);

  if ShowCaption or GlobalShowCaption then
  begin
    TextAngle := startAngle + sweepAngle / 2;
    TextRadius := Radius * FTextRadiusFactor;
    TextCenter := Temp1.P;
    TextOut(g, s, Drawing.Colors.TextColor);
  end;
end;

procedure TRggArc.GetInfo(ML: TStrings);
begin
  inherited;
  if Point1 = nil then
    ML.Add(Caption + '.Point1 = nil');
  if Point2 = nil then
    ML.Add(Caption + '.Point2 = nil');
  if Point3 = nil then
    ML.Add(Caption + '.Point3 = nil');
end;

function TRggArc.GetSweepAngle: single;
var
  Angle2, Angle3: single;
  sweepAngle: single;
begin
  Angle2 := RadToDeg(Point2.Center.Angle(Point1.Center));
  Angle3 := RadToDeg(Point3.Center.Angle(Point1.Center));

  sweepAngle := (Angle2 - Angle3);
  result := sweepAngle;
end;

procedure TRggArc.SetRadius(const Value: single);
begin
  FRadius := Value;
  RadiusF.X := FRadius;
  RadiusF.Y := FRadius;
end;

procedure TRggArc.Param1(Delta: single);
begin
  Radius := Radius + Delta;
end;

procedure TRggArc.Param2(Delta: single);
begin
  FTextRadiusFactor := FTextRadiusFactor + Delta / 50;
end;

{ TRggLagerLine }

procedure TRggLagerLine.Draw(g: TBGRABitmap);
begin
  inherited;
  DrawLager(g, (Drawing.FaxPoint3D + Point1.Center).P, True);
  DrawLager(g, (Drawing.FaxPoint3D + Point2.Center).P, False);
end;

procedure TRggLagerLine.DrawLager(g: TBGRABitmap; P: TPointF; FestLager: Boolean);
var
  Angle: single;
  l: single;
  d: single;

  TempA: TPointF;
  TempB: TPointF;
  TempC: TPointF;
  TempD: TPointF;

  TempE: TPointF;
  TempF: TPointF;

  o: TPointF;
  TempP: ArrayOfTPointF;
  i: Integer;
begin
  Angle := DegToRad(30);
  l := 30;

  TempA.X := cos(Angle) * Point1.FRadius;
  TempA.Y := -sin(Angle) * Point1.FRadius;
  TempB.X := TempA.X + sin(Angle) * l;
  TempB.Y := TempA.Y + cos(Angle) * l;
  TempC.X := -TempB.X;
  TempC.Y := TempB.Y;
  TempD.X := -TempA.X;
  TempD.Y := TempA.Y;
  o.X := P.X;
  o.Y := P.Y;

  TempA.Offset(o);
  TempB.Offset(o);
  TempC.Offset(o);
  TempD.Offset(o);

  SetLength(TempP, 4);
  TempP[0] := PointF(TempA.X, TempA.Y);
  TempP[1] := PointF(TempB.X, TempB.Y);
  TempP[2] := PointF(TempC.X, TempC.Y);
  TempP[3] := PointF(TempD.X, TempD.Y);

  g.DrawPolyLineAntialias(TempP, CssGray, StrokeThickness, Drawing.Colors.BackgroundColor);

  if not FestLager then
  begin
    o.X := 0;
    o.Y := 5;
    TempB.Offset(o);
    TempC.Offset(o);
    { g.DrawLine(TempB, TempC, 1.0); }
    MoveTo(TempB);
    LineTo(g, TempC);
  end;

  TempE := TempC;
  TempF.X := TempE.X - sin(Angle) * l * 0.5;
  TempF.Y := TempE.Y + cos(Angle) * l * 0.5;

  d := (TempB - TempC).Length / 3;

  o.X := -0.4 * d;
  o.Y := 0;
  TempE.Offset(o);
  TempF.Offset(o);

  o.X := d;
  o.Y := 0;
  for i := 1 to 3 do
  begin
    TempE.Offset(o);
    TempF.Offset(o);
    { g.DrawLine(TempE, TempF, Opacity); }
    MoveTo(TempE);
    LineTo(g, TempF);
  end;
end;

{ TRggLinePair }

function TRggLinePair.CompareVV(v1, v2: TPoint3D): Integer;
var
  m1, m2: TPoint3D;
  r: single;
begin
  m1 := v1.Normalize;
  m2 := v2.Normalize;
  r := m2.Z - m1.Z;
  if r > 0 then
    result := -1
  else if r < 0 then
    result := 1
  else
    result := 0;
end;

procedure TRggLinePair.ReportData(ML: TStrings);
  procedure AddPoint(LN, PN: string; P: TPoint3D);
  begin
    ML.Add(Format('%s [%s] = (%.2f, %.2f, %.2f)', [PN, LN, P.X, P.Y, P.Z]));
  end;
begin
  AddPoint(L1.Caption, 'A', L1.Point1.Center.C);
  AddPoint(L1.Caption, 'B', L1.Point2.Center.C);
  AddPoint(L2.Caption, 'C', L2.Point1.Center.C);
  AddPoint(L2.Caption, 'D', L2.Point2.Center.C);
end;

function TRggLinePair.CompareSPZ: Integer;
var
  za, zb, dz: single;
begin
  za := L1.ComputeSPZ(SP);
  zb := L2.ComputeSPZ(SP);

  dz := zb - za;

  if dz > 0 then
    result := -1
  else if dz < 0 then
    result := 1
  else
    result := 0;
end;

function TRggLinePair.HasCommonPoint: Boolean;
begin
  result :=
    (L1.Point1.Center.C = L2.Point1.Center.C) or
    (L1.Point1.Center.C = L2.Point2.Center.C) or
    (L1.Point2.Center.C = L2.Point1.Center.C) or
    (L1.Point2.Center.C = L2.Point2.Center.C);
end;

function TRggLinePair.IsParallel: Boolean;
begin
  result := not SchnittGG;
end;

function TRggLinePair.CompareCommon: Integer;
var
  v1, v2: TPoint3D;
begin
  result := 0;
  if L1.Point1.IsEqual(L2.Point1) then
  begin
    v1 := L1.Point2.Center.C - L1.Point1.Center.C;
    v2 := L2.Point2.Center.C - L2.Point1.Center.C;
    result := CompareVV(v1, v2);
  end
  else if L1.Point1.IsEqual(L2.Point2) then
  begin
    v1 := L1.Point2.Center.C - L1.Point1.Center.C;
    v2 := L2.Point1.Center.C - L2.Point2.Center.C;
    result := CompareVV(v1, v2);
  end
  else if L1.Point2.IsEqual(L2.Point1) then
  begin
    v1 := L1.Point1.Center.C - L1.Point2.Center.C;
    v2 := L2.Point2.Center.C - L2.Point1.Center.C;
    result := CompareVV(v1, v2);
  end
  else if L1.Point2.IsEqual(L2.Point2) then
  begin
    v1 := L1.Point1.Center.C - L1.Point2.Center.C;
    v2 := L2.Point1.Center.C - L2.Point2.Center.C;
    result := CompareVV(v1, v2);
  end;
end;

function TRggLinePair.SchnittGG: Boolean;
var
  a1, a2: single;
  sx, sz, x1, z1, x3, z3: single;
  Quotient: single;
  Fall: TBemerkungGG;
begin
  result := True;
  Fall := ggOK;

  a1 := 0;
  a2 := 0;
  sx := 0;
  sz := 0;

  x1 := L1.Point1.Center.X;
  z1 := L1.Point1.Center.Z;
  x3 := L2.Point1.Center.X;
  z3 := L2.Point1.Center.X;

  Quotient := L1.Point2.Center.X - L1.Point1.Center.X;
  if abs(Quotient) > 0.001 then
    a1 := (L1.Point2.Center.Z - L1.Point1.Center.Z) / Quotient
  else
    Fall := g1Vertical;

  Quotient := L2.Point2.Center.X - L2.Point1.Center.X;
  if abs(Quotient) > 0.001 then
    a2 := (L2.Point2.Center.Z - L1.Point1.Center.Z) / Quotient
  else
    Fall := g2Vertical;

  if (Fall = ggOK) and (abs(a2-a1) < 0.001) then
    Fall := ggParallel;

  case Fall of
    ggParallel:
    begin
      sx := 0;
      sz := 0;
      result := False;
    end;

    ggOK:
      begin
        sx := (-a1 * x1 + a2 * x3 - z3 + z1) / (-a1 + a2);
        sz := (-a2 * a1 * x1 + a2 * z1 + a2 * x3 * a1 - z3 * a1) / (-a1 + a2);
      end;

    g1Vertical:
      begin
        sz := a2 * x1 - a2 * x3 + z3;
        sx := x1;
      end;

    g2Vertical:
      begin
        sz := a1 * x3 - a1 * x1 + z1;
        sx := x3;
      end;
  end;

  SP.X := sx;
  SP.Y := 0;
  SP.Z := sz;
end;

{ TRggLabel }

constructor TRggLabel.Create;
begin
  inherited;
  TypeName := 'Label';
  Position.X := 20;
  Position.Y := 20;
end;

procedure TRggLabel.Draw(g: TBGRABitmap);
var
  x, y: Integer;
  w, h: Integer;
  R: TRect;
begin
  TextCenter := Position;

  x := Round(TextCenter.X);
  y := Round(TextCenter.Y);

  g.FontName := 'Consolas';
  g.FontHeight := 16;

  if IsMemoLabel then
  begin
    w := 520;
    h := 500;
    R := Rect(x, y, x + w, y + h);
    g.TextRect(R, Text, TAlignment.taLeftJustify, TTextLayout.tlTop, CssPlum);
  end
  else
  begin
    g.TextOut(x, y, Text, Drawing.Colors.TextColor);
  end;
end;

function TRggLabel.GetListCaption: string;
begin
  result := inherited;
  result := '-- ' + result;
end;

{ TRggPolyLine }

constructor TRggPolyLine.Create(ACaption: string = '');
begin
  inherited;
  TypeName := 'PolyLine';
end;

constructor TRggPolyLine.Create(ACaption: string; ACount: Integer);
begin
  Create(ACaption);
  if (ACount > 2) and (ACount < 202) then
  begin
    FCount := ACount;
    SetLength(Poly, Count);
    SetLength(TransformedPoly, Count);
  end;
end;

procedure TRggPolyLine.Draw(g: TBGRABitmap);
var
  i: Integer;
begin
  Temp1 := Point1.Center + Drawing.FaxPoint3D;
  Temp2 := Point2.Center + Drawing.FaxPoint3D;

  if not ShowPoly then
    inherited
  else
  begin
    if Drawing.WantOffset then
    begin
      for i := 0 to Length(Poly) - 1 do
      begin
        TransformedPoly[i].X := Poly[i].X + Drawing.FaxPoint3D.X;
        TransformedPoly[i].Y := Poly[i].Y + Drawing.FaxPoint3D.Y;
      end;
      g.DrawPolyLineAntialias(TransformedPoly, StrokeColor, Strokethickness);
    end
    else
      g.DrawPolyLineAntialias(Poly, StrokeColor, Strokethickness);

    DrawText(g);
  end;
end;

procedure TRggPolyLine.DrawText(g: TBGRABitmap);
begin
  if ShowCaption or GlobalShowCaption then
  begin
    TextCenter := Temp1.P + (Temp2.P - Temp1.P) * 0.5;
    TextOut(g, Caption, Drawing.Colors.TextColor);
  end;
end;

{ TRggPolyLine }

constructor TRggPolyLine3D.Create(ACaption: string; ACount: Integer);
begin
  inherited;
  TypeName := 'PolyLine3D';
  UpdateCount;
end;

procedure TRggPolyLine3D.UpdateCount;
var
  l: Integer;
begin
  l := Length(Poly);
  if Length(RggPoly) <> l then
    SetLength(RggPoly, l);
  if Length(TransformedPoly) <> l then
    SetLength(TransformedPoly, l);
end;

procedure TRggPolyLine3D.Draw(g: TBGRABitmap);
var
  i: Integer;
begin
  if not Visible then
    Exit;

  if not WantRotation then
  begin
    inherited;
    Exit;
  end;

  if not ShowPoly then
    inherited
  else
  begin
    for i := 0 to Length(RggPoly) - 1 do
    begin
      TransformedPoly[i].X := RggPoly[i].X + Drawing.FaxPoint3D.X;
      TransformedPoly[i].Y := RggPoly[i].Y + Drawing.FaxPoint3D.Y;
    end;
    g.DrawPolyLineAntialias(TransformedPoly, StrokeColor, StrokeThickness);
    DrawText(g);
  end;
end;

procedure TRggPolyLine3D.Transform;
var
  i: Integer;
begin
  if not WantRotation then
    Exit;

  Assert(FCount = Length(RggPoly));

  for i := 0 to FCount - 1 do
  begin
    RggPoly[i].C := RggPoly[i].C * TRggCircle.Matrix;
  end;
end;

procedure TRggPolyLine3D.Reset;
var
  i: Integer;
  l: Integer;
begin
  l := Length(RggPoly);
  for i := 0 to l - 1 do
  begin
    RggPoly[i].X := Poly[i].X;
    RggPoly[i].Y := Poly[i].Y;
    RggPoly[i].Z := 0;
  end;
end;

{ TSchnittKKCircleLL }

constructor TSchnittKKCircleLL.Create(ACaption: string);
begin
  inherited;
  TypeName := 'SKK Circle LL';
  IsComputed := True;
  Radius1 := 100;
  Radius2 := 100;
  SchnittKK := TSchnittKK.Create;
end;

destructor TSchnittKKCircleLL.Destroy;
begin
  SchnittKK.Free;
  inherited;
end;

procedure TSchnittKKCircleLL.InitRadius;
begin
  Radius1 := L1.LineLength;
  Radius2 := L2.LineLength;
end;

procedure TSchnittKKCircleLL.Param1(Delta: single);
begin
  Radius1 := Radius1 + Delta;
end;

procedure TSchnittKKCircleLL.Param2(Delta: single);
begin
  Radius2 := Radius2 + Delta;
end;

procedure TSchnittKKCircleLL.GetInfo(ML: TStrings);
begin
  inherited;
  if L1 = nil then
    ML.Add(Caption + '.L1 = nil');
  if L2 = nil then
    ML.Add(Caption + '.L2 = nil');
end;

function TSchnittKKCircleLL.GetValid: Boolean;
begin
  result := inherited;
  result := result and (L1 <> nil);
  result := result and (L2 <> nil);
end;

procedure TSchnittKKCircleLL.Compute;
begin
  Inc(Counter);

  SchnittKK.SchnittEbene := seXY;
  SchnittKK.Radius1 := Radius1;
  SchnittKK.Radius2 := Radius2;
  SchnittKK.MittelPunkt1 := L1.Point1.Center.C;
  SchnittKK.MittelPunkt2 := L2.Point1.Center.C;
  Center.C := SchnittKK.SchnittPunkt2;

  L1.Point2.OriginalCenter.C := Center.C;
  L2.Point2.OriginalCenter.C := Center.C;

  L1.Point2.Center.C := Center.C;
  L2.Point2.Center.C := Center.C;
end;

{ TSchnittKKCircle }

constructor TSchnittKKCircle.Create(ACaption: string);
begin
  inherited;
  TypeName := 'SKK Circle';
  IsComputed := True;
  Radius1 := 100;
  Radius2 := 100;
  NeedCalc := True;
  WantS2 := True;
end;

procedure TSchnittKKCircle.InitRadius;
begin
  Radius1 := (Center - MP1.Center).Length;
  Radius2 := (Center - MP2.Center).Length;
end;

function TSchnittKKCircle.GetBem: TBemerkungKK;
begin
  if NeedCalc = True then
    ComputeInternal;
  result := Bem;
end;

function TSchnittKKCircle.GetBemerkung: string;
begin
  if NeedCalc = True then
    ComputeInternal;
  case Bem of
    bmKonzentrisch:
      result := 'concentric circles';
    bmZwei:
      result := 'two intersections';
    bmEntfernt:
      result := 'two distant circles';
    bmEinerAussen:
      result := 'touching outside';
    bmEinerK1inK2:
      result := 'touching inside, C1 in C2';
    bmEinerK2inK1:
      result := 'touching inside, C2 in C1';
    bmK1inK2:
      result := 'C1 inside C2';
    bmK2inK1:
      result := 'C2 inside C1';
    bmRadiusFalsch:
      result := 'invalid radius';
  end;
end;

procedure TSchnittKKCircle.GetInfo(ML: TStrings);
begin
  inherited;
  if MP1 = nil then
    ML.Add(Caption + '.MP1 = nil');
  if MP2 = nil then
    ML.Add(Caption + '.MP2 = nil');
end;

function TSchnittKKCircle.GetL1: single;
begin
  if NeedCalc then
    ComputeInternal;
  result := (Center - MP1.Center).Length;
end;

function TSchnittKKCircle.GetL2: single;
begin
  if NeedCalc then
    ComputeInternal;
  result := (Center - MP2.Center).Length;
end;

function TSchnittKKCircle.GetValid: Boolean;
begin
  result := inherited;
  result := result and (MP1 <> nil);
  result := result and (MP2 <> nil);
end;

procedure TSchnittKKCircle.Param1(Delta: single);
begin
  Radius1 := Radius1 + Delta;
  NeedCalc := True;
end;

procedure TSchnittKKCircle.Param2(Delta: single);
begin
  Radius2 := Radius2 + Delta;
  NeedCalc := True;
end;

function TSchnittKKCircle.Vorhanden: Boolean;
begin
  if NeedCalc = True then
    ComputeInternal;
  result := sv;
end;

procedure TSchnittKKCircle.ComputeInternal;
var
  a, b, h1, h2, p, q, Entfernung: single;
  DeltaX, DeltaY: single;
  AbsDeltaX, AbsDeltaY: single;
  DeltaNullx, DeltaNully: Boolean;
  M1M2, M1S1, KreuzProd: TPoint3D;
  M1, M2, SP: TPoint3D;
begin
  R1 := Radius1;
  R2 := Radius2;
  M1 := MP1.Center.C;
  M2 := MP2.Center.C;

  NeedCalc := False;
  sv := False;

  S1 := TPoint3D.Zero;
  S2 := TPoint3D.Zero;

  { Radien sollen größer Null sein }
  if (R1 <= 0) or (R2 <= 0) then
  begin
    Bem := bmRadiusFalsch;
    Exit;
  end;

  DeltaX := M2.X - M1.X;
  DeltaY := M2.Y - M1.Y;
  DeltaNullx := DeltaX = 0;
  DeltaNully := DeltaY = 0;
  AbsDeltaX := abs(DeltaX);
  AbsDeltaY := abs(DeltaY);

  { Spezialfall konzentrische Kreise }
  if DeltaNullx and DeltaNully then
  begin
    Bem := bmKonzentrisch;
    Exit;
  end;

  h1 := (R1 * R1 - R2 * R2) + (M2.X * M2.X - M1.X * M1.X) + (M2.Y * M2.Y - M1.Y * M1.Y);

  { Rechnung im Normalfall }

  if AbsDeltaY > AbsDeltaX then
  begin
    a := - DeltaX / DeltaY;
    b := h1 / (2 * DeltaY);
    p := 2 * (a * b - M1.X - a * M1.Y) / (1 + a * a);
    q := (M1.X * M1.X + b * b - 2 * b * M1.Y + M1.Y * M1.Y - R1 * R1) / (1 + a * a);
    h2 := p * p / 4 - q;
    if h2 >= 0 then
    begin
      h2 := sqrt(h2);
      S1.X := -p / 2 + h2;
      S2.X := -p / 2 - h2;
      S1.Y := a * S1.X + b;
      S2.Y := a * S2.X + b;
      sv := True;
    end;
  end
  else
  begin
    a := - DeltaY / DeltaX;
    b := h1 / (2 * DeltaX);
    p := 2 * (a * b - M1.Y - a * M1.X) / (1 + a * a);
    q := (M1.Y * M1.Y + b * b - 2 * b * M1.X + M1.X * M1.X - R1 * R1) / (1 + a * a);
    h2 := p * p / 4 - q;
    if h2 >= 0 then
    begin
      h2 := sqrt(h2);
      S1.Y := -p / 2 + h2;
      S2.Y := -p / 2 - h2;
      S1.X := a * S1.Y + b;
      S2.X := a * S2.Y + b;
      sv := True;
    end;
  end;

  Entfernung := (M2 - M1).Length;

  if sv = False then
  begin
    if Entfernung > R1 + R2 then
      Bem := bmEntfernt
    else if Entfernung + R1 < R2 then
      Bem := bmK1inK2
    else if Entfernung + R2 < R1 then
      Bem := bmK2inK1;
    Exit;
  end;

  if sv = True then
  begin
    Bem := bmZwei;
    if Entfernung + R1 = R2 then
      Bem := bmEinerK1inK2
    else if Entfernung + R2 = R1 then
      Bem := bmEinerK2inK1
    else if Entfernung = R1 + R2 then
      Bem := bmEinerAussen;
  end;

  { den "richtigen" SchnittPunkt ermitteln }
  if Bem = bmZwei then
  begin
    M1M2 := M2 - M1;
    M1S1 := S1 - M1;
    KreuzProd := M1M2.CrossProduct(M1S1);
    if KreuzProd.Z < 0 then
    begin
      SP := S2;
      S2 := S1;
      S1 := SP;
    end;
  end;
end;

procedure TSchnittKKCircle.Compute;
begin
//  if NeedCalc then
    ComputeInternal;
  if WantS2 then
    Center.C := S2
  else
    Center.C := S1;
end;

procedure TSchnittKKCircle.Draw(g: TBGRABitmap);
begin
  Temp1 := MP1.Center + Drawing.FaxPoint3D;
  Temp2 := MP2.Center + Drawing.FaxPoint3D;
  Temp3 := Center + Drawing.FaxPoint3D;

  MoveTo(Temp1.P);
  LineTo(g, Temp3.P);

  MoveTo(Temp2.P);
  LineTo(g, Temp3.P);

  inherited;
end;

{ TRggParam }

constructor TRggParam.Create;
begin
  inherited;
  TypeName := 'Param';
  FScale := 1.0;
  FOriginalValue := 400;
  FValue := FOriginalValue;
  StartPoint := PointF(10, 10);
  StrokeThickness := 2;
  StrokeColor := CssGray;
  ShowCaption := True;
end;

procedure TRggParam.Reset;
begin
  FValue := FOriginalValue;
end;

procedure TRggParam.Save;
begin
  FOriginalValue := FValue;
end;

procedure TRggParam.SetBaseValue(const Value: single);
begin
  FBaseValue := Value;
end;

procedure TRggParam.SetScale(const Value: single);
begin
  FScale := Value;
end;

procedure TRggParam.SetValue(const Value: single);
begin
  FValue := Value;
end;

procedure TRggParam.Param1(Delta: single);
begin
  FValue := FValue + Delta;
end;

procedure TRggParam.Draw(g: TBGRABitmap);
var
  EndPoint: TPointF;
begin
  EndPoint.Y := StartPoint.Y;
  EndPoint.X := StartPoint.X + FOriginalValue;

  StrokeThickness := 5;
  StrokeColor := CssYellow;
  MoveTo(StartPoint);
  LineTo(g, EndPoint);

  EndPoint.X := StartPoint.X + FValue;
  StrokeThickness := 1;
  StrokeColor := CssNavy;
  MoveTo(StartPoint);
  LineTo(g, EndPoint);

  if ShowCaption or GlobalShowCaption then
  begin
    TextCenter := StartPoint;
    TextCenter.Offset(20, -15);
    TextOutLeading(g, Text, StrokeColor);
  end;
end;

function TRggParam.GetRelativeValue: single;
begin
  result := FBaseValue + (Value - 400) * FScale;
end;

{ TRggRotaLine }

constructor TRggRotaLine.Create(ACaption: string);
begin
  inherited Create(ACaption);
  TypeName := 'RotaLine';
end;

procedure TRggRotaLine.Param1(Delta: single);
begin
  { swap Params, do inherited Param 2}
  inherited Param2(Delta);
end;

procedure TRggRotaLine.Param2(Delta: single);
begin
  { swap Params, do inherited Param 1}
  inherited Param1(Delta);
end;

{ TFederLine }

constructor TRggFederLine.Create(ACaption: string);
begin
  inherited Create(ACaption, 8);
end;

procedure TRggFederLine.Draw(g: TBGRABitmap);
var
  i: Integer;
  l: single;
  a: single;
  b: single;
  vp, vq: TPoint3D;
  vn, wn: TPoint3D;
  v, w: TPoint3D;

  p0, p1: TPoint3D;
  vx, vy: TPoint3D;
begin
  Temp1 := Point1.Center + Drawing.FaxPoint3D;
  Temp2 := Point2.Center + Drawing.FaxPoint3D;

  vp := Temp1.C;
  vq := Temp2.C;

  v := vq - vp;

  vn := v.Normalize;
  vx := TPoint3D.Create(vn.X, vn.Y, 0);
  vy := RotateDegrees(vx, 90);
  wn := TPoint3D.Create(vy.X, vy.Y, 0);

  l := v.Length;
  a := l / 3 / 8;
  b := 20.0;

  Poly[0] := PointF(vp.X, vp.Y);

  v := vn * 8 * a;
  p0.X := vp.X + v.X;
  p0.Y := vp.Y + v.Y;
  Poly[1] := PointF(p0.X, p0.Y);

  v := vn * a;
  w := wn *  b;
  for i := 2 to FCount-3 do
  begin
    p0 := p0 + v;
    if i mod 2 = 0 then
      p1 := p0 + w
    else
      p1 := p0 - w;
    Poly[i] := PointF(p1.X, p1.Y);
  end;

  p0 := p0 + v;
  Poly[FCount-2] := PointF(p0.X, p0.Y);

  Poly[FCount-1] := PointF(vq.X, vq.Y);

  g.DrawPolyLineAntialias(Poly, StrokeColor, StrokeThickness);
end;

function TRggFederLine.RotateDegrees(ov: TPoint3D; wi: single): TPoint3D;
var
  a: single;
  m: TMatrix3D;
begin
  a := DegToRad(DegNormalize(Abs(wi)));
  if wi >= 0 then
    m := TMatrix3D.CreateRotation(TPoint3D.Create(0,0,1), a)
  else
    m := TMatrix3D.CreateRotation(TPoint3D.Create(0,0,-1), a);
  result := ov * m;
end;

{ TRggBigCircle }

constructor TRggBigCircle.Create(ACaption: string);
begin
  inherited Create;
  TypeName := 'BigCircle';
  Caption := ACaption;
  ShowCaption := DefaultShowCaption;
end;

procedure TRggBigCircle.Draw(g: TBGRABitmap);
begin
  Temp1 := Center + Drawing.FaxPoint3D;

  g.EllipseAntialias(Temp1.X, Temp1.Y, Radius, Radius, StrokeColor, 1.0);

  if ShowCaption or GlobalShowCaption then
  begin
    TextCenter := Temp1.P;
    TextOut(g, Caption, Drawing.Colors.TextColor);
  end;
end;

procedure TRggBigCircle.Param3(Delta: single);
begin
  FRadius := FRadius + Delta;
end;

{ TRggBigArc }

constructor TRggBigArc.Create(ACaption: string);
begin
  inherited Create;
  TypeName := 'BigArc';
  Caption := ACaption;
  ShowCaption := False;
  FSweepAngle := 30;
end;

procedure TRggBigArc.Draw(g: TBGRABitmap);
var
  Arrow: TRggPoint3D;
  Angle: single;
  RadiusF: TPointF;
  arcData: ArrayOfTPointF;
  sa: single;
begin
  Temp1 := Point1.Center + Drawing.FaxPoint3D;
  Temp2 := Point2.Center + Drawing.FaxPoint3D;

  Arrow.C := Temp2.C - Temp1.C;
  Angle := -Arrow.Angle(RggPoint3DZero);
  RadiusF.X := Arrow.Length;
  RadiusF.Y := RadiusF.X;

  sa := DegToRad(SweepAngle);

  arcData := g.ComputeArcRad(
    Temp1.X, Temp1.Y,
    RadiusF.X, RadiusF.Y,
    Angle - sa, Angle + sa);
  g.DrawPolyLineAntialias(arcData, StrokeColor, StrokeThickness);

  if ShowCaption or GlobalShowCaption then
  begin
    TextCenter := Temp1.P + (Temp2.P - Temp1.P) * 0.5;
    TextOut(g, Caption, Drawing.Colors.TextColor);
  end;
end;

procedure TRggBigArc.GetInfo(ML: TStrings);
begin
  inherited;
  if Point1 = nil then
    ML.Add(Caption + '.Point1 = nil');
  if Point2 = nil then
    ML.Add(Caption + '.Point2 = nil');
end;

function TRggBigArc.GetValid: Boolean;
begin
  result := inherited;
  result := result and (Point1 <> nil);
  result := result and (Point2 <> nil);
end;

procedure TRggBigArc.Param1(Delta: single);
begin
  SweepAngle := FSweepAngle + Delta;
end;

procedure TRggBigArc.SetSweepAngle(const Value: single);
begin
  FSweepAngle := Value;
  if FSweepAngle < 10 then
    FSweepAngle := 10;
end;

{ TRggPolyCurve }

constructor TRggPolyCurve.Create(ACaption: string; ACount: Integer);
begin
  inherited Create;
  TypeName := 'PolyCurve';
  Caption := ACaption;
  if (ACount > 2) and (ACount < 202) then
  begin
    FCount := ACount;
    SetLength(Poly, Count);
    SetLength(TransformedPoly, Count);
  end;
end;

procedure TRggPolyCurve.Draw(g: TBGRABitmap);
var
  i: Integer;
begin
  if Drawing.WantOffset then
  begin
    for i := 0 to Length(Poly) - 1 do
    begin
      TransformedPoly[i].X := Poly[i].X + Drawing.FaxPoint3D.X;
      TransformedPoly[i].Y := Poly[i].Y + Drawing.FaxPoint3D.Y;
    end;
    PolyLine(g, TransformedPoly);
  end
  else
    PolyLine(g, Poly);

  DrawText(g);
end;

procedure TRggPolyCurve.DrawText(g: TBGRABitmap);
var
  pf: TPointf;
begin
  if ShowCaption or GlobalShowCaption then
  begin
    pf.x := Poly[0].x;
    pf.y := Poly[0].y;
    TextCenter := pf;
    TextOut(g, Caption, Drawing.Colors.TextColor);
  end;
end;

{ TRggColorScheme }

procedure TRggColorScheme.GoDark;
begin
  TextColor := CssWhite;
  BackgroundColor.FromColor(TRggColors.Color333333);
  LabelColor := CssAntiquewhite;
end;

procedure TRggColorScheme.GoLight;
begin
  TextColor := CssBlack;
  BackgroundColor := CssWhite;
  LabelColor := CssPlum;
end;

{ TRggFixpointCircle }

constructor TRggFixpointCircle.Create(ACaption: string);
begin
  inherited;
  TypeName := 'Circle';
  ShowCaption := False;
  IsComputed := True;
end;

procedure TRggFixpointCircle.Draw(g: TBGRABitmap);
begin
  Temp1 := Center + Drawing.FaxPoint3D;
  g.EllipseAntialias(Temp1.X, Temp1.Y, FRadius, FRadius, Drawing.Colors.BackgroundColor, 0.0);
  g.EllipseAntialias(Temp1.X, Temp1.Y, FRadius, FRadius, CssPlum, StrokeThickness);
end;

end.
