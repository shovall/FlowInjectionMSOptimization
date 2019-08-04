% Folders that will be added to the Matlab path
folders = {'Figures','Preprocessing','RangesOptimization','SaveData','Utils'};
for i=1:length(folders)
    addpath(genpath(folders{i}));
end

global Config 
Config = {};

Config.SAMPLES_CONFIG_PATH = 'ConfigSamples.xml';
Config.SUGGESTED_RANGES = '';  %%% Write a path here%%%
Config.SUGGESTED_RANGES_MATLAB = ''; %%% Write a path here%%%

% MS analysis
Config.MS_ACCURACY = 5/1000000;
Config.SCANS_SELECTED = [1:8];
Config.SAMPLE_IONIZATION = {'samples_NEG','samples_POS'};

% Significant features parameters:
Config.SF_SNR = 4;
Config.SF_RSD = 0.3;
Config.SF_SNR_TOP_BLANK = 0.9;
Config.SF_SNR_TOP_SAMPLE = 0.5;
Config.SF_NUM_SAMPLES = 0.9;
Config.SF_INTENSITY = 1000;

% Annotation:
Config.PROTON_MASS = 1.007276;

% Exhaustive scanning parameters:
Config.EXHAUSTIVE_MIN_MZ = 70;
Config.EXHAUSTIVE_MAX_MZ = 2500;
Config.EXHAUSTIVE_STEP = 20;
Config.EXHAUSTIVE_WINDOW = 30;
Config.EXHAUSTIVE_SCANS_IN_SAMPLE = 7;

% Figures labels:
Config.NUM_FEAT_LABEL = 'Number of significant m/z features';
Config.MZ_LABEL = 'm/z';
Config.TIC_LABEL = 'Total ion count';

clear('fields','i');