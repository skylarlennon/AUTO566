clear all;
close all;

% Sample motor parameters (update with real motor data)
motor_speed = linspace(500, 5000, 50); % RPM (lower motor speed range for better clarity)
motor_torque = linspace(5, 300, 50); % Nm (adjust torque range)

[SpeedGrid, TorqueGrid] = meshgrid(motor_speed, motor_torque);
EfficiencyGrid = 0.9 - 0.1 * (TorqueGrid / max(motor_torque)) .* (SpeedGrid / max(motor_speed)); % Update with motor efficiency data

% Define vehicle parameters
C_d = 0.15; % Drag coefficient
A = 0.95; % Frontal area (m²)
rho = 1.16; % Air density (kg/m³)
m_vehicle = 135; % Vehicle mass (kg)
C_rr = 0.0018; % Rolling resistance coefficient
grav = 9.81; % Gravitational constant (m/s²)
D_wheel = 2 * 0.203; % Wheel diameter (m)
R_f = 4.0; % Final drive ratio

% Define gear ratios for the bike transmission
gear_ratios = [0.279, 0.316, 0.360, 0.409, 0.464, 0.528, 0.600, 0.682, ...
                0.774, 0.881, 1.000, 1.135, 1.292, 1.467]; % Gear ratios

% Initialize arrays for vehicle speed and efficiency
vehicle_speed = zeros(length(motor_speed), length(motor_torque)); % Initialize vehicle speed array
efficiency_per_gear = zeros(length(motor_speed), length(motor_torque), length(gear_ratios)); % Store efficiencies for each gear

% Loop over each gear to calculate efficiency
for g = 1:length(gear_ratios)
    for i = 1:length(motor_speed)
        for j = 1:length(motor_torque)
            
            % Calculate motor power input (W)
            P_motor_in = motor_speed(i) * motor_torque(j); 
            
            % Convert motor speed to vehicle speed (m/s)
            omega_motor_rad_s = motor_speed(i) * 2 * pi / 60; % Convert RPM to rad/s
            vehicle_speed(i,j) = omega_motor_rad_s * D_wheel / R_f; % Vehicle speed in m/s

            % Calculate efficiency (this is a placeholder; update with real data)
            efficiency = 0.9 - 0.1 * (motor_torque(j) / max(motor_torque)) * (motor_speed(i) / max(motor_speed)); 

            % Adjust efficiency based on power consumption and opposing forces
            P_total = C_rr * m_vehicle * grav + 0.5 * C_d * A * rho * vehicle_speed(i,j)^2; % Total power to overcome forces
            efficiency_per_gear(i,j,g) = efficiency * (P_motor_in / P_total); % Store efficiency for this gear
        end
    end
end

% Plot Efficiency vs Vehicle Speed for each gear
figure;
hold on;

% Loop through each gear and plot the efficiency as a function of vehicle speed
for g = 1:length(gear_ratios)
    % Extract the vehicle speeds and average efficiency for each gear
    gear_vehicle_speeds = squeeze(mean(vehicle_speed(:,:,1), 2)); % Use average vehicle speed over all motor torques
    gear_efficiency = squeeze(mean(efficiency_per_gear(:,:,g), 2)); % Average efficiency for each gear

    % Plot efficiency vs vehicle speed for the current gear
    plot(gear_vehicle_speeds, gear_efficiency, 'DisplayName', sprintf('Gear %d', g));
end

hold off;

xlabel('Vehicle Speed (m/s)');
ylabel('Efficiency');
title('Efficiency vs Vehicle Speed for Each Gear');
legend('show');
