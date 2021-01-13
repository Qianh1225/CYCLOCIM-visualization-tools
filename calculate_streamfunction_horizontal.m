function [psi, maxPsi] = calculate_streamfunction_horizontal(v, M3d, mask, ...
                                                   grd, msk, str);
% zonally integrated meridional volume transport: Psi.
% Psi(z, i) z: depth, i: latitude,  sum vdzdx from depth z to surface.
% mask = 1 (ocean) 0 (land).
    [ny, nx, nz] = size(M3d);
    DXV = grd.DXV3d;
    DZV = grd.DZV3d;
    v1 = M3d * 0;
    v1(msk.vkeep) = v;
    v2 = v1 .* mask;
    dpsi_mask = v2.*DXV.*(DZV);
    dpsi_mask = squeeze(sum(dpsi_mask,2))';
    keyboard
    sum_flow = sum(dpsi_mask, 1); 
    Area = squeeze(mean(mean(grd.DZV3d .* grd.DZV3d, 2),1));
    %% remove the background circulation for ATL and Pacific
    if (strcmp(str, 'ATL') | strcmp(str, 'PAC'))
        for i = 1 : ny
            if (abs(sum_flow(i)) > 1e4)
                id = find(dpsi_mask(:,i) ~= 0);
                if (size(id, 2) > 0)
                    v_b = sum_flow(i) / sum(Area(id));
                end
                for k = 1 : size(id, 1)
                    dpsi_mask(id(k), i) = dpsi_mask(id(k), i) - v_b * ...
                        Area(id(k));
                end
            end
        end
    end
    % calculate the Psi and maxPsi
    psi = zeros(nz + 1, ny) * 0;
    dpsi_mask1 = dpsi_mask;
    dpsi_mask1(dpsi_mask1 == 0) = nan; 
    maxPsi = zeros(ny,1);
    % define the psi = 0  in the boundary;
    for i = 1:ny
        for k = 1 : nz 
                psi(k + 1, i) = sum(dpsi_mask1(1:k,i));
        end
        P1 = min(psi(:,i));
        P2 = max(psi(:,i));
        if (abs(P1) > abs(P2))
            maxPsi(i) = P1;
        else
            maxPsi(i) = P2;
        end
    end        
    psi = psi / 1e6; % unit: Sv
