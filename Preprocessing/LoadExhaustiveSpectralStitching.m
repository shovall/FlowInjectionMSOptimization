function [DIMS_arr1,minMz,maxMz]  = LoadExhaustiveSpectralStitching(folderPath)
% Loads the exhaustive mass-stitching experiment: exhaustive scanning of small ranges,
% starting from minMzThresh to maxMzThresh with a constant step (as in Config)

global Config;

minMzThresh = Config.EXHAUSTIVE_MIN_MZ;
maxMzThresh = Config.EXHAUSTIVE_MAX_MZ;
step = Config.EXHAUSTIVE_STEP;
window = Config.EXHAUSTIVE_WINDOW;
numScansInSample = Config.EXHAUSTIVE_SCANS_IN_SAMPLE;

DIMS_arr1 = {};

minMz = minMzThresh:step:maxMzThresh;
maxMz = minMzThresh+window:step:maxMzThresh;
overlapEachSide = (window-step)/2;
minMz(2:end) = minMz(2:end)+overlapEachSide;
maxMz(1:(end-1)) = maxMz(1:(end-1))-overlapEachSide;
minMz = minMz(1:length(maxMz));
rangeCount = 1;

for i=1:ceil(length(minMz)/numScansInSample)
    disp(i)
    filePath1 = strrep(folderPath,'*',num2str(i));
    config_xml1= GetConfigXML(filePath1);
    
    for scanId = 1:numScansInSample
        options = struct('scanNum',scanId,'minMz',minMz(rangeCount),'maxMz',maxMz(rangeCount));
        DIMS_arr1{end+1} = Analyze_DIMS(config_xml1,options);
        
        if(maxMz(rangeCount)>=maxMzThresh)
            break;
        end
        
        rangeCount = rangeCount+1;
    end
end

end
