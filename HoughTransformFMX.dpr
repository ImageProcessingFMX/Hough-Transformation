program HoughTransformFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  GUI.FMX.HoughTransform_Demo in 'GUI.FMX.HoughTransform_Demo.pas' {Form1},
  Unit_HoughTransformation in 'Unit_HoughTransformation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
