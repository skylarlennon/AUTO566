%% Tau Omega Histogram Plotter
clc;
clear;
close all;
tire_radius = 0.554/2;
%addpath("WSC_Route_Files\");
%files = dir("WSC_Route_Files\*.csv");
%%
csv_path = 'C:\Users\harri\Documents\MATLAB\UMSM\SCLoad\wsc_2025_at_28.0556.csv';
data = readtable(csv_path);
%%
tau = 0;
omega = 0;
Energy = 0;
CdA = 0.070;
mass = 250;
for i = 1:length(data.start_x)
    [F, E, V] = get_road_load_CdA(CdA, data.step_time(i), data.start_v(i),...
        data.accel(i), data.gravity(i), data.inc(i), mass);
    tau = cat(1, tau, F*tire_radius);
    omega = cat(1, omega, V/(tire_radius));
    Energy = cat(1, Energy, E);
end
%%
figure(1);
h = histogram2(tau, omega);
ax = gca;
title("Tau Omega Histogram for Set Speed of  m/s");
xlabel("tau");
ylabel("omega");
zlabel("Operation Point Frequency - Time Weighted")
disp("Total Road Load Energy");
disp(sum(Energy)/3600);
%%
figure(2);
y = linspace(min(tau), max(tau), 50);
z = linspace(min(omega), max(omega), 50);
hist2w([tau, omega], Energy/sum(Energy), y, z, sky(100));
xlabel("$\tau$ Nm", Interpreter="latex");
ylabel("$\omega$ [rad/s]", Interpreter="latex");
zlabel("Fraction of Energy On Race")
title("Work Weighted Tau Omega Histogram");

%%
%savefig("WorkWeightedPlot.fig");

%% Mitsuba Motor Efficiency Plot Low Coil

Mit1_Kt = 0.42319;
Mit1_alpha_kt = -0.00063;
Mit1_Ke = 0.42319;
Mit1_alpha_ke = -0.00063;
Mit1_r = 0.054962;
Mit1_alphar = 0.00393;
Mit1_Hys = 2.08064;
Mit1_alpha_Hys = 0.0364;
Mit1_EC = 0.42371;
Mit1_alpha_ec = -0.00065;

figure(3);
hold on;
ax1 = axes;
histogram2(ax1, tau, omega, [200, 200], 'DisplayStyle', 'tile');
title(ax1, "Mitsuba Low Coil Efficiency overlayed on Tau Omega Histogram");
xlabel("$\tau$ [Nm]", Interpreter="latex");
ylabel("\omega [rad/s]");
[seen_tau, seen_omega] = meshgrid(linspace(min(tau), max(tau), 200), linspace(min(omega), max(omega), 200));
mitsuba_low = Motor(Mit1_Kt, Mit1_Ke, 100, Mit1_r, Mit1_Hys, Mit1_EC, Mit1_alpha_kt, Mit1_alpha_ke, ...
    Mit1_alphar, Mit1_alpha_Hys, Mit1_alpha_ec, 25);
Motor_L = mitsuba_low.Get_Power_Loss(seen_tau, seen_omega, 25);
Motor_E = 1-Motor_L./(abs(seen_tau.*seen_omega));
lev = [0.7, 0.8, 0.85, 0.9, 0.95, 0.98];
ax2 = axes;
contour(ax2, seen_tau, seen_omega, Motor_E, lev, "ShowText", "on", "LineWidth", 1);
ax2.Visible = 'off';
linkaxes([ax1, ax2]);

%%Give each one its own colormap
mapEff = 2*[0.5 0 0
    0.4 0.1 0
    0.35 0.2 0
    0.25 0.25 0
    0.2 0.3 0
    0.1 0.5 0];
colormap(ax1,'parula');
colormap(ax2, mapEff);
ax2.XTick = [];
ax2.YTick = [];
%%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .625 .815]);
cb1 = colorbar(ax1,'Position',[.80 .11 .0375 .815]);
cb2 = colorbar(ax2,'Position',[.90 .11 .0375 .815]);
xlim(ax1, [-50, 50]);
ylim(ax1, [50, 110]);
%% Mitsuba Motor Efficiency Plot High Coil
Mit2_Kt = 0.29188;
Mit2_alpha_kt = -0.0006;
Mit2_Ke = 0.29188;
Mit2_alpha_ke = -0.0006;
Mit2_r = 0.078436;
Mit2_alphar = 0.00393;
Mit2_Hys = 2.08064;
Mit2_alpha_Hys = 0.0364;
Mit2_EC = 0.42371;
Mit2_alpha_ec = -0.00065;

figure(4);
hold on;
ax1 = axes;
histogram2(ax1, tau, omega, [200, 200], 'DisplayStyle', 'tile');
title(ax1, "Mitsuba High Coil Efficiency overlayed on Tau Omega Histogram");
xlabel("$\tau$ [Nm]", Interpreter="latex");
ylabel("\omega [rad/s]");
[seen_tau, seen_omega] = meshgrid(linspace(min(tau), max(tau), 200), linspace(min(omega), max(omega), 200));
mitsuba_high = Motor(Mit2_Kt, Mit2_Ke, 100, Mit2_r, Mit2_Hys, Mit2_EC, Mit2_alpha_kt, Mit2_alpha_ke, ...
    Mit2_alphar, Mit2_alpha_Hys, Mit2_alpha_ec, 25);
Mit_H_Motor_L = mitsuba_high.Get_Power_Loss(seen_tau, seen_omega, 25);
Mit_H_Motor_E = 1-Mit_H_Motor_L./(abs(seen_tau.*seen_omega));
lev = [0.7, 0.8, 0.85, 0.9, 0.95, 0.98];
ax2 = axes;
contour(ax2, seen_tau, seen_omega, Mit_H_Motor_E, lev, "ShowText", "on", "LineWidth", 1);
ax2.Visible = 'off';
linkaxes([ax1, ax2]);

%%Give each one its own colormap
mapEff = 2*[0.5 0 0
    0.4 0.1 0
    0.35 0.2 0
    0.25 0.25 0
    0.2 0.3 0
    0.1 0.5 0];
colormap(ax1,'parula');
colormap(ax2, mapEff);
ax2.XTick = [];
ax2.YTick = [];
%%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .625 .815]);
cb1 = colorbar(ax1,'Position',[.80 .11 .0375 .815]);
cb2 = colorbar(ax2,'Position',[.90 .11 .0375 .815]);
xlim(ax1, [-50, 50]);
ylim(ax1, [50, 110]);
%% Ray Tek Motor Efficiency Plot
Ray_Kt = 1/2.228;
Ray_alpha_kt = -0.00063;
Ray_Ke = 1/2.228;
Ray_alpha_ke = -0.00063;
Ray_r = 0.03597 + 0.00780;
Ray_alphar = 0.00393;
Ray_Hys = 0.001352;
Ray_alpha_Hys = 0.0364;
Ray_EC = 0.01;
Ray_alpha_ec = -0.00065;

figure(5);
hold on;
ax1 = axes;
histogram2(ax1, tau, omega, [200, 200], 'DisplayStyle', 'tile');
title(ax1, "Ray Tek Efficiency overlayed on Tau Omega Histogram");
xlabel("$\tau$ [Nm]", Interpreter="latex");
ylabel("\omega [rad/s]");
[seen_tau, seen_omega] = meshgrid(linspace(min(tau), max(tau), 200), linspace(min(omega), max(omega), 200));
Ray_Tek = Motor(Ray_Kt, Ray_Ke, 100, Ray_r, Ray_Hys, Ray_EC, Ray_alpha_kt, Ray_alpha_ke, ...
    Ray_alphar, Ray_alpha_Hys, Ray_alpha_ec, 25);
Ray_Motor_L = Ray_Tek.Get_Power_Loss(seen_tau, seen_omega, 25);
Ray_Motor_E = 1-Ray_Motor_L./(abs(seen_tau.*seen_omega));
lev = [0.7, 0.8, 0.85, 0.9, 0.95, 0.98];
ax2 = axes;
contour(ax2, seen_tau, seen_omega, Ray_Motor_E, lev, "ShowText", "on", "LineWidth", 1);
ax2.Visible = 'off';
linkaxes([ax1, ax2]);

%%Give each one its own colormap
mapEff = 2*[0.5 0 0
    0.4 0.1 0
    0.35 0.2 0
    0.25 0.25 0
    0.2 0.3 0
    0.1 0.5 0];
colormap(ax1,'parula');
colormap(ax2, mapEff);
ax2.XTick = [];
ax2.YTick = [];
%%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .625 .815]);
cb1 = colorbar(ax1,'Position',[.80 .11 .0375 .815]);
cb2 = colorbar(ax2,'Position',[.90 .11 .0375 .815]);
xlim(ax1, [-50, 50]);
ylim(ax1, [50, 110]);
%%
figure(6);
hold on;
colormap(mapEff);
clim([0, 1]);
colorbar;
surf(seen_tau, seen_omega, Ray_Motor_E, FaceColor="interp", FaceAlpha=0.8);
surf(seen_tau, seen_omega, Motor_E, FaceColor="interp", FaceAlpha=0.7);
surf(seen_tau, seen_omega, Mit_H_Motor_E, FaceColor="interp", FaceAlpha=0.6);
xlabel("\tau [Nm]");
ylabel("\omega [rad/s]");
zlabel("Efficiency");
xlim([-30, 50]);
ylim([0, 110]);
zlim([0.4, 1]);
view([130, 20]);
legend("Ray Tek Motor", "Mitsuba Low Coil", "Mitsuba High Coil");
%%
disp("Total Power Lost over the race is " + sum(mitsuba_low.Get_Power_Loss(tau, omega, 25))/3600);
disp("Total Power Lost over the race is " + sum(Ray_Tek.Get_Power_Loss(tau, omega, 25))/3600);
