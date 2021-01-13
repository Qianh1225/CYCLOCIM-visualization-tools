function [] = plot_RMSE(RMSE, models, model_list, option)
% plot RMSE for each model for comparsion
names = fieldnames(models);
figure("Position", [100, 100, 1200, 400])       
% Potential temperature                        
subplot(1,3,1)
for i = 1 : numel(model_list)
    model_name = model_list(i);
    z = - models.(model_name).grid.zt; 
    plot(RMSE.(model_name).temp.vertical_annual, z,'linewidth',2.0);
    hold on
end
legend(model_list, "box", "off", 'fontsize', 14);
xlabel("RMSE (^\circC)",'fontsize', 16);
ylabel("Depth (m)",'fontsize', 16);
set(gca,'lineWidth',1.5,...
        'fontsize', 16, ...
        'YTick',[-5000:1000:0],...
        'YLim', ([-5000, 0]));
text(0.08, -150, '(a)', 'fontsize', 16);
%title("Potential Temperature", "fontsize", 18)

% subplot
if strcmp(option.season_subplot, 'on')
    model_name = option.season_subplot_model;
    axes('Position',[0.191 0.215 0.142 0.3835])
    plot(RMSE.(model_name).temp.vertical_season(1:10,:),z(1:10),'linewidth', 1.5);
    hold on
    legend1 = legend("DJF","MAM","JJA","SON", "box", "off", 'fontsize', ...
                 14, 'location', 'southeast'); 
    set(gca,'lineWidth',1.5,...
        'fontsize', 14,...
        'YTick',[-400:200:0],...
        'XTick',[0:0.5:1.5],...
        'XLim',([0, 1.5]),...
        'YLim', ([-500, 0]));
end
% Salt                        
subplot(1,3,2)
for i = 1 : numel(model_list)
    model_name = model_list(i);
    z = - models.(model_name).grid.zt; 
    plot(RMSE.(model_name).salt.vertical_annual, z,'linewidth',2.0);
    hold on
end
legend(model_list, "box", "off", 'fontsize', 14);
xlabel("RMSE(PSU)",'fontsize', 16);
% ylabel("Depth (m)",'fontsize', 16);
set(gca,'lineWidth',1.5,...
        'fontsize', 16,...
        'YTick',[-5000:1000:0],...
        'YLim', ([-5000, 0]));
text(0.015, -150, '(b)', 'fontsize', 16);
%title("Salinity", "fontsize", 18)
% subplot
if strcmp(option.season_subplot, 'on')
    model_name = option.season_subplot_model;
    axes('Position',[0.470 0.215 0.142 0.3835])
    plot(RMSE.(model_name).salt.vertical_season(1:10,:),z(1:10),'linewidth', 1.5);
    hold on
    legend1 = legend("DJF","MAM","JJA","SON", "box", "off", 'fontsize', ...
                 14, 'location', 'southeast');
    set(gca,'lineWidth',1.5,...
        'fontsize', 14, ...
        'YTick',[-400:200:0],...
        'XTick',[0:0.1:0.3],...
        'XLim',([0, 0.34]),...
        'YLim', ([-500, 0]));

end
% CFC-11                        
subplot(1,3,3)
for i = 1 : numel(model_list)
    model_name = model_list(i);
    z = - models.(model_name).grid.zt; 
    plot(RMSE.(model_name).cfc11.vertical_annual, z,'linewidth',2.0);
    hold on
end
legend(model_list, "box", "off", 'fontsize', 14);
xlabel("RMSE (pmol/kg)",'fontsize', 16);
set(gca,'lineWidth',1.5,...
        'fontsize', 16,...
        'YTick',[-5000:1000:0],...
        'YLim', ([-5000, 0]));
%title("CFC-11","fontsize", 18)  
text(0.004, -150, '(c)', 'fontsize', 16);