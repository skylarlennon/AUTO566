%% linear_track_generator.m
% AUTO 566 Supermileage
% Author: Skylar Lennon (using ChatGPT)

clc;clear;close all;

%% Lap Parameters (Indianapolis Motor Speedway Road Course, Flat Model)
lap_length_mi = 9.76;
meters_per_mile = 1609.34;
lap_length = lap_length_mi*meters_per_mile; % meters
num_laps = 1;       % Simulate 3 laps
elev_profile_type = 'flat';
elev_params = [0, lap_length, 0];

% TRACK WITH VARIOUS SEGMENTS EXAMPLE
% elev_profile_type = 'sections';
% Define a single lap's elevation profile with different segments
% elev_params = [0, 500, 0.01;    % 0 to 500m: 1% incline
%                500, 1000, -0.01; % 500 to 1000m: 1% decline
%                1000, 1500, 0];    % 1000 to 1500m: flat

%% Generate track
task_matrix = LinearTrackGenerator(lap_length, num_laps, elev_profile_type, elev_params);

%% Visualize Track Elevationesdwbn                   
figure;
plot(task_matrix(:,1), task_matrix(:,3), 'b', 'LineWidth', 2);
xlabel('Distance (m)');
ylabel('Elevation (m)');
title('Track Elevation Profile');
grid on;

%% Save Track Model to CSV
writematrix(task_matrix,'track_model.csv');

%% LinearTrackGenerator Function
function track_matrix = LinearTrackGenerator(lap_length, num_laps, elev_profile_type, elev_params)
    % Generate a linear track with specified elevation characteristics
    % Inputs:
    %   lap_length (m) - Length of one lap
    %   num_laps - Number of laps
    %   elev_profile_type - 'flat', 'incline', 'decline', or 'sections'
    %   elev_params - Parameters defining elevation profile
    %       For 'sections': A Nx3 matrix where each row defines a segment with:
    %           Column 1: Start distance (m)
    %           Column 2: End distance (m)
    %           Column 3: Slope (m/m, i.e., elevation change per meter)
    %       Example:
    %           elev_params = [0, 500, 0.01;    % 0 to 500m: 1% incline
    %                         500, 1000, -0.01; % 500 to 1000m: 1% decline
    %                         1000, 1500, 0];    % 1000 to 1500m: flat
    % Output:
    %   track_matrix - Nx3 matrix [x_dist, y_dist (zero), elev]
    
    % Error checking: Ensure elev_params max distance matches lap_length
    if max(elev_params(:,2)) ~= lap_length
        error('Elevation profile does not match lap length. Adjust elev_params.');
    end

    cumulativeElevation = 0;
    % Check that the starting and final elevation of the track are the same
    if num_laps > 1
        for i = 1:length(elev_params(:,1)) %loop through all segments
            m = elev_params(i,3);
            delta_elev = m*(elev_params(i,2) - elev_params(i,1));
            cumulativeElevation = cumulativeElevation + delta_elev;
        end

        if cumulativeElevation ~= 0
            error('Laps do not start & end at same elevation. Adjust elev_params.');
        end
    end
    
    % Initialize full track vectors
    x_dist = [];
    y_dist = [];
    elev = [];
    
    % Loop over number of laps
    for lap = 1:num_laps
        lap_x = linspace((lap-1)*lap_length, lap*lap_length, 1000)';
        lap_y = zeros(size(lap_x));
        lap_elev = zeros(size(lap_x));
        
        % Carry over previous lap elevation
        if isempty(elev)
            prev_elev = 0;
        else
            prev_elev = elev(end);
        end
        
        % Apply elevation profile
        switch lower(elev_profile_type)
            case 'flat'
                lap_elev = zeros(size(lap_x)) + prev_elev;
            
            case 'incline'
                slope = elev_params(1); % Elevation change per meter
                lap_elev = slope * (lap_x - (lap-1)*lap_length) + prev_elev;
            
            case 'decline'
                slope = elev_params(1); % Elevation change per meter
                lap_elev = -slope * (lap_x - (lap-1)*lap_length) + prev_elev;
            
            case 'sections'
                for i = 1:size(elev_params, 1)
                    start_dist = elev_params(i, 1) + (lap-1)*lap_length;
                    end_dist = elev_params(i, 2) + (lap-1)*lap_length;
                    slope = elev_params(i, 3);
                    
                    mask = (lap_x >= start_dist) & (lap_x < end_dist);
                    if any(mask)
                        lap_elev(mask) = slope * (lap_x(mask) - start_dist) + prev_elev;
                    end
                    % Update prev_elev for continuity
                    if any(mask)
                        prev_elev = lap_elev(find(mask, 1, 'last'));
                    end
                end
            
            otherwise
                error('Invalid elevation profile type. Choose flat, incline, decline, or sections.');
        end
        
        % Append to full track vectors
        x_dist = [x_dist; lap_x];
        y_dist = [y_dist; lap_y];
        elev = [elev; lap_elev];
    end
    
    % Combine into output matrix
    track_matrix = [x_dist, y_dist, elev];
end
