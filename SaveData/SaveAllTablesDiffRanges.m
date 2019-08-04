function SaveAllTablesDiffRanges(DIMS_arr,lipMetStr,centerMz,folderPath,separateFiles)
% For an array of DIMS data, creates tables for each element (positive and
% negative polarization), or a combined matrix (based on the input separateFiles)

if(separateFiles)
    for i=1:length(DIMS_arr)
        T = CreateTableDIMSData(DIMS_arr{i},'POS');
        fileName = strcat(lipMetStr,'_POS_MZ=',num2str(centerMz(i)),'.xlsx');
        writetable(T,fullfile(folderPath,fileName));
        
        T = CreateTableDIMSData(DIMS_arr{i},'NEG');
        fileName = strcat(lipMetStr,'_NEG_MZ=',num2str(centerMz(i)),'.xlsx');
        writetable(T,fullfile(folderPath,fileName));
    end
else
    for i=1:length(DIMS_arr)
        TCurPos= CreateTableDIMSData(DIMS_arr{i},'POS');
        TCurNeg= CreateTableDIMSData(DIMS_arr{i},'NEG');
        if(i==1)
            TPos = TCurPos;
            TNeg = TCurNeg;
        else
            TPos = MergeTwoTables(TPos,TCurPos);
            TNeg = MergeTwoTables(TNeg,TCurNeg);
        end
    end
    TPos = [TPos(:,1) TPos(:,sort(TPos.Properties.VariableNames(2:end)))];
    fileName = strcat(lipMetStr,'_entireRange_POS','.xlsx');
    writetable(TPos,fullfile(folderPath,fileName));
    TNeg = [TNeg(:,1) TNeg(:,sort(TNeg.Properties.VariableNames(2:end)))];
    fileName = strcat(lipMetStr,'_entireRange_NEG','.xlsx');
    writetable(TNeg,fullfile(folderPath,fileName));
end
end