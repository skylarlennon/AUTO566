%% linear_track_generator.m
% AUTO 566 Supermileage
% Author: Skylar Lennon (using ChatGPT)
clc;clear;close all;

%% Select Track
track_number = 3;   % 0 = Custom Track
                    % 1 = Detroit Streets
                    % 2 = Indianapolis Motor Speedway
                    % 3 = Sonoma Raceway
track_name = ""; 
lap_length = 0; % [meters]
num_laps = 0; 
elev_profile_type = '';
elev_params = [];
switch track_number
    case 0
        track_name = "Input Track Name Here";
        lap_length = 2000; % [Input lap length]
        num_laps = 5; % [Input number of laps]
        elev_profile_type = 'sections';
        % elev_params = []; % [Input elev params]
        elev_params = [0 500 -0.02;
                500 1500 0.01;
                1500 2000 0];
    case 1
        track_name = "Detroit";
        lap_length = 3895;
        num_laps = 4;
        elev_profile_type = 'flat';
        elev_params = [0, lap_length, 0];
    case 2
        track_name = "Indy";
        lap_length = 3925;
        num_laps = 4;
        elev_profile_type = 'flat';
        elev_params = [0, lap_length, 0];
    case 3
        track_name = "Sonoma";
        lap_length = 1440;
        num_laps = 10;
        elev_profile_type = 'flat';
        elev_params = [0, lap_length, 0];
    otherwise
        error("Not a valid track number"); 
end

%% Generate track
track_matrix = LinearTrackGenerator(lap_length, num_laps, elev_profile_type, elev_params,track_name);

%% Save Track Model to CSV locally and for drive strat
if elev_profile_type == 'flat'
    filenameLocal = sprintf('csv/flat_projected/%s.csv', track_name);
    filenamDriveStrat = sprintf('../drive_strat/csv/flat_projected/%s.csv',track_name);
    writematrix(track_matrix, filenameLocal);
    writematrix(track_matrix, filenamDriveStrat);
else
    filenameLocal = sprintf('csv/elev_projected/%s.csv', track_name);
    filenamDriveStrat = sprintf('../drive_strat/csv/elev_projected/%s.csv',track_name);
    writematrix(track_matrix, filenameLocal);
    writematrix(track_matrix, filenamDriveStrat);
end

%% LinearTrackGenerator Function
function track_matrix = LinearTrackGenerator(lap_length, num_laps, elev_profile_type, elev_params,track_name)
    % Generate a linear track with specified elevation characteristics
    % Inputs:
    %   lap_length:         (m) - Length of one lap
    %   num_laps:           Number of laps (0 if it's not a closed loop track)
    %   elev_profile_type:  'flat', or 'sections'
    %   elev_params:        Parameters defining elevation profile for ONE
    %                       lap
    %       For 'sections': elev_params = Nx3 matrix where each row defines a segment with:
    %           Column 1: Start distance (m)
    %           Column 2: End distance (m)
    %           Column 3: Slope (m/m, i.e., elevation change per meter)
    %       Example:
    %           elev_params = [0, 500, 0.01;    % 0 to 500m: 1% incline
    %                         500, 1000, -0.01; % 500 to 1000m: 1% decline
    %                         1000, 1500, 0];   % 1000 to 1500m: flat
    %       For 'flat': 
    %           elev_params = A 1x3 matrix [0, lap_length, 0]
    % Output:
    %   track_matrix - Nx3 matrix [x_dist, y_dist (zero), elev]
    
    % Error checking: Ensure elev_params max distance matches lap_length
    if abs(elev_params(end,2) - lap_length) > 1e-3
        error('Elevation profile does not match lap length. Adjust elev_params.');
    end

    cumulativeElevation = 0;
    % Check that the starting and final elevation of the track are the same
    if num_laps >= 1
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


    % Visualize Track Elevation                 
    figure;
    plot(track_matrix(:,1), track_matrix(:,3), 'b', 'LineWidth', 2);
    xlabel('Distance (m)');
    ylabel('Elevation (m)');
    titleText = sprintf('%s Elevation Profile',track_name);
    title(titleText);
    grid on;
end
