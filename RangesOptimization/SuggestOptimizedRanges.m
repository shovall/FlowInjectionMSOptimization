function SuggestOptimizedRanges(TicNeg,TicPos,FeatNeg,FeatPos,mzMinVec,mzMaxVec,lipMetStr,numScans,minMz,maxMz,overlap)
% Calculates m/z scan ranges based on the distribution of input data: 
% total ion count and the number of significant m/z features, which was measured in
% specific m/z ranges given by mzMinVec and mzMaxVec.
% The calculated ranges are saved to text files and Matlab files. 
% numScans: the number or requested output scans. 
% minMz, maxMz: the minimal and maximal m/z for the output scans.
% lipMetStr: string which represents the data (e.g. Lipidomics)

global Config;
filePath = fullfile(Config.SUGGESTED_RANGES,sprintf('SuggestedRanges- %d - %s.txt',numScans,lipMetStr));
fileID = fopen(filePath,'wt');

%Uniform
ranges = round(linspace(minMz,maxMz,numScans+1));
WriteToFiles('Uniform',ranges,fileID,lipMetStr,overlap);

%Total ion count, neg, pos
if(~sum(isnan(TicNeg)) && ~sum(isnan(TicNeg)))
    ranges = FindEqualEffectRanges(TicNeg,mzMinVec,mzMaxVec,numScans,minMz,maxMz);
    WriteToFiles('TIC-NEG',ranges,fileID,lipMetStr,overlap);
    
    ranges = FindEqualEffectRanges(TicPos,mzMinVec,mzMaxVec,numScans,minMz,maxMz);
    WriteToFiles('TIC-POS',ranges,fileID,lipMetStr,overlap);
end

%Significant features
if(~sum(isnan(FeatNeg)) && ~sum(isnan(FeatPos)))
    ranges = FindEqualEffectRanges(FeatNeg,mzMinVec,mzMaxVec,numScans,minMz,maxMz);
    WriteToFiles('SF-NEG',ranges,fileID,lipMetStr,overlap);
    
    ranges = FindEqualEffectRanges(FeatPos,mzMinVec,mzMaxVec,numScans,minMz,maxMz);
    WriteToFiles('SF-POS',ranges,fileID,lipMetStr,overlap);
end

fclose(fileID);
end

function WriteToFiles(title,ranges,fileID,lipMetStr,overlap)
global Config;
rangesMin = ranges(1:end-1);
rangesMax = ranges(2:end);

% Add ovarlap
rangesMin(2:end) = rangesMin(2:end)-overlap;
rangesMax(1:end-1) = rangesMax(1:end-1)+overlap;

fprintf(fileID,'%s - %s \n',lipMetStr,title);

for i=1:length(rangesMin)
    fprintf(fileID,'#%d: %s-%s',i, num2str(rangesMin(i)),num2str(rangesMax(i)));
    if(i<length(rangesMin))
        fprintf(fileID,', ');
    end
    if(mod(i,8)==0)
        fprintf(fileID,'\n');
    end
end
fprintf(fileID,'\n\n');
matlabFilePath = fullfile(Config.SUGGESTED_RANGES_MATLAB,sprintf('%s-%d-%s',lipMetStr,length(ranges)-1,title));
save(matlabFilePath,'ranges');
end
