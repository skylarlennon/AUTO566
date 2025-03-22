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

track3D = [x,y,z];

scatter3(x, y, z);      %plot the raw GPS trace in meters
xlabel('x'); ylabel('y'); zlabel('z');

% Save local copies of the output
csvwrite('csv/sonomaMeters.csv', track3D);

% Save copies to be combined with the driving strategy
csvwrite('../drive_strat/csv/sonomaMeters.csv', track3D);