function [] = plot_c14_model_vs_obs(models, model_name_list)
model = models.(model_name_list(1));
M3d = model.M3d;
pkeep = model.msk.pkeep;
grd = model.grid;    
MSKS = model.MSKS;
% prepare data and plot
% global ocean
figure('position', [50 50 600 900])
subplot(3,1,1)
not_ocean = find(M3d == 0);
[Rc14_data, Rc14_models] = prepare_data(models, ...
                                        model_name_list, ...
                                        not_ocean);
plot_c14(Rc14_data, Rc14_models, model_name_list, '(a)', grd);

% Atlantic
subplot(3,1,2)
not_Atlantic =  find(MSKS.ATL == 0);
[Rc14_data, Rc14_models] = prepare_data(models, ...
                                        model_name_list, ...
                                        not_Atlantic);
plot_c14(Rc14_data, Rc14_models, model_name_list, '(b)', grd);

% Pacific and Indian 
subplot(3,1,3)
mask = MSKS.PAC + MSKS.IND; 
not_Pacific_and_Indian = find(mask == 0);
[Rc14_data, Rc14_models] = prepare_data(models, ...
                                        model_name_list, ...
                                        not_Pacific_and_Indian);
plot_c14(Rc14_data, Rc14_models, model_name_list, '(c)', grd);
% plot

function [] = plot_c14(Rc14_data, Rc14_models, model_name_list,  label_str, grd)
% Glodapv2
plot(grd.yt, mean(Rc14_data, 2), 'linewidth', 1.5); 
hold on;
% models
for i = 1 : numel(model_name_list)
    model_name = model_name_list(i);
    plot(grd.yt, Rc14_models.(model_name), 'linewidth', 1.5);
    hold on;
end
legend_str = ['GLODAPv2', model_name_list];
legend(legend_str, 'fontsize', 14, 'location', 'east');
xlim([-90 90]);
ylim([0.76 0.92])
xlabel('LAT');
ylabel('(^{14}C/^{12}C)/(^{14} C/^{12}C)_{atm}');   
set(gca,'lineWidth',1.2,...
        'fontsize', 16, ...
        'Xtick',[-90:30:90],...
        'Xticklabel', {'90^{\circ}S','60^{\circ}S','30^{\circ}S',...
                    '0','30^{\circ}N', '60^{\circ}N', ...
                    '90^{\circ}N'}); 
%title('Global, \Delta^{14}C', 'fontsize', 16)
text(-80, 0.9, label_str, 'fontsize', 16);
grid on;

function [Rc14_data, Rc14_model] = prepare_data(models, model_name_list, ...
                                                pkeep_not_region)
model = models.(model_name_list(1));
M3d = model.M3d;
pkeep = model.msk.pkeep;
grd = model.grid;    
% volume and area
V = grd.DXT3d .* grd.DYT3d .* grd.DZT3d;
Area = grd.DXT3d .* grd.DYT3d;
Area = Area(:, : , 1);
% prepare GLODAPv2 data
Hc14 = model.data.Hc14; 
Rc14_data = M3d + nan;
Rc14_data(pkeep) = Hc14 \ model.data.Rc14star;
Rc14_data(pkeep_not_region) = nan;
Rc14_data(Rc14_data == 0) = nan; 
id_nan = find(isnan(Rc14_data)); 
V(id_nan) = nan; 
Rc14_data = Rc14_data .* V;
Rc14_data =  nansum(nansum(Rc14_data, 3), 2) ./ nansum(nansum(V, 3), 2);
% prepare models' data
for i = 1 : numel(model_name_list)
    model_name = model_name_list(i);
    model = models.(model_name);
    tmp = zeros(length(pkeep), 12);
    tmp(:) = model.Rc14;
    Rc14_m = M3d + nan;
    Rc14_m(pkeep) = mean(tmp, 2);
    Rc14_m(pkeep_not_region) = nan;
    Rc14_m(id_nan) = nan;
    Rc14_m = Rc14_m .* V; 
    Rc14_m =  nansum(nansum(Rc14_m, 3), 2) ./ ....
              nansum(nansum(V, 3), 2);
    Rc14_model.(model_name) = Rc14_m;
end
 