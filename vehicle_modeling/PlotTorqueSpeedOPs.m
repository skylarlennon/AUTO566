%% Plot Motor's Torque Speed Operating Points for Drive Cycle

% Calculate the speed at which the torque starts to decrease
thresholdSpeed = motorMaxPower / motorMaxTorque;
envelopeSpeed = linspace(0, motorMaxSpeed, 1000); % Speed from 0 to maxSpeed
% Calculate torque
envelopeTorque = zeros(size(envelopeSpeed));
for i = 1:length(envelopeSpeed)
    if envelopeSpeed(i) <= thresholdSpeed
        envelopeTorque(i) = motorMaxTorque;
    else
        envelopeTorque(i) = motorMaxPower / envelopeSpeed(i);
    end
end

figure;
grid on
xlabel('Speed (radps)')
ylabel('Torque (Nm)')
xlim([0 motorMaxSpeed*1.05])
ylim([0 motorMaxTorque*1.05])
titleString = sprintf('Torque Speed Data for %.2f Nm, %d kW Motor',motorMaxTorque, motorMaxPower/1e3);
title(titleString)
hold on

% Motor Efficiency Contour
contourf(omegaBreakpoints, torqueBreakpoints, motorEff, ...
         [0.5 0.6 0.7 0.75 0.8 0.85 0.9 0.93 0.95], ...
         'ShowText', 'on', 'LineColor', 'k');
colormap(turbo); 
colorbar;
% caxis([0.5 0.95]);

plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
scatter(motorSpeedOut,motorTorqueOut)
hold off
legend('Motor Efficiency Contours','Torque-Speed Envelope', 'Torque-Speed Operating Points')

%% Histogram

% Define bin edges for full range
torqueEdges = linspace(min(motorTorqueOut), motorMaxTorque, 30);
speedEdges = linspace(min(motorSpeedOut), motorMaxSpeed, 30);

% 2D histogram of torque vs. speed
[counts, tEdges, sEdges] = histcounts2(motorTorqueOut, motorSpeedOut, torqueEdges, speedEdges);

% Get bin centers
tCenters = (tEdges(1:end-1) + tEdges(2:end)) / 2;
sCenters = (sEdges(1:end-1) + sEdges(2:end)) / 2;

% FLIP: Speed is X, Torque is Y
[S, T] = meshgrid(sCenters, tCenters);

% Plot base grid
figure;
surf(S, T, zeros(size(S)), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
colormap([0.9 0.9 0.9]);  % light gray base
hold on;

% Bar color
barColor = [0.2 0.6 0.9];  % blueish

% Draw 3D bars
for i = 1:numel(S)
    freq = counts(i);
    if freq > 0
        x = S(i);
        y = T(i);
        h = freq;

        w = (sEdges(2)-sEdges(1)) * 0.8;
        d = (tEdges(2)-tEdges(1)) * 0.8;

        xVerts = [x-w/2 x+w/2 x+w/2 x-w/2 x-w/2 x+w/2 x+w/2 x-w/2];
        yVerts = [y-d/2 y-d/2 y+d/2 y+d/2 y-d/2 y-d/2 y+d/2 y+d/2];
        zVerts = [0 0 0 0 h h h h];

        faces = [
            1 2 3 4;
            5 6 7 8;
            1 2 6 5;
            2 3 7 6;
            3 4 8 7;
            4 1 5 8
        ];

        patch('Vertices', [xVerts' yVerts' zVerts'], 'Faces', faces, ...
              'FaceColor', barColor, 'EdgeColor', 'none');
    end
end

xlabel('Speed (rad/s)');
ylabel('Torque (Nm)');
zlabel('Frequency');
title('3D Histogram of Torque-Speed Operating Points');
view(45, 30);
axis tight;
grid on;
