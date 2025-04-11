%% PnG_Simple.m (only for flat tracks)
% Auto 566 Supermileage
% Author: Skylar Lennon (using ChatGPT)
clc;clear;close all

%% === Define All Track Configurations ===
track_configs = [
    struct( ...
        'name', "Detroit Streets", ...
        'file', ["csv/flat_projected/Detroit_flat_projected.csv"], ...
        'num_laps', 4, ...
        'stop_point', 1947 ...
    );
    struct( ...
        'name', "Indianapolis Motor Speedway", ...
        'file', ["csv/flat_projected/Indy_flat_projected.csv"], ...
        'num_laps', 4, ...
        'stop_point', 1867 ...
    );
    struct( ...
        'name', "Sonoma Raceway", ...
        'file', ["csv/flat_projected/Sonoma_flat_projected.csv"], ...
        'num_laps', 10, ...
        'stop_point', 395 ...
    );
    struct( ...
        'name', "Test", ...
        'file', ["csv/flat_projected/Test_flat_projected.csv"], ...
        'num_laps', 10, ...
        'stop_point', 395 ...
    )
];

%% === Select Track ===
track_number = 1;   % 1 = Detroit Streets
                    % 2 = Indianapolis Motor Speedway
                    % 3 = Sonoma Raceway
                    % 4 = Test
track_type = 1;     % 1 = Flat Projection

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
decel_to_stop_rate = 0.25; % [m/s^2]        % [Edit based on track]
pulse_accel_rate = 0.5; % [m/s^2]           % [Edit based on track]
deltaV = 2; % [m/s]                         % [Edit based on track]
maxVelocity = 17; % [m/s]                   % [Edit based on vehicle] (automate) 


%% === Load Vehicle Parameters ===
run("../../vehicle_modeling/ConstantsVehicleBody.m");
run("../../vehicle_modeling/ConstantsTransmission.m");
run("../../vehicle_modeling/ConstantsEnvironment.m");

road_load_fn = @(v) (Crr * massVeh * gravity + 0.5 * rho * Cd * Af * v.^2) / massVeh;

drive_matrix = PulseAndGlideStrategy(track_data, lap_length, num_laps, stop_points, total_race_time, accel_from_stop_rate, decel_to_stop_rate, pulse_accel_rate, road_load_fn, deltaV, maxVelocity);

function drive_matrix = PulseAndGlideStrategy(track_data, lap_length, num_laps, stop_points, total_race_time, accel_from_stop_rate, decel_to_stop_rate, pulse_accel_rate, road_load_fn, deltaV, maxVelocity)
    % Load track data
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
    position = 0;
    time = 0;
    velocity = 0;

    % Calculate optimal steady state speed (Vs) from time constraint
    num_stops = length(stop_points);
    A = num_stops / (2 * accel_from_stop_rate) + num_stops / (2 * decel_to_stop_rate);
    A = A + 1 / (2 * accel_from_stop_rate) + 1 / (2 * decel_to_stop_rate);
    B = -total_race_time * 60;
    C = total_distance;
    discriminant = B^2 - 4 * A * C;
    if discriminant < 0
        error('Acceleration and deceleration rates do not allow completion in the given time. Adjust parameters.');
    end
    Vs1 = (-B + sqrt(discriminant)) / (2 * A);
    Vs2 = (-B - sqrt(discriminant)) / (2 * A);
    if (Vs1 > 0 && Vs1 < maxVelocity) && (Vs1 < Vs2)
        Vs = Vs1;
    elseif Vs2 > 0 && Vs2 < maxVelocity
        Vs = Vs2;
    else
        error('Cannot find valid steady-state velocity. Adjust parameters.');
    end

    v_high = Vs + deltaV;
    v_low = Vs - deltaV;

    if v_high > maxVelocity
        error('Steady state speed plus deltaV greater than max vehicle velocity')
    end

    pos_arr = [];
    vel_arr = [];
    time_arr = [];

    stop_idx = 1;
    coast_phase = true;
    accelerating_from_stop = true;

    while position < total_distance
        if stop_idx <= length(stop_points)
            dist_to_stop = stop_points(stop_idx) - position;
        else
            dist_to_stop = Inf;
        end

        decel_to_stop_dist = v_low^2 / (2 * decel_to_stop_rate);
        if dist_to_stop < decel_to_stop_dist
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

        if coast_phase && velocity <= v_low
            coast_phase = false;
            accelerating_from_stop = false;
        elseif ~coast_phase && velocity >= v_high
            coast_phase = true;
        end

        position = position + velocity * dt;
        time = time + dt;

        pos_arr(end+1,1) = position;
        vel_arr(end+1,1) = velocity;
        time_arr(end+1,1) = time;

        if velocity <= 0.1 && dist_to_stop < 1
            stop_idx = stop_idx + 1;
            accelerating_from_stop = true;
        end
    end

    y_interp = interp1(x_dist_full, y_dist_full, pos_arr, 'linear', 'extrap');
    elev_interp = interp1(x_dist_full, elev_full, pos_arr, 'linear', 'extrap');

    drive_matrix = [pos_arr, y_interp, elev_interp, vel_arr, time_arr];

    writematrix(drive_matrix, 'csv/drive_strategy.csv');
    writematrix(drive_matrix, '../../vehicle_modeling/csv/drive_strategy.csv');

    figure;
    plot(pos_arr, vel_arr, 'b-', 'LineWidth', 2);
    xlabel('Distance (m)');
    ylabel('Velocity (m/s)');
    title('Pulse-and-Glide Velocity Profile');
    grid on;
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

% TODO/thoughts, should we use the calcs for finding the steady state average speed from the previous code
% and then just have a parameter for deltaV or how much you deviate from
% this average speed?
% - Include total_race_time to find the optimal 