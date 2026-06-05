unit GUI.FMX.HoughTransform_Demo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.EditBox, FMX.SpinBox,
  Unit_HoughTransformation;

type
  TForm1 = class(TForm)
    img_SourceImage: TImage;
    rctngl1: TRectangle;
    btn_Close: TCornerButton;
    btn_LoadImage: TCornerButton;
    btn_HoughCircle: TCornerButton;
    btn_HoughLine: TCornerButton;
    dlgOpen: TOpenDialog;
    img_HoughResult: TImage;
    img_THoughAccumulator: TImage;
    mmo_log: TMemo;
    spnbx: TSpinBox;
    spnbx_HoughTreshold: TSpinBox;
    procedure btn_LoadImageClick(Sender: TObject);
    procedure btn_HoughCircleClick(Sender: TObject);
    procedure btn_HoughLineClick(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FImageFilename: string;

    FHoughResult: THoughResult;
    FHoughFinal: THoughFinal;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btn_CloseClick(Sender: TObject);
begin
  mmo_log.Lines.Add('Bye');

  Close;
end;

procedure TForm1.btn_HoughCircleClick(Sender: TObject);
var
  testRadius: Integer;
  ResultBitmap: TBitMap;
  ResultFinalBitmap: TBitMap;
begin
  mmo_log.Lines.Add('execute a Hough circle  transformation');

  ResultBitmap := TBitMap.Create;

  ResultFinalBitmap := TBitMap.Create;

  testRadius := Round(spnbx.Value);

  Hough_CircleDetection(img_SourceImage.Bitmap, FHoughResult, testRadius);

  HoughresultToBitMap(ResultBitmap, FHoughResult);

  img_HoughResult.Bitmap.Assign(ResultBitmap);

  ResultBitmap.Free;

  ResultFinalBitmap.Free;

end;

procedure TForm1.btn_HoughLineClick(Sender: TObject);

var
  ResultBitmap: TBitMap;
  ResultFinalBitmap: TBitMap;
  Thres: Integer;
begin

  mmo_log.Lines.Add('execute a Hough Line transformation');

  ResultBitmap := TBitMap.Create;

  ResultFinalBitmap := TBitMap.Create;

  Hough_LineDetection(img_SourceImage.Bitmap, FHoughResult);

  HoughresultToBitMap(ResultBitmap, FHoughResult);

  img_HoughResult.Bitmap.Assign(ResultBitmap);

  Thres := Round(spnbx_HoughTreshold.Value);

  HoughResultToParameterDynamic(FHoughResult, (Thres / 100), FHoughFinal);

  HoughResultLineParameterToBitMap(ResultFinalBitmap, FHoughFinal);

  img_THoughAccumulator.Bitmap.Assign(ResultFinalBitmap);

  ResultBitmap.Free;

  ResultFinalBitmap.Free;
end;

procedure TForm1.btn_LoadImageClick(Sender: TObject);
begin
  mmo_log.Lines.Add('Load a test image');
  if dlgOpen.Execute then
  begin
    FImageFilename := dlgOpen.FileName;
    img_SourceImage.Bitmap.LoadFromFile(FImageFilename);
  end;
end;

end.
