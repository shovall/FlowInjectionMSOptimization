function [samples] = ChooseSigFeatures(samples,idsOfSamples,idsOfBlanks)
% Identifies significant m/z features based on the following criteria: 
% (a) Appearing in most samples (based on Config.SF_NUM_SAMPLES)
% (b) SNR (signla to noise ratio) of the Config.SF_SNR_TOP_SAMPLE percetntile of sample
% compared to the Config.SF_SNR_TOP_BLANK percentile in blanks is higher
% than Config.SF_SNR
% (c) Median intensity is higher than Config.SF_INTENSITY
% (d) RSD (relative standard deviation) is lower than Config.SF_RSD

global Config;

sample_num = length(idsOfSamples);

% Features appearing in most samples (a)
samples.features_sig_sample_num = find(sum(samples.table_mz_all(idsOfSamples, :) ~= 0) >= sample_num*Config.SF_NUM_SAMPLES);

% SNR (b)
featIdsSig = samples.features_sig_sample_num;
intSamples = samples.table_intensity_all(idsOfSamples, featIdsSig);
intBlanks = samples.table_intensity_all(idsOfBlanks, featIdsSig);
percentileSamples = zeros(1,size(intBlanks,2));
percentileBlanks = zeros(1,size(intBlanks,2));
numTopBlank = floor(size(intBlanks,1) * Config.SF_SNR_TOP_BLANK);
numTopSample = floor(size(intSamples,1) * Config.SF_SNR_TOP_SAMPLE);

for i=1:size(intBlanks,2)  
    sortedIntBlank = sort(intBlanks(:,i));
    percentileBlanks(i) = sortedIntBlank(numTopBlank);
    
    sortedIntSample = sort(intSamples(:,i));
    percentileSamples(i) = sortedIntSample(numTopSample);
end

snrVals = percentileSamples./percentileBlanks;
samples.features_SNR = zeros(size(samples.table_intensity_all,2), 1);
samples.features_SNR(featIdsSig) = snrVals;
samples.features_sig_SNR = featIdsSig(snrVals > Config.SF_SNR);

% Intensity threshold (c)
medianIntSample = median(intSamples);
samples.features_sig_intensity = featIdsSig(medianIntSample > Config.SF_INTENSITY);

% RSD (d)
featIdsSig = intersect(samples.features_sig_SNR, samples.features_sig_intensity);

mat = samples.table_intensity_all(idsOfSamples, featIdsSig);

mat = mat ./ repmat(median(mat,2),1,size(mat,2)) .* repmat(median(mat,1),size(mat,1),1);
rsdVals = std(mat)./mean(mat);

samples.features_RSD = zeros(size(samples.table_intensity_all,2), 1);
samples.features_RSD(featIdsSig) = rsdVals;

samples.sig_features = featIdsSig(rsdVals<Config.SF_RSD);

sig_features_mz = zeros(size(samples.sig_features));
for i = 1:size(samples.table_mz_all,2)
    mzDiffSamples = samples.table_mz_all(:, i);
    mzDiffSamples = mzDiffSamples(mzDiffSamples~=0);
    mz(i) = median(mzDiffSamples);
end

samples.mz_analyzed_median = mz;
samples.sig_features_mz = mz(samples.sig_features);
end
