# FlowInjectionMSOptimization

The code in this repository was used the generate the results appering in the article: 
Sarvin, B., Lagziel, S., Sarvin, N. et al. Fast and sensitive flow-injection mass spectrometry metabolomics by analyzing sample-specific ion distributions. Nat Commun 11, 3186 (2020). https://doi.org/10.1038/s41467-020-17026-6

There are two config files:
1. configFile.m, which contains configurations for the entire flow-injection mass spectrometry analysis, including the parameters for detecting reproducible m/z features (also reffered in the code as significant).
2. ConfigSamples.xml, which contains the information of the samples scanned (i.e. Samples and Blank file names format).

On the top of the script file you can find a section of the parameters for the script marked by:
%%%%%%%%% Script parameters %%%%%%%%%
It includes the path of the data and strings describing the analysis.

NOTE: In order to use this code a file named mzxmlread_my.m have to be created,
which is a modified version of the original Matlab file
named 'mzxmlread.m'. 
Comment out the following line (#465 in Matlab 2017b):  	
out.scan = out.scan([out.scan.num]);

The raw data is publicly available in Metabolomics Workbench with the identifier ST001380 [https://doi.org/10.21228/M8P41V].
