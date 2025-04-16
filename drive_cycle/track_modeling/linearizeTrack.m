clear; clc; close all;

track_name = 'Indy';
track_path = sprintf('csv/raw/%s_raw.csv',track_name);
trackData = importdata(track_path);     %import raw csv from SwiftNav
trackData = trackData.data;             %cut off the header
% trackData = trackData(1500:18280, :);   % (TODO: Get from google earth & delete) cut the data so there is no overlap

% Use for Sonoma
% lat = trackData(:, 2);
% lon = trackData(:, 3);
% elev = trackData(:, 4);

% Use for every other track
lat = trackData(:, 1);
lon = trackData(:, 2);
elev = trackData(:, 3);

%project latitude and longitude onto the globe to convert to meters
[y, x, z] = geodetic2ned(lat, lon, elev, lat(1), lon(1), elev(1), referenceEllipsoid('GRS80','m'));
elevSmoothFactor = 100; % larger = smoother elevation profile

x = smooth(x, 5);   %basic smoothing
y = smooth(y, 5);
z = -smooth(z, elevSmoothFactor);  %the elevation in the raw GPS log is inverted. fix it

%x = downsample(x, 20);
%y = downsample(y, 20);
%z = downsample(z, 20);

rawTrack = [x, y, z];
totalDist = 0;
subsampledTrack = rawTrack(1, :);
linearizedTrack = [0, 0, 0];

for i = 2:length(rawTrack)
   dist = norm(subsampledTrack(end, :) - rawTrack(i, :));     %calculate the euclidean distance from the previous point to the current point
   
   if (totalDist + dist) / 5 > size(subsampledTrack, 1)       %this spaces out the points to every 5 meters
      totalDist = totalDist + dist;
      subsampledTrack = [subsampledTrack; rawTrack(i, :)];    %append point to subsampled points
      linearizedTrack = [linearizedTrack; totalDist, 0, rawTrack(i, 3)];   %keep track of 2D track (X, Y=0, Z)
   end
end

%% Save Outputs
% Local
Full3D_Local = sprintf('csv/full_3D/%s_3D.csv',track_name);
Projected_Local = sprintf('csv/elev_projected/%s_elev_projected.csv',track_name);

csvwrite(Full3D_Local, subsampledTrack);
csvwrite(Projected_Local, linearizedTrack);

% For Drive Strat
Full3D_DriveStrat = sprintf('../drive_strat/csv/full_3D/%s_3D.csv',track_name);
Projected_DriveStrat = sprintf('../drive_strat/csv/elev_projected/%s_elev_projected.csv',track_name);

csvwrite(Full3D_DriveStrat, subsampledTrack);
csvwrite(Projected_DriveStrat, linearizedTrack);

fprintf("Saved 3D track data to: \n%s\n%s\n\n", Full3D_Local,Full3D_DriveStrat);
fprintf("Saved elevated projection track data to: \n%s\n%s\n", Projected_Local,Projected_DriveStrat);

%% Plot Results
figure(1)
scatter3(x, y, z);      %plot the raw GPS trace in meters
xlabel('x'); ylabel('y'); zlabel('z');
titleText = sprintf('%s Raw GPS Racing Line in Meters',track_name);
title(titleText);

figure(2);
plot(linearizedTrack(:, 1), linearizedTrack(:, 3));
xlabel('Distance along track in m');
ylabel('Relative elevation in m');
titleText = sprintf('%s Elevated Projected Track',track_name);
title(titleText);
grid on;