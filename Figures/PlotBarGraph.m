function PlotBarGraph(data, labels,ylabelStr, title, fileName,folder,toSort,xTickAngle,options)
% Plots a bar graph based on the variable 'data', accepts additional
% parameters through the 'options' struct: yLines (array of y values to
% plot hortizontal lines), legendTitles, legendLocation, xLabel, errorBars
% (should be on the same size of the input data and works for three
% columns only)

lineWidth = 1.5;
if(nargin<9)
    options = struct;
end

hold off;
if(toSort)
    [data,I] = sort(data,'descend');
    labels = labels(I);
end
labels = strrep(labels,'_',' ');

bar(data);

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

if(isfield(options,'legendTitles'))
    lgd = legend(options.legendTitles);
    lgd.FontSize = 14;
    lgd.Location = 'best';
end

if(isfield(options,'legendLocation'))
    lgd.Location = options.legendLocation;
end

if(isfield(options,'xLabel'))
    xlabel(options.xLabel);
end

if(isfield(options,'errorBars'))
    errorBars = options.errorBars;
    hold on;
    for i=1:size(data,1)
        errorbar(i-0.225,data(i,1),errorBars(i,1),'HandleVisibility','off','Color','black');
        errorbar(i,data(i,2),errorBars(i,2),'HandleVisibility','off','Color','black');
        errorbar(i+0.225,data(i,3),errorBars(i,3),'HandleVisibility','off','Color','black');
    end   
end

set(gca,'XTickLabel',labels);

xtickangle(xTickAngle);
title(title);
set(gca,'fontsize',14);
grid on;
ylabel(ylabelStr);

filePath = fullfile(folder,sprintf('%s.pdf',fileName));
print(gcf,filePath,'-dpdf','-bestfit');
hold off;

end
