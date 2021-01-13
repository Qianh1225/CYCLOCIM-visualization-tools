function [] = calculate_and_plot_streamfunction(models, ...
                                                model_name_list)
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        model = models.(model_name);
        msk = model.msk;
        M3d = model.M3d;
        MSKS = model.MSKS;
        grd = model.grid;
        z = [grd.zw, grd.zt(end)]; 
        v = model.v;
        v = mean(v, 2);
        % % Global ocean
        % [psi_global, maxPsi_global] = calculate_streamfunction(mean(v,2), M3d, M3d, ...
        %                                                   grd, msk, 'glo');         
        f = figure('Position', [10 10 500 1200]);
        sgtitle(model_name, 'fontsize', 18); 
        % Atlantic
        subplot(3, 1, 1)
        mask = MSKS.ATL;
        max_mld = find_max_mixed_layer(model.data.mld, mask); 
        [psi_ATL, maxPsi_ATL] = calculate_streamfunction(v, M3d, mask, ...
                                                         grd, msk,'ATL');
        option.x = 80;
        option.y = -5000;
        option.label_str = "(a)";
        option.interval = 4;
        lat_range = find(grd.yt >= -20);
        plot_streamfunction(psi_ATL(:,lat_range), max_mld(lat_range), grd.yt(:,lat_range), z, ...
                            option, 'ATL');                   
        
        % Pacfic
        subplot(3, 1, 2)
        mask = MSKS.PAC;
        max_mld = find_max_mixed_layer(model.data.mld, mask); 
        [psi_PAC, maxPsi_PAC] = calculate_streamfunction(v, M3d, mask, ...
                                                         grd, msk, 'PAC');    
        str = "Pacific MOC-Annual Mean";
        option.x = 80;
        option.y = -5000;
        option.label_str = "(b)";
        option.interval = 4;
        lat_range = find(grd.yt >= -20);
        plot_streamfunction(psi_PAC(:,lat_range), max_mld(lat_range), grd.yt(:,lat_range), z, ...
                            option, 'PAC');

        % Southern ocean
        subplot(3, 1, 3)
        mask = M3d;
        max_mld = find_max_mixed_layer(model.data.mld, mask);
        [psi_SO, maxPsi_SO] = calculate_streamfunction(v, M3d, mask, ...
                                                       grd, msk, 'SO');
        option.x = -32;
        option.y = -5000;
        option.label_str = "(c)";
        option.interval = 4;
        lat_range = find(grd.yt <= -30);
        plot_streamfunction(psi_SO(:,lat_range), max_mld(lat_range),grd.yt(:,lat_range), z, ...
                            option, 'SO');    
    end

function [f] = plot_streamfunction(psi, max_mld, y, z, option,  str)
% interval = option.interval;
% cr1 = [-66:interval:42];
% cr2 = [-34:interval:34];
% cr3 = [2:interval:42];    % solid line for positive
% cr4 = [-66:interval:-2];  % dash line for negative

    interval = option.interval;
    cr1 = [-66:interval:42];
    cr2 = [-38:interval:38];
    cr3 = [2:interval:42];    % solid line for positive
    cr4 = [-66:interval:-2];  % dash line for negative
    [c,h] = contourf(y, -z, psi, cr1, 'linestyle','none');
    hold on
    contourf(y, -z, psi, cr3, '.k');
    contour(y, -z, psi, cr4, '--k'); 
    load colorScheme/RedBlue1.mat
    colormap(mycmap);   
    %caxis([-34 34]);  
    caxis([-38, 38]);
    [z_nan, y_nan] = find(isnan(psi));
    land_edge = zeros(length(y), 1) - max(z);
    for i = 1 : length(y)
        id = find(y_nan == i);
        if(~isempty(id))
            land_edge(i) = -z(min(z_nan(id)) - 1);
        end
    end 
    h2 = area(y, land_edge, -max(z));
    h2.FaceColor = [0.8, 0.8, 0.8];
    h2.LineStyle = 'none'; 
    ylabel('Depth (km)')
    if (strcmp(str, 'ATL') || strcmp(str, 'PAC')) 
        set(gca, 'Xtick', [-20:20:80]);  
        xticklabels({'20^{\circ}S', '0','20^{\circ}N','40^{\circ}N',...
                     '60^{\circ}N','80^{\circ}N'});    
    end
    if strcmp(str, 'SO')
        set(gca, 'Xtick', [-80:10:-30]);  
        xticklabels({'80^{\circ}S','70^{\circ}S','60^{\circ}S',...
                     '50^{\circ}S','40^{\circ}S', '30^{\circ}S'});
        xlabel('Latitude');
    end
    text(option.x, option.y, option.label_str, 'fontsize', 18);
    set(gca,'lineWidth',1.2,...
            'fontsize', 18, ...
            'YTick', [-5000:1000:0],...
            'YTickLabels',[-5:1:0])   

    hold on 
    % maximun mixed layber
    plot(y, -max_mld, 'linewidth', 4.0, 'color', ...
         [0.9, 0.9, 0.1250]);
    % subplot colorbar
    if strcmp(str, 'SO')
        subplot('position',[0.15 0.03 0.7 0.02]);
        contourf(cr2,[1, 2],[cr2(:),cr2(:)]',cr2); hold on
        contour(cr2,[1, 2],[cr2(:),cr2(:)]', cr2);
        h = gca; 
        % h.XTick = [-30:8:-6, 0, 6:8:30];
        h.XTick = [-38:8:-6, 0, 6:8:38]; 
        h.YTick = [];
        %caxis([-34,34]);
        caxis([-38, 38]);
        ylabel('Sv', 'Rotation', 0);
        set(gca,'FontSize',16);
        set(gca,'YTickLabel',[]); 
        %    set(gca,'YAxisLocation','right');
        set(gca,'TickLength',[0 0])       
    end





function [max_mld] = find_max_mixed_layer(mld, mask)
    id = find(mask(:,:,1) == 0);
    for i = 1 : 12
        tmp = mld(:, :, i);
        tmp(id) = nan;
        mld(:, :, i) = tmp;
    end
    max_mld = max(max(mld(:,:,:),[], 3), [], 2);    


function [psi, maxPsi] = calculate_streamfunction(v, M3d, mask, ...
                                                  grd, msk, str);
    % zonally integrated meridional volume transport: Psi.
    % Psi(z, i) z: depth, i: latitude,  sum vdzdx from depth z to surface.
    % mask = 1 (ocean) 0 (land).
    [ny, nx, nz] = size(M3d);
    DXV = grd.DXV3d;
    DZV = grd.DZV3d;
    v1 = M3d * 0;
    v1(msk.vkeep) = v;
    v2 = v1 .* mask;
    dpsi_mask = v2.*DXV.*(DZV);
    dpsi_mask = squeeze(sum(dpsi_mask,2))';  
    sum_flow = sum(dpsi_mask, 1);
    % old mistake: Area = squeeze(mean(mean(grd.DZV3d .* grd.DZV3d, 2),1));
    Area = squeeze(mean(mean(DXV .* DZV, 2),1)); % changed!                              
    %% remove the background circulation for ATL and Pacific
    if (strcmp(str, 'ATL') | strcmp(str, 'PAC'))
        for i = 1 : ny
            if (abs(sum_flow(i)) > 1e4)
                id = find(dpsi_mask(:,i) ~= 0);
                if (size(id, 2) > 0)
                    v_b = sum_flow(i) / sum(Area(id));
                end
                for k = 1 : size(id, 1)
                    dpsi_mask(id(k), i) = dpsi_mask(id(k), i) - v_b * ...
                        Area(id(k));
                end
            end
        end
    end
    % calculate the Psi and maxPsi
    psi = zeros(nz + 1, ny) * 0;
    dpsi_mask1 = dpsi_mask;
    dpsi_mask1(dpsi_mask1 == 0) = nan; 
    maxPsi = zeros(ny,1);
    % define the psi = 0  in the boundary;
    for i = 1:ny
        for k = 1 : nz 
            psi(k + 1, i) = sum(dpsi_mask1(1:k,i));
        end
        P1 = min(psi(:,i));
        P2 = max(psi(:,i));
        if (abs(P1) > abs(P2))
            maxPsi(i) = P1;
        else
            maxPsi(i) = P2;
        end
    end        
    psi = psi / 1e6; % unit: Sv
