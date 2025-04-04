% Parameters
% motor_speed - Vector of motor speeds (RPM)
% motor_torque - Vector of motor torques (Nm)
% gear_ratios - Vector of gear ratios for each gear
% motor_efficiency_map - 2D array of motor efficiency values (rows=speed, cols=torque)

% Create sample data if not available
if ~exist('motor_speed', 'var')
    motor_speed = linspace(0, 5000, 50); % RPM
end
if ~exist('motor_torque', 'var')
    motor_torque = linspace(0, 100, 50); % Nm
end
if ~exist('gear_ratios', 'var')
    gear_ratios = [3.5, 2.8, 2.0, 1.5, 1.2, 1.0]; % Example gear ratios
end

% Create or load motor efficiency map
if ~exist('motor_efficiency_map', 'var')
    % Sample efficiency map (normally from motor datasheet)
    [X, Y] = meshgrid(motor_speed, motor_torque);
    motor_efficiency_map = 0.75 + 0.2 * exp(-((X-2500).^2/1e6 + (Y-50).^2/500));
    % Efficiency drops at extremes of operation range
    motor_efficiency_map(X < 500 | X > 4500 | Y < 10 | Y > 90) = ...
        motor_efficiency_map(X < 500 | X > 4500 | Y < 10 | Y > 90) * 0.7;
end

% Calculate wheel speed and torque for each gear
num_gears = length(gear_ratios);
wheel_speed = zeros(length(motor_speed), num_gears);
wheel_torque = zeros(length(motor_torque), num_gears);

for g = 1:num_gears
    wheel_speed(:, g) = motor_speed / gear_ratios(g);
    wheel_torque(:, g) = motor_torque * gear_ratios(g);
end

% Calculate transmission efficiency for each gear
% In a real system, you'd include mechanical losses that vary by gear
transmission_efficiency = ones(num_gears, 1) * 0.95;
transmission_efficiency = transmission_efficiency - (0:0.01:0.01*(num_gears-1))'; % Higher gears slightly less efficient

% Calculate total efficiency map for each motor speed, torque, and gear combination
efficiency_per_gear = zeros(length(motor_speed), length(motor_torque), num_gears);

for g = 1:num_gears
    for s = 1:length(motor_speed)
        for t = 1:length(motor_torque)
            % Total efficiency = motor efficiency * transmission efficiency
            efficiency_per_gear(s, t, g) = motor_efficiency_map(t, s) * transmission_efficiency(g);
        end
    end
end

% Find optimal gear for each speed-torque combination
[max_efficiency, optimal_gear] = max(efficiency_per_gear, [], 3);

% Function to get optimal gear for a specific motor speed and torque
function gear = getOptimalGear(speed, torque, motor_speed, motor_torque, optimal_gear)
    % Find closest speed and torque indices
    [~, speed_idx] = min(abs(motor_speed - speed));
    [~, torque_idx] = min(abs(motor_torque - torque));
    
    % Get optimal gear
    gear = optimal_gear(speed_idx, torque_idx);
end

% Visualize gear selection map
figure;
[X, Y] = meshgrid(motor_speed, motor_torque);
surf(X, Y, optimal_gear');
title('Optimal Gear Selection Map');
xlabel('Motor Speed (RPM)');
ylabel('Motor Torque (Nm)');
zlabel('Optimal Gear');
colormap(jet);
colorbar;
view(2); % 2D view

% Plot efficiency map for each gear at mid torque
figure;
hold on;
mid_torque_idx = round(length(motor_torque)/2);
for g = 1:num_gears
    plot(motor_speed, efficiency_per_gear(:, mid_torque_idx, g), 'LineWidth', 1.5, 'DisplayName', ['Gear ' num2str(g)]);
end
xlabel('Motor Speed (RPM)');
ylabel('Efficiency');
title(['Efficiency vs Motor Speed at ' num2str(motor_torque(mid_torque_idx)) ' Nm']);
legend('show', 'Location', 'best');
grid on;
hold off;

% Example usage: Find optimal gear for specific operating point
example_speed = 2000; % RPM
example_torque = 40; % Nm
optimal_gear_example = getOptimalGear(example_speed, example_torque, motor_speed, motor_torque, optimal_gear);
disp(['Optimal gear at ' num2str(example_speed) ' RPM and ' num2str(example_torque) ' Nm: Gear ' num2str(optimal_gear_example)]);

% Plot contour of maximum efficiency
figure;
contourf(X, Y, max_efficiency');
colormap(jet);
colorbar;
title('Maximum Efficiency Map');
xlabel('Motor Speed (RPM)');
ylabel('Motor Torque (Nm)');
hold on;
[C, h] = contour(X, Y, optimal_gear', 1:num_gears, 'k', 'LineWidth', 1.5);
clabel(C, h, 'FontWeight', 'bold');
hold off;