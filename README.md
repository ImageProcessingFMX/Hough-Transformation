\# Hough-Transformation



Hough transformation for \*\*circle\*\* and \*\*line\*\* detection in Delphi / Pascal (FMX demo included)



Looking for the VCL version: https://sourceforge.net/projects/houghtransforma/ \[2]



\---



\## Overview



This project contains a Delphi/Pascal implementation of the Hough Image Transformation algorithm.

It supports:



\- \*\*Line detection\*\* via classic Hough space (θ, r) voting

\- \*\*Circle detection\*\* via a circle Hough transform (radius provided by the user/UI) \[1]



The implementation produces good results on simple test images and includes post-processing capabilities with dynamic thresholding \[3].



\---



\## Algorithm Details



\### Line Detection Algorithm



The line Hough transform works by:



1\. \*\*Voting in parameter space\*\*: For each edge point in the image, the algorithm votes in a 2D accumulator array indexed by angle (θ) and distance (r) \[3]

2\. \*\*Peak detection\*\*: After voting, peaks in the accumulator represent likely lines in the original image

3\. \*\*Thresholding\*\*: The implementation includes both fixed and dynamic thresholding methods to filter results \[3]



The key mathematical relationship is:

\- `r = X \\\* cos(θ) + Y \\\* sin(θ)`



The algorithm provides two thresholding approaches:

\- \*\*Fixed threshold\*\*: Using `HoughResultToParameter` with a set range value \[3]

\- \*\*Dynamic threshold\*\*: Using `HoughResultToParameterDynamic` for adaptive filtering based on local statistics \[3]



\### Circle Detection Algorithm



Circle detection is exposed as a function that takes:

\- An input bitmap

\- A Hough accumulator/result structure

\- A \*\*test radius\*\* (chosen by the user) \[1]



The implementation is designed to run for a specific radius. To detect circles of unknown sizes, you would need to repeat the process across multiple radii \[1].



\---



\## Project Structure



\- `Unit\\\_HoughTransformation.pas`

&#x20; Core algorithm implementation for line and circle detection, including helper functions for finding maxima and thresholding \[3].

&#x20;

\- `GUI.FMX.HoughTransform\\\_Demo.pas`

&#x20; FireMonkey (FMX) demo GUI that loads an image, runs line/circle detection, and displays results \[1].

&#x20;

\- `README.md`

&#x20; This file.



\---



\## API / Key Types



The algorithm unit defines:



\- `THoughResult = array of array of integer;` - 2D accumulator array \[3]

\- `THoughFinal` - Structure containing filtered results with X, Y, and Z (vote count) coordinates \[3]



Main entry points:



\- `procedure Hough\\\_LineDetection(AnalysisBitmap: TBitMap; var aHoughResult: THoughResult);` \[1]

\- `procedure Hough\\\_CircleDetection(AnalysisBitmap: TBitMap; var aHoughResult: THoughResult; Radius: Integer);` \[1]



Helper functions:



\- `function MAX\\\_2D(aHoughResult: THoughResult): integer;` - Finds maximum value in accumulator \[3]

\- `function MEAN\\\_2D\\\_Local(aHoughResult: THoughResult; x\\\_pos, y\\\_pos, x\\\_size, y\\\_size: integer): integer;` - Calculates local mean \[3]

\- `procedure HoughResultToParameterDynamic(aHoughResult: THoughResult; Range: Real; var aHoughFinal: THoughFinal);` - Applies dynamic thresholding \[3]



\---



\## How to Use



\### 1) Line Detection (Basic)



```pascal

var

\&#x20; AnalysisBitmap: TBitmap;

\&#x20; HoughResult: THoughResult;

\&#x20; ResultBitmap: TBitmap;

begin

\&#x20; // Prepare your source bitmap

\&#x20; AnalysisBitmap := TBitmap.Create;

\&#x20; // ... load image into AnalysisBitmap ...

\&#x20; 

\&#x20; // Run Hough line detection

\&#x20; Hough\\\_LineDetection(AnalysisBitmap, HoughResult);

\&#x20; 

\&#x20; // Convert result to viewable bitmap

\&#x20; ResultBitmap := TBitmap.Create;

\&#x20; HoughresultToBitMap(ResultBitmap, HoughResult);

\&#x20; 

\&#x20; // Display or save ResultBitmap

\&#x20; // ...

\&#x20; 

\&#x20; ResultBitmap.Free;

\&#x20; AnalysisBitmap.Free;

end;





2\\) Line Detection (With Thresholding)









```pascal

var

\&#x20; AnalysisBitmap: TBitmap;

\&#x20; HoughResult: THoughResult;

\&#x20; HoughFinal: THoughFinal;

\&#x20; ResultBitmap: TBitmap;

\&#x20; Threshold: Integer;

begin

\&#x20; // Run detection

\&#x20; Hough\\\_LineDetection(AnalysisBitmap, HoughResult);

\&#x20; 

\&#x20; // Apply dynamic thresholding

\&#x20; Threshold := 50; // Percentage (0-100)

\&#x20; HoughResultToParameterDynamic(HoughResult, (Threshold / 100), HoughFinal);

\&#x20; 

\&#x20; // Convert filtered results to bitmap

\&#x20; ResultBitmap := TBitmap.Create;

\&#x20; HoughResultLineParameterToBitMap(ResultBitmap, HoughFinal);

\&#x20; 

\&#x20; ResultBitmap.Free;

end;







3\\) Circle Detection




```pascal
var

\&#x20; AnalysisBitmap: TBitmap;

\&#x20; HoughResult: THoughResult;

\&#x20; ResultBitmap: TBitmap;

\&#x20; TestRadius: Integer;

begin

\&#x20; // Set the radius to search for

\&#x20; TestRadius := 25; // pixels

\&#x20; 

\&#x20; // Run Hough circle detection

\&#x20; Hough\\\_CircleDetection(AnalysisBitmap, HoughResult, TestRadius);

\&#x20; 

\&#x20; // Convert and display result

\&#x20; ResultBitmap := TBitmap.Create;

\&#x20; HoughresultToBitMap(ResultBitmap, HoughResult);

\&#x20; 

\&#x20; ResultBitmap.Free;

end;





FMX Demo Usage

The included FireMonkey demo provides a GUI for testing the algorithms 

GUI.FMX.HoughTr...m\_Demo.pas

:



Loading an Image

Click the Load Image button

Select a test image from your file system 

GUI.FMX.HoughTr...m\_Demo.pas

Line Detection

Load an image

Optionally adjust the Hough Threshold slider (controls filtering sensitivity) 

GUI.FMX.HoughTr...m\_Demo.pas

Click Hough Line button to run line detection 

GUI.FMX.HoughTr...m\_Demo.pas

View results:

Hough Result: Raw accumulator visualization

Hough Accumulator: Filtered line parameters overlaid on image 

GUI.FMX.HoughTr...m\_Demo.pas

Circle Detection

Load an image

Set the radius value using the spinbox control 

GUI.FMX.HoughTr...m\_Demo.pas

Click Hough Circle button to run circle detection 

GUI.FMX.HoughTr...m\_Demo.pas

View the Hough Result image showing detected circles 

GUI.FMX.HoughTr...m\_Demo.pas

Implementation Notes

Dynamic Thresholding

The implementation includes dynamic thresholding functionality that adapts to the accumulator data 

Unit\_HoughTransformation.pas

:



Computes maximum values across the accumulator using MAX\_2D 

Unit\_HoughTransformation.pas

Filters votes based on a percentage of the maximum (Range \* max) 

Unit\_HoughTransformation.pas

Can incorporate local gradient information with configurable minimum gradient (Grad\_Min) 

Unit\_HoughTransformation.pas

Result Interpretation

Bright pixels in accumulator = High vote counts = Likely line/circle parameters

The HoughFinal structure contains filtered (X, Y, Z) coordinates where:

X, Y = Parameter space coordinates (θ, r for lines; center coordinates for circles)

Z = Vote count (confidence)




