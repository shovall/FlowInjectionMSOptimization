function config_xml = GetConfigXML(folderPath,configPath)
% Loads a general format config_xml file which is saved in
% Config.SAMPLES_CONFIG_PATH and update its path attribute to the
% input folderPath

global Config;
if(nargin<2)
    configPath = Config.SAMPLES_CONFIG_PATH;
end
config_xml = xml2struct(configPath);
config_xml.Config.Path.Text  = sprintf('%s\\',folderPath);
end
