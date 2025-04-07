%% Tau Omega Histogram Plotter
clc;
clear;
close all;

%% Load Driving Data
tire_radius = 0.554 / 2;
csv_path = "wsc_2025_at_28.0556.csv";
data = readtable(csv_path);

tau = 0;
omega = 0;
Energy = 0;
CdA = 0.070;
mass = 250;

for i = 1:length(data.start_x)
    V = data.start_v(i);
    F = 0.5 * CdA * 1.225 * V^2 + 30;
    E = F * V * data.step_time(i);

    tau = cat(1, tau, F * tire_radius);
    omega = cat(1, omega, V / tire_radius);
    Energy = cat(1, Energy, E);
end

%% Figure 1: Motor Efficiency Map (From Power Loss Model)

% Define motor operating ranges
speed_rpm = linspace(0, 5000, 100);     % RPM
omega = speed_rpm.*2.*pi./60;
torque_nm = linspace(0, 3.5, 100);       % Torque in Nm

[speed_grid_rpm, torque_grid] = meshgrid(speed_rpm, torque_nm);
omega_grid = speed_grid_rpm * 2 * pi / 60;  % rad/s

% Instantiate your motor (same constants from datasheet)
motor = Motor(0.0707, 0.0707, 38, 0.113, 1.0, 0.3, ...
              -0.0006, -0.0006, 0.0039, 0, -0.0001, 23);

% Initialize power values
P_out = torque_grid .* omega_grid;
P_loss = zeros(size(P_out));
eta_map = zeros(size(P_out));

% Loop to calculate power loss and efficiency
for i = 1:length(torque_nm)
    for j=1:length(speed_rpm)
     [P_l, ~, ~, ~] = motor.Get_Power_Loss(torque_grid(i), omega_grid(j), 25);
     P_loss(i,j) = P_l;
     eta_map(i,j) = P_out(i,j) / (P_out(i,j) + P_l + 1e-6);  % avoid division by zero
    end
end

% Clamp efficiency between 0 and 1
eta_map = max(0, min(1, eta_map));

% Plot the efficiency contour
figure(1); clf;
contourf(speed_grid_rpm / 1000, torque_grid, eta_map, ...
         [0.5 0.6 0.7 0.75 0.8 0.85 0.9 0.93 0.95], ...
         'ShowText', 'on', 'LineColor', 'k');

colormap(turbo); 
colorbar;
caxis([0.5 0.95]);

xlabel('Speed [krpm]');
ylabel('Torque [Nm]');
title('Motor Efficiency Map (From Power Loss Model)');
grid on;

%% Save to csv
outputFileName = "../csv/motorEffOut.csv"
outputMatrix = zeros(length(speed_rpm)+1, length(torque_nm)+1);
outputMatrix(2:end,2:end) = eta_map;
outputMatrix(2:end,1) = torque_nm;
outputMatrix(1,2:end) = omega;
zeroIdx = (outputMatrix == 0);
outputMatrix(zeroIdx) = 0.25;
writematrix(outputMatrix,outputFileName);

%% Figure 2: I²R Power Loss Map (Resistive Losses Only)

% Reuse speed and torque grid
% speed_rpm = linspace(0, 5000, 100);
% torque_nm = linspace(0, 3.5, 100);
% [speed_grid_rpm, torque_grid] = meshgrid(speed_rpm, torque_nm);
% omega_grid = speed_grid_rpm * 2 * pi / 60;
% 
% % Initialize resistive loss matrix
% P_loss_R = zeros(size(omega_grid));
% 
% for i = 1:numel(omega_grid)
%     P_loss_R(i) = motor.get_power_loss_resistive(torque_grid(i));
% end
% 
% % Plot contour
% figure(2); clf;
% contourf(speed_grid_rpm, torque_grid, P_loss_R, 10, 'ShowText', 'on');
% colormap(parula);
% colorbar;
% title('I²R Losses');
% xlabel('RPM');
% ylabel('Torque (N·m)');
% c = colorbar;
% c.Label.String = 'Power Loss (W)';
% grid on;
% 
% 
% 
