function [] = calculate_and_plot_horizontal_streamfunction(models, ...
                                                model_name_list, type)

    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        % load data 
        M3d = models.(model_name).M3d;
        msk = models.(model_name).msk;
        grd = models.(model_name).grid;
        if strcmp(type, "all")
            u = mean(models.(model_name).u, 2);
        elseif strcmp(type, "ssh")
            u = mean(models.(model_name).u_h, 2);
        elseif strcmp(type, "density")
            u = mean(models.(model_name).u_d, 2);
        elseif strcmp(type, "ssh+density")
            u = mean(models.(model_name).u_h_f, 2);
        end    
        % calcualte streamfunction
        sf = calculate_streamfunction_horizontal(M3d, msk, grd, u);
        % plot calculated streamfunction
        option.caxis = [-50, 250];
        option.cr = linspace(-50, 250, 20);
        option.title = [model_name,type];
        plot_horizontal_streamfunction(grd, M3d, sf, option)
    end
end

function [sf] = calculate_streamfunction_horizontal(M3d, msk, grd, u)
% calculate horizontal mass streamfunction
% d[u]/dx + d[v]/dy = 0  [u] is the integral of u from depth 0 to -z
% calculation method:  
% 1. calculate the vertical integrated U flux:Uzdy
% 2. define the Antantatic land as C = 0, and fill all the grid boxes ...
%     in Antantatic with 0
% 3. start to search other continents or islands
%     for i_lon = 0 : 360
%       for i_lat = -90:90
%         if (i_lon, i_lat) is a land and the land is not marked
%         with constant C:
%           (1) marked the grid box with constant C = C_ previous
%               land + accumulated flux between them
%           (2) fill all the grid boxes in the islands or
%               continent with the same constant (DFS)
%         if (i_lon, i_lat) is a land and is marked:
%            pass.
%         if (i_lon, i_lat) is an ocean:
%           record the accumulated flux. 
    u_3d = M3d *nan; 
    u_3d(msk.ukeep) = u;
    % vertical integrated U flux 
    Area = grd.DZU3d .* grd.DYU3d;
    udzdy = u_3d .* Area;
    uzdy = nansum(udzdy, 3);
    % initialize horizontal streamfunction sf
    sf = M3d(:,:,1);
    sf(sf==0) = nan; % fill land with nan
    sf(sf==1) = -1; % marked ocean  with negative number  
    C = 0;% initialize Antarctic with constant C = 0
    i_lon = 1;
    i_lat = 1;
    sf = fill_constant(i_lat, i_lon, sf, C);
    [n_lat, n_lon] = size(sf);
    % iterate i_lon, i_lat and search for other continents or islands
    for i_lon = 1 : n_lon
        uflux = 0;
        C = 0;
        for i_lat = 1 : n_lat
            if isnan(sf(i_lat, i_lon)) % is land and not filled
                C = C + uflux;
                sf = fill_constant(i_lat, i_lon, sf, C);
                % %
                % option.caxis = [-50, 250];
                % option.cr = linspace(-50, 250, 20);
                % option.title = ["lll"];
                % plot_horizontal_streamfunction(grd, M3d, sf, ...
                %                                 option)
                % drawnow()
            elseif M3d(i_lat,i_lon,1) == 1 % ocean
                uflux = uflux + uzdy(i_lat, i_lon);
                sf(i_lat, i_lon) = uflux;
            end
        end
    end
end

function [] = plot_horizontal_streamfunction(grd, M3d, c, option)
    figure;
    m_proj('robinson','lon',[0 360]);
    m_coast('patch',[.8 .8 .8], 'linestyle', 'none');
    hold on;
    c(M3d(:,:,1)==0)=nan;
    m_contourf(grd.xt, grd.yt, c/1e6, 20, 'linestyle', 'none')
    m_grid('linewidth',1.0,'fontsize',14,...
       'XTick', [0:90:360],...
       'YTick',[-90:30:90]);
    mycmap = flip(cbrewer('div','Spectral', 20,'PCHIP'));
    colormap(mycmap);
    title(option.title, 'fontsize', 16);
    subplot('position',[0.25 0.05 0.5 0.05]);
    cr2 = option.cr;
    contourf(cr2,[1, 2],[cr2(:),cr2(:)]',cr2); hold on
    contour(cr2,[1, 2],[cr2(:),cr2(:)]',cr2);
    caxis(option.caxis);
    set(gca,'FontSize', 13);
    set(gca,'YTickLabel', []);
    %set(gca,'XTick', option.XTick);    
    %set(gca,'YAxisLocation', 'right');
    set(gca,'TickLength', [0 0]);
end

function [sf] = fill_constant(i_lat, i_lon, sf, C)
    [n_lat, n_lon] = size(sf); 
    stack=java.util.Stack();
    stack.push([i_lat, i_lon]);
    while(~stack.empty())
        index = stack.pop();
        i_lat = index(1);
        i_lon = index(2);
        sf(i_lat, i_lon) = C;
        if i_lat+1 <= n_lat & isnan(sf(i_lat+1, i_lon))
            stack.push([i_lat+1, i_lon]);
        end
        if i_lon+1 <= n_lon & isnan(sf(i_lat, i_lon+1))
            stack.push([i_lat, i_lon+1]);
        end
        if i_lat-1 > 0 & isnan(sf(i_lat-1, i_lon))
            stack.push([i_lat-1, i_lon]);
        end
        if i_lon-1 > 0 & isnan(sf(i_lat, i_lon-1))
            stack.push([i_lat, i_lon-1]);
        end
    end
end