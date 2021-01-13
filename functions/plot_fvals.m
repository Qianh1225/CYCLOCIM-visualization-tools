% data
% weight on ssh = 1
fT_1 = [4.07, 2.86, 2.34, nan];
fS_1 = [3.79, 2.79, 2.33, nan];
fcfc11_1 = [4.02, 2.97, 2.69, nan];
fc14_1 = [2.7, 2.38, 2.01, nan];
fh_1 = [38.94, 28.33, 22.66, nan];

% weight on ssh = 10
fT_10 = [9.04, 5.87, 4.85, 4.16];
fS_10 = [6.65, 5.09, 4.30, 4.37];
fcfc11_10 = [5.26, 3.65, 3.22, 2.92];
fc14_10 = [3.36, 2.95, 2.58, 2.28];
fh_10 = [189.89/10, 135.67/10, 109.66/10, 91.4/10];


% weight on ssh = 100
fT_100 = [24.65, 15.57, 16.07, 6.75];
fS_100 = [12.91, 14.26, 13.77, 11.14];
fcfc11_100 = [11.78, 7.83, 6.79, 5.03];
fc14_100 = [10.44, 8.07, 4.19,  3.31];
fh_100 = [1247/100.0, 604/100.0, 309.87/100, 189.3/100];

% weight on ssh = 500
fT_500 = [40.12, 15.15, 7.23, 5.51];
fS_500 = [32.40, 23.05, 19.58, 16.92];
fcfc11_500 = [15.98, 9.57, 6.65, 5.17];
fc14_500 = [28.97, 5.54, 3.28, 2.57];
fh_500 = [1290/500.0, 106/500, 14.42/500, 2.48/500];


% weight on ssh = 1000
fT_1000 = [32.38, 13.32, 7.68, 6.39];
fS_1000 = [32.35, 24.52,  20.23, 17.40];
fcfc11_1000 = [15.80, 9.42, 6.74, 5.57];
fc14_1000 = [15.61, 4.48, 3.04, 2.60];
fh_1000 = [592.94/1000, 26.939/1000, 2.538/1000, 0.804882/1000];


figure;
subplot(2,3,1)

it = [2000, 4000, 6000, 8000]
plot(it, fT_1, '*-');
hold on
plot(it, fT_10, 'o-');
hold on
plot(it, fT_100, '^-');
hold on
plot(it, fT_500, '>-');
hold on
plot(it, fT_1000,'+-');
legend({'w1','w10', 'w100','w500','w1000'})
title("fT, 0 iteration = 2.7e4", "fontsize", 14)
xlabel("iterations", 'fontsize', 14);
set(gca, 'fontsize', 14, 'linewidth', 1.2)

subplot(2,3,2)
plot(it, fS_1, '*-');
hold on
plot(it, fS_10, 'o-');
hold on
plot(it, fS_100, '^-');
hold on
plot(it, fS_500, '>-');
hold on
plot(it, fS_1000,'+-');
legend({'w1','w10', 'w100','w500','w1000'})
xlabel("iterations", 'fontsize', 14);
set(gca, 'fontsize', 14, 'linewidth', 1.2)
title("fS, 0 iteration = 750",  "fontsize", 14)


subplot(2,3,3)
plot(it, fcfc11_1, '*-');
hold on
plot(it, fcfc11_10, 'o-');
hold on
plot(it, fcfc11_100, '^-');
hold on
plot(it, fcfc11_500, '>-');
hold on
plot(it, fcfc11_1000,'+-');
legend({'w1','w10', 'w100','w500','w1000'})
xlabel("iterations", 'fontsize', 14);
set(gca, 'fontsize', 14, 'linewidth', 1.2)


title("fcfc11, 0 iteration = 44", "fontsize", 14)


subplot(2,3,4)
plot(it, fc14_1, '*-');
hold on
plot(it, fc14_10, 'o-');
hold on
plot(it, fc14_100, '^-');
hold on
plot(it, fc14_500, '>-');
hold on
plot(it, fc14_1000,'+-');
legend({'w1','w10', 'w100','w500','w1000'})
xlabel("iterations", 'fontsize', 14);
set(gca, 'fontsize', 14, 'linewidth', 1.2)
title("fc14, 0 iteration = 583", "fontsize", 14)


subplot(2,3,5)
plot(it, fh_1, '*-');
hold on
plot(it, fh_10, 'o-');
hold on
plot(it, fh_100, '^-');
hold on
plot(it, fh_500, '>-');
hold on
plot(it, fh_1000,'+-');
legend({'w1','w10', 'w100','w500','w1000'})
xlabel("iterations", 'fontsize', 14);
set(gca, 'fontsize', 14, 'linewidth', 1.2)

legend({'w1','w10', 'w100','w500','w1000'})
title("fh, 0 iteration = 109", "fontsize", 14)


