unit Unit_HoughTransformation;
{ *******************************************************************************
  *
  *
  *   a PASCAL / DELPHI implementaion of the Hough Image Transformation Algorithm
  *
  *
  *
  *   initial code version :   03.04.2011 by BDLM
  *
  *   rev 0.01  :   this is the first release for circle and line detection
  *                 on simple test images this implemention will create good results
  *                 but due to the lack of any post processing code on the Accumulator
  *                 results this unit is not able to process complex images
  *   rev 0.02  :   use FRAMEWORK_VCL or FRAMEWORK_FMX as conditionla define statement
  *                 in order to use this UNIT with both frameworks
  ******************************************************************************* }

interface

uses Windows, Messages, SysUtils, Variants, Classes,
  Math,
  StrUtils, Contnrs,
{$IFDEF  FRAMEWORK_VCL}
  VCL.Graphics;
{$ENDIF}
{$IFDEF  FRAMEWORK_FMX}
FMX.Graphics, System.UITypes;
{$ENDIF}

type

  /// 2 D coordinate definition, Float data type
  FPoint = record
    X: Real;
    /// X value
    Y: Real;
    /// Y value
  end;

  /// 3 D coordinate definition  (integer values)
  THPoint3D = record
    X: integer;
    Y: integer;
    z: integer;
    Z1: integer;
    /// only for debug Hough transformation  .... ugly code !!!!!
  end;

  THoughResult = array of array of integer;
  THoughFinal = Array of THPoint3D;
  TImageContentList = TObjectList;

  /// Hough Transformation  -> Algo for Line detection
procedure Hough_LineDetection(AnalysisBitmap: TBitMap;
  var aHoughResult: THoughResult);

/// Hough Transformation  -> Algo for Circle  detection
procedure Hough_CircleDetection(AnalysisBitmap: TBitMap;
  var aHoughResult: THoughResult; r: integer);

/// show accumulator Box
procedure HoughresultToBitMap(ResultBitmap: TBitMap;
  aHoughResult: THoughResult);

/// screen for maxima inside the Hough accu box
procedure HoughResultToParameter(aHoughResult: THoughResult; Range: Real;
  var aHoughFinal: THoughFinal);

/// does a pixel have a certain value or not ???
function IsPixel(xpos, ypos: integer; aBitmap: TBitMap;
  ThresHold: integer): boolean;

/// increase sensitivity
procedure HoughResultToParameterDynamic(aHoughResult: THoughResult; Range: Real;
  var aHoughFinal: THoughFinal);

/// show accumulator Box as lines
procedure HoughResultLineParameterToBitMap(var aAnalysisBitmap: TBitMap;
  aHoughFinal: THoughFinal);

/// show accumulator Box as circles
procedure HoughResultCircleParameterToBitMap(var aAnalysisBitmap: TBitMap;
  aHoughFinal: THoughFinal; aRadius: integer);

/// convert the Lines into TThicklines ObjectList
procedure HoughResultLineParameterToObjectArray(aAnalysisBitmap: TBitMap;
  aHoughFinal: THoughFinal; aImageContentList: TImageContentList);

/// set aq values insde the HOUGH array to ZERO
function ResetArray(var aHoughResult: THoughResult): integer;

implementation

///
/// check if there is a pixel or not ....
///
/// rgb (white) = (255 | 255 | 255 )
/// rgb (black) = ( 0| 0 | 0 )
///
///

{$IFDEF  FRAMEWORK_VCL}

function IsPixel(xpos, ypos: integer; aBitmap: TBitMap;
  ThresHold: integer): boolean;
var
  p: pbyteArray;
  r, g, b, mean: integer;
begin

  aBitmap.PixelFormat := pf24bit;

  if (ypos <= aBitmap.Height - 1) and (xpos <= aBitmap.Width - 1) then

  begin
    p := aBitmap.ScanLine[ypos];

    r := p[3 * xpos];
    g := p[3 * xpos + 1];
    b := p[3 * xpos + 2];
    mean := ((round(r) + round(g) + round(b)) div 3);

    if (mean > ThresHold) then
      result := true
    else
      result := false;

  end
  else
  begin
    result := false
  end;

end;

{$ENDIF}


{$IFDEF  FRAMEWORK_FMX}

function IsPixel(xpos, ypos: integer; aBitmap: TBitMap;
  ThresHold: integer): boolean;
var
  r, g, b, mean: integer;

  bitdata: TBitmapData;
  I: integer;
  J: integer;
  C: TAlphaColor;
begin
  if (aBitmap.Map(TMapAccess.Read, bitdata)) then
    try

      C := bitdata.GetPixel(xpos, ypos);

      r := TAlphaColorRec(C).r;
      g := TAlphaColorRec(C).g;
      b := TAlphaColorRec(C).b;

      mean := round((r + g + b) / 3);

      if (mean > ThresHold) then
        result := true
      else
        result := false;

    finally
      aBitmap.Unmap(bitdata);
    end;
end;

{$ENDIF}

///
/// Hough transformation for line detection
/// r =  sin(theta) * a + cos(theta) * b
///
///
procedure Hough_LineDetection(AnalysisBitmap: TBitMap;
  var aHoughResult: THoughResult);
var
  X, Y, theta: integer;
  r: Extended;
  ImageWidth: integer;
  ImageHeight: integer;
  max_d: integer;
  max_theta: integer;
begin

  /// size of hough array
  ImageWidth := AnalysisBitmap.Width;
  ImageHeight := AnalysisBitmap.Height;

  max_d := round(sqrt(ImageHeight * ImageHeight + ImageWidth * ImageWidth));
  max_theta := 180;

  // phi         r
  SetLength(aHoughResult, max_theta, max_d);

  // For all rows in image do :
  for Y := 0 to AnalysisBitmap.Height - 1 do
  begin

    // For all pixel in one row do :
    for X := 0 to AnalysisBitmap.Width - 1 do
    begin

      // Is there a point there or not ?  If not, just skip the pixel ( threshold based methode ...)
      if IsPixel(X, Y, AnalysisBitmap, 128) then
      begin
        // iterate the unknown variables :   ( r, theta )
        // loop theta ->  to be able to determine the other unknown -> r
        for theta := 0 to max_theta do
        begin
          r := X * cos(theta * PI / max_theta) + Y *
            sin(theta * PI / max_theta);

          // Plot the finding (theta,r) into an array.
          // Ignore negative values...
          //
          if r >= 0 then
            Inc(aHoughResult[theta, round(r)]);
        end;
      end;
    end;
  end;

end;

///
/// Hough transformation for circle detection
///
///
/// AnalysisBitmap : TBitMap;         ->  the image  for hough tranmsformation
/// aHoughResult   :  THoughResult    ->  the result of the Hough transformation  array of array of integer
/// r              :  Integer;        ->  the search radius
///
///

procedure Hough_CircleDetection(AnalysisBitmap: TBitMap;
  var aHoughResult: THoughResult; r: integer);
var
  X, Y: integer;
  ImageWidth: integer;
  ImageHeight: integer;
  theta: integer;
  max_theta: integer;
  Box_LL: FPoint;
  Box_UR: FPoint;
  TestPoint: TPoint;
begin

  /// size of hough array
  ImageWidth := AnalysisBitmap.Width;
  ImageHeight := AnalysisBitmap.Height;

  ///
  Box_LL.X := 0;
  Box_UR.Y := 0;

  Box_UR.X := ImageWidth;
  Box_UR.Y := ImageHeight;

  max_theta := 360;
  // a        //  b
  SetLength(aHoughResult, ImageWidth, ImageHeight);

  // For all rows in image:
  for Y := 0 to AnalysisBitmap.Height - 1 do
  begin

    // For all pixel in one row :
    for X := 0 to AnalysisBitmap.Width - 1 do
    begin

      // Is there a point  ?
      if IsPixel(X, Y, AnalysisBitmap, 128) then
      begin

        for theta := 0 to max_theta do
        begin

          TestPoint.X := round(X - r * cos(theta * PI / max_theta));
          TestPoint.Y := round(Y - r * sin(theta * PI / max_theta));

          // if  IsPointInBox( Box_LL , Box_UR, testPoint ) then Inc(aHoughResult[x,y]);

          if ((TestPoint.X < ImageWidth) and (TestPoint.X > 0) and
            (TestPoint.Y < ImageHeight) and (TestPoint.Y > 0)) then
            Inc(aHoughResult[TestPoint.X, TestPoint.Y]);

        end;
      end;
    end;
  end;

end;

///
/// Max_Array  2D Integer array  , very simple scan through the hole array
///
function MAX_2D(aHoughResult: THoughResult): integer;
var
  n, m: integer;
  I, J: integer;
  max: integer;
begin
  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  max := aHoughResult[0][0];

  for I := 0 to n - 1 do
    for J := 0 to m - 1 do
      if aHoughResult[I][J] > max then
        max := aHoughResult[I][J];

  result := max;

end;

///
/// MEAN_Array  2D Integer array
///

function MEAN_2D_Local(aHoughResult: THoughResult;
  x_pos, y_pos, x_size, y_size: integer): integer;
var
  n, m: integer;
  I, J: integer;
  mean: integer;
begin
  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  mean := 0;

  if ((x_pos >= (n - x_size)) or (y_pos >= (m - y_size))) then
  begin
    result := 0;
    exit;
  end;

  for I := x_pos to x_pos + x_size do
    for J := y_pos to y_pos + y_size do
      mean := mean + aHoughResult[I][J];

  result := round(mean / ((x_size + 1) * (y_size + 1)));

end;

///
/// MAX_Array  2D Integer array
///

function MAX_2D_Local(aHoughResult: THoughResult;
  x_pos, y_pos, x_size, y_size: integer): integer;
var
  n, m: integer;
  I, J: integer;
  max: integer;
begin
  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  if ((x_pos >= (n - x_size)) or (y_pos >= (m - y_size))) then
  begin
    result := 0;
    exit;
  end;

  max := aHoughResult[x_pos][y_pos];

  for I := x_pos to x_pos + x_size do
    for J := y_pos to y_pos + y_size do
      if aHoughResult[I][J] > max then
        max := aHoughResult[I][J];

  result := max;

end;

///
/// Min_Array  2D Integer array
///
function MIN_2D(aHoughResult: THoughResult): integer;
var
  n, m: integer;
  I, J: integer;
  min: integer;
begin
  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  min := aHoughResult[0][0];

  for I := 0 to n - 1 do
    for J := 0 to m - 1 do
      if aHoughResult[I][J] < min then
        min := aHoughResult[I][J];

  result := min;

end;

///
/// clear result array
///
function ResetArray(var aHoughResult: THoughResult): integer;
var
  n, m: integer;
  I, J: integer;
  // min      :  Integer;
begin
  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  // min :=  aHoughResult[0][0];

  for I := 0 to n - 1 do
    for J := 0 to m - 1 do
      aHoughResult[I][J] := 0;
  result := 1;

end;

///
/// copy the Hough Accumulator into a 3D INT Array Data type
/// in :
/// aHoughResult   ->  the Hough accu
/// range [ 0..1]
/// out:
/// aHoughFinal     list of points above the max
/// [x,y,z]
///
///
procedure HoughResultToParameter(aHoughResult: THoughResult; Range: Real;
  var aHoughFinal: THoughFinal);
var
  n, m: integer;
  I, J: integer;
  max: integer;
  MAXR: Real;
  resultlen: integer;
begin

  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  resultlen := 0;

  max := MAX_2D(aHoughResult);
  if (max = 0) then
    max := 1;

  MAXR := max * Range;

  for I := 0 to n - 1 do
    for J := 0 to m - 1 do
      if (aHoughResult[I, J] > MAXR) then
      begin

        SetLength(aHoughFinal, resultlen + 1);

        aHoughFinal[resultlen].X := I;

        aHoughFinal[resultlen].Y := J;

        aHoughFinal[resultlen].z := aHoughResult[I, J];

        resultlen := resultlen + 1;

      end;

end;

///
/// as above, but now with dynamic thresholding
/// http://homepages.inf.ed.ac.uk/rbf/HIPR2/histeq.htm
/// http://homepages.inf.ed.ac.uk/rbf/HIPR2/hough.htm
///
///

procedure HoughResultToParameterDynamic(aHoughResult: THoughResult; Range: Real;
  var aHoughFinal: THoughFinal);
var
  n, m: integer;
  I, J: integer;
  max: integer;
  mean: integer;
  MAXR: Real;
  resultlen: integer;
  Grad: integer;
  Grad_Min: integer;
begin

  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  resultlen := 0;

  Grad_Min := 30;

  for I := 0 to n - 1 do
    for J := 0 to m - 1 do
    begin

      max := MAX_2D_Local(aHoughResult, I, J, 10, 10);

      mean := MEAN_2D_Local(aHoughResult, I, J, 10, 10);

      Grad := (max - mean);

      MAXR := max * Range;

      if ((aHoughResult[I, J] > MAXR) and (Grad > Grad_Min)) then
      begin

        SetLength(aHoughFinal, resultlen + 1);

        aHoughFinal[resultlen].X := I;

        aHoughFinal[resultlen].Y := J;

        aHoughFinal[resultlen].z := aHoughResult[I, J];

        aHoughFinal[resultlen].Z1 := round(MAXR);

        resultlen := resultlen + 1;

      end;
    end;

end;

///
/// all bright points represet a line ---  you need to draw them now ....
///
///

procedure HoughResultLineParameterToBitMap(var aAnalysisBitmap: TBitMap;
  aHoughFinal: THoughFinal);
var
  lenArray, I: integer;
  s, C: Extended;
  dx, dy: integer;
  angle: integer;
  Radius: integer;
  MPoint: TPoint;
  maxlen: integer;

begin
  lenArray := length(aHoughFinal);

  maxlen := max(aAnalysisBitmap.Width, aAnalysisBitmap.Height);

  for I := 0 to lenArray - 1 do
  begin

    angle := aHoughFinal[I].X;

    Radius := aHoughFinal[I].Y;

    sincos(degtorad(angle), s, C);

    MPoint := Point(round(C * Radius), round(s * Radius));

    sincos(degtorad(angle + 90), s, C);

    dx := round(C * maxlen);

    dy := round(s * maxlen);

{$IFDEF  FRAMEWORK_VCL}
    With aAnalysisBitmap.canvas Do
    Begin

      pen.color := clRed;

      moveto(MPoint.X + dx, MPoint.Y + dy);

      lineto(MPoint.X - dx, MPoint.Y - dy);
    End;
{$ENDIF}
  end;

end;

///
///
/// the Hough Array only contains the line - without start and ending coordinates - scan the line inside the *.bmp
/// for starting and ending point
/// NOT YET IMPLEMENTED NEED CODE SUPPORT HERE !!!!!
///

procedure HoughResultLineParameterToObjectArray(aAnalysisBitmap: TBitMap;
  aHoughFinal: THoughFinal; aImageContentList: TImageContentList);
var
  lenArray, I: integer;
  // angle        :  Integer;
  // Radius       :  Integer;
  // maxlen       :  Integer;

begin
  lenArray := length(aHoughFinal);

  // maxlen := max( aAnalysisBitmap.Width, aAnalysisBitmap.Height);

  for I := 0 to lenArray - 1 do
  begin

    // angle := aHoughFinal[i].x;

    // Radius := aHoughFinal[i].y;

    // aLine := TThickline.Create;

    // aImageContentList.Add(aLine)

  end;
end;

///
///
///

procedure HoughResultCircleParameterToBitMap(var aAnalysisBitmap: TBitMap;
  aHoughFinal: THoughFinal; aRadius: integer);
var
  lenArray, I: integer;
  A, b: integer;

  // maxlen          :  Integer;

begin
  lenArray := length(aHoughFinal);

  // maxlen := max( aAnalysisBitmap.Width, aAnalysisBitmap.Height);

  aRadius := round(aRadius / 4);

  for I := 0 to lenArray - 1 do
  begin

    A := aHoughFinal[I].X;

    b := aHoughFinal[I].Y;

{$IFDEF  FRAMEWORK_VCL}
    With aAnalysisBitmap.canvas Do
    Begin

      pen.color := clRed;

      ellipse(A + aRadius, b + aRadius, A - aRadius, b - aRadius);

    End;
{$ENDIF}
  end;

end;

///
/// copy the Hough Accumulator into a 2D INT Array Data type
///
{$IFDEF  FRAMEWORK_FMX}

procedure HoughresultToBitMap(ResultBitmap: TBitMap;
  aHoughResult: THoughResult);

var
  n, m: integer;

  h, w: integer;
  xquer: integer;
  max: integer;
  bitdata: TBitmapData;
  C: TAlphaColor;
begin

  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  ResultBitmap.Width := n; // 1. parameter
  ResultBitmap.Height := m; // 2. Parameter

  max := MAX_2D(aHoughResult);
  if (max = 0) then
    max := 1;

  if (ResultBitmap.Map(TMapAccess.ReadWrite, bitdata)) then
    try

      For h := 0 to ResultBitmap.Height - 1 do
        for w := 0 to ResultBitmap.Width - 1 do
        begin
          xquer := round(aHoughResult[w, h] / max * 255);

          // C := bitdata.GetPixel(h, w);

          TAlphaColorRec(C).r := xquer;
          TAlphaColorRec(C).g := xquer;
          TAlphaColorRec(C).b := xquer;
          TAlphaColorRec(C).A := 255;

          bitdata.SetPixel(h, w, C)

        end;
    finally
      ResultBitmap.Unmap(bitdata);
    end;

end;
{$ENDIF}
{$IFDEF  FRAMEWORK_VCL}

procedure HoughresultToBitMap(ResultBitmap: TBitMap;
  aHoughResult: THoughResult);
type
  PixArray = Array [1 .. 3] of Byte;
var
  n, m: integer;
  p: ^PixArray;
  h, w: integer;
  xquer: integer;
  max: integer;
  bitdata: TBitmapData;
begin

  n := length(aHoughResult);
  m := length(aHoughResult[0]);

  ResultBitmap.Width := n; // 1. parameter
  ResultBitmap.Height := m; // 2. Parameter

  max := MAX_2D(aHoughResult);
  if (max = 0) then
    max := 1;

  ResultBitmap.PixelFormat := pf24bit;

  For h := 0 to ResultBitmap.Height - 1 do
  begin
    p := ResultBitmap.ScanLine[h];
    For w := 0 to ResultBitmap.Width - 1 do
    begin
      xquer := round(aHoughResult[w, h] / max * 255);
      p^[1] := xquer;
      p^[2] := xquer;
      p^[3] := xquer;
      Inc(p);
    end;
  end;

end;
{$ENDIF}

end.
