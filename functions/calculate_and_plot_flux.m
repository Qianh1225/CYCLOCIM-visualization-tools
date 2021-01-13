function calculate_and_plot_flux(models, model_name_list, figure_type)
    % HeatFlux
    % prepare data
    [temp_a, temp_model] = prepare_data(models, model_name_list, ...
                                        'temperature');
    [salt_a, salt_model] = prepare_data(models, model_name_list, ...
                                        'salinity');
    % calculate the heat flux 
    par.c = 4.18; % unit: J/(g * K)
    par.rho = 1.028 * 1e6;  % unit: g/m3
    [heatflux_spatial, heatflux_div] = calculate_flux(models, model_name_list,...
                                                      temp_a, temp_model, ... 
                                                      'temp', par);
    % heat transport in Atlantic
    [~, heatflux_div_ATL] = calculate_regional_flux(models, model_name_list,...
                                                    temp_a, temp_model, 'ATL', ... 
                                                    'temp', par);
    % heat transport in Pacific
    [~, heatflux_div_PAC] = calculate_regional_flux(models, model_name_list,...
                                                    temp_a, temp_model, 'PAC',... 
                                                    'temp', par);
    % calculate the fresh flux 
    [freshflux_spatial, freshflux_div] = calculate_flux(models, model_name_list,...
                                                      salt_a, salt_model,... 
                                                      'sal', par);
    % plot  
    if contains(figure_type, 'spatial')
        for i = 1 : length(model_name_list)
            model_name = model_name_list(i);
            model = models.(model_name);
            % heat flux
            option.cr1 = [-380:40:300];
            option.cr2 = [-300:40:300];
            option.xtick = [-300:80:-60, 0, 60:80:300];
            option.caxis = [-300,300];
            option.xlabel = "W m^{-2}";
            option.label_str = "(a)";
            plot_flux_spatial(model.grid, heatflux_spatial.(model_name), option);
            % freshwater flux
            option.cr1 = [-5.7:0.6:4.5];
            option.cr2 = [-4.5:0.6:4.5];
            option.xtick = [-4.5:1.2:-0.9,0, 0.9:1.2:4.5];
            option.caxis = [-5, 5];
            option.xlabel = "m / year";
            option.label_str = "(c)";
            plot_flux_spatial(model.grid, freshflux_spatial.(model_name), option);     
        end 
    end 
    if contains(figure_type, 'div')
        % heat flux
        option.x = -80;
        option.y = 2.2;
        option.label_str = "(b)";
        %option.ylim = [-1.5 2.5];
        %option.ytick = [-1:1:2.5];
        option.ylim = [-2 5];
        option.ytick = [-2:1:5];
        option.title_str = "Meridional Heat Transport (PW)";
        plot_flux_div(models, model_name_list, heatflux_div, "temp", option);

        % fresh water flux
        option.x = -80;
        option.y = 0.9;
        option.label_str = "(d)";
        %option.ylim = [-1.5 1];
        %option.ytick = [-1.5:0.5:1];
        option.ylim = [-3 2];
        option.ytick = [-3:1:2];
        option.title_str = "Meridional Fresh water Transport (Sv)";
        plot_flux_div(models, model_name_list, freshflux_div, "sal", option);
    end 

    if contains(figure_type, 'regional div')
        % heat flux
        option.x = -80;
        option.y = 2.2;
        option.label_str = "(b)";
        option.ylim = [-1.5 2.5];
        option.ytick = [-1:1:2.5];
        option.title_str = "Meridional Heat Transport (PW)";
        plot_flux_regional_div(models, model_name_list, heatflux_div_PAC, ...
                               "temp",'PAC', option);
        plot_flux_regional_div(models, model_name_list, heatflux_div_ATL, ...
                               "temp",'ATL', option);
        
    end 


function [] = plot_flux_spatial(grd, flux_spatial, option)
    figure('Position', [20 20 600 400]);  
    H = subplot('position',[0.15 0.25 0.7 0.7]);
    m_proj('miller','lat',[-86,86],'lon',[0 360]);
    m_coast('patch',[.8 .8 .8], 'linestyle', 'none');
    hold on
    m_contourf(grd.xt, grd.yt, -flux_spatial, option.cr1, 'linestyle', ...
               'none');
    hold on
    m_grid('linewith',1.2,'fontsize',16,...
           'XTick', [0:60:360],...
           'YTick',[-90:30:90],...
           'linestyle', 'none');
    load colorScheme/RedBlue1.mat
    colormap(mycmap);
    caxis(option.caxis);
    %title('Heat Flux', 'fontsize', 16);
    text(-2.9, 1.8, option.label_str,'fontsize',16);
    subplot('position',[0.15 0.15 0.7 0.05]);
    cr2 = option.cr2;
    contourf(cr2,[1, 2],[cr2(:),cr2(:)]',cr2); hold on
    contour(cr2,[1, 2],[cr2(:),cr2(:)]',cr2);
    h = gca; 
    h.XTick = option.xtick; 
    h.YTick = [];
    caxis(option.caxis);
    xlabel(option.xlabel); 
    set(gca, 'Ycolor', 'k',...
             'FontSize',16, ...
             'YTickLabel',[], ...
             'TickLength',[0 0]);            


function [] = plot_flux_div(models, model_name_list, flux, tracer_name, ... 
                            option)
    f = figure('Position', [20 20 600 400]);
    if contains(tracer_name, 'temp')
        y = readtable('data/CORE_heatflux.csv');
        y = table2array(y);
        plot(y(:,1), y(:, 2), '--',...
             'linewidth', 1.5);
    end

    if contains(tracer_name, 'sal')
        y = readtable('data/CORE_freshflux.csv');
        y = table2array(y);
        plot(y(:,1), y(:, 2), '--',...
             'linewidth', 1.5); 
    end    
    hold on
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        model = models.(model_name);
        grd = model.grid;
        plot(grd.yt(1 : end), flux.(model_name)(2 : end), ...
             'linewidth', 1.5); 
        hold on
    end  
    hold on;
    xlabel("Latitude");
    ylabel("northward transport (PW)");
    xlim([-90, 90]);
    ylim(option.ylim);
    hold on;
    plot(grd.yt(1 : end), zeros(length(grd.yt), 1) , ...
         'linewidth', 1.5, 'color', 'k');
    legend_str = ['CORE.v2', model_name_list];
    legend(legend_str);
    text(option.x, option.y, option.label_str, 'fontsize', 16);
    set(gca,'Ycolor', 'k', ...
            'lineWidth',1.2,...
            'fontsize', 16, ...
            'XTick', [-80:20:80], ...
            'YTick', option.ytick, ...
            'Xticklabel', {'80^{\circ}S','60^{\circ}S','40^{\circ}S','20^{\circ}S',...
                        '0','20^{\circ}N', '40^{\circ}N', ...
                        '60^{\circ}N', '80^{\circ}N'});
%title(option.title_str, 'fontsize', 16)


function [c_a, c_model] = prepare_data(models, model_name_list, tracer_name)
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        model = models.(model_name);
        msk = model.msk;
        M3d = model.M3d;
        grd = model.grid;
        pkeep = msk.pkeep;
        hkeep = msk.hkeep;
        ukeep = msk.ukeep;
        vkeep = msk.vkeep;
        [ny, nx, nz] = size(M3d); 
        np = length(pkeep);
        nh = length(hkeep);
        nu = length(ukeep);
        nv = length(vkeep);
        tmp = 0*M3d;
        tmp(:,:,1) = 1;
        q = tmp(pkeep);
        tau = 30 * 24 * 60 * 60;
        K = d0(q)./tau;
        KT = K(:, 1:nh);  
        if strcmp(model_name, 'OCIM')
            c_a_1 = zeros(nh,1);
            if contains(tracer_name, 'temp')
                c_model_1 = model.T;
                c_a_1(:) = model.sol((nu+nv)+1 : (nu+nv)+nh);
            end
            if contains(tracer_name, 'sal')
                c_model_1 = model.S;
                c_a_1(:) = model.sol((nu+nv+nh)+1 : (nu+nv+nh+nh));
            end
        else
            c_a_1 = zeros(nh,12);
            c_model_1 = zeros(np,12);
            if contains(tracer_name, 'temp')
                c_a_1(:) = model.sol((nu+nv)*12+1:(nu+nv)*12+nh*12);
                % for i = 1:12
                %     c_model_1(:, i) = model.temp((i-1)*np+1:i*np);
                % end
                c_model_1(:) = model.temp;
            end
            if contains(tracer_name, 'sal')
                c_model_1(:) = model.salt;
                c_a_1(:) = model.sol((nu+nv+nh)*12+1:end - 1);
            end
            c_a_1 = mean(c_a_1, 2);
            c_model_1 = mean(c_model_1, 2);
            
        end
        c_a.(model_name) = KT * c_a_1;  
        c_model.(model_name) = K * c_model_1;
    end
    
function [flux_spatial, flux_div] = calculate_flux(models, model_name_list, ...
                                                   c_a, c_model,...
                                                   tracer_name, par)
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        model = models.(model_name);
        msk = model.msk;
        M3d = model.M3d;
        grd = model.grid;
        pkeep = msk.pkeep;
        dz = grd.dzt(1); 
        flux = M3d * nan;
        secyear = 365 * 24 * 60 * 60;
        if contains(tracer_name, 'temp')
            rho = par.rho;
            c = par.c;
            flux(pkeep) = rho * c * dz * (c_a.(model_name) - c_model.(model_name));
        end
        if contains(tracer_name, 'sal')
            % unit: m/year
            flux(pkeep) = - dz * (c_a.(model_name) - c_model.(model_name)) / ...
                35 * secyear;
        end
        % spatial distributed heatflux
        flux1 = flux(:,:,1);
        flux_spatial.(model_name) = flux1;
        
        % meridional transport
        Area = grd.DXT3d .* grd.DYT3d; 
        flux2 = flux1 .* Area(:,:,1);
        ny = size(grd.yt, 2);
        flux3 = nansum(flux2, 2);
        flux4 = zeros(ny + 1, 1);  
        for i = 1 : ny
            flux4(i + 1) = flux4(i) + flux3(i);
        end
        if contains(tracer_name, 'sal')
            flux4 = flux4 / 1e6 / secyear; % unit: Sv
        end
        if contains(tracer_name, 'temp')
            flux4 = flux4 / 1e15; % unit: PW
        end
        flux_div.(model_name) = flux4;
    end 

function [flux_spatial, flux_div] = calculate_regional_flux(models, model_name_list, ...
                                                      c_a, c_model, region,...
                                                      tracer_name, par)
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        model = models.(model_name);
        msk = model.msk;
        M3d = model.M3d;
        grd = model.grid;
        mask = model.MSKS.(region);
        pkeep = msk.pkeep;
        dz = grd.dzt(1); 
        flux = M3d * nan;
        secyear = 365 * 24 * 60 * 60;
        if contains(tracer_name, 'temp')
            rho = par.rho;
            c = par.c;
            flux(pkeep) = rho * c * dz * (c_a.(model_name) - c_model.(model_name));
        end
        if contains(tracer_name, 'sal')
            % unit: m/year
            flux(pkeep) = - dz * (c_a.(model_name) - c_model.(model_name)) / ...
                35 * secyear;
        end
        % spatial distributed heatflux
        flux1 = flux(:,:,1);
        flux_spatial.(model_name) = flux1;
        
        % meridional transport
        Area = grd.DXT3d .* grd.DYT3d .* mask; 
        flux2 = flux1 .* Area(:,:,1);
        ny = size(grd.yt, 2);
        flux3 = nansum(flux2, 2);
        flux4 = zeros(ny + 1, 1);  
        for i = 1 : ny
            flux4(i + 1) = flux4(i) + flux3(i);
        end
        if contains(tracer_name, 'sal')
            flux4 = flux4 / 1e6 / secyear; % unit: Sv
        end
        if contains(tracer_name, 'temp')
            flux4 = flux4 / 1e15; % unit: PW
        end
        flux_div.(model_name) = flux4;
    end 

function [] = plot_flux_regional_div(models, model_name_list, flux, tracer_name, region,... 
                                     option)

    f = figure('Position', [20 20 600 400]);
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        model = models.(model_name);
        grd = model.grid;
        plot(grd.yt(1 : end), flux.(model_name)(2 : end), ...
             'linewidth', 1.5); 
        hold on
    end  
    hold on;
    xlabel("Latitude");
    ylabel("northward transport (PW)");
    xlim([-90, 90]);
    ylim(option.ylim);
    hold on;
    plot(grd.yt(1 : end), zeros(length(grd.yt), 1) , ...
         'linewidth', 1.5, 'color', 'k');
    legend_str = [model_name_list];
    legend(legend_str);
    text(option.x, option.y, option.label_str, 'fontsize', 16);
    set(gca,'Ycolor', 'k', ...
            'lineWidth',1.2,...
            'fontsize', 16, ...
            'XTick', [-80:20:80], ...
            'YTick', option.ytick, ...
            'Xticklabel', {'80^{\circ}S','60^{\circ}S','40^{\circ}S','20^{\circ}S',...
                        '0','20^{\circ}N', '40^{\circ}N', ...
                        '60^{\circ}N', '80^{\circ}N'});
    title(region)


function A = d0(r)
    m = length(r(:));

    K = speye(m);

    [i,j] = find(K);

    A = sparse(i,j,r(:),m,m); 