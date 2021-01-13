function [RMSE] = calculate_and_plot_RMSE(models)
% input: data struct containing different versions of CYCLOCIM and OCIM
% calculate volume_weighted RMSE for CYCLOCIM and OCIM and make plots
% return: RMSE

% unpack the data and calculate RMSE
names = fieldnames(models); % model's name
for iname = 1 : numel(names)
    RMSE.(string(names(iname))) = ...
        calculate_RMSE(models.(string(names(iname))), names(iname));
end

% plot RMSE

function [RMSE] = calculate_RMSE(model, model_name)
% input: model data
% return: struct data:volume_weighted RMSE.
% RMSE contains: mean RMSE,
%                annual mean vertical RMSE,
%                seasonal vertical RMSE,
%                monthly vertical RMSE
M3d = model.M3d;
grd = model.grid;
msk = model.msk;
pkeep = msk.pkeep;
np = size(pkeep,1);
% prepare modeled and observed tracer: potential temperature,
% salinity and cfc11
if contains(model_name, "CYCLOCIM")
    [temp_model, temp_obs] = prepare_data(model.temp, model.data.ptemp.ptstar,...
                         M3d, pkeep, np, model_name);
    [salt_model, salt_obs] = prepare_data(model.salt, model.data.salt.sstar, ...
                                          M3d, pkeep, np, model_name);
    [cfc11_model, cfc11_obs] = prepare_data_cfc(model.cfc11, ...
                                                  model.data.cfc11star, ...
                                                  model.data.CFC11h1, model_name);
else
    [temp_model, temp_obs] = prepare_data(model.T, model.tstar,...
                         M3d, pkeep, np, model_name);
    [salt_model, salt_obs] = prepare_data(model.S, model.sstar, ...
                                          M3d, pkeep, np, model_name);
    [cfc11_model, cfc11_obs] = prepare_data_cfc(model.CFC11, ...
                                                  model.cfc11star, ...
                                                  0, model_name);
end
% calculate the mean RMSE of temperature and salinity
RMSE.T.mean = calculate_mean_RMSE(temp_model, temp_obs,  grd, ...
                                  pkeep);
RMSE.S.mean = calculate_mean_RMSE(salt_model, salt_obs, grd, ...
                                  pkeep);
% calculate the vertical RMSE of temperature, salinity and CFC11
if contains(model_name, "CYCLOCIM")
    [RMSE.T.vertical_annual, RMSE.T.vertical_season, RMSE.T.vertical_month]...
    = calculate_vertical_RMSE(temp_model, temp_obs, M3d, grd);
    [RMSE.S.vertical_annual, RMSE.S.vertical_season, RMSE.S.vertical_month]...
    = calculate_vertical_RMSE(salt_model, salt_obs, M3d, grd);
else
    RMSE.T.vertical_annual = vertical_RMSE(temp_model, temp_obs, ...
                                           M3d, grd);
    RMSE.S.vertical_annual = vertical_RMSE(salt_model, salt_obs, ...
                                           M3d, grd);
end
RMSE.CFC11.vertical_annual = calculate_vertical_RMSE_cfc(cfc11_model, cfc11_obs, ...
                                            M3d, grd);

function [c_model_reshape, c_obs_reshape] = prepare_data(c_model, c_obs, M3d, pkeep, np, model_name)
if contains(model_name, "CYCLOCIM")
    c_model_reshape = zeros([size(M3d),12]);
    tmp = M3d * nan;
    for i = 1:12
        tmp(pkeep) = c_model((i-1)*np +1: i*np);
        c_model_reshape(:,:,:,i) = tmp;
    end
    c_obs_reshape = c_obs;
else
    c_model_reshape = M3d*0;
    c_model_reshape(pkeep) = c_model;
    c_obs_reshape = M3d*0;
    c_obs_reshape(pkeep) = c_obs;
end

function[c_model_reshape, c_obs_reshape] = prepare_data_cfc(c_model, ...
                                                  c_obs, H1, model_name)
if contains(model_name, "CYCLOCIM")
    c_model_reshape = zeros(size(c_obs));  
    c_model_reshape(:) = H1 * c_model(:);
else
    c_model_reshape = c_model;
end
    c_obs_reshape = c_obs;

function RMSE_mean = calculate_mean_RMSE(c_model, c_obs, grd, pkeep)
% calculate the total RMSE
c_obs_mean = mean(c_obs, 4);
c_obs_mean = c_obs_mean(pkeep);
c_model_mean = mean(c_model, 4);
c_model_mean = c_model_mean(pkeep);
volt = grd.DXT3d.*grd.DYT3d.*grd.DZT3d; 
volt = volt(pkeep); 
RMSE_mean = RMSD(c_model_mean, c_obs_mean, volt);

function [r_annual, r_season, r_month] = calculate_vertical_RMSE(...
                                          c_model, c_obs, M3d, grd)
    nz = size(M3d,3);
    r_month = zeros(nz, 12);
    r_season = zeros(nz, 4);
    r_annual = zeros(nz, 1);
    for i = 1 : 12
        r_month(:,i) = vertical_RMSE(c_model(:,:,:,i), c_obs(:,:,:,i), ...
                                     M3d, grd);
    end
    id = [12, 1, 2; 3, 4, 5; 6, 7, 8; 9, 10, 11];
    for i = 1 : 4
        c_model_season = mean(c_model(:,:,:,squeeze(id(i,:))), 4);
        c_obs_season = mean(c_obs(:,:,:,squeeze(id(i,:))), 4);
        r_season(:,i) = vertical_RMSE(c_model_season, c_obs_season, M3d, grd);
    end
    r_annual = vertical_RMSE(mean(c_model,4), mean(c_obs,4), M3d, grd);

function r = vertical_RMSE(c_model, c_obs, M3d, grd)
    nz = size(M3d,3);
    Volt = grd.DXT3d.*grd.DYT3d.*grd.DZT3d; 
    r = zeros(nz,1);
    for z = 1:nz
        M3d_z = M3d(:,:,z);
        pkeep_z = find(M3d_z(:) == 1);
        c_model_z = squeeze(c_model(:,:,z));
        c_model_z = c_model_z(pkeep_z);  
        c_obs_z = squeeze(c_obs(:,:,z));
        c_obs_z = c_obs_z(pkeep_z);
        volt_z = Volt(:,:,z);
        volt_z = volt_z(pkeep_z);
        % delete the -9.9990 points
        np = size(c_obs_z(:),1);
        nn = find(c_obs_z(:) >-5);
        H1_t = speye(np);
        H1_t = H1_t(nn,:);
        % calculate the RMSD in each depth
        r(z) = RMSD(H1_t*c_obs_z, H1_t*c_model_z, H1_t*volt_z);
    end
function r = calculate_vertical_RMSE_cfc(c_model, c_obs, M3d, grd)
    pkeep = find(M3d(:) == 1);
    nz = size(M3d, 3);
    nt = size(c_model,2);
    c_model_3d = zeros([nt, size(M3d)]) * (-9);
    c_model_3d(:, pkeep) = c_model';
    cfc_obs_3d = zeros([nt, size(M3d)]) * (-9);
    cfc_obs_3d(:, pkeep) = c_obs';
    Volt = grd.DXT3d.*grd.DYT3d.*grd.DZT3d;
    r = zeros(nz,1);
    for i = 1:nz
        c_model_3d_z = c_model_3d(:,:,:,i);
        c_model_3d_z = c_model_3d_z(:,:);
        cfc_obs_3d_z = squeeze(cfc_obs_3d(:,:,:,i));
        cfc_obs_3d_z = squeeze(cfc_obs_3d_z(:,:));
        Volt_z0 = Volt(:,:,i);
        Volt_z = kron(ones(nt,1), Volt_z0(:));
        % delete the Nan points
        np = size(cfc_obs_3d_z(:),1);
        nn = find(cfc_obs_3d_z(:) >-5);
        H1 = speye(np);
        H1 = H1(nn,:);
        r(i) = RMSD(H1 * cfc_obs_3d_z(:), H1 * c_model_3d_z(:), H1 * Volt_z(:));
    end    

function r = RMSD(y,ym,volt)
    r = sqrt(sum((y-ym).^2.*volt)/(sum(volt)));

