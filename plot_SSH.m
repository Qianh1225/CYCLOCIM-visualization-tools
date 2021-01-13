function [] = plot_SSH(models, model_name_list, option)
for i = 1:length(model_name_list)
    model_name = model_name_list(i);
    model = models.(model_name);
    M3d = model.M3d;
    grd = model.grid;
    msk = model.msk;
    % modeled ssh
    ssh = model.h;
    ssh_model = zeros([size(M3d(:,:,1)), 12]);
    for i = 1 : 12
        tmp = M3d(:,:,1) * nan;
        tmp(msk.hkeep) = ssh(:,i);
        ssh_model(:,:,i) = tmp;
    end
    % AVISO ssh
    load data/AVISO_SSH.mat
    if contains(model_name, '8x8')
        ssh_obs = AVISO.SSH_8x8;
        %ssh_obs = model.data.ssh.h_2d;
    end
    if contains(model_name, '4x4')
        ssh_obs = AVISO.SSH_4x4;
    end
    if contains(model_name, '2x2')
        ssh_obs = AVISO.SSH_2x2;
    end
    % % calculate the integral of model SSH and assert whether it is
    % % equal to 0
    % % observation
    % ssh_area = mean(ssh_obs, 3) .* grd.Areat;
    % fprintf('integral of annual mean ssh over area: %.2f\n', nansum(nansum(ssh_area)));   
    % for i = 1 : 12
    %     inan = find(isnan(ssh_obs(:,:,i)));
    %     ssh_area = ssh_obs(:,:,i) .* grd.Areat;
    %     fprintf('integral of observed ssh over area on month %d: %.2f\n', ...
    %             i, nansum(nansum(ssh_area)));
    %     fprintf('integral of observed ssh over area on month %d:divided by area  %.2f\n', ...
    %             i, nansum(nansum(ssh_area))/nansum(nansum(grd.Areat(inan)))); 
    % end 
    % % model results
    % ssh_area = mean(ssh_model, 3) .* grd.Areat;
    % fprintf('integral of annual mean modeled ssh over area: %.2f\n', nansum(nansum(ssh_area)));   
    % for i = 1 : 12
    %         ssh_area = ssh_model(:,:,i) .* grd.Areat;
    %         fprintf('integral of  ssh over area on month %d: %.2f\n', ...
    %                 i, nansum(nansum(ssh_area)));  
    % end
    
    % plot
    % annual mean  
    option.cr = linspace(-4.0, 4.0, 40);
    option.title = ['Annual-mean ', model_name];
    option.colormap = 'RdYlBu';
    option.ncol = 20;
    option.caxis =[-1.2 1.2];
    option.cticks = [-1.2:0.3:1.2];
    option.cr2 = linspace(-1.5, 1.5, 20);
    ssh_model_mean = mean(ssh_model, 3);
    ssh_obs_mean = mean(ssh_obs, 3);
    %ssh_obs_mean = mean(ssh_obs, 3) - nansum(nansum(ssh_area))/nansum(nansum(grd.Areat(inan)));
    plot_SSH_model_obs(ssh_model_mean, ssh_obs_mean, grd, M3d, option)
    % difference
    option.title = [model_name, '- AVISO (annual mean)'];
    option.colormap = 'RdBu';
    option.caxis =[-2 2];
    option.cr = linspace(-5, 5, 40);
    plot_difference(ssh_model_mean, ssh_obs_mean, grd, M3d, ...
                    option);
    saveas(gcf,model_name,'epsc');
    % monthly comparsion
    if strcmp(option.monthly, 'on')
        for i = 1 : 12
            option.cr = linspace(-1.2, 1.2, 20);
            option.title = ['Month', num2str(i), model_name];
            option.colormap = 'RdYlBu';
            option.ncol = 20;
            option.caxis =[-1.5 1.5];
            option.cticks = [-1.2:0.3:1.2];
            option.cr = linspace(-1.8, 1.8, 20);
            option.cr2 = linspace(-1.5, 1.5, 20);
            plot_SSH_model_obs(ssh_model(:,:,i), ssh_obs(:,:,i), grd, M3d, option)
            %
            option.title = [model_name, '- AVISO (annual mean), ' ...
                                'Month = ', num2str(i)];
            option.colormap = 'RdBu';
            option.caxis =[-1 1];
            option.cr = linspace(-1, 1, 20);
            plot_difference(ssh_model(:,:,i), ssh_obs(:,:,i), grd, M3d, option)
        end
    end
    
    
    
    
end


function plot_SSH_model_obs(ssh_2d, ssh_obs, grd, M3d, option)
    figure('Position', [20 20 700 900]);
    subplot(2,1,1)
    plot_SSH_1(grd, M3d, ssh_2d, option);
    subplot(2,1,2)
    option.title = 'AVISO';
    plot_SSH_1(grd, M3d, ssh_obs, option);  
    % colorbar
    subplot('position',[0.25 0.05 0.5 0.025]);
    cr2 = option.cr2;
    contourf(cr2,[1, 2],[cr2(:),cr2(:)]',cr2); hold on
    contour(cr2,[1, 2],[cr2(:),cr2(:)]',cr2);
    caxis(option.caxis);
    set(gca,'FontSize', 13);
    set(gca,'YTickLabel', []);
    set(gca,'XTick', option.cticks);    
    %set(gca,'YAxisLocation', 'right');
    set(gca,'TickLength', [0 0]);

function plot_difference(ssh_2d, ssh_obs, grd, M3d, option)
    % plot the difference between CYCLOCIM and AVISO
    figure
    plot_SSH_1(grd, M3d, ssh_2d - ssh_obs, option);
    subplot('position',[0.25 0.05 0.5 0.025]);
    cr2 = option.cr;
    contourf(cr2,[1, 2],[cr2(:),cr2(:)]',cr2); hold on
    contour(cr2,[1, 2],[cr2(:),cr2(:)]',cr2);
    caxis(option.caxis);
    set(gca,'FontSize', 13);
    set(gca,'YTickLabel', []);
    %set(gca,'XTick', option.cticks);    
    %set(gca,'YAxisLocation', 'right');
    set(gca,'TickLength', [0 0])

function plot_SSH_1(grd, M3d, ssh, option)
m_proj('robinson','lon',[0 360]);
m_coast('patch',[.8 .8 .8], 'linestyle', 'none');
hold on;
mycmap = cbrewer('div',option.colormap, option.ncol,'PCHIP');
colormap(flip(mycmap));
m_contourf(grd.xt, grd.yt, ssh,...
           option.cr,'linestyle','none'); 
m_grid('linewidth',1.0,'fontsize',14,...
       'XTick', [0:90:360],...
       'YTick',[-90:30:90]);
caxis(option.caxis);
grid on;
title(option.title, 'fontsize', 16)