driveCycle = readmatrix('csv/drive_strategy.csv');

% Extract time and speed columns
distanceX = driveCycle(:, 1);
distanceY = driveCycle(:, 2);
elevation = driveCycle(:, 3);
speed = driveCycle(:, 4);
time = driveCycle(:, 5);

deltaDistance = diff(distanceX);                % Calculate distance between consecutive points
deltaElevation = diff(elevation);               % Calculate elevation change between consecutive points
theta = atan2(deltaElevation, deltaDistance);   % Calculate road grade (theta) at each point (Output is in radians)
theta = [theta(1); theta];                      % Interpolate theta to match the length of the original arrays and keep the first value constant

timeSpeedData = timeseries(speed,time);         % Commanded speed input
timeThetaData = timeseries(theta,time);         % Theta vs time input (vehicle has to match drive cycle for this to work)

time_step = time(2);
StopTime = time(end);

%% Error Checking 
if any(isnan(speed)) || any(isinf(speed))
    error('Speed data contains NaN or Inf values.');
end