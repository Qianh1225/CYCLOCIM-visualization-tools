% This is the main script to run all the analysis and make plots
% for CYCLOCIM's results.
% How to customize your plots:
% step1: choose different models to load.
% Note that for some plots you can choose multiple models to
% compare. 
% step2: choose the type of plots you want to produce
% Note here some plot types don't support OCIM version.


% add path for external package
addpath('colorScheme/cbrewer');  % color scheme for plot
addpath('functions/'); % path of the plotting functions

% step 1: load data
% example
load ./sol_4x4_v1_3000.mat  
output.sol = sol;
output.ithist = ithist;
% output.data.ptemp.ptstar = output.data.ptemp.ptstar_3d;
% output.data.salt.sstar = output.data.salt.sstar_3d;
models.CYCLOCIM4x4 = output;

% load ./sol_2x2_v1_1000.mat 
% output.sol = sol;
% output.ithist = ithist; 
% models.CYCLOCIM2x2 = output;

% OCIM
load ./CTL.mat output sol
output.sol = sol;
models.OCIM = output;


model_name_list = ["CYCLOCIM4x4", "OCIM"];  
disp("The following model's results are loaded");
disp(model_name_list)  


% step 2: plot figures
% choose the type of plots you want to produce
% The plots includes:
% (1) optimization iterations for current solution.
% (1) vertical RMSE for Potential temperature, salinity, and CFC-11
% (2) Joint distribution function for the gridbox volume weighted
%     observed and modeled tracer concentrations
% (3) Temperature and Salinity difference in the upper ocean
% (4) longitued-depth section of the modeled  and observed potential temperature
% abnormaly in comparsion with the annual mean along 36S 
% (5) Masked zonal mean CFCs concentration for CYCLOCIM compared to
%     GLODAPv2 observation in each decade: 1980-1989, 1990-1999, 2000-2009
% (6) Masked zonal mean C14/C12/(C14/C14)_atm 
% (7) Heat flux and freshwater flux
% (8) stream function
% (9) horizontal stream function
% (10) sea surface height (SSH)
plot_option.optimization_progress = 'off';
plot_option.RMSE = 'on';
plot_option.joint_distribution = 'on';
plot_option.upper_ocean_difference = 'on';
plot_option.seasonal_obnormaly = 'on';
plot_option.cfcs_model_vs_obs = 'on'; 
plot_option.c14_model_vs_obs = 'on';
plot_option.flux = 'on';
plot_option.streamfunction = 'on'; 
plot_option.streamfunction_horizontal = 'on'; 
plot_option.SSH = 'on';


% plot optimization process
if strcmp(plot_option.optimization_progress, 'on')
    plot_optimization_progress(models, model_name_list);   
end


% calculate and plot RMSE 
if strcmp(plot_option.RMSE, 'on')
    RMSE = calculate_RMSE(models); 
    % options for the subplot
    % (1) whether to plot the RMSE in each season
    % (2) which model's result to display
    option.season_subplot = 'off';
    option.season_subplot_model = 'CYCLOCIM4x4'; 
    % 
    plot_RMSE(RMSE, models, model_name_list, option)   
end


% Joint distribution function for the gridbox volume weighted
% observed and modeled tracer concentrations
if strcmp(plot_option.joint_distribution,'on') 
    % choose model to plot, No "OCIM";
    model_name = "CYCLOCIM4x4";
    plot_joint_distribution(models.(model_name))  
end  


% Temperature and Salinity difference in the upper ocean (depth <=
% max_depth)
if strcmp(plot_option.upper_ocean_difference, 'on');
    % model_name_list = ["OCIM", "CYCLOCIM", "CYCLOCIM_0"]
    option.max_depth = 200;
    % temp
    option.tracer_name = "Potential temperature";
    plot_upper_ocean_difference(models, model_name_list, option); 
    % salt
    option.tracer_name = "salinity";
    plot_upper_ocean_difference(models, model_name_list, option);
end


% longitued-depth section of the modeled  and observed potential temperature
% abnormaly in comparsion with the annual mean along 36S 
% no OCIM
% need hand on tuning the colorbar
if strcmp(plot_option.seasonal_obnormaly, 'on')
    y_lat = 14; %36S in 4x4;
    plot_seasonal_obnormaly(models, model_name_list, y_lat);    
end


% Masked zonal mean CFCs concentration for CYCLOCIM compared to
% GLODAPv2 observation in each decades: 1980-1989, 1990-1999, 2000-2009
% no OCIM
if strcmp(plot_option.cfcs_model_vs_obs, 'on');
    model_name_list = ["CYCLOCIM4x4"];
    plot_cfcs_model_vs_obs(models, model_name_list);
end


% Masked zonal mean C14/C12/(C14/C14)_atm 
% no OCIM
if strcmp(plot_option.c14_model_vs_obs, 'on')
    % model_name_list = ["CYCLOCIM8x8"];
    plot_c14_model_vs_obs(models, model_name_list);       
end


% Heat flux and freshwater flux
if strcmp(plot_option.flux, 'on')
    % spatial distribution
    calculate_and_plot_flux(models, model_name_list, 'spatial');       
    % meridional transport
    calculate_and_plot_flux(models, model_name_list, 'div');    
end


% stream function
% no OCIM
if strcmp(plot_option.streamfunction, 'on')
    model_name_list = ["CYCLOCIM4x4"];
    calculate_and_plot_streamfunction(models, model_name_list); 
end 


% plot horizontal streamfunction
if strcmp(plot_option.streamfunction_horizontal, 'on')
    calculate_and_plot_horizontal_streamfunction(models, model_name_list, ...
                                                 "all");
    % calculate_and_plot_horizontal_streamfunction(models, model_name_list, ...
    %                                               "ssh");
    % calculate_and_plot_horizontal_streamfunction(models, model_name_list, ...
    %                                                "density");
    
end     


% plot sea surface height 
if strcmp(plot_option.SSH, 'on');
    option.monthly = 'off';
    plot_SSH(models, model_name_list, option);            
end  
