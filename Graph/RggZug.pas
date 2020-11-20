unit RggZug;

interface

uses
  SysUtils,
  Classes,
  Graphics,
  BGRABitMap,
  BGRABitmapTypes,
  RggTypes;

type
  TRaumGraphData = class
  public
    xA0, xB0, xC0, xD0, xE0, xF0, xA, xB, xC, xD, xE, xF: single;
    yA0, yB0, yC0, yD0, yE0, yF0, yA, yB, yC, yD, yE, yF: single;
    zA0, zB0, zC0, zD0, zE0, zF0, zA, zB, zC, zD, zE, zF: single;

    xP0, yP0: single;
    xX, yX: single;
    xY, yY: single;
    xZ, yZ: single;
    xM, yM: single;
    xN, yN: single;
    xP, yP: single;
  end;

  TRaumGraphProps = class
  public
    SalingTyp: TSalingTyp;
    ControllerTyp: TControllerTyp;
    BogenIndexD: Integer;
    Bogen: Boolean;
    Coloriert: Boolean;
    Color: TColor;
    Koppel: Boolean;
    Gestrichelt: Boolean;
    RiggLED: Boolean;
    OffsetX: Integer;
    OffsetY: Integer;
  end;

  TZug0 = class
  public
    Data: TRaumGraphData; // injected
    Props: TRaumGraphProps; // injected
  end;

  TZug3DBase = class(TZug0)
  public
    ZugRumpf: ArrayOfTPointF;
    ZugMast: ArrayOfTPointF;
    ZugMastKurve: ArrayOfTPointF;
    ZugSalingFS: ArrayOfTPointF;
    ZugSalingDS: ArrayOfTPointF;
    ZugWanteStb: ArrayOfTPointF;
    ZugWanteBb: ArrayOfTPointF;
    ZugController: ArrayOfTPointF;
    ZugVorstag: ArrayOfTPointF;
    ZugKoppelKurve: ArrayOfTPointF;
    ZugAchsen: ArrayOfTPointF;
    ZugMastfall: ArrayOfTPointF;
    ZugRP: ArrayOfTPointF;

    { no need to call SetLength for these, will be copied via Copy }
    ZugMastKurveD0D: ArrayOfTPointF;
    ZugMastKurveDC: ArrayOfTPointF;

    constructor Create;
    procedure FillZug; virtual; abstract;
    procedure DrawToCanvas(g: TBGRABitmap); virtual; abstract;
    procedure GetPlotList(ML: TStrings); virtual; abstract;
  end;

implementation

{ TZug3DBase }

constructor TZug3DBase.Create;
begin
  inherited;
  SetLength(ZugRumpf, 8);
  SetLength(ZugMast, 4);
  SetLength(ZugMastKurve, BogenMax + 2);
  SetLength(ZugSalingFS, 4);
  SetLength(ZugSalingDS, 3);
  SetLength(ZugWanteStb, 3);
  SetLength(ZugWanteBb, 3);
  SetLength(ZugController, 2);
  SetLength(ZugVorstag, 2);
  SetLength(ZugAchsen, 4);
  SetLength(ZugMastfall, 3);
  SetLength(ZugRP, 4);
  SetLength(ZugKoppelKurve, 101);
end;

end.
