
%Input
load(Inp.import_filename); % SCD data
clf;
counts=counts(:,:,:,1);
XEdges=meta.edges.Tp(1:end);
YEdges=meta.edges.Hm0(1:end);


counts_surf=zeros(size(counts)+1);
counts_surf(1:size(counts,1),1:size(counts,2))=counts;

% Outputted data to text file:
EDGES{1}=XEdges-Inp.CorrectionParameter.Tp;
EDGES{2}=YEdges-Inp.CorrectionParameter.Hm0;

Tp_exp=Data(1).Seastates(:,2);
Hm0_exp=Data(1).Seastates(:,1);

Nbin=hist3([Tp_exp,Hm0_exp],"Edges", EDGES)'; % recount the exported values
%Nbin(Nbin==0)=nan;
h=surf(XEdges(1:end),YEdges(1:end),Nbin); % use counted values as overlay
set(h,'facealpha',0.5);
set(h,'edgealpha',.5);

g=gca;
set(g,'xtick',XEdges);
set(g,'ytick',YEdges); % leave end axis labels off for sums rows
%set(g,'yticklabel',horzcat(YEdges(1:end-3),['_','_','_'])); % leave end axis labels off for sums rows


xlabel('Wave period, T_p [s]','fontsize',14);
ylabel('Significant wave height, H_{m0} [m]','fontsize',14);
zlabel('Counts');
title('Scatter diagram','fontsize',14);
grid on;
view(0,-90); % 2D top view

cb=colorbar;
get(cb);
set(cb,'ytick',[min(Nbin(:)):1:max(Nbin(:))]);
set(cb,'title','Realized waves','FontSize',11);


cbj=colormap('jet');
cbj(end,:)=[1,1,1];
colormap(flip(cbj));


% Add labels to plot from real counts
Values=counts';
for xi=1:size(XEdges,2)-1
    for yi=1:size(YEdges,2)-1
        if Values(xi,yi) > 0
            text(mean(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)), num2str(Values(xi,yi)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',9);
        end
    end
end



countsums=sum(Values');

xi=1;
yi=19;
backCol=[.75,.75,.75];
text(mean(XEdges(xi:xi+1))-.5*diff(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)),'SUM Counts', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle','FontSize',10,'backgroundcolor',backCol);
for xi=1:size(XEdges,2)-1
text(mean(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)),num2str(countsums(xi)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',10,'fontangle','italic','backgroundcolor',backCol);
end
text((XEdges(xi+1))+.1*diff(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)),num2str(sum(countsums)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',10,'edgecolor','k','fontangle','italic','fontweight','bold','backgroundcolor',backCol);

countsumsRlz=sum(Nbin);
xi=1;
yi=yi+1;
text(mean(XEdges(xi:xi+1))-.5*diff(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)),'SUM Realized waves', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle','FontSize',10,'backgroundcolor',backCol);
for xi=1:size(XEdges,2)-1
text(mean(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)),num2str(countsumsRlz(xi)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',10,'fontangle','italic','backgroundcolor',backCol);
end
text((XEdges(xi+1))+.1*diff(XEdges(xi:xi+1)), mean(YEdges(yi:yi+1)),num2str(sum(countsumsRlz)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',10,'edgecolor','k','fontangle','italic','fontweight','bold','backgroundcolor',backCol);

