function T = CreateTableDIMSData(DIMS,strPosNeg)
% Creates a table of the m/z and intensities of DIMS data, for negative or
% positive polarization, strPosNeg should be 'NEG' or 'POS'

fieldPosNeg = strcat('samples_',strPosNeg);
samples = DIMS.(fieldPosNeg);

for i = 1:size(samples.table_mz_all,2)
    v = samples.table_mz_all(:, i);
    v = v(v~=0);
    mz(i) = median(v);
end

T1 = table(mz','VariableNames',{'mz'});

numSamples = length(samples.samples_is_blank);
varNames = cell(1,numSamples);
if(isfield(DIMS,'sample_type_arr'))
    for i=1:length(DIMS.sample_type_arr)
        sampleIds = DIMS.sample_type{i};
        for j=1:length(sampleIds)
            varNames{sampleIds(j)} = strcat(DIMS.sample_type_arr{i},'_',num2str(sampleIds(j)));
        end
    end
else
    for i=1:length(samples.samples_is_blank)
        varNames{i} = strtrim(samples.sample_name{i});
    end
end
T2 = array2table(samples.table_intensity_all','VariableNames',varNames);

T = [T1,T2];
end