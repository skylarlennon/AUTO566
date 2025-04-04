clear all

% Define Parameters
gear_ratios = [.279, .316, .360, .409, .464, .528, .6, .682, .774, .881, 1, 1.135, 1.292, 1.467]; % Gear ratios
wheel_radius = 0.203; % in meters
final_drive_ratio = 3.9; % Final drive ratio
motor_rpm_range = 0:100:12000; % Electric motor speed range in RPM
max_motor_rpm = 12000; % Maximum motor speed

% Compute Vehicle Speed for Each Gear
num_gears = length(gear_ratios);
speed_matrix = zeros(num_gears, length(motor_rpm_range));

for g = 1:num_gears
    speed_matrix(g, :) = (motor_rpm_range * wheel_radius * 2 * pi) ./ ...
                         (gear_ratios(g) * final_drive_ratio * 60);
end

% Find the highest possible gear at each speed while staying within RPM limits
max_speed = max(speed_matrix(:));
speed_range = linspace(0, max_speed, 200); % Speed values to analyze
optimal_gear = zeros(size(speed_range));

for i = 1:length(speed_range)
    speed = speed_range(i);
    
    % Find valid gears that allow the speed without exceeding max motor RPM
    valid_gears = find(speed <= speed_matrix(:, end));
    
    if isempty(valid_gears)
        optimal_gear(i) = NaN; % No valid gear
    else
        optimal_gear(i) = max(valid_gears); % Highest possible gear
    end
end

% Plot Results
figure; hold on;
for g = 1:num_gears
    plot(speed_matrix(g, :), g * ones(size(motor_rpm_range)), 'LineWidth', 2);
end
scatter(speed_range, optimal_gear, 50, 'r', 'filled');

xlabel('Vehicle Speed (m/s)');
ylabel('Gear Number');
title('Optimal Gear Selection for Electric Motor');
legend(arrayfun(@(g) sprintf('Gear %d', g), 1:num_gears, 'UniformOutput', false));
grid on;
hold off;
