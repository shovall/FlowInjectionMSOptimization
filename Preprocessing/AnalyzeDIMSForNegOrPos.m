function [samples] = AnalyzeDIMSForNegOrPos(config_xml,NEGorPOS,options)
% Performs the DIMS data analysis for negative or positive
% polarization mode based on the given string as input: NEGorPOS, which
% should be 'NEG' or 'POS'. The config_xml should contain sample and blank
% names (config_xml.Config.SampleFile{i}.Text) and path
% config_xml.Config.Path.Text
% It accepts additional parameters through the
% options struct: scanNum (the numbers of scan ranges in the samples to
% analyze), minMz and maxMz (minimal and maximal m/z values to analyze),
% idsSamplesForSigFeatCalc and idsBlanksForSigFeatCalc (ids of samples and
% blanks to use for significant features check), toAnnotate, annotation_db

global Config;
if(isfield(options,'scanNum'))
    SCANS_SELECTED = options.scanNum;
else
    SCANS_SELECTED = Config.SCANS_SELECTED;
end

samples.data = [];
samples_is_blank_original = [];
fprintf('Sample %s # %d', NEGorPOS,length(config_xml.Config.SampleFile));
for i=1:length(config_xml.Config.SampleFile)
    sample = LoadSample([config_xml.Config.Path.Text NEGorPOS '_' config_xml.Config.SampleFile{i}.Text]);
    if(isstruct(sample))
        samples.data{end+1} = sample;
        samples_is_blank_original(end+1) = 0;
        fprintf('.');
    end
end
fprintf('\n');

fprintf('Blank %s # %d', NEGorPOS, length(config_xml.Config.BlankFile));
for i=1:length(config_xml.Config.BlankFile)
    sample = LoadSample([config_xml.Config.Path.Text NEGorPOS '_' config_xml.Config.BlankFile{i}.Text]);
    if(isstruct(sample))
        samples.data{end+1} = sample;
        samples_is_blank_original(end+1) = 1;
        fprintf('.');
    end
end
fprintf('\n');

samples.mode = NEGorPOS;

samples.samples_is_blank = samples_is_blank_original;
samples.data_raw = samples.data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose Scans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
samples.scan_index_used = SCANS_SELECTED; 

for i=1:length(samples.data)
    samples.data{i}.scan = samples.data{i}.scan(samples.scan_index_used);
end

samples.scan_num = length(samples.scan_index_used);

% Remove peaks outside selected range
if(isfield(options,'minMz') && isfield(options,'maxMz'))
    [samples] = SamplesAfterPeakSelctionInRange(samples,options.minMz,options.maxMz);
end

[samples] = AddRTAndTICData(samples);

% Add sample names
f1 = [config_xml.Config.SampleFile config_xml.Config.BlankFile];
f2 = [];
for i=1:length(f1)
    s = f1{i}.Text;
    f2{i} = s(1:end-6);
end
samples.sample_name = f2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Align peaks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Align Peaks %s',NEGorPOS);
samples = FindJointPeaks(samples);
fprintf('\n');
[samples] = AddIntensityData(samples);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose significant features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idsSamplesForSigFeatCalc = find(samples.samples_is_blank == 0);
if(isfield(options,'idsSamplesForSigFeatCalc'))
    idsSamplesForSigFeatCalc = idsSamplesForSigFeatCalc(options.idsSamplesForSigFeatCalc);
end
idsBlanksForSigFeatCalc = find(samples.samples_is_blank == 1);
if(isfield(options,'idsBlanksForSigFeatCalc'))
    idsBlanksForSigFeatCalc = idsBlanksForSigFeatCalc(options.idsBlanksForSigFeatCalc);
end
if(~isempty(idsSamplesForSigFeatCalc) && ~isempty(idsBlanksForSigFeatCalc))
    samples = ChooseSigFeatures(samples,idsSamplesForSigFeatCalc,idsBlanksForSigFeatCalc);
end
if(isfield(options,'removeRepeatedSigMzs'))
    samples = RemoveRepeatedSigMzs(samples);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Annotate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isfield(options,'toAnnotate') && isfield(options,'annotation_db') && options.toAnnotate==1 )
    annotation_db = options.annotation_db; 
    samples = AnnotatePeaks(samples, annotation_db);
end
end

function [samples] = AddRTAndTICData(samples)
scan_sample_data = [];
scan_sample_RT = [];
scan_sample_totalIonCount = [];
s = 0;
for i=1:samples.scan_num
    for x=1:length(samples.data)
        X = samples.data{x}.scan(i).peaks.mz(1:2:end);
        Y = samples.data{x}.scan(i).peaks.mz(2:2:end);
        
        scan_sample_data{i}{x} = [X, Y];
        scan_sample_RT(i, x) = str2num(samples.data{x}.scan(i).retentionTime(3:end-1));
        scan_sample_totalIonCount(i, x) = samples.data{x}.scan(i).totIonCurrent;
    end
end

samples.scan_sample_data = scan_sample_data;
samples.scan_sample_RT = scan_sample_RT;
samples.scan_sample_totalIonCount = scan_sample_totalIonCount;
end

function [samples] = AddIntensityData(samples)
numMzs = size(samples.table_intensity_all,2);
samples_median_intensity = zeros(1,numMzs);
blanks_median_intensity = zeros(1,numMzs);

samples_median_intensity = median(samples.table_intensity_all(samples.samples_is_blank==0,:));
blanks_median_intensity = median(samples.table_intensity_all(samples.samples_is_blank==1,:));

samples.samples_median_intensity = samples_median_intensity;
samples.blanks_median_intensity = blanks_median_intensity;
end

function samples = AnnotatePeaks(samples, MetabolomeDB)
global Config;
mz_list = median(samples.table_mz_all(samples.samples_is_blank == 0, samples.sig_features));
TOL = Config.MS_ACCURACY;
mass_HnE =  Config.PROTON_MASS;

mz_met_list = sparse(length(mz_list), length(MetabolomeDB.mass));
for i=1:length(mz_list)
    
    if strcmp(samples.mode, 'NEG') == 1
        mz = mz_list(i) + mass_HnE;
    else
        mz = mz_list(i) - mass_HnE;
    end
    
    mzIds = find(abs(MetabolomeDB.mass-mz)./MetabolomeDB.mass < TOL);
    mz_met_list(i, mzIds) = 1;
end

%%%%%%%%%
mzIds = find(sum(mz_met_list') >0 );
formula_list = cell(length(mzIds),1);
name_list = cell(length(mzIds),1);
class_list = cell(length(mzIds),1);
sub_class_list = cell(length(mzIds),1);

for i=1:length(mzIds)
    idsInData = find(mz_met_list(mzIds(i), :));
    
    formulas = MetabolomeDB.formula(idsInData);
    formula_list{i} = formulas;
   
    
    names = MetabolomeDB.name(idsInData);
    name_list{i} = names;
    
    classes = MetabolomeDB.main_class(idsInData);
    class_list{i} = classes;
    
    sub_classes = MetabolomeDB.sub_class(idsInData);
    sub_class_list{i} = sub_classes;
end

samples.annotation.met_id = mzIds';
samples.annotation.mz = mz_list(mzIds)';
samples.annotation.formula_list = formula_list;
samples.annotation.name_list = name_list;
samples.annotation.class_list = class_list;
samples.annotation.sub_class_list = sub_class_list;

end

function [samples] = SamplesAfterPeakSelctionInRange(samples,minMz,maxMz)
for i=1:samples.scan_num
    for x=1:length(samples.data)
        X = samples.data{x}.scan(i).peaks.mz(1:2:end);
        Y = samples.data{x}.scan(i).peaks.mz(2:2:end);
        
        ids = find(X>=minMz & X<=maxMz);
        
        X = X(ids);
        Y = Y(ids);
        mzVec = reshape([X'; Y'], [], 1);
        samples.data{x}.scan(i).peaks.mz = mzVec;
        samples.data{x}.scan(i).lowMz = min(X);
        samples.data{x}.scan(i).highMz = max(X);
        samples.data{x}.scan(i).totIonCurrent = sum(Y);
    end
end
end
