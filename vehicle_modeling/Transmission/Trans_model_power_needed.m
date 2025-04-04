%% Bike Transmission Shift Map Based on Motor Power with 95% Efficiency
% Define Parameters
clear; clc;

% Gear ratios (example values, modify as needed)
gear_ratios = [0.279, 0.316, 0.360, 0.409, 0.464, 0.528, 0.600, 0.682, ...
               0.774, 0.881, 1.000, 1.135, 1.292, 1.467];
num_gears = length(gear_ratios);

% Physical parameters
m = 135; % Mass (kg)
CdA = 0.15 * 0.95; % Drag coefficient * area (m^2)
Crr = 0.0018; % Rolling resistance coefficient
g = 9.81; % Gravity (m/s^2)
r_wheel = 0.203; % Wheel radius (m)
rho_air = 1.16; % Air density (kg/m^3)
eta = 0.95; % Gear efficiency (95%)

% Define motor power curve (example, modify as needed)
P_motor = @(speed) 71.733 * ones(size(speed)); % Constant power output from motor (W)

% Speed range (m/s)
speed_min = 2;
speed_max = 15;
speed_vals = linspace(speed_min, speed_max, 100);

% Define shift map
shift_map = zeros(size(speed_vals));

for i = 1:length(speed_vals)
    speed = speed_vals(i);
    P = P_motor(speed); % Get power from motor
    best_gear = 1;
    min_diff = inf;
    
    for g = 1:num_gears
        % Calculate expected power in each gear with efficiency loss
        wheel_speed = speed / r_wheel;
        motor_speed = wheel_speed / gear_ratios(g);
        power_estimate = P_motor(motor_speed) * eta; % Apply 95% efficiency
        
        % Find the gear that minimizes power deviation
        diff = abs(power_estimate - P);
        if diff < min_diff
            min_diff = diff;
            best_gear = g;
        end
    end
    
    shift_map(i) = best_gear;
end

% Plot Shift Map
figure;
plot(speed_vals, shift_map, 'LineWidth', 2);
xlabel('Speed (m/s)');
ylabel('Optimal Gear');
title('Shift Map Based on Motor Power with 95% Efficiency');
grid on;