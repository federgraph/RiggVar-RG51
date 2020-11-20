unit RiggVar.FZ.Z07_Triangle;

interface

uses
  BGRABitmapTypes,
  RiggVar.FD.Elements,
  RiggVar.FD.Drawings;

type
  TRggDrawingZ07 = class(TRggDrawing)
  private
    function GetHelpText: string;
  public
    HT: TRggLabel;

    A: TRggCircle;
    B: TRggCircle;
    C: TRggCircle;

    AB: TRggLine;
    AC: TRggLine;
    BC: TRggLine;

    T: TRggTriangle;
    constructor Create;
    procedure InitDefaultPos; override;
    procedure GoDark; override;
    procedure GoLight; override;
  end;

implementation

{ TRggDrawingZ07 }

procedure TRggDrawingZ07.InitDefaultPos;
begin
  A.Center.X := 100;
  A.Center.Y := 400;
  A.Center.Z := 0;

  B.Center.X := 400;
  B.Center.Y := 400;
  B.Center.Z := 0;

  C.Center.X := 200;
  C.Center.Y := 200;
  C.Center.Z := 0;
end;

constructor TRggDrawingZ07.Create;
var
  L: TRggLine;
begin
  inherited;
  Name := 'Z07-Triangle';

  HT := TRggLabel.Create;
  HT.Caption := 'HelpText';
  HT.Text := GetHelpText;
  HT.StrokeColor := CssPlum;
  HT.IsMemoLabel := True;
  Add(HT);

  A := TRggCircle.Create;
  A.Caption := 'A';
  A.StrokeColor := CssRed;

  B := TRggCircle.Create;
  B.Caption := 'B';
  B.StrokeColor := CssTeal;

  C := TRggCircle.Create;
  C.Caption := 'C';
  C.StrokeColor := CssDodgerblue;

  InitDefaultPos;

  T := TRggTriangle.Create;
  T.Caption := 'ABC';
  T.StrokeColor := CssAliceblue;
  T.Point1 := A;
  T.Point2 := B;
  T.Point3 := C;
  Add(T);

  L := TRggLine.Create('AB');
  L.StrokeColor := CssDodgerblue;
  L.Point1 := A;
  L.Point2 := B;
  Add(L);
  AB := L;

  L := TRggLine.Create('AC');
  L.StrokeColor := CssTeal;
  L.Point1 := A;
  L.Point2 := C;
  Add(L);
  AC := L;

  L := TRggLine.Create('BC');
  L.StrokeColor := CssRed;
  L.Point1 := B;
  L.Point2 := C;
  Add(L);
  BC := L;

  Add(A);
  Add(B);
  Add(C);
end;

procedure TRggDrawingZ07.GoDark;
begin
  inherited;
  A.StrokeColor := CssTomato;
  BC.StrokeColor := CssTomato;

  B.StrokeColor := CssDodgerblue;
  AC.StrokeColor := CssDodgerblue;

  C.StrokeColor := CssLime;
  AB.StrokeColor := CssLime;

  T.StrokeColor := CssGray;
end;

procedure TRggDrawingZ07.GoLight;
begin
  inherited;
  A.StrokeColor := CssRed;
  BC.StrokeColor := CssRed;

  B.StrokeColor := CssDodgerblue;
  AC.StrokeColor := CssDodgerblue;

  C.StrokeColor := CssTeal;
  AB.StrokeColor := CssTeal;

  T.StrokeColor := CssAliceblue;
end;

function TRggDrawingZ07.GetHelpText: string;
begin
  ML.Add('2D Triangle');
  ML.Add('');
  ML.Add('Press F2 to toggle color scheme between Dark and Light.');
  ML.Add('  Selection of colors still pending ...');

  result := ML.Text;
  ML.Clear;
end;

end.
