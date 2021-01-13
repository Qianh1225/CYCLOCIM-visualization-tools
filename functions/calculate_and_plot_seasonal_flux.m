function calculate_and_plot_seasonal_flux(models, model_name_list, figure_type)
    % HeatFlux
    % prepare data
    [temp_a, temp_model] = prepare_data(models, model_name_list, ...
                                        'temperature');
    [salt_a, salt_model] = prepare_data(models, model_name_list, ...
                                        'salinity');

    for season = 1 : 4
        % calculate the heat flux 
        par.c = 4.18; % unit: J/(g * K)
        par.rho = 1.028 * 1e6;  % unit: g/m3
        [heatflux_spatial, heatflux_div] = calculate_flux(models, model_name_list,...
                                                          temp_a, temp_model, ... 
                                                          'temp', par, season);
        % calculate the fresh flux 
        [freshflux_spatial, freshflux_div] = calculate_flux(models, model_name_list,...
                                                          salt_a, salt_model,... 
                                                          'sal', par, season);
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
            title_str = [char(model_name), ' heat flux season', ...
                         num2str(season)];  
            plot_flux_spatial(model.grid, heatflux_spatial.(model_name), ...
                              option, title_str);
            saveas(gcf,['hf_season', num2str(season)],'epsc');
            % freshwater flux
            option.cr1 = [-7:0.6:5.7];
            option.cr2 = [-5.7:0.6:5.7];
            option.xtick = [-5.7:1.2:-0.9,0, 0.9:1.2:5.7];
            option.caxis = [-6, 6];
            option.xlabel = "m / year";
            option.label_str = "(c)";
            title_str = [char(model_name), ' freshwater flux season', ...
                         num2str(season)];
            plot_flux_spatial(model.grid, freshflux_spatial.(model_name), ...
                              option, title_str);
            %saveas(gcf,['ff_season', num2str(season)],'epsc');
        end 
    end 

    
function [] = plot_flux_spatial(grd, flux_spatial, option, title_str)
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
    title(title_str, 'fontsize', 16);
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
        % seasonal mean
        c_a_1 = calculate_seasonal_mean(c_a_1);
        c_model_1 = calculate_seasonal_mean(c_model_1);
        c_a.(model_name) = KT * c_a_1;  
        c_model.(model_name) = K * c_model_1;
    end

function [c_season] = calculate_seasonal_mean(c)
    [n, ~] = size(c);
    c_season = zeros(n, 4);    
    c_season(:,1) = mean(c(:,[12,1,2]), 2);
    c_season(:,2) = mean(c(:,[3,4,5]), 2);
    c_season(:,3) = mean(c(:,[6,7,8]), 2);
    c_season(:,4) = mean(c(:,[9,10,11]), 2);



function [flux_spatial, flux_div] = calculate_flux(models, model_name_list, ...
                                                   c_a, c_model,...
                                                   tracer_name, par, ...
                                                   season)
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
            flux(pkeep) = rho * c * dz * (c_a.(model_name)(:,season) - c_model.(model_name)(:,season));
        end
        if contains(tracer_name, 'sal')
            % unit: m/year
            flux(pkeep) = - dz * (c_a.(model_name)(:,season) - c_model.(model_name)(:,season)) / ...
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

