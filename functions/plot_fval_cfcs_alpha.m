load fval_cfcs_alpha.mat
alpha_list = alpha_list*100/(365*24);
figure;
plot(alpha_list, fcfc11, 'linewidth', 1.2)
hold on;
plot(alpha_list, fcfc12, 'linewidth', 1.2)
legend('CFC-11', 'CFC-12', 'fontsize', 18);
set(gca, 'lineWidth',1.2,...
         'fontsize', 16,...
         'ylim', [1, 6],...
         'ytick', [0:1:6])        
xlabel('$\alpha \: (\frac{cm}{h}/\frac{m^2}{s^2})$', ...  
       'fontsize', 24, 'Interpreter','latex')         
ylabel('$\hat{f}$', 'fontsize', 24, 'Interpreter','latex')        
  