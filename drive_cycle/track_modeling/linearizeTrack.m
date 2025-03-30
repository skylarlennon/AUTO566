clear; clc; close all;

trackData = importdata('csv/sonoma.csv');   %import raw csv from SwiftNav
trackData = trackData.data;             %cut off the header
trackData = trackData(1500:18280, :);   %cut the data so there is no overlap

lat = trackData(:, 2);
lon = trackData(:, 3);
elev = trackData(:, 4);

%project latitude and longitude onto the globe to convert to meters
[y, x, z] = geodetic2ned(lat, lon, elev, lat(1), lon(1), elev(1), referenceEllipsoid('GRS80','m'));

x = smooth(x, 5);   %basic smoothing
y = smooth(y, 5);
z = -smooth(z, 5);  %the elevation in the raw GPS log is inverted. fix it

%x = downsample(x, 20);
%y = downsample(y, 20);
%z = downsample(z, 20);

scatter3(x, y, z);      %plot the raw GPS trace in meters
xlabel('x'); ylabel('y'); zlabel('z');

rawTrack = [x, y, z];

totalDist = 0;
%distLog = [];
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

%figure;
%scatter3(subsampledTrack(:, 1), subsampledTrack(:, 2), subsampledTrack(:, 3));

% Save local copies of the output
csvwrite('csv/sonomaMeters.csv', subsampledTrack);
csvwrite('csv/sonomaLinearized.csv', linearizedTrack);

% Save copies to be combined with the driving strategy
csvwrite('../drive_strat/csv/sonomaMeters.csv', subsampledTrack);
csvwrite('../drive_strat/csv/sonomaLinearized.csv', linearizedTrack);

figure;
plot(linearizedTrack(:, 1), linearizedTrack(:, 3));
xlabel('Distance along track in m');
ylabel('Relative elevation in m');
grid on;

lap_length_mi = totalDist/1609