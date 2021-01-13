function plot_seasonal_obnormaly(models, model_name_list, y_lat)
model = models.(model_name_list(1));
M3d = model.M3d;
grd = model.grid;  
% prepare data 
temp = model.temp;
pkeep = find(M3d(:) == 1);
np = size(pkeep,1);
temp_model = zeros([size(M3d),12]);
t = M3d * nan;
for i = 1:12
    t(pkeep) = temp((i-1)*np +1: i*np);
    temp_model(:,:,:,i) = t;
end
% observation
temp_obs = model.data.ptemp.ptstar;
% season
s = [12,1,2;3,4,5;6,7,8;9,10,11];
for i = 1:4
    temp_obs_season(:,:,:,i) = mean(temp_obs(:,:,:,s(i,:)),4);
    temp_model_season(:,:,:,i) = mean(temp_model(:,:,:,s(i,:)),4); 
end 

% plot
fg1 = figure('Position', [2035   92  800  600]);
season = ['DJF';'MAM';'JJA';'SON'];  
cr =[-2.5:0.5:2.5];
load colorScheme/RedBlue2.mat  
colormap(mycmap); 
for i = 1: 8
    subplot(4,2,i);
    if (mod(i,2) == 1)
        n = ceil(i/2);
        tmp = squeeze(temp_model_season(y_lat,:,1:9,n) - ...
                      mean(temp_model_season(y_lat,:,1:9,:), 4))';
        [C,h] = contourf(grd.xt, -grd.zt(1:9), tmp, ...
                         cr, 'linestyle', 'none');
        % if (n == 1)
        %     title("Model", "fontsize", 22);
        % end
        ylabel(season(n,:), "fontsize", 18);
        str ='abcdefgh';
        text(30, -100, ['(',str(i),')'], 'fontsize', 18,...
             'fontweight', 'bold', 'fontname', 'Times New Roman'); 
    else
        n = i/2;
        tmp = squeeze(temp_obs_season(y_lat,:,1:9,n) - ...
                      mean(temp_obs_season(y_lat,:,1:9,:), 4))';
        [C,h] = contourf(grd.xt, -grd.zt(1:9), tmp, ...
                         cr, 'linestyle', 'none');
        % if (n == 1)
        %     title("Observation", 'FontSize', 22);
        % end 
        set(gca, 'YTickLabel', {});
        text(30, -100, ['(',str(i),')'], 'fontsize', 18,...
             'fontweight', 'bold', 'fontname', 'Times New Roman'); 
    end
    % colorbar;
    %v = [8,16];
    %clabel(C,h,v, 'Color','white','FontSize',16, 'labelspacing', 1000);
    set(gca,'lineWidth',1.5,...
            'FontName','Times New Roman',...
            'fontsize', 14, 'fontweight','bold',...
            'XTick', [0:60:360],...
            'YTick',[-400:200:0],...
            'Clim', [-2.5 2.5]);   
    if (n == 4)
        set(gca, 'XTickLabel',{'0','60E','120E','180','120W','60W'} ...
                 );
    else 
        set(gca, 'XTickLabel',{});
    end
end
% colorbar
subplot('position',[0.923 0.11 0.032 0.815]);
contourf([1 2],cr,[cr(:),cr(:)],cr); hold on
contour([1 2],cr,[cr(:),cr(:)],cr);
set(gca,'FontSize',14);
set(gca,'XTickLabel',[]);
set(gca,'YTick', cr);
set(gca,'YAxisLocation','right');
set(gca,'TickLength',[0 0])             