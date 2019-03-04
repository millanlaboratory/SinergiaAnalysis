# SinergiaAnalysis

Allow the analysis of EEG signal for each run, each session and each patient. Results can be visualized in:
* Topoplot
* Spectrogram
* Discriminancy map

## Requirements:
The analysis has been developped on MATLAB R2017b.
Data should be stored as follow:
* Data Folder
  * Subject
    * Session
      * Run 1
      * Run 2
      * ...

Please be careful about naming sessions. Calibration session should be name as `calibration_numberOfCalibrationSession_movement`. Example:
`calibration_1_flex`, `calibration_2_ext`

## How to
1. Select data folder and press button **Validate**, subjects should be listed
2. Select one or more subject and press button **Validate**, sessions should be listed
3. Select one or more sessions and press button **Validate**, runs should be listed
4. Select one or more runs and press button **Validate**, analysis panel should appear
5. Choose Analysis folder
6. We recommend saving computed analysis to save time in future presentation
7. If you have already done the analysis once and saved it in the analysis folder, you can choose to re-use it to save time.
8. Select which visualization of the data you want to observe. The visualization will be applied on each class distinctively: rest and movement.
9. Select which specific movement you want to analyze
10. Select how you want to analyze the data:
  * Per run: each visualization selected will be applied on the procesed data of each run.
  * Per session: analysis of runs of each session will be averaged per session and visualizations will be applied on the averaged data
  * Per subject: runs of all sessions will be grouped by 4 categories: **calibration flexion**, **calibration extension**, **training flexion** and **training extension**. Visualization will be available for each category.
11. When ready, press **Analyze** to start the analysis. Progress about the analysis will be displayed on the progress bar and the two text areas below.

![alt text](https://github.com/millanlaboratory/SinergiaAnalysis/blob/master/resources/gui_marked.png "GUI image here")
