%% simple_drive_strat.m
% Auto 566 Supermileage
% Author: Skylar Lennon (using ChatGPT & Claude AIs)
clc;clear;close all

%% === Define All Track Configurations ===
track_configs = [
    struct( ...
        'name', "Detroit Streets", ...
        'file', ["csv/flat_projected/Detroit_flat_projected.csv", ...
                 "csv/elev_projected/Detroit_elev_projected.csv"], ...
        'num_laps', 4, ...
        'stop_point', 1947 ...
    );
    struct( ...
        'name', "Indianapolis Motor Speedway", ...
        'file', ["csv/flat_projected/Indy_flat_projected.csv", ...
                 "csv/elev_projected/Indy_elev_projected.csv"], ...
        'num_laps', 4, ...
        'stop_point', 1867 ...
    );
    struct( ...
        'name', "Sonoma Raceway", ...
        'file', ["csv/flat_projected/Sonoma_flat_projected.csv", ...
                 "csv/elev_projected/Sonoma_elev_projected.csv"], ...
        'num_laps', 10, ...
        'stop_point', 395 ...
    );
    struct( ...
        'name', "Test", ...
        'file', ["csv/flat_projected/Test_flat_projected.csv", ...
                 "csv/elev_projected/Test_elev_projected.csv"], ...
        'num_laps', 10, ...
        'stop_point', 395 ...
    )
];

%% === Select Track ===
track_number = 3;   % 1 = Detroit Streets
                    % 2 = Indianapolis Motor Speedway
                    % 3 = Sonoma Raceway
                    % 4 = Test
track_type = 2;     % 1 = Flat Projection
                    % 2 = Elevated Projection

%% === Auto-load settings ===
selected_track = track_configs(track_number);
track_file = selected_track.file(track_type);

% Validate track file
if exist(track_file, 'file') ~= 2
    error("Track file does not exist")
end
track_data = readmatrix(track_file);

num_laps = selected_track.num_laps;
stop_point = selected_track.stop_point;
lap_length = track_data(end,1);         % Assumes track data gives single lap
stop_points = generate_stop_points(2*num_laps-1,lap_length,stop_point);

%% Define Driving Strategy
total_race_time = 35; % [minutes]           % [Edit based on track]
accel_rate = 0.4; % [m/s^2]                % [Edit based on track]
decel_rate = 0.25; % [m/s^2]                % [Edit based on track]
max_speed = 15; % [m/s]                     % [Edit based on vehicle]           

% Calculate driving strategy (this now includes plotting)
SimpleDriveStrategy(track_file, lap_length, num_laps, stop_points, total_race_time, accel_rate, decel_rate, max_speed);

function drive_matrix = SimpleDriveStrategy(track_file, lap_length, num_laps, stop_points, total_race_time, accel_rate, decel_rate, max_speed)
    % Load track data
    track_data = readmatrix(track_file);
    x_dist = track_data(:,1);
    y_dist = track_data(:,2);
    elev = track_data(:,3);
    
    n_points = length(track_data(:,1));
    x_dist_full = zeros(n_points * num_laps, 1);
    y_dist_full = zeros(n_points * num_laps, 1);
    elev_full = zeros(n_points * num_laps, 1);
    
    % Duplicate track data num_laps times
    for i = 0:(num_laps-1)
        idx = (1:n_points) + i * n_points;
        x_dist_full(idx) = x_dist + i * lap_length;
        y_dist_full(idx) = y_dist;
        elev_full(idx) = elev;
    end

    % Ensure unique and sorted x_dist
    [x_dist_full, unique_idx] = unique(x_dist_full, 'stable');
    y_dist_full = y_dist_full(unique_idx);
    elev_full = elev_full(unique_idx);

    % Define time step resolution
    num_time_steps = length(x_dist_full) * 10;
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
    max_x_dist = max(x_dist_full);
    valid_positions = position <= max_x_dist;

    % Use valid positions for interpolation
    y_interp = NaN(size(position));
    elev_interp = NaN(size(position));

    y_interp(valid_positions) = interp1(x_dist_full, y_dist_full, position(valid_positions), 'linear');
    elev_interp(valid_positions) = interp1(x_dist_full, elev_full, position(valid_positions), 'linear');

    % Extrapolate for positions beyond track data
    remaining_positions = ~valid_positions & isfinite(position);
    if any(remaining_positions)
        % Extrapolate using last available point or some logical extension
        y_interp(remaining_positions) = y_dist_full(end);
        elev_interp(remaining_positions) = elev_full(end);
    end

    % Combine into output matrix
    drive_matrix = [position, y_interp, elev_interp, velocity, time_vector];

    % Save CSV local
    writematrix(drive_matrix, 'csv/drive_strategy.csv');

    % Save CSV for vehicle model
    writematrix(drive_matrix, '../../vehicle_modeling/drive_strategy.csv');

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

function stop_points = generate_stop_points(sizeStopPoints,lap_length,stop_point)
    stop_points = zeros(1,sizeStopPoints);
    laps = 0;
    for i = 1:sizeStopPoints
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
end