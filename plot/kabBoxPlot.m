function kabBoxPlot(y,x,labels,colors,jitter)

    markersize = 60;
    extra = jitter/8;
    greyColor = colors(size(colors,1),:)

    % figure(1)
    % set(gcf,'color','w');
    % hold on;

    allMaxX = [];
    allMinX = [];
    muY = [];
    allq25 = [];
    allq75 = [];

    grps = unique(x);
    for i=1:numel(grps)

        % Generate scatter plots
        ids = find(x==grps(i));
        thisX = x(ids);
        thisY = y(ids);
        thisX=violaPoints(thisX,thisY);

        scatter(thisX,thisY,markersize,'MarkerFaceColor',greyColor,...
                'MarkerEdgeColor',greyColor);

        maxX = max(thisX)+extra;
        minX = min(thisX)-extra;
        
        allMaxX = [allMaxX,maxX];
        allMinX = [allMinX,minX];

        muY = [muY,median(thisY)];

        q = quantile(thisY,[0.25,0.75]);
        
        allq25 = [allq25,q(1)];
        allq75 = [allq75,q(2)];

    end

    for i=1:numel(grps)

        % plot quartile block
        patchX = [allMinX(i) allMaxX(i) allMaxX(i) allMinX(i)];
        patchY = [allq25(i) allq25(i) allq75(i) allq75(i)];
        h = fill(patchX,patchY,colors(i,:),'LineStyle','none');
        set(h,'facealpha',.4);
        
        %plot median
        seqX = allMinX(i):0.01:allMaxX(i);
        seqY = 0*seqX+muY(i);
        plot(seqX,seqY,'Color',colors(i,:),'LineWidth',4);
        
    end
    

    function X=violaPoints(X,Y)
    % Variable jitter according to how many points occupy each range of values. 
        [counts,~,bins] = histcounts(Y,10);
        inds = find(counts~=0);
        counts = counts(inds);
        
        Xr = X;
        for jj=1:length(inds)
            tWidth = jitter * (1-exp(-0.1 * (counts(jj)-1)));
            xpoints = linspace(-tWidth*0.8, tWidth*0.8, counts(jj));
            Xr(bins==inds(jj)) = xpoints;
        end
        X = X+Xr;
    end % function violaPoints
        
        %Set x axis labels
        xticks(grps)
        xticklabels(labels);
        
end
