% Refined transmission efficiency model incorporating both speed and torque dependencies
function efficiency_per_gear = calculateEfficiency(motor_speed, motor_torque, gear_ratios, motor_efficiency_map)
    % Initialize variables
    num_gears = length(gear_ratios);
    efficiency_per_gear = zeros(length(motor_speed), length(motor_torque), num_gears);
    
    % Calculate wheel parameters for each gear
    wheel_speed = zeros(length(motor_speed), num_gears);
    wheel_torque = zeros(length(motor_torque), num_gears);
    
    for g = 1:num_gears
        for s = 1:length(motor_speed)
            wheel_speed(s, g) = motor_speed(s) / gear_ratios(g);
        end
        
        for t = 1:length(motor_torque)
            wheel_torque(t, g) = motor_torque(t) * gear_ratios(g);
        end
    end
    
    % Define transmission efficiency parameters
    % These should be adjusted based on actual transmission characteristics
    base_efficiencies = [0.97, 0.965, 0.96, 0.955, 0.95, 0.945]; % Base efficiency for each gear
    
    % Speed ranges for efficiency calculations (in wheel RPM)
    optimal_speed_min = 15; % Below this speed, efficiency drops
    optimal_speed_max = 80; % Above this speed, efficiency drops
    
    % Torque ranges for efficiency calculations (in wheel Nm)
    optimal_torque_min = 10; % Below this torque, efficiency drops
    optimal_torque_max = 150; % Above this torque, efficiency drops
    
    % Calculate transmission efficiency for each operating point
    for g = 1:num_gears
        base_efficiency = base_efficiencies(min(g, length(base_efficiencies)));
        
        for s = 1:length(motor_speed)
            current_wheel_speed = wheel_speed(s, g);
            
            % Speed-dependent efficiency factor
            if current_wheel_speed < optimal_speed_min
                % Efficiency drops at low speeds (e.g., more friction relative to power)
                speed_factor = 0.75 + 0.25 * (current_wheel_speed / optimal_speed_min);
            elseif current_wheel_speed > optimal_speed_max
                % Efficiency drops at high speeds (e.g., windage losses, bearing friction)
                excess_speed_ratio = (current_wheel_speed - optimal_speed_max) / optimal_speed_max;
                speed_factor = 1.0 - 0.15 * min(1, excess_speed_ratio);
            else
                % Optimal speed range
                speed_factor = 1.0;
            end
            
            for t = 1:length(motor_torque)
                current_wheel_torque = wheel_torque(t, g);
                
                % Torque-dependent efficiency factor
                if current_wheel_torque < optimal_torque_min
                    % Efficiency drops at very low torque (e.g., overcome static friction)
                    torque_factor = 0.85 + 0.15 * (current_wheel_torque / optimal_torque_min);
                elseif current_wheel_torque > optimal_torque_max
                    % Efficiency drops at very high torque (e.g., chain/gear deformation)
                    excess_torque_ratio = (current_wheel_torque - optimal_torque_max) / optimal_torque_max;
                    torque_factor = 1.0 - 0.2 * min(1, excess_torque_ratio^1.5);
                else
                    % Optimal torque range
                    torque_factor = 1.0;
                end
                
                % Gear-specific factors
                gear_specific_factor = 1.0;
                
                % First gear often has more complex path/additional idlers
                if g == 1
                    gear_specific_factor = 0.98;
                end
                
                % Higher gears may have more chain crossover
                if g >= num_gears - 1
                    gear_specific_factor = 0.99;
                end
                
                % Combined transmission efficiency
                trans_efficiency = base_efficiency * speed_factor * torque_factor * gear_specific_factor;
                
                % Get motor efficiency for this operating point
                motor_eff = motor_efficiency_map(t, s);
                
                % Total efficiency = motor efficiency * transmission efficiency
                efficiency_per_gear(s, t, g) = motor_eff * trans_efficiency;
            end
        end
    end
end

% Example of how to use this function in your main script:
% --------------------------------------------------------------------
% Main script (you would incorporate this into your existing code)
% --------------------------------------------------------------------

% Create or load your motor data
motor_speed = linspace(0, 5000, 50); % RPM
motor_torque = linspace(0, 100, 50); % Nm
gear_ratios = [3.5, 2.8, 2.0, 1.5, 1.2, 1.0]; % Example gear ratios

% Create or load motor efficiency map (example)
[X, Y] = meshgrid(motor_speed, motor_torque);
motor_efficiency_map = 0.75 + 0.2 * exp(-((X-2500).^2/1e6 + (Y-50).^2/500));
motor_efficiency_map(X < 500 | X > 4500 | Y < 10 | Y > 90) = ...
    motor_efficiency_map(X < 500 | X > 4500 | Y < 10 | Y > 90) * 0.7;

% Calculate efficiency for all operating points using the refined model
efficiency_per_gear = calculateEfficiency(motor_speed, motor_torque, gear_ratios, motor_efficiency_map);

% Find optimal gear for each speed-torque combination
[max_efficiency, optimal_gear] = max(efficiency_per_gear, [], 3);

% Visualize results
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

% Visualize efficiency for each gear
figure;
hold on;
mid_torque_idx = round(length(motor_torque)/2);
for g = 1:length(gear_ratios)
    plot(motor_speed, efficiency_per_gear(:, mid_torque_idx, g), 'LineWidth', 1.5, 'DisplayName', ['Gear ' num2str(g)]);
end
xlabel('Motor Speed (RPM)');
ylabel('Efficiency');
title(['Efficiency vs Motor Speed at ' num2str(motor_torque(mid_torque_idx)) ' Nm']);
legend('show', 'Location', 'best');
grid on;
hold off;

% Gear boundaries and max efficiency contour
figure;
contourf(X, Y, max_efficiency');
colormap(jet);
colorbar;
title('Maximum Efficiency Map');
xlabel('Motor Speed (RPM)');
ylabel('Motor Torque (Nm)');
hold on;
[C, h] = contour(X, Y, optimal_gear', 1:length(gear_ratios), 'k', 'LineWidth', 1.5);
clabel(C, h, 'FontWeight', 'bold');
hold off;