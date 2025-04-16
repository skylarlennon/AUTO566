%% PnG_Simple.m (only for flat tracks)
% Auto 566 Supermileage
% Author: Skylar Lennon (using ChatGPT)
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
        'num_laps', 9, ...
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
track_number = 2;   % 1 = Detroit Streets
                    % 2 = Indianapolis Motor Speedway
                    % 3 = Sonoma Raceway
                    % 4 = Test
track_type = 2;     % 1 = Flat Projection
                    % 2 = Elev Projection

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
accel_from_stop_rate = 0.4; % [m/s^2]       % [Edit based on track]
decel_to_stop_rate = 0.5; % [m/s^2]        % [Edit based on track]
pulse_accel_rate = 0.4; % [m/s^2]           % [Edit based on track]
deltaV = 2; % [m/s]                         % [Edit based on track]
maxVelocity = 15; % [m/s]                   % [Edit based on vehicle] 

%% === Load Vehicle Parameters ===
run("../../vehicle_modeling/ConstantsVehicleBody.m");
run("../../vehicle_modeling/ConstantsTransmission.m");
run("../../vehicle_modeling/ConstantsEnvironment.m");

road_load_fn = @(v) (Crr * massVeh * gravity + 0.5 * rho * Cd * Af * v.^2) / massVeh;

drive_matrix = PulseAndGlideStrategy(track_data, lap_length, num_laps, stop_points, total_race_time, accel_from_stop_rate, decel_to_stop_rate, pulse_accel_rate, road_load_fn, deltaV);
% TODO: Ensure that it doesn't exceed the max velocity

animate_drive_matrix(drive_matrix,track_file,selected_track.name,selected_track.num_laps);

%% Functions
function drive_matrix = PulseAndGlideStrategy(track_data, lap_length, num_laps, stop_points, total_race_time, accel_from_stop_rate, decel_to_stop_rate, pulse_accel_rate, road_load_fn, deltaV)
    x_dist = track_data(:,1);
    y_dist = track_data(:,2);
    elev = track_data(:,3);

    n_points = length(track_data(:,1));
    x_dist_full = zeros(n_points * num_laps, 1);
    y_dist_full = zeros(n_points * num_laps, 1);
    elev_full = zeros(n_points * num_laps, 1);

    for i = 0:(num_laps-1)
        idx = (1:n_points) + i * n_points;
        x_dist_full(idx) = x_dist + i * lap_length;
        y_dist_full(idx) = y_dist;
        elev_full(idx) = elev;
    end

    [x_dist_full, unique_idx] = unique(x_dist_full, 'stable');
    y_dist_full = y_dist_full(unique_idx);
    elev_full = elev_full(unique_idx);

    total_distance = num_laps * lap_length;
    dt = 0.1; % seconds

    Vs_guess = total_distance / (total_race_time * 60); % Initial guess
    tolerance = 1.0; % seconds
    max_iterations = 1000;
    iter = 0;
    final_time_error = Inf;

    while abs(final_time_error) > tolerance && iter < max_iterations
        iter = iter + 1;

        v_high = Vs_guess + deltaV;
        v_low = Vs_guess - deltaV;

        position = 0;
        time = 0;
        velocity = 0;

        pos_arr = [];
        vel_arr = [];
        time_arr = [];

        stop_idx = 1;
        coast_phase = true;
        accelerating_from_stop = true;

        while (position + velocity * dt) < total_distance || velocity > 0.05
            if stop_idx <= length(stop_points)
                next_stop = stop_points(stop_idx);
            else
                next_stop = total_distance;
            end

            dist_to_stop = next_stop - position;
            decel_to_stop_dist = velocity^2 / (2 * decel_to_stop_rate);

            if dist_to_stop <= decel_to_stop_dist + 1e-2
                coast_phase = true;
                v_target = 0;
            elseif coast_phase
                v_target = v_low;
            else
                v_target = v_high;
            end

            if coast_phase
                F_load = road_load_fn(velocity);
                acc = -F_load;
            elseif accelerating_from_stop
                acc = accel_from_stop_rate;
            else
                acc = pulse_accel_rate;
            end

            velocity = velocity + acc * dt;
            velocity = max(min(velocity, v_high), 0);

            % Enforce gradual deceleration
            if dist_to_stop <= decel_to_stop_dist + 1e-2
                required_velocity = sqrt(max(0, 2 * decel_to_stop_rate * dist_to_stop));
                velocity = min(velocity, required_velocity);
            end

            % Transition states based on distance to stop
            if coast_phase && velocity <= v_low && dist_to_stop > decel_to_stop_dist + 1e-2
                coast_phase = false;
                accelerating_from_stop = false;
            elseif ~coast_phase && velocity >= v_high && dist_to_stop > decel_to_stop_dist + 1e-2
                coast_phase = true;
            end

            % Prevent overshooting stop points and finish
            if position + velocity * dt > next_stop
                velocity = max(0, (next_stop - position) / dt);
            end

            position = position + velocity * dt;
            time = time + dt;

            pos_arr(end+1,1) = position;
            vel_arr(end+1,1) = velocity;
            time_arr(end+1,1) = time;

            if velocity <= 0.05 && dist_to_stop < 1
                stop_idx = stop_idx + 1;
                accelerating_from_stop = true;
            end
        end

        final_time_error = time - total_race_time * 60;
        % Vs_guess = Vs_guess + 0.05 * sign(-final_time_error);
        % Adaptive step size (proportional control)
        Vs_guess = Vs_guess + 0.001 * final_time_error;
        fprintf("Total Distance Traveled:\t%.4f = %.2f (mi) \nTotal Distance:\t\t\t%.4f\nVguess:\t%.4f\n\n",position,position/1609,lap_length*num_laps,Vs_guess);
    end

    y_interp = interp1(x_dist_full, y_dist_full, pos_arr, 'linear', 'extrap');
    elev_interp = interp1(x_dist_full, elev_full, pos_arr, 'linear', 'extrap');

    drive_matrix = [pos_arr, y_interp, elev_interp, vel_arr, time_arr];

    writematrix(drive_matrix, 'csv/drive_strategy.csv');
    writematrix(drive_matrix, '../../vehicle_modeling/csv/drive_strategy.csv');

    figure;
    title('Pulse-and-Glide Velocity & Elevation Profiles');

    yyaxis left;
    hold on
    plot(time_arr, vel_arr, 'b-', 'LineWidth', 2);
    ylabel('Velocity (m/s)');
    ylim([0, max(vel_arr)*1.1]);

    yyaxis right;
    plot(time_arr, elev_interp, 'r-', 'LineWidth', 1.5);
    hold off
    ylabel('Elevation (m)');
    xlabel('Time (s)');
    grid on;

    xlim([0 time_arr(end)*1.01])
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

function animate_drive_matrix(drive_matrix, track_file, track_name, num_laps)
    % Load base track data
    track_data = readmatrix(track_file);
    track_x = track_data(:,1);
    track_z = track_data(:,3);

    % Extend the track over all laps
    track_x_laps = [];
    track_z_laps = [];

    lap_length = track_x(end);
    for i = 0:(num_laps-1)
        track_x_laps = [track_x_laps; track_x + i * lap_length];
        track_z_laps = [track_z_laps; track_z];
    end

    % Extract vehicle path
    x = drive_matrix(:,1);
    z = drive_matrix(:,3);
    time_vec = drive_matrix(:,5);

    % Setup figure
    % Desired figure size
    fig_width = 1500;
    fig_height = 75;
    
    % Get screen size: [left, bottom, screen_width, screen_height]
    screen_size = get(0, 'ScreenSize');
    
    % Calculate centered position
    left = (screen_size(3) - fig_width) / 2;
    bottom = (screen_size(4) - fig_height) / 2;
    
    % Create centered figure window
    figure('Color', 'w', 'Position', [left, bottom, fig_width, fig_height]);
    hold on;
    axis tight;
    grid on;
    title(['Vehicle Animation - ' track_name]);
    xlabel('Track Distance (m)');
    ylabel('Elevation (m)');

    % Plot extended track
    plot(track_x_laps, track_z_laps, 'k-', 'LineWidth', 1.5);

    % Plot full planned vehicle path in light gray
    plot(x, z, '-', 'Color', [0.8 0.8 0.8]);

    % Initialize animated red dot
    h = plot(x(1), z(1), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % === Animation settings ===
    frame_rate = 30;               % [frames/sec]
    sim_duration = time_vec(end); % [sec]
    animation_duration = 60;      % [sec] of playback time

    n_frames = animation_duration * frame_rate;
    anim_time_vec = linspace(0, sim_duration, n_frames);

    % Interpolate vehicle position for smooth animation
    x_anim = interp1(time_vec, x, anim_time_vec, 'linear', 'extrap');
    z_anim = interp1(time_vec, z, anim_time_vec, 'linear', 'extrap');

    % Animate
    for i = 1:length(anim_time_vec)
        set(h, 'XData', x_anim(i), 'YData', z_anim(i));
        drawnow;
        pause(1/frame_rate);
    end

    % Final position
    set(h, 'XData', x_anim(end), 'YData', z_anim(end));
end

