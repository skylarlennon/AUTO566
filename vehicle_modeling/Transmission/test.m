clear all
close all

%Sample Values (Update with real motor model)
motor_speed = linspace(0, 5000, 50); % RPM
motor_torque = linspace(0, 300, 50); % Nm
EfficiencyGrid = 0.9 - 0.1 * (motor_torque / max(motor_torque)) * (motor_speed / max(motor_speed)); % (Update with motor efficiency values)

% Plot efficiency map
figure;
contour(motor_speed, motor_torque, EfficiencyGrid, 100);
colorbar;
xlabel('Motor Speed (RPM)');
ylabel('Torque (Nm)');
title('Electric Motor Efficiency Map');

% Define vehicle parameters
C_d = 0.15; % Drag coefficient
A = 0.95; % Frontal area
rho = 1.16; % Air density
m_vehicle = 135; % Vehicle mass
C_rr = 0.0018; % Rolling resistance coeff
g = 9.81; % Gravitational constant (m/s²)
D_wheel = 2*.203 ; % Wheel diameter
R_f = 4.0; % Final drive ratio (Sample- UPDATE)

% Define gear ratios for each gear in the bike transmission (internal gear ratios for Rohloff SPEEDHUB 500/14)
gear_ratios = [0.279, 0.316, 0.360, 0.409, 0.464, 0.528, 0.600, 0.682, ...
                0.774, 0.881, 1.000, 1.135, 1.292, 1.467];


% Placeholder for shift maps (motor speed vs gear, vehicle speed vs gear)
% (Update Based on Motor Model)
shift_map_motor_speed = zeros(length(motor_speed), length(motor_torque));
shift_map_vehicle_speed = zeros(length(motor_speed), length(motor_torque));

% Iterate over each gear and calculate power consumption and vehicle speed
for g = 1:length(gear_ratios)
    for i = 1:length(motor_speed)
        for j = 1:length(motor_torque)
            
            P_motor_in = motor_speed(i) * motor_torque(j); % Power input to motor (W)
           
            omega_motor_rad_s = motor_speed(i) * 2 * pi / 60; % Convert RPM to rad/s
            v_vehicle = omega_motor_rad_s * D_wheel / R_f; % Vehicle speed in m/s

            %Opposing Forces assuming constant velocity
            F_roll = C_rr * m_vehicle * g; % Rolling resistance force (N)
            P_roll = F_roll * v_vehicle; % Power to overcome rolling resistance (W)
            F_aero = 0.5 * C_d * A * rho * v_vehicle^2; % Aerodynamic drag force (N)
            P_aero = F_aero * v_vehicle; % Power to overcome drag (W)
            P_total = P_roll + P_aero;

            % Adjust energy consumption by factoring in efficiency and total power
            energy_consumption = 1000 * (P_motor_in / P_total); % Adjusted energy consumption

            % Select gear based on motor efficiency (lowest energy consumption)
            if g == 1 || energy_consumption < shift_map_motor_speed(i,j)
                shift_map_motor_speed(i,j) = g;
            end

            % Select gear based on vehicle speed (minimize energy consumption)
            if g == 1 || v_vehicle < shift_map_vehicle_speed(i,j)
                shift_map_vehicle_speed(i,j) = g;
            end
        end
    end
end

% Plot the Shift Map based on Motor Speed vs Gear
figure;
contourf(SpeedGrid, TorqueGrid, shift_map_motor_speed, length(gear_ratios));
colorbar;
xlabel('Motor Speed (RPM)');
ylabel('Motor Torque (Nm)');
title('Shift Map (Motor Speed vs Gear)');

% Plot the Shift Map based on Vehicle Speed vs Gear
vehicle_speed_grid = (SpeedGrid * 2 * pi / 60) * D_wheel / R_f; % Convert motor speed to vehicle speed
figure;
contourf(vehicle_speed_grid, TorqueGrid, shift_map_vehicle_speed, length(gear_ratios));
colorbar;
xlabel('Vehicle Speed (m/s)');
ylabel('Motor Torque (Nm)');
title('Shift Map (Vehicle Speed vs Gear)');
