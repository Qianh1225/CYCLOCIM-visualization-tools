function [] = plot_optimization_progress(models, model_name_list)
figure('position', [50, 50, 500, 400]);
for name = model_name_list
    model = models.(name);
    ithist = model.ithist;
    plot(ithist(:,1), ithist(:,2), 'linewidth', 2.0);
    set(gca, 'YScale', 'log');
    set(gca, 'fontsize', 14)
    hold on
end
legend(model_name_list, 'fontsize', 14);
