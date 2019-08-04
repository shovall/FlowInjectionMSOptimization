function [DIMS] = Analyze_DIMS(config_xml, options)
% Loads direct injection mass spectrometry data files and perform
% preprocessing including m/z alignment, significant features detection
% and annotation. It accepts additional parameters through the options
% struct: negOrPosOnly (1 for Neg, otherwise positive only; if nor stated
% both polarities will be analyzed), and additional parameters that will be
% passed to AnalyzeDIMSForNegOrPos function (read its documentation)

if(nargin<2)
    options = struct;
end

config_xml.Config.Path.Text = fullfile(config_xml.Config.Path.Text,'\');

if (isfield(config_xml.Config,'SampleFileWC'))
    config_xml.Config.SampleFile = cell(0);
    for i=str2num(config_xml.Config.SampleFirst.Text):str2num(config_xml.Config.SampleStep.Text):str2num(config_xml.Config.SampleLast.Text)
        s = strrep(config_xml.Config.SampleFileWC.Text, '*', num2str(i));
        config_xml.Config.SampleFile{end+1}.Text = s;
    end
end

if (isfield(config_xml.Config,'BlankFileWC'))
    config_xml.Config.BlankFile = cell(0);
    for i=str2num(config_xml.Config.BlankFirst.Text):str2num(config_xml.Config.BlankStep.Text):str2num(config_xml.Config.BlankLast.Text)
        s = strrep(config_xml.Config.BlankFileWC.Text, '*', num2str(i));
        config_xml.Config.BlankFile{end+1}.Text = s;
    end
end

if(isfield(options,'negOrPosOnly'))
    if(options.negOrPosOnly ==1)
        [DIMS.samples_NEG] = AnalyzeDIMSForNegOrPos(config_xml,'NEG',options);
    else
        [DIMS.samples_POS] = AnalyzeDIMSForNegOrPos(config_xml,'POS',options);
    end
else
    [DIMS.samples_NEG] = AnalyzeDIMSForNegOrPos(config_xml,'NEG',options);
    [DIMS.samples_POS] = AnalyzeDIMSForNegOrPos(config_xml,'POS',options);
end
DIMS.output_path = [config_xml.Config.Path.Text 'DI_MS_Analysis\\'];
DIMS.config_xml = config_xml;
end
