function PlotDiffRanges(X,Y,labelX, labelY, titleStr, fileName,folder,options)
% Plots results obtained in different scan
% ranges (e.g. number of feature). X and Y are the data points input. The
% default plot function is 'plot'. The function accepts several options
% through the options struct: function (the plot function), Y2CellArr
% (additional Y arrays for the same X values which will be plotted in the
% same figure), legendTitles, rangesThreshs (vertical lines will be plotted
% in this given values) yLines (horizontal lines plot),legendLocation

if(nargin<8)
    options=struct;
end

if(isfield(options,'function'))
    plotFunc = str2func(options.function);
else
    plotFunc = str2func('plot');
end

lineWidth = 1.5;
hold off;
plotFunc(X,Y,'LineWidth',lineWidth)

if(isfield(options,'Y2CellArr'))
    Y2CellArr = options.Y2CellArr;
    hold on;
    for i=1:length(Y2CellArr)
        plotFunc(X,options.Y2CellArr{i},'LineWidth',lineWidth);
    end
    if(isfield(options,'legendTitles'))
        lgd = legend(options.legendTitles);
        lgd.FontSize = 14;
    end
end

if(isfield(options,'rangesThreshs'))
    rangesThreshs = options.rangesThreshs;
    visibility='on';
    for i=1:length(rangesThreshs)
        if(i>1)
            visibility='off';
        end
        line([rangesThreshs(i),rangesThreshs(i)],ylim,'LineStyle',':','Color','black','HandleVisibility',visibility);
    end
end

if(isfield(options,'yLines'))
    yLines = options.yLines;
    visibility='on';
    for i=1:length(yLines)
        if(i>1)
            visibility='off';
        end
        line(xlim,[yLines(i),yLines(i)],'LineStyle',':','Color','black','HandleVisibility',visibility,'LineWidth',lineWidth);
    end
end

if(isfield(options,'legendTitles') && isfield(options,'rangesThreshs'))
    if(isfield(options,'rangesThreshsLegend'))
        strLegend =options.rangesThreshsLegend;
    else
        strLegend = 'Ranges';
    end
    lgd = legend([options.legendTitles,strLegend]);
    lgd.FontSize = 14;
end

if(isfield(options,'legendLocation'))
    lgd.Location = options.legendLocation;
end

if(isfield(options,'legendTitles') && isfield(options,'yLines'))
    lgd = legend([options.legendTitles,'']);
    lgd.FontSize = 14;
end

xlabel(labelX) 
ylabel(labelY)
title(titleStr);
set(gca,'fontsize',14);
grid on;
filePath = fullfile(folder,sprintf('%s.pdf',fileName));
print(gcf,filePath,'-dpdf','-bestfit');
hold off;
end
