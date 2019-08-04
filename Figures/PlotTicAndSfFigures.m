function PlotTicAndSfFigures(centerMz,TicNeg,TicPos,featNeg,featPos,strDesc,plotFolder)
% Plots several graphs representing the distribution of significant
% features and TIC in the different scanned mz ranges.
% Get as input arrays of the number of features and TIC in specific sample
% type (e.g. Lip or Met) in Negative and positive polarization modes. 
% In addition gets the centerMz of each of the scanned ranges (should be
% the same size as the other input arrays). 

global Config;
PlotDiffRanges(centerMz,smooth(TicNeg),Config.MZ_LABEL, 'Total ion count', '', strcat(strDesc,'TIC-Neg'),plotFolder)
PlotDiffRanges(centerMz,smooth(TicPos),Config.MZ_LABEL, 'Total ion count', '', strcat(strDesc,'TIC-Pos'),plotFolder)
PlotDiffRanges(centerMz,smooth(TicNeg+TicPos),Config.MZ_LABEL, 'Total ion count', '', strcat(strDesc,'TIC-PosPlusNeg'),plotFolder)
PlotDiffRanges(centerMz,smooth(featNeg),Config.MZ_LABEL, Config.NUM_FEAT_LABEL, '', strcat(strDesc,'Features-Neg'),plotFolder)
PlotDiffRanges(centerMz,smooth(featPos),Config.MZ_LABEL,Config.NUM_FEAT_LABEL, '', strcat(strDesc,'Features-Pos'),plotFolder)
PlotDiffRanges(centerMz,smooth(featNeg+featPos),Config.MZ_LABEL,Config.NUM_FEAT_LABEL, '', strcat(strDesc,'Features-PosPlusNeg'),plotFolder)
end