%% simple_drive_strat.m
% Auto 566 Supermileage
% Author: Skylar Lennon (using ChatGPT)

clc;clear;close all

%% Load Track Model 
track_file = "track_model.csv";
lap_length_mi = 9.76/4;
meters_per_mile = 1609.34;
lap_length = lap_length_mi*meters_per_mile; % meters
num_laps = 1;
stop_point = 1.18*meters_per_mile; %meters
stop_points = zeros(1, 2*num_laps-1);

%% Driving Strategy
total_race_time = 35/4; % minutes
accel_rate = 0.5; %m/s^2
decel_rate = 0.5; %m/s^2
max_speed = 15; % max vehicle speed (m/s)

% For Shell Eco Marathon at Indy 500 Road Course, 1 stop per lap, and stop
% at finish line once per lap.
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

% calculate driving strategy
drive_strat = SimpleDriveStrategy(track_file, lap_length, num_laps, stop_points, total_race_time, accel_rate, decel_rate, max_speed);

% extract solution
x = drive_strat(:,1);
y = drive_strat(:,2);
z = drive_strat(:,3);
v = drive_strat(:,4);
t = drive_strat(:,5);

figure;
% Subplot velocity and elevation vs. distance
subplot(2,1,1)
hold on
yyaxis left;
plot(x, v, 'b', 'LineWidth', 2);
ylabel('Velocity (m/s)');
xlabel('Distance (m)');

yyaxis right;
plot(x, z, 'r', 'LineWidth', 2);
hold off
ylabel('Elevation (m)');
title('Velocity and Elevation vs. Distance');
grid on;


% Subplot: Velocity and elevation vs. time
subplot(2,1,2);
hold on

yyaxis left
plot(t, v, 'b', 'LineWidth', 2);
ylabel('Velocity (m/s)');
xlabel('Time (s)');

yyaxis right
plot(t, z, 'r', 'LineWidth', 2);
hold off
ylabel('Elevation (m)');
title('Velocity & Elevation vs. Time');
grid on;

%% Calculate Simple Drive Strategy
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
    
    % Define time step resolution (e.g., 10x the number of track points)
    num_time_steps = length(x_dist) * 10;
    time_vector = linspace(0, total_race_time * 60, num_time_steps)';
    
    % Compute total race distance
    total_distance = num_laps * lap_length;
    num_stops = length(stop_points);
    
    % Solve for steady-state velocity (Vs) using quadratic equation
    A = (num_stops + 1) / (2 * accel_rate) + (num_stops + 1) / (2 * decel_rate);
    B = -total_race_time * 60;
    C = total_distance;
    
    discriminant = B^2 - 4 * A * C;
    if discriminant < 0
        error('Acceleration and deceleration rates do not allow completion in the given time. Adjust parameters.');
    end
    
    Vs1 = (-B + sqrt(discriminant)) / (2 * A); % Take the positive root
    Vs2 = (-B - sqrt(discriminant)) / (2 * A); % Take the positive root

    % Take minimum solution for Vs that is greater than 0
    if Vs1 > 0 && Vs2 > 0
        Vs = min(Vs1,Vs2);
    else
        Vs = Vs1;
    end
    
    % Check if steady-state speed exceeds max vehicle speed
    if Vs > max_speed
        error('Calculated steady-state speed exceeds maximum vehicle speed. Adjust parameters.');
    end
    
    % Compute acceleration and deceleration distances
    accel_dist = Vs^2 / (2 * accel_rate);
    decel_dist = Vs^2 / (2 * decel_rate);
    
    % Initialize velocity and position tracking
    velocity = zeros(size(time_vector));
    position = zeros(size(time_vector));
    stopping = false;
    stop_index = 1;
    
    % Generate velocity profile with acceleration, steady-state, deceleration, and stop phases
for i = 2:length(time_vector)
    dt = time_vector(i) - time_vector(i-1); % Time step size

    % Check if we need to start decelerating for an upcoming stop
    if stop_index <= num_stops && (position(i-1) + velocity(i-1) * dt >= stop_points(stop_index) - decel_dist)
        stopping = true;
    end

    if stopping
        % Decelerate towards the stop point
        velocity(i) = max(0, velocity(i-1) - decel_rate * dt);

        % Ensure full stop at the stop point
        if position(i-1) >= stop_points(stop_index) || velocity(i) == 0
            velocity(i) = 0;  % Explicitly stop the vehicle
            stopping = false;  % Stop process completed
            if stop_index < num_stops  % Prevent out-of-bounds index
                stop_index = stop_index + 1;
            end
        end
    elseif velocity(i-1) == 0 && stop_index > 1 && position(i-1) == stop_points(stop_index-1)
        % Accelerate after a stop
        velocity(i) = min(Vs, velocity(i-1) + accel_rate * dt);
    elseif position(i-1) < stop_points(1) % Initial acceleration at the start
        velocity(i) = min(Vs, velocity(i-1) + accel_rate * dt);
    else
        % Maintain steady-state velocity
        velocity(i) = Vs;
    end

    % Update position based on velocity
    position(i) = position(i-1) + velocity(i) * dt;
end

    
    % Perform interpolation using position instead of x_dist
    y_interp = interp1(x_dist, y_dist, position, 'linear', 'extrap');
    elev_interp = interp1(x_dist, elev, position, 'linear', 'extrap');
    
    % Combine into output matrix
    drive_matrix = [position, y_interp, elev_interp, velocity, time_vector];
    
    % Save to CSV
    writematrix(drive_matrix,'drive_strategy.csv');
end