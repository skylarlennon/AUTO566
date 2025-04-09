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
plot(envelopeSpeed, envelopeTorque, 'LineWidth', 2, 'DisplayName', 'Torque-Speed Envelope'); % The envelope line
scatter(motorSpeedOut,motorTorqueOut)
hold off
legend('Torque-Speed Envelope', 'Torque-Speed Operating Points')