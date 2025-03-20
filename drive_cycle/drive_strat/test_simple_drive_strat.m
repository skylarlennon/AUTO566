%% simple_drive_strat.m
% Auto 566 Supermileage
% Author: Skylar Lennon (using ChatGPT & Claude AIs)

clc;clear;close all

%% Load Track Model 
track_file = "track_model.csv";
lap_length_mi = 9.76/4;
meters_per_mile = 1609.34;
lap_length = lap_length_mi*meters_per_mile; % meters
num_laps = 4;
stop_point = 1.18*meters_per_mile; %meters
stop_points = zeros(1, 2*num_laps-1);

%% Driving Strategy
total_race_time = 35; % minutes
accel_rate = 0.25; %m/s^2
decel_rate = 0.25; %m/s^2
max_speed = 15; % max vehicle speed (m/s)

% Generate stop points (1 stop per lap + finish line)
laps = 0;
for i = 1:length(stop_points)
    if mod(i,2) == 0 % Finish line stops
        stop_points(i) = lap_length * laps;
    else % Mid-race stops
        stop_points(i) = lap_length * laps + stop_point;
    end
    
    % Increment lap counter after each pair of stops
    if mod(i,2) == 1
        laps = laps + 1;
    end
end

% Calculate driving strategy (this now includes plotting)
SimpleDriveStrategy(track_file, lap_length, num_laps, stop_points, total_race_time, accel_rate, decel_rate, max_speed);

function drive_matrix = SimpleDriveStrategy(track_file, lap_length, num_laps, stop_points, total_race_time, accel_rate, decel_rate, max_speed)
    % Load track data
    track_data = readmatrix(track_file);
    x_dist = track_data(:,1);
    y_dist = track_data(:,2);
    elev = track_data(:,3);
    
    % Ensure unique and sorted x_dist
    [x_dist, unique_idx] = unique(x_dist, 'stable');
    y_dist = y_dist(unique_idx);
    elev = elev(unique_idx);
    
    % Define time step resolution
    num_time_steps = length(x_dist) * 10;
    time_vector = linspace(0, total_race_time * 60, num_time_steps)';
    
    % Compute total race distance
    total_distance = num_laps * lap_length;
    num_stops = length(stop_points);
    finish_line = total_distance;
    
    % Find the average velocity without considering accel & decel
    avg_velo = total_distance/(total_race_time*60);


    % Solve for steady-state velocity (Vs) using quadratic equation
    % Only count the intermediate stops (not start/finish) for acceleration/deceleration phases
    A = num_stops / (2 * accel_rate) + num_stops / (2 * decel_rate);
    
    % Add acceleration from start and deceleration to finish
    A = A + 1 / (2 * accel_rate) + 1 / (2 * decel_rate);
    
    B = -total_race_time * 60;
    C = total_distance;
    
    discriminant = B^2 - 4 * A * C;
    if discriminant < 0
        error('Acceleration and deceleration rates do not allow completion in the given time. Adjust parameters.');
    end
    
    Vs1 = (-B + sqrt(discriminant)) / (2 * A);
    Vs2 = (-B - sqrt(discriminant)) / (2 * A);

    % Take the positive solution that's less than max_speed
    if Vs1 > 0 && Vs1 <= max_speed
        Vs = Vs1;
    elseif Vs2 > 0 && Vs2 <= max_speed
        Vs = Vs2;
    elseif Vs1 > max_speed && Vs2 > 0
        Vs = Vs2; % Try to use the second solution if first exceeds max_speed
    else
        error('Cannot find valid steady-state velocity. Adjust parameters.');
    end
    
    % Check if steady-state speed exceeds max vehicle speed
    if Vs > max_speed
        warning('Calculated steady-state speed exceeds maximum vehicle speed. Using max speed instead.');
        Vs = max_speed;
    end
    
    % Compute acceleration and deceleration distances
    accel_dist = Vs^2 / (2 * accel_rate);
    decel_dist = Vs^2 / (2 * decel_rate);
    
    % Initialize arrays
    velocity = zeros(size(time_vector));
    position = zeros(size(time_vector));
    dt = time_vector(2) - time_vector(1); % Time step
    
    % Initial state: vehicle starts from rest
    velocity(1) = 0;
    position(1) = 0;
    
    % Initialize state tracking
    current_stop_idx = 1;
    state = 'accelerating'; % Initial state is accelerating from start
    
    % Main simulation loop
    for i = 2:length(time_vector)
        % Current position
        current_pos = position(i-1);
        
        % Distance to next stop (if there is one)
        if current_stop_idx <= num_stops
            dist_to_stop = stop_points(current_stop_idx) - current_pos;
        else
            dist_to_stop = Inf; % No more stops
        end
        
        % Distance to finish line
        dist_to_finish = finish_line - current_pos;
        
        % State transition logic
        switch state
            case 'accelerating'
                % Accelerate until reaching steady state
                velocity(i) = min(Vs, velocity(i-1) + accel_rate * dt);
                
                % If we've reached steady state, transition
                if abs(velocity(i) - Vs) < 1e-3
                    state = 'steady';
                end
                
            case 'steady'
                % Maintain steady state speed
                velocity(i) = Vs;
                
                % Check if we're approaching a stop point
                if dist_to_stop <= decel_dist && current_stop_idx <= num_stops
                    state = 'decelerating_to_stop';
                % Check if we're approaching the finish line
                elseif dist_to_finish <= decel_dist
                    state = 'decelerating_to_finish';
                end
                
            case 'decelerating_to_stop'
                % Decelerate until stopped
                velocity(i) = max(0, velocity(i-1) - decel_rate * dt);
                
                % Check if we've reached the stop point or stopped
                if velocity(i) < 1e-3 || (dist_to_stop < 0 && abs(dist_to_stop) < 1e-1)
                    velocity(i) = 0; % Ensure full stop
                    
                    % Move to next stop point
                    current_stop_idx = current_stop_idx + 1;
                    state = 'accelerating';
                end
                
            case 'decelerating_to_finish'
                % Decelerate to finish line
                velocity(i) = max(0, velocity(i-1) - decel_rate * dt);
                
                % Check if we've reached the finish line or stopped
                if velocity(i) < 1e-3 || (dist_to_finish < 0 && abs(dist_to_finish) < 1e-1)
                    velocity(i) = 0; % Ensure stop at finish
                    state = 'finished';
                end
                
            case 'finished'
                % Race complete
                velocity(i) = 0;
        end
        
        % Update position
        position(i) = position(i-1) + velocity(i) * dt;
    end
    
    % Interpolate track data
    % Handle potential out-of-bounds issues with position exceeding x_dist range
    max_x_dist = max(x_dist);
    valid_positions = position <= max_x_dist;
    
    % Use valid positions for interpolation
    y_interp = NaN(size(position));
    elev_interp = NaN(size(position));
    
    y_interp(valid_positions) = interp1(x_dist, y_dist, position(valid_positions), 'linear');
    elev_interp(valid_positions) = interp1(x_dist, elev, position(valid_positions), 'linear');
    
    % Extrapolate for positions beyond track data
    remaining_positions = ~valid_positions & isfinite(position);
    if any(remaining_positions)
        % Extrapolate using last available point or some logical extension
        y_interp(remaining_positions) = y_dist(end);
        elev_interp(remaining_positions) = elev(end);
    end
    
    % Combine into output matrix
    drive_matrix = [position, y_interp, elev_interp, velocity, time_vector];
    
    % Save to CSV
    writematrix(drive_matrix, 'drive_strategy.csv');
    
    % Plot the results
    figure;
    
    % Plot velocity and elevation vs. distance
    subplot(2,1,1);
    yyaxis left;
    plot(position, velocity, 'b-', 'LineWidth', 2);
    ylabel('Velocity (m/s)');
    ylim([0, max(velocity)*1.1]);
    
    yyaxis right;
    plot(position, elev_interp, 'r-', 'LineWidth', 1.5);
    ylabel('Elevation (m)');
    
    xlabel('Distance (m)');
    title('Velocity and Elevation vs. Distance');
    grid on;
    
    % Add markers for stop points
    hold on;
    yyaxis left;
    for j = 1:num_stops
        xline(stop_points(j), '--k');
        text(stop_points(j), 0, ['Stop ' num2str(j)], 'VerticalAlignment', 'bottom');
    end
    xline(finish_line, '--k');
    text(finish_line, 0, 'Finish', 'VerticalAlignment', 'bottom');
    hold off;
    
    % Plot velocity and elevation vs. time
    subplot(2,1,2);
    yyaxis left;
    plot(time_vector, velocity, 'b-', 'LineWidth', 2);
    ylabel('Velocity (m/s)');
    ylim([0, max(velocity)*1.1]);
    
    yyaxis right;
    plot(time_vector, elev_interp, 'r-', 'LineWidth', 1.5);
    ylabel('Elevation (m)');
    
    xlabel('Time (s)');
    title('Velocity and Elevation vs. Time');
    grid on;
    
    % Add markers for stop times
    hold on;
    yyaxis left;
    for j = 1:num_stops
        % Find time when position is closest to stop point
        [~, stop_time_idx] = min(abs(position - stop_points(j)));
        if ~isempty(stop_time_idx) && stop_time_idx > 0
            xline(time_vector(stop_time_idx), '--k');
            text(time_vector(stop_time_idx), 0, ['Stop ' num2str(j)], 'VerticalAlignment', 'bottom');
        end
    end
    
    % Find time when position is closest to finish line
    [~, finish_time_idx] = min(abs(position - finish_line));
    if ~isempty(finish_time_idx) && finish_time_idx > 0
        xline(time_vector(finish_time_idx), '--k');
        text(time_vector(finish_time_idx), 0, 'Finish', 'VerticalAlignment', 'bottom');
    end
    hold off;
    
    % Print simulation summary
    fprintf('Simulation Summary:\n');
    fprintf('- Steady state speed: %.2f m/s = %.2f km/h = %.2f mph \n', Vs, Vs*3.6, Vs*2.23694);
    fprintf('- Average Speed: %.2f m/s = %.2f km/h = %.2f mph \n', avg_velo,avg_velo*3.6,avg_velo*2.23694);
    fprintf('- Acceleration distance: %.2f m\n', accel_dist);
    fprintf('- Deceleration distance: %.2f m\n', decel_dist);
    fprintf('- Total race distance: %.2f m\n', total_distance);
    fprintf('- Total race time: %.2f minutes\n', time_vector(end)/60);
end