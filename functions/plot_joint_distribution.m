function [] = plot_joint_distribution(model)
% plot Joint distribution for the grid box volume weighted observed
% and modeled tracer concentrations  


% load model parameters
grd = model.grid;
M3d = model.M3d;
pkeep = model.msk.pkeep;   


% Potential temperature
% prepare data
temp_model = model.temp;
ptemp = permute(model.data.ptemp.ptstar,[4,1,2,3]);
temp_obs = ptemp(:,pkeep).';
temp_obs = temp_obs(:); 
dvt = grd.DXT3d .*grd.DYT3d .*grd.DZT3d;
dvt = kron(ones(12,1), dvt(pkeep));
% options for plot
option.xlabel = 'observed Temperature (\circ{}C)';
option.ylabel = 'modeled Temperature (\circ{}C)';
option.title = 'Potential Temperature';
% calculate volume weighted Rsquare
R2_value = Rsqured(temp_model, temp_obs, dvt);
R2.str = ['R^2 = ' num2str(round(R2_value,3))];
R2.x_axis = 2;
R2.y_axis = 18;
% bandwidth parameters for mykde2d.m 
min1 = 0;
max1 = 30;
% plot's min and max limit for x_axis and y_axis
min2 = 0;
max2 = 20;
plot_scatter_percentage(temp_model, temp_obs, dvt, min1,...
                        max1, min2, max2, 5, R2, option);


% Salinity
salt_model = model.salt;
salt = permute(model.data.salt.sstar,[4,1,2,3]);
salt_obs = salt(:,pkeep).';
salt_obs = salt_obs(:);
dvt = ones(size(salt_model));
% options for plot
option.xlabel = 'observed Salinity (\circ{}C)';
option.ylabel = 'modeled Salinity (\circ{}C)'; 
option.title = 'Salinity';
% calculate volume weighted Rsquare
R2_value = Rsqured(salt_model, salt_obs, dvt);
R2.str = ['R^2 = ' num2str(round(R2_value,3))];
R2.x_axis = 33.4;
R2.y_axis = 36.5;
% bandwidth parameters for mykde2d.m 
min1 = 33;
max1 = 37;
% plot's min and max limit for x_axis and y_axis
min2 = 33;
max2 = 37;
plot_scatter_percentage(salt_model, salt_obs, dvt, min1,...
                        max1, min2, max2, 5, R2, option);


% CFC-11 
cfc11_h1 = model.data.CFC11h1;
cfc11_h2 = model.data.CFC11h2; 
cfc11_obs = cfc11_h2 * model.data.cfc11star(:);  
cfc11_model = cfc11_h2 * cfc11_h1 *model.cfc11(:);   
x = cfc11_model;
y = cfc11_obs;
% dvt
dvt = grd.DXT3d .*grd.DYT3d .*grd.DZT3d; 
dvt = kron(ones(1,size(model.data.cfc11star,2)),dvt(pkeep));
dvt = cfc11_h2 * dvt(:);  
% option for plot
option.xlabel = 'observed CFC-11 (pmol/kg)';
option.ylabel = 'modeled CFC-11 (pmol/kg)';
option.title = 'CFC-11';    
% calculate volume weighted Rsquare
R2_value = Rsqured(cfc11_model, cfc11_obs, dvt);
R2.str = ['R^2 = ' num2str(round(R2_value,3))];
R2.x_axis = 0.5;
R2.y_axis = 5.3;
% bandwidth parameters for kde2d.m 
min1 = 0;
max1 = 8;
% plot's min and max limit for x_axis and y_axis
min2 = 0;
max2 = 6;
plot_scatter_percentage(cfc11_model, cfc11_obs, dvt, min1,...
                        max1, min2, max2, 6, R2, option);


% CFC-12 
cfc12_h1 = model.data.CFC12h1;
cfc12_h2 = model.data.CFC12h2; 
cfc12_obs = cfc12_h2 * model.data.cfc12star(:);  
cfc12_model = cfc12_h2 * cfc12_h1 *model.cfc12(:);   
x = cfc12_model;
y = cfc12_obs;
% dvt
dvt = grd.DXT3d .*grd.DYT3d .*grd.DZT3d; 
dvt = kron(ones(1,size(model.data.cfc12star,2)),dvt(pkeep));
dvt = cfc12_h2 * dvt(:);  
% option for plot
option.xlabel = 'observed CFC-12 (pmol/kg)';
option.ylabel = 'modeled CFC-12 (pmol/kg)';
option.title = 'CFC-12';    
% calculate volume weighted Rsquare
R2_value = Rsqured(cfc12_model, cfc12_obs, dvt);
R2.str = ['R^2 = ' num2str(round(R2_value,3))];
R2.x_axis = 0.3;
R2.y_axis = 2.6;
% bandwidth parameters for kde2d.m 
min1 = 0;
max1 = 5;
% plot's min and max limit for x_axis and y_axis
min2 = 0;
max2 = 3;
plot_scatter_percentage(cfc12_model, cfc12_obs, dvt, min1,...
                        max1, min2, max2, 6, R2, option);


% C14
% prepare data
nt = size(find(M3d(:) == 1), 1);
Rc14 = model.Rc14;
Rc14_0 = zeros(nt,12);
Rc14_0(:) = Rc14; 
Hc14 = model.data.Hc14;
Rc14_model = Hc14 * mean(Rc14_0, 2);
Rc14_obs = model.data.Rc14star;    
dvt = grd.DXT3d .*grd.DYT3d .*grd.DZT3d; 
dvt = dvt(pkeep); 
dvt = Hc14 * dvt(:);
% option for plot
option.xlabel = ' observed (^{14}C/^{12}C)/(^{14} C/^{12}C)_{atm}';
option.ylabel = 'modeled (^{14}C/^{12}C)/(^{14} C/^{12}C)_{atm}';  
option.title = '\Delta{}^{14}C';   
%
% calculate volume weighted Rsquare
R2_value = Rsqured(Rc14_model, Rc14_obs, dvt);
R2.str = ['R^2 = ' num2str(round(R2_value,3))];
R2.x_axis = 0.77;
R2.y_axis = 0.97;
% bandwidth parameters for kde2d.m 
min1 = 0.7;
max1 = 1;
% plot's min and max limit for x_axis and y_axis
min2 = 0.75;
max2 = 1;
plot_scatter_percentage(Rc14_model, Rc14_obs, dvt, min1,...
                        max1, min2, max2, 6, R2, option);



function [] = plot_scatter_percentage(x, y, dvt, min1, max1, ...
                                      min2, max2, n, R2, option)
% function to make kde2d plot

% x is model, and y is observation
data = [y,x];
% calculate the volume weighted pdf of the joint distribution    
[bandwidth,density,X,Y] = kde2d(data,2^7,[min1 min1],[max1 max1], dvt);   
% calculate the cdf of the percentiles of the cumulative
% distribution function.The Nth percentile is defined such that N%
% of the joint distribution lies outside N% contour.
% Contours with large percentiles correspond to the highest density
% and cluster close to the 1:1 line.
dx = X(3,5)-X(3,4); dy = Y(4,2)-Y(3,2); 
[q,i] = sort(density(:)*dx*dy,'descend');
D = density;
D(i) = cumsum(q);   
figure;
H = subplot('position',[0.2 0.2 0.6 0.6]);
cr = 5:10:95;
cmap = flip(colormap,1); 
colormap(cmap); 
D(D>0.95) = nan;
contourf(X,Y,100*D,cr); hold on     
contour(X,Y,100*D,cr);  
caxis([5 95])     
set(gca,'FontSize',16,...
        'linewidth',1.5, ...
        'Ylim',[min2 max2], ...
        'Xlim',[min2 max2],...
        'Ytick',linspace(min2, max2, n), ...
        'Xtick',linspace(min2, max2, n));    

axis square
xlabel(option.xlabel); 
ylabel(option.ylabel);
%title(option.title);     
plot([min2 max2],[min2 max2],'--');    
hold on
text(R2.x_axis, R2.y_axis, R2.str, 'fontsize', 16)
subplot('position',[0.82 0.2 0.05 0.6]); 
contourf([1 2],cr,[cr(:),cr(:)],cr); hold on   
contour([1 2],cr,[cr(:),cr(:)],cr);  
set(gca,'FontSize',14);
set(gca, 'Ytick', cr);   
set(gca,'XTickLabel',[]);
set(gca,'YAxisLocation','right');
set(gca,'TickLength',[0 0])
ylabel('(percentage)');


function [x] = Rsqured(y,ym,volt)
% y represents the data
% ym represents the intepolated data
ybar = sum(y.*volt)/sum(volt);
SStot = sum((y-ybar).^2.*volt);
SSres = sum((y-ym).^2.*volt);
x = 1-SSres/SStot;


