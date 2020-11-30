program rg51;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FrmMain, FrmAction, FrmMemo, RiggVar.App.Model, RiggVar.RG.Speed01,
  RiggVar.RG.Speed02, RiggVar.RG.Rota, FrmAuswahl, FrmConfig, FrmTrimmTab,
  RiggVar.FB.ActionMap, RiggVar.FB.SpeedBar, RiggVar.FB.SpeedColor,
  RiggVar.FB.TextBase, RggTestData, RggChartModel, RggChartGraph,
  RiggVar.FederModel.ActionList, RiggVar.FederModel.Menu
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='RG51';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

