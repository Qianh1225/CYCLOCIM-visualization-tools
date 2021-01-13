function [] = plot_cfcs_model_vs_obs(models, model_name_list)
    model = models.(model_name_list(1));
    M3d = model.M3d;
    pkeep = model.msk.pkeep;
    grd = model.grid;    
    % prepare data
    % prepare GLODAPv2 data
    [cfc11_obs, cfc11_obs_var, cfc11_obs_year, cfc11_obs_month] = ...
        prepare_obs_data(model, "cfc11");
    [cfc12_obs, cfc12_obs_var, cfc12_obs_year, cfc12_obs_month] = ...
        prepare_obs_data(model, "cfc12");
    % prepare model result
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i)
        model = models.(model_name);
        cfc11.(model_name) = prepare_model_data(model, "cfc11", ...
                                                cfc11_obs, ...
                                                cfc11_obs_year,...
                                                cfc11_obs_month);
        cfc12.(model_name) = prepare_model_data(model, "cfc12", ...
                                                cfc12_obs, ...
                                                cfc12_obs_year,...
                                                cfc12_obs_month);    
    end

    % plot three decades
    decades = [1980, 1989; 1990, 1999; 2000, 2009];
    f = figure('position', [30 30 1000 1200]);
    % cfc11
    option.leftYlim = [0 5];
    option.rightYlim = [0 0.34];
    option.rightYtick = [0 : 0.1 : 0.3];
    label_str = ["(a)", "(c)", "(e)"];  
    option.x = -85; 
    option.y = 4.7;
    for i = 1:2:5
        j = floor(i/2) + 1;
        subplot(3, 2, i)
        option.label = label_str(j);
        id1 = find(cfc11_obs_year >= decades(j, 1) & ...
                   cfc11_obs_year <= decades(j, 2));
        plot_zonal_cfc(id1, cfc11, cfc11_obs, cfc11_obs_var, ...
                       model_name_list, grd, M3d, pkeep, option) 
    end
    % cfc12
    option.x = -85;
    option.y = 2.6;
    option.leftYlim = [0 2.8];
    option.rightYlim = [0 0.1];
    option.rightYtick = [0: 0.03 : 0.09];
    label_str = ["(b)", "(d)", "(f)"];  
    for i = 2:2:6
        subplot(3, 2, i)
        j = floor(i / 2);
        option.label = label_str(j);
        id1 = find(cfc12_obs_year >= decades(j, 1) & ...
                   cfc12_obs_year <= decades(j, 2));
        plot_zonal_cfc(id1, cfc12, cfc12_obs, cfc12_obs_var, ...
                       model_name_list, grd, M3d, pkeep, option) 
    end




function [c_obs, c_obs_var, c_obs_year, c_obs_month] ...
        = prepare_obs_data(model, tracer_name)
    % prepare GLODAPv2 data 
    if contains(tracer_name, 'cfc11') 
        c_obs = model.data.cfc11star;
        c_obs_id = model.data.cfc11id;
        c_obs_var = model.data.varcfc11;
    end
    if contains(tracer_name, 'cfc12')
        c_obs = model.data.cfc12star;
        c_obs_id = model.data.cfc12id;
        c_obs_var = model.data.varcfc12;
    end
    c_obs(c_obs < -9) = nan;
    c_obs_var(c_obs_var < -9) = nan;  
    c_obs_year = zeros(size(c_obs_id));
    c_obs_month = zeros(size(c_obs_id));
    for i = 1 : length(c_obs_id)
        if mod(c_obs_id(i), 12) == 0
            c_obs_year(i) = floor(c_obs_id(i) / 12) - 1;
            c_obs_month(i) = 12;
        else
            c_obs_year(i) = floor(c_obs_id(i) / 12);
            c_obs_month(i) = mod(c_obs_id(i), 12);
        end
    end




function c_model = prepare_model_data(model, tracer_name, c_obs, ...
                                      c_obs_year, c_obs_month)
    if contains(tracer_name, 'cfc11')
        c = model.cfc11;
    end
    if contains(tracer_name, 'cfc12')
        c = model.cfc12;
    end
    c_model_year = 1940:2009;
    c_model_month = 1:12; 
    c_model = zeros(size(c_obs)) + nan; 
    for i = 1 : length(c_obs_year)
        c_model(:, i) = c(:, find(c_model_year == c_obs_year(i)),...
                          find(c_model_month == c_obs_month(i))); 
    end



function [] = plot_zonal_cfc(id1, c_model, c_obs, c_obs_var,...
                             model_name_list, grd, M3d, pkeep, option)

    % calculate masked zonal mean cfcs for GLODAPv2
    c_obs_1 = M3d * nan;
    c_obs_1(pkeep) = nanmean(c_obs(:, id1), 2);
    id_nan = find(isnan(c_obs_1));
    V = grd.DXT3d .* grd.DYT3d .* grd.DZT3d;
    c_obs_1 = c_obs_1 .* V;
    V(id_nan) = nan;
    d_cfc11_1 =  nansum(nansum(c_obs_1, 3),2) ./ ...
        nansum(nansum(V, 3),2);
    % calculate variance of the zonal mean cfcs for GLODAPv2
    c_obs_var_2 = M3d * nan;
    c_obs_var_2(pkeep) = nanmean(c_obs_var(:, id1), 2);
    c_obs_var_2 = c_obs_var_2 .* (V.^2);
    d_cfc11_var_2 =  nansum(nansum(c_obs_var_2, 3),2) ./ ...
        nansum(nansum(V, 3),2).^2;   
    % plot GLODAPv2 cfcs
    shadedErrorBar(grd.yt, d_cfc11_1, 2 * sqrt(d_cfc11_var_2), ...
                   'lineProps',{'color', 'k', 'LineWidth', 1.5}) ...
    % e = errorbar(grd.yt, d_cfc11_1, sqrt(d_cfc11_var_2), 'linewidth', ...
    %              1.5);
    % e.CapSize = 5;  
    hold on
    colors = get(gca, 'colorOrder');
    % iterate models and calculate masked zonal mean cfc 
    for i = 1 : length(model_name_list)
        model_name = model_name_list(i);
        c_model_1 = M3d;
        c_model_1(pkeep)= nanmean(c_model.(model_name)(:, id1), 2);
        c_model_1(id_nan) = nan;
        c_model_1 = c_model_1 .* V;
        m_cfc11_1 =  nansum(nansum(c_model_1, 3),2) ./ ...
            nansum(nansum(V, 3),2);
        plot(grd.yt, m_cfc11_1, 'linewidth', 1.5, 'color', colors(i,:));
    end
    ylabel('pmol/kg');  
    xlim([-90 90]);
    xlabel('LAT');
    ylim(option.leftYlim); 
    set(gca,'lineWidth',1.2,...
            'fontsize', 14, ...
            'Xtick',[-90:30:90],...
            'Xticklabel', {'90^{\circ}S','60^{\circ}S','30^{\circ}S',...
                        '0','30^{\circ}N', '60^{\circ}N', ...
                        '90^{\circ}N'}); 
    grid on;
    box on;
    legend_str = [["GLODAPv2"] model_name_list];
    legend(legend_str, 'fontsize', 14, 'location','north');    
    text(option.x, option.y, option.label, 'fontsize', 16);
    % title(str_title, 'fontsize', 16)   

