function [samples] = FindJointPeaks(samples)
% Identifies and aligns m/z peaks of different samples based on an input
% tolerance (Config.MS_ACCURACY).
% For running time reasons this function uses parfor and calculates for each
% scan separately (in a different Matlab worker).

global Config;
MS_ACCURACY = Config.MS_ACCURACY;
scan_sample_data = samples.scan_sample_data;
scan_num = samples.scan_num;
sample_num = length(scan_sample_data{1});
table_mz_all_Arr = cell(scan_num,1);
table_intensity_all_Arr = cell(scan_num,1);
table_mz_scan_Arr = cell(scan_num,1);

% Find the maximal m/z in all samples (in all scans)
maxMzInData = 0;
for i=1:scan_num
    for j=1:sample_num
        maxMzCur = max(scan_sample_data{i}{j}(:,1));
        maxMzInData = max(maxMzInData,maxMzCur);
    end
end
maxMzInData = double(ceil(maxMzInData));

parfor i=1:scan_num
    table_mz_all_Cur = zeros(sample_num,0);
    table_intensity_all_Cur = zeros(sample_num,0);
    table_mz_scan_Cur = [];
    fprintf('.');
    peaksRoundedMat = [];
    allPeaksRounded = [];
    for x=1:sample_num
        curPeaksRounded = round(scan_sample_data{i}{x}(:,1));
        peaksRoundedMat{x} = sparse([1:length(curPeaksRounded)]', double(curPeaksRounded(:,1)),...
            ones(length(curPeaksRounded), 1), length(curPeaksRounded), maxMzInData);
        allPeaksRounded = [allPeaksRounded; curPeaksRounded];
    end
    
    for y=min(allPeaksRounded):max(allPeaksRounded)
        scan_sample_data2 = [];
        for x=1:sample_num
            scan_sample_data2{x} = scan_sample_data{i}{x}( find(peaksRoundedMat{x}(:, y)), :);
        end
        [table_mz, table_intensity, table_diff] = FindJointPeaksPerScan(scan_sample_data2, MS_ACCURACY);
        
        %Remove overlapping feature groups
        for z=1:size(table_mz,1)
            [mzs,~,~]=unique(table_mz(z,:));
            for k=1:length(mzs)
                if (mzs(k) == 0)
                    continue;
                end
                curSampleMzs = table_mz(z,:);        
                matchedMzIds = find(curSampleMzs==mzs(k));
                if length(matchedMzIds)>1          
                    mzGroups = table_mz(:, matchedMzIds);
                    [~,selectedGroupId] = max(sum(mzGroups~=0));
                    
                    locsToRemove = zeros(length(curSampleMzs), 1);
                    locsToRemove(matchedMzIds) = 1;
                    locsToRemove(matchedMzIds(selectedGroupId)) = 0;
                    
                    table_mz = table_mz(:, locsToRemove==0);
                    table_intensity = table_intensity(:, locsToRemove==0);         
                end
            end
        end
        
        table_mz_all_Cur = [table_mz_all_Cur, table_mz];
        table_intensity_all_Cur = [table_intensity_all_Cur, table_intensity];
        table_mz_scan_Cur = [table_mz_scan_Cur; zeros(size(table_mz,2), 1)+ i];
    end
    
    table_mz_all_Arr{i} = table_mz_all_Cur;
    table_intensity_all_Arr{i} = table_intensity_all_Cur;
    table_mz_scan_Arr{i} = table_mz_scan_Cur;
end

table_mz_all = zeros(sample_num,0);
table_intensity_all = zeros(sample_num,0);
table_mz_scan = [];

for i=1:length(table_mz_all_Arr)
    table_mz_all = [table_mz_all,table_mz_all_Arr{i}];
    table_intensity_all = [table_intensity_all,table_intensity_all_Arr{i}];
    table_mz_scan = [table_mz_scan;table_mz_scan_Arr{i}];
end
samples.table_mz_all = table_mz_all;
samples.table_intensity_all = table_intensity_all;
samples.table_mz_scan = table_mz_scan;

end

function [table_mz_unique, table_intensity_unique, table_diff] = FindJointPeaksPerScan(d,MS_ACCURACY)
TOL = MS_ACCURACY*2;

sample_num = length(d);

table_mz = zeros(sample_num,0);
table_intensity = zeros(sample_num,0);
table_diff = zeros(0, 1);
col_num = 1;

for i=1:sample_num
    for x=1:size(d{i},1)
        mz = d{i}(x, 1);
        intensity = d{i}(x, 2);
        
        v_mz = zeros(sample_num,1);
        v_intensity = zeros(sample_num,1);
        
        v_mz(i) = mz;
        v_intensity(i) = intensity;
        
        for y=1:sample_num
            if y==i
                continue;
            end
            v = find(d{y}(:, 1) > mz*(1-TOL) & d{y}(:, 1) < mz*(1+TOL));
            
            if length(v)>1
                if  (abs(d{y}(v(1), 1)-mz) < abs(d{y}(v(2), 1)-mz))
                    v = v(1);
                else
                    v = v(2);
                end
            end
            
            if ~isempty(v)
                v_mz(y) = d{y}(v, 1);
                v_intensity(y) = d{y}(v, 2);
            end
        end
        
        u = v_mz(v_mz~=0);
        group_diff = (max(u) - min(u))./max(u);
        if ( group_diff < TOL )
            table_mz(:, col_num) = v_mz;
            table_intensity(:, col_num) = v_intensity;
            table_diff(col_num) = group_diff;
            col_num = col_num + 1;
        end
        
    end
end

[table_mz_unique, a, b] = unique(table_mz', 'rows');
table_mz_unique = table_mz_unique';
table_intensity_unique = table_intensity(:, a);

end
