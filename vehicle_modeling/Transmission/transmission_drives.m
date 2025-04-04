clear all

% Hub drive efficiency
gear_ratios = [.279, .316, .360, .409, .464, .528, .6, .682, .774, .881, 1, 1.135, 1.292, 1.467]; % Hub gear ratios
efficiencies = .945 % Rohloff 14 speed hub
wheel_radius = 0.203; % in meters
final_drive_ratio = 4; % Final drive gear ratio
rpm_range = 0:500:10000; % Motor RPM

% Compute Vehicle Speed for Each Gear
num_gears = length(gear_ratios);
speed_matrix = zeros(num_gears, length(rpm_range));

for g = 1:num_gears
    speed_matrix(g, :) = (rpm_range * wheel_radius * 2 * pi) ./ ...
                         (gear_ratios(g) * final_drive_ratio * 60);
end

% Determine Optimal Gear at Each Speed
[~, optimal_gear_indices] = max(efficiencies .* (speed_matrix > 0), [], 1);
optimal_gears = gear_ratios(optimal_gear_indices); % Get the corresponding gear ratio

% Plot Results
figure; hold on;
for g = 1:num_gears
    plot(speed_matrix(g, :), g * ones(size(rpm_range)), 'LineWidth', 2);
end
scatter(speed_matrix(optimal_gear_indices, :), optimal_gear_indices, 50, 'r', 'filled');

xlabel('Vehicle Speed (m/s)');
ylabel('Gear Number');
title('Optimal Gear Selection vs. Vehicle Speed');
legend(arrayfun(@(g) sprintf('Gear %d', g), 1:num_gears, 'UniformOutput', false));
grid on;
hold off;
