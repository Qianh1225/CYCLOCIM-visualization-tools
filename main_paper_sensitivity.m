% This is the main script to run all the analysis and make plots
% for CYCLOCIM's results.
% How to customize your plots:
% step1: choose different models to load 
% step2: choose the type of plots you want to produce
% step3: In each plot, clarity which models to plot
% by modify the model_name_list
% Note here some plot types don't support OCIM version.
 
 
% load different models' results
% you can choose different model's result
load ./sol4x4_C14_3000_w.mat output sol
output.sol = sol;
models.CYCLOCIM = output;

load ./sol_4x4_v1_high_iso_2000.mat output sol
output.sol = sol;
models.highISO = output;
load ./sol_4x4_v1_low_iso_2000.mat output sol
output.sol = sol;
models.lowISO = output;
load sol_4x4_v1_high_dia_2000.mat output sol
output.sol = sol;
models.highDIA = output;
model_name_list = ["CYCLOCIM", "highISO", "lowISO", "highDIA"];
calculate_and_plot_streamfunction(models, model_name_list);

% options for the subplot
% (1) whether to plot the RMSE in each season
% (2) which model's result to display
option.season_subplot = 'off';
option.season_subplot_model = 'CYCLOCIM';
%
model_name_list = ["CYCLOCIM", "highISO", "lowISO", "highDIA"];
calculate_and_plot_streamfunction(models, model_name_list);




%
load ./sol_4x4_v1_high_iso_2000.mat output sol
output.sol = sol;
models.CYCLOCIMhighISO = output;
load ./sol_4x4_v1_low_iso_2000.mat output sol
output.sol = sol;
models.CYCLOCIMlowISO = output;
load sol_4x4_v1_high_dia_2000.mat output sol
output.sol = sol;
models.CYCLOCIMhighDIA = output;
model_name_list = ["CYCLOCIM", "CYCLOCIMhighISO", "CYCLOCIMlowISO"];

RMSE = calculate_RMSE(models);
plot_RMSE(RMSE, models, model_name_list, option)        
   
%keyboard

% Different restoring time scales
load sol_4x4_v1_1500_15_day_restore.mat output sol
output.sol = sol;
models.tau15 = output;
load sol_4x4_v1_1500_60_days_restore.mat output sol 
output.sol = sol;
models.tau60 = output; 
% meridional transport
model_name_list = ["CYCLOCIM", "tau15", "tau60"]; 
calculate_and_plot_flux(models, model_name_list, 'div'); 
    
% different alpha
for alpha = [1, 5, 10, 15, 20, 100]
    name = ['sol_4x4_v1_3000_alpha', num2str(alpha),'.mat'];
    load(name, 'output');
    models.(['alpha',num2str(alpha)]) = output;
end 

model_name_list = ["CYCLOCIM", "alpha1", "alpha5", ...
                    "alpha20", "alpha100"]; 
plot_cfcs_model_vs_obs(models, model_name_list);    
    




