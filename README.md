# FlowInjectionMSOptimization

The code in this repository was used the generate the results appering in the manuscript: A method for optimizing flow-injection mass spectrometry scan ranges for high-throughput metabolomics and lipidomics screening.

There are two config files:
1. configFile.m, which contains configurations for the entire flow-injection mass spectrometry analysis, including the parameters for detecting significant m/z features.
2. ConfigSamples.xml, which contains the information of the samples scanned (i.e. Samples and Blank names/name format).

On the top of the script file you can find a section of the parameters for the script marked by:
%%%%%%%%% Script parameters %%%%%%%%%
It includes the path of the data and strings describing the analysis.

NOTE: In order to use this code a file named mzxmlread_my.m have to be created,
which is a modified version of the original Matlab file
named 'mzxmlread.m'. 
Comment out the following line (#465 in Matlab 2017b):  	
out.scan = out.scan([out.scan.num]);

The raw data is publicly available in the Zenodo repository. https://doi.org/10.5281/zenodo.3581227
