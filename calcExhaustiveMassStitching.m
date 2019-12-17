% Loads DIMS samples scanned using mass-stitching or using a single scan,
% plots distributions of significant features and total ion count and
% calculates optimized scan ranges

configFile;

%%%%%%%%% Script parameters %%%%%%%%%
folderPath1 = 'FOLDERPATH\*'; %%% Change to the correct folder path %%%
folderPath2 = 'FOLDERPATH\*';
singleRangePath1 = ''; %%% Write a path here%%%
singleRangePath2 = ''; %%% Write a path here%%%
plotFolder = ''; %%% Write a path here%%% Folder for figure plots
plotFolderRaw1 = ''; %%% Write a path here%%% Folder for raw data #1
plotFolderRaw2 = ''; %%% Write a path here%%% Folder for raw data #2
strDesc1= 'Lip';
strDesc2 = 'Met';
% Parameters for optimizing scan ranges:
numRangesVec = [1,2,4,8,16,32,64];
min1 = 70; max1 = 2500;
min2 = 70; max2 = 2500;
overlap=2;
%%%%%%%%% End of script parameters %%%%%%%%%

% Loads exhaustive scanning using mass stitching of 20 m/z-wide ranges
[DIMS_arr1,minMz,maxMz]  = LoadExhaustiveSpectralStitching(folderPath1);
[DIMS_arr2,~,~]  = LoadExhaustiveSpectralStitching(folderPath2);

%Loads single range scans 70-2500
config_xml1 = GetConfigXML(singleRangePath1);
options = struct('scanNum',1);
oneRangeScan1 = Analyze_DIMS(config_xml1,options);
config_xml1 =  GetConfigXML(singleRangePath2);
options = struct('scanNum',1);
oneRangeScan2 = Analyze_DIMS(config_xml1,options);

% Compares mass-stitching to single scan
PlotFiguresManyVsSingleRange(DIMS_arr1,DIMS_arr2,oneRangeScan1,oneRangeScan2,minMz,maxMz,plotFolder)

% Extracts the number of significant m/z features and total ion count in
% each scan in the mass-stitching
centerMz = (minMz+maxMz)/2;
numRanges = length(maxMz);
featNeg1 = zeros(numRanges,1);featNeg2 = zeros(numRanges,1);
featPos1 = zeros(numRanges,1);featPos2 = zeros(numRanges,1);
TicNeg1 = zeros(numRanges,1);TicPos1 = zeros(numRanges,1);
TicNeg2 = zeros(numRanges,1);TicPos2 = zeros(numRanges,1);
for i=1:numRanges
    TicNeg1(i) = median(DIMS_arr1{i}.samples_NEG.scan_sample_totalIonCount...
        ((~DIMS_arr1{i}.samples_NEG.samples_is_blank)));
    TicPos1(i) = median(DIMS_arr1{i}.samples_POS.scan_sample_totalIonCount...
        ((~DIMS_arr1{i}.samples_POS.samples_is_blank)));
    TicNeg2(i) = median(DIMS_arr2{i}.samples_NEG.scan_sample_totalIonCount...
        ((~DIMS_arr2{i}.samples_NEG.samples_is_blank)));
    TicPos2(i) = median(DIMS_arr2{i}.samples_POS.scan_sample_totalIonCount...
        ((~DIMS_arr2{i}.samples_POS.samples_is_blank)));
    
    featNeg1(i) = length(DIMS_arr1{i}.samples_NEG.sig_features);
    featNeg2(i) = length(DIMS_arr2{i}.samples_NEG.sig_features);
    featPos1(i) = length(DIMS_arr1{i}.samples_POS.sig_features);
    featPos2(i) = length(DIMS_arr2{i}.samples_POS.sig_features);
end

% Plots distributions of significant features and TIC
PlotTicAndSfFigures(centerMz,TicNeg1,TicPos1,featNeg1,featPos1,strDesc1,plotFolder);
PlotTicAndSfFigures(centerMz,TicNeg2,TicPos2,featNeg2,featPos2,strDesc2,plotFolder);

% Optimizes scan ranges
for i=numRangesVec
    SuggestOptimizedRanges(TicNeg1,TicPos1,featNeg1,featPos1,minMz,maxMz,strDesc1,i,min1,max1,overlap)
    SuggestOptimizedRanges(TicNeg2,TicPos2,featNeg2,featPos2,minMz,maxMz,strDesc2,i,min2,max2,overlap)
end

% Saves Raw tables
SaveAllTablesDiffRanges(DIMS_arr1,strDesc1,centerMz,plotFolderRaw1,0);
SaveAllTablesDiffRanges(DIMS_arr2,strDesc2,centerMz,plotFolderRaw2,0);
