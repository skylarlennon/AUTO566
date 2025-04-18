% Inverter
figure;
sgtitle("Inverter Power Efficiency")

subplot(2,1,1)
hold on
plot(tout,inverterPowerInput,'LineWid',2)
plot(tout,motorPowerInputOut,'LineWidth',2)
plot(tout,inverterLosses,'LineWidth',2)
hold off
grid on
xlabel('Time (s)')
ylabel('Power (W)')
legend('Inverter Input Power','Inverter Output Power','Inverter Losses')

subplot(2,1,2)
inverterEfficiency = motorPowerInputOut./inverterPowerInput.*100;
plot(tout,inverterEfficiency,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Efficiency (%)')

inverterEfficiency = inverterEfficiency(~isnan(inverterEfficiency));
avgInvEff = mean(inverterEfficiency);
fprintf('Mean Inverter Eff:\t%.4f %%\n',avgInvEff)

% Motor
figure;
sgtitle("Motor Power Efficiency")

subplot(2,1,1)
hold on
plot(tout,motorPowerInputOut,'LineWid',2)
plot(tout,motorPowerOut,'LineWidth',2)
plot(tout,motorPowerLossesOut,'LineWidth',2)
hold off
grid on
xlabel('Time (s)')
ylabel('Power (W)')
legend('Motor Input Power','Motor Output Power','Motor Losses')

subplot(2,1,2)
motorEfficiency = motorPowerOut./motorPowerInputOut.*100;
plot(tout,motorEfficiency,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Efficiency (%)')

motorEfficiency = motorEfficiency(~isnan(motorEfficiency));
avgMotorEff = mean(motorEfficiency);
fprintf('Mean Motor Eff:\t\t%.4f %%\n',avgMotorEff)


% Transmission [Incomplete]
figure;
sgtitle("Transmission Power Efficiency")

% subplot(2,1,1)
% plot(tout, drivelinePowerLossOut)
% xlabel('Time (s)')
% ylabel('Power Loss (W)')
% grid on

subplot(2,1,1)
hold on
plot(tout,motorPowerOut,'LineWidth',2) %driveline input power
plot(tout,positiveTractivePowerOut,'LineWidth',2) %driveline output power
plot(tout,drivelinePowerLossOut,'LineWidth',2) %losses
hold off
grid on
xlabel('Time (s)')
ylabel('Power (W)')
legend('Driveline Input Power','Driveline Output Power','Driveline Losses')


drivelineEfficiency = drivelineEfficiencyOut.*ones(1,length(tout)).*100;
subplot(2,1,2)
plot(tout, drivelineEfficiency)
grid on
xlabel('Time (s)')
ylabel('Efficiency (%)')
grid on

drivelineEfficiency = drivelineEfficiency(~isnan(drivelineEfficiency));
avgDrivetrainEff = mean(drivelineEfficiency);
fprintf('Mean Drivetrain Eff:\t%.4f %%\n',avgDrivetrainEff)