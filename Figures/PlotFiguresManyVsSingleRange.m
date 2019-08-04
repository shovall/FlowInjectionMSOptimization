function PlotFiguresManyVsSingleRange(DIMS_Lip,DIMS_Met,oneRangeScanLip,oneRangeScanMet,minMz,maxMz,plotFolder)
% Plots several graphs comparing the results in the exhaustive scanning to
% the results of a single scan

global Config;

legendTitles = {'20 Da ranges','Single range'};
centerMz = (minMz+maxMz)/2;
[~,~,featLipNegMulti,featLipNegSingle] = FindSigMzInEachRange(oneRangeScanLip,DIMS_Lip,minMz,maxMz,'samples_NEG');
PlotDiffRanges(centerMz,smooth(featLipNegMulti),Config.MZ_LABEL, Config.NUM_FEAT_LABEL, '', 'LipNeg vs SingleRange',plotFolder,struct('Y2CellArr',{{smooth(featLipNegSingle)}},'legendTitles',{legendTitles}));
[~,~,featLipPosMulti,featLipPosSingle] = FindSigMzInEachRange(oneRangeScanLip,DIMS_Lip,minMz,maxMz,'samples_POS');
PlotDiffRanges(centerMz,smooth(featLipPosMulti),Config.MZ_LABEL, Config.NUM_FEAT_LABEL, '', 'LipPos vs SingleRange',plotFolder,struct('Y2CellArr',{{smooth(featLipPosSingle)}},'legendTitles',{legendTitles}));

[~,~,featMetNegMulti,featMetNegSingle] = FindSigMzInEachRange(oneRangeScanMet,DIMS_Met,minMz,maxMz,'samples_NEG');
PlotDiffRanges(centerMz,smooth(featMetNegMulti),Config.MZ_LABEL, Config.NUM_FEAT_LABEL, '', 'MetNeg vs SingleRange',plotFolder,struct('Y2CellArr',{{smooth(featMetNegSingle)}},'legendTitles',{legendTitles}));
[~,~,featMetPosMulti,featMetPosSingle] = FindSigMzInEachRange(oneRangeScanMet,DIMS_Met,minMz,maxMz,'samples_POS');
PlotDiffRanges(centerMz,smooth(featMetPosMulti),Config.MZ_LABEL, Config.NUM_FEAT_LABEL, '', 'MetPos vs SingleRange',plotFolder,struct('Y2CellArr',{{smooth(featMetPosSingle)}},'legendTitles',{legendTitles}));

legeneds = {'Metabolomics~positive ionization','Metabolomics~negative ionization', 'Lipidomics~positive ionization','Lipidomics~negative ionization'};
legeneds = cellfun(@(x) strrep(x,'~','\newline'), legeneds,'UniformOutput',false);

totalMulti = [sum(featMetPosMulti);sum(featMetNegMulti);sum(featLipPosMulti);sum(featLipNegMulti)];
totalSingle = [sum(featMetPosSingle);sum(featMetNegSingle);sum(featLipPosSingle);sum(featLipNegSingle)];
data = [totalMulti,totalSingle];
PlotBarGraph(data, legeneds,Config.NUM_FEAT_LABEL,'', 'TotalMulti vs Single',plotFolder,0,30,struct('legendTitles',legendTitles));
end
