function [] = plot_upper_ocean_difference(models, model_name_list, ...
                                          option)
    figure('Position', [20 20 700 900]);
    n_subfigures = length(model_name_list);
    label_strs = ['(a)'; '(b)'; '(c)'; '(d)'];
    if contains(option.tracer_name, 'temp')
        option.cr1 = [-5.1:0.6:4.5];
        option.cr2 = [-4.5:0.6:4.5];
        option.caxis = [-4 4];
        option.XTick = [-3.9:1.2:-0.3, 0.3:1.2:4.2];
    end
    if contains(option.tracer_name, 'sal')
        option.cr1 = [-1.1:0.2:1.1]; 
        option.cr2 = [-1.1:0.2:1.1];
        option.caxis = [-1, 1];
        option.XTick = [-0.9:0.2:-0.1, 0.1:0.2:0.9];
    end
    for i = 1 : n_subfigures
        subplot(n_subfigures, 1, i)
        model_name = model_name_list(i);
        model = models.(model_name);
        diff = prepare_data(model, model_name, option.tracer_name, ...
                            option.max_depth);
        plot_difference(diff, model.grid, option.cr1, ...
                        label_strs(i,:), option.caxis);
    end    

    %colorbar
    subplot('position',[0.25 0.05 0.5 0.025]);
    %subplot('position',[0.1 0.1 0.7 0.05])
    cr2 = option.cr2;
    contourf(cr2,[1, 2],[cr2(:),cr2(:)]',cr2); hold on
    contour(cr2,[1, 2],[cr2(:),cr2(:)]',cr2);
    caxis(option.caxis);
    load colorScheme/RedBlue1.mat 
    colormap(mycmap); 
    set(gca,'FontSize', 13);
    set(gca,'YTickLabel', []);
    set(gca,'XTick', option.XTick);    
    %set(gca,'YAxisLocation', 'right');
    set(gca,'TickLength', [0 0])

    
function diff = prepare_data(model, model_name, tracer_name, depth)
    M3d = model.M3d;
    msk = model.msk;
    grd = model.grid;
    pkeep = msk.pkeep;
    np = size(pkeep,1);
    if contains(tracer_name, 'temp')
        if contains(model_name, "CYCLOCIM")
            c_obs = model.data.ptemp.ptstar;
            c_model = model.temp;
        else
            c_obs = model.tstar;
            c_model = model.T;
        end
    end 
    if contains(tracer_name, 'sal')
        if contains(model_name, "CYCLOCIM")
            c_obs = model.data.salt.sstar;
            c_model = model.salt;
        else
            c_obs = model.sstar;
            c_model = model.S;
        end
    end
    c_obs = data_1D_to_3D(c_obs, M3d, msk, model_name, tracer_name,  ...
                          "annual"); 
    c_model = data_1D_to_3D(c_model, M3d, msk, model_name, tracer_name, ...
                            "annual"); 
    ilayer = find(grd.zt < depth); 
    diff = mean(c_model(:,:,ilayer) - c_obs(:,:,ilayer), 3);  

    
function plot_difference(difference, grd, cr, label_str, caxis_limit)
    % addpath('/Users/qian/Documents/MATLAB/m_map');
    m_proj('robinson','lon',[0 360]);
    m_coast('patch',[.8 .8 .8], 'linestyle', 'none');
    hold on;
    load colorScheme/RedBlue1.mat 
    colormap(mycmap);
    caxis(caxis_limit)
    m_contourf(grd.xt, grd.yt, difference,...
               cr,'linestyle','none'); 
    m_grid('linewidth',1.0,'fontsize',14,...
           'XTick', [0:90:360],...
           'YTick',[-90:30:90]);
    grid on;
    text(-2, 1.24, label_str,'fontsize',16);


function data_3D = data_1D_to_3D(data_1D, M3d, msk, ...
                                 model_name, tracer_name, option)
    % convert 1D vector to 3D spatial matrix
    % For OCIM, convert 1D vector to 3D spatial matrix: (nlat, nlon, nz)
    % For CYCLOCIM convert 1D vector to 12 3D matrix: (nlat, nlon, nz, 12)
    % model_name: either contains CYCLOCIM or OCIM
    % option: if option == "annual", return return annual mean 3D
    % matrix
    if length(size(data_1D)) > 2
        data_3D = data_1D;
        return
    end
    pkeep = msk.pkeep;
    np = size(pkeep,1);
    if ~(contains(tracer_name, "CFC")) 
        if contains(model_name, "CYCLOCIM")
            data_3D = zeros([size(M3d),12]);
            t = M3d * nan;
            for i = 1:12
                t(pkeep) = data_1D((i-1)*np+1 : i*np);
                data_3D(:,:,:,i) = t;
            end
            if contains(option, "annual");
                data_3D = mean(data_3D, 4);
            end
        else
            data_3D = M3d * nan;
            data_3D(msk.pkeep) = data_1D;
        end
    end