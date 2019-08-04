function [rangesThresholds] = FindEqualEffectRanges(dataArr,mzMinVec,mzMaxVec,numScans,minMz,maxMz)
% Calculates m/z scan ranges based on the distribution of input data (e.g.
% total ion count or number of significant m/z features), which was measured in
% specific m/z ranges given by mzMinVec and mzMaxVec.
% numScans: the number or requested output scans. 
% minMz, maxMz: the minimal and maximal m/z for the output scans.

dataExtended = DataExtension(mzMinVec,mzMaxVec,dataArr,minMz,maxMz);

% Cumulative sum is calculated
dataCum = cumsum(dataExtended);

% minMz and maxMz are defined as the boundaries of the output ranges
rangesThresholds = [minMz,maxMz];
totalsum = dataCum(end);
sumToSplitIn = totalsum/numScans;

% For each i from 1 to the number of requested ranges the boundaries are
% calclated. The end boundary of scan number i, it finds the minimal i such
% that the cumulative sum is higher than i*sumToSplitIn
for i=1:numScans-1
    rangesThresholds(end+1) = FindMzToSplitIn(dataCum,i*sumToSplitIn);
end
rangesThresholds = sort(rangesThresholds);
end

function mzSplit = FindMzToSplitIn(dataCum,sumToSplitIn)
mzSplit = find(dataCum>sumToSplitIn);
mzSplit = mzSplit(1);
end

function dataExtended = DataExtension(mzMinVec,mzMaxVec,data,minMz,maxMz)

dataExtended = zeros(mzMaxVec(end),1);

for i=1:length(data)
    rangeDist = mzMaxVec(i)-mzMinVec(i);
    dataExtended(mzMinVec(i):mzMaxVec(i)) = data(i)/rangeDist;
end

dataExtended(1:(minMz-1)) = 0;
dataExtended((maxMz+1):end) = 0;
end
