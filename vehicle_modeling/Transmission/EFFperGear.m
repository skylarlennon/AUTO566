clear all
close all

% Sample Values (Update with real motor model)
motor_speed = linspace(0, 5000, 50); % RPM
motor_torque = linspace(0, 300, 50); % Nm
[SpeedGrid, TorqueGrid] = meshgrid(motor_speed, motor_torque);
EfficiencyGrid = 0.9 - 0.1 * (TorqueGrid / max(motor_torque)) .* (SpeedGrid / max(motor_speed)); % (Update with motor efficiency values)

% % Plot efficiency map
% figure;
% contourf(SpeedGrid, TorqueGrid, EfficiencyGrid, 100);
% colorbar;
% xlabel('Motor Speed (RPM)');
% ylabel('Torque (Nm)');
% title('Electric Motor Efficiency Map');

% Define vehicle parameters
C_d = 0.15; % Drag coefficient
A = 0.95; % Frontal area (m²)
rho = 1.16; % Air density (kg/m³)
m_vehicle = 135; % Vehicle mass (kg)
C_rr = 0.0018; % Rolling resistance coefficient
g = 9.81; % Gravitational constant (m/s²)
D_wheel = 2 * 0.203; % Wheel diameter (m)
R_f = 4.0; % Final drive ratio

% Gear ratios (internal gear ratios for Rohloff SPEEDHUB 500/14)
% gear_ratios = [0.279, 0.316, 0.360, 0.409, 0.464, 0.528, 0.600, 0.682, ...
%                 0.774, 0.881, 1.000, 1.135, 1.292, 1.467]; 

gear_ratios= [.25, .5, .75, 1, 1.25, 1.5]; % (Update)

% Initialize efficiency map for each gear
efficiency_per_gear = zeros(length(motor_speed), length(motor_torque), length(gear_ratios));

% power consumption and efficiency for each combination of motor speed and torque
for g = 1:length(gear_ratios)
    for i = 1:length(motor_speed)
        for j = 1:length(motor_torque)
            
            P_motor_in = motor_speed(i) * motor_torque(j); % Power input to motor (W)
            
            omega_motor_rad_s = motor_speed(i) * 2 * pi / 60; % Convert RPM to rad/s
            v_vehicle = omega_motor_rad_s * D_wheel / R_f; % Vehicle speed in m/s

            % Opposing Forces assuming constant velocity
            F_roll = C_rr * m_vehicle * g; % Rolling resistance force (N)
            P_roll = F_roll * v_vehicle; % Power to overcome rolling resistance (W)
            F_aero = 0.5 * C_d * A * rho * v_vehicle^2; % Aerodynamic drag force (N)
            P_aero = F_aero * v_vehicle; % Power to overcome drag (W)
            P_total = P_roll + P_aero;

            % Calculate efficiency
            efficiency = 0.95 - 0.1 * (motor_torque(j) / max(motor_torque)) * (motor_speed(i) / max(motor_speed)); %(UPDATE)

            % Store the efficiency for the current gear
            efficiency_per_gear(i, j, g) = efficiency * (P_motor_in / P_total); % Adjusting by total power
        end
    end
end

%Line
figure;
hold on

% Define labels for legend
gear_labels = cell(1, 6);
num_gears = size(efficiency_per_gear, 3);
mid_torque_idx = round(length(motor_torque)/2);

% Plot each gear efficiency in a loop
for gear = 1:num_gears
    plot(motor_speed, efficiency_per_gear(:, mid_torque_idx, gear), 'DisplayName', ['Gear ' num2str(gear)]);
    gear_labels{gear} = ['Gear ' num2str(gear)];
end

xlabel('Motor Speed (RPM)');
ylabel('Efficiency');
title('Efficiency vs Motor Speed at Mid Torque');
legend('show', 'Location', 'best');
grid on; % Adds grid lines for better readability
hold off



% Plot Efficiency for each gear Contour
% figure;
% hold on;
% for g = 1:length(gear_ratios)
%     contourf(SpeedGrid, TorqueGrid, efficiency_per_gear(:,:,g), 100, 'DisplayName', sprintf('Gear %d', g));
% end
% hold off;
% 
% colorbar;
% xlabel('Motor Speed (RPM)');
% ylabel('Motor Torque (Nm)');
% title('Efficiency Map for Each Gear');
% legend('show');


%Surface
% figure;
% surf(SpeedGrid, TorqueGrid, efficiency_per_gear(:,:,1)); % Surface plot for Gear 1
% xlabel('Motor Speed (RPM)');
% ylabel('Motor Torque (Nm)');
% zlabel('Efficiency');
% title('Surface Plot of Gear 1 Efficiency');
% 
% HeatMap
% figure;
% imagesc(SpeedGrid(1,:), TorqueGrid(:,1), efficiency_per_gear(:,:,1));
% colorbar;
% xlabel('Motor Speed (RPM)');
% ylabel('Motor Torque (Nm)');
% title('Heatmap of Gear 1 Efficiency');


% %Scatter
% figure;
% scatter3(SpeedGrid(:), TorqueGrid(:), efficiency_per_gear(:,:,1)(:), 20, efficiency_per_gear(:,:,1)(:), 'filled');
% colorbar;
% xlabel('Motor Speed (RPM)');
% ylabel('Motor Torque (Nm)');
% zlabel('Efficiency');
% title('3D Scatter Plot of Gear 1 Efficiency');



