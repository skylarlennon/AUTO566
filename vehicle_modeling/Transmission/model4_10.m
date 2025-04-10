% 4-10 Transmission Params
clear all
close all

n_chain= 54; %number of teeth on chain ring (Update)
n_cassette= [14 16 18 21 24 28]; %number of teeth on cassette gears (% Shimano MF-TZ510-6-CP Multi-Speed Freewheel)
gear_ratios= n_cassette./n_chain; 
torque_ratios= 1./gear_ratios;

shifting= .95; %derailleur losses

%load motor

%sample data (Update to real)
motor_speed = linspace(0, 5000, 50); % RPM
motor_torque = linspace(0, 100, 50); % Nm
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
output_speed = zeros(length(motor_speed), num_gears);
output_torque = zeros(length(motor_torque), num_gears);

for g = 1:num_gears
    output_speed(:, g) = motor_speed / gear_ratios(g);
    output_torque(:, g) = motor_torque * gear_ratios(g);
end


transmission_efficiency = ones(num_gears, 1) * .97; %Baseline efficiency of motor to trans
transmission_efficiency = transmission_efficiency - (0:0.01:0.01*(num_gears-1))'; % Higher gears slightly less efficient

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





% function recommended_gear = recommend_gear_change(current_rpm, desired_rpm, motor_efficiency_map, motor_speed, motor_torque, gear_ratios, transmission_efficiency)
%     % Find the closest motor speeds in our model
%     [~, current_rpm_idx] = min(abs(motor_speed - current_rpm));
%     [~, desired_rpm_idx] = min(abs(motor_speed - desired_rpm));
% 
%     % Estimate the torque needed at desired RPM
%     % This is a simplification - in a real system, you'd use a motor model or lookup
%     estimated_torque_idx = round(length(motor_torque)/2); % Using middle torque as estimate
% 
%     % Get efficiencies for all gears at the desired operating point
%     gear_efficiencies = zeros(length(gear_ratios), 1);
%     for g = 1:length(gear_ratios)
%         gear_efficiencies(g) = motor_efficiency_map(estimated_torque_idx, desired_rpm_idx) * transmission_efficiency(g);
%     end
% 
%     % Find the most efficient gear
%     [~, best_gear] = max(gear_efficiencies);
% 
%     % Return the recommended gear
%     recommended_gear = best_gear;
% end