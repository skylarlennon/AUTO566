% Inverter
figure;
sgtitle("Inverter Power Efficiency")

subplot(2,1,1)
hold on
plot(tout,inverterPowerInput,'LineWid',2)
plot(tout,motorPowerInputOut,'LineWidth',2)
plot(tout,inverterLosses,'LineWidth',2)
hold off
xlabel('Time (s)')
ylabel('Power (W)')
legend('Inverter Input Power','Inverter Output Power','Inverter Losses')

subplot(2,1,2)
inverterEfficiency = motorPowerInputOut./inverterPowerInput.*100;
plot(tout,inverterEfficiency,'LineWidth',2)
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
xlabel('Time (s)')
ylabel('Power (W)')
legend('Motor Input Power','Motor Output Power','Motor Losses')

subplot(2,1,2)
motorEfficiency = motorPowerOut./motorPowerInputOut.*100;
plot(tout,motorEfficiency,'LineWidth',2)
xlabel('Time (s)')
ylabel('Efficiency (%)')

motorEfficiency = motorEfficiency(~isnan(motorEfficiency));
avgMotorEff = mean(motorEfficiency);
fprintf('Mean Motor Eff:\t\t%.4f %%\n',avgMotorEff)


% Transmission [Incomplete]
figure;
sgtitle("Transmission Power Efficiency")

plot(tout, drivelinePowerLossOut)
xlabel('Time (s)')
ylabel('Power Loss (W)')
grid on

% subplot(2,1,1)
% hold on
% plot(tout,motorPowerInputOut,'LineWid',2)
% plot(tout,motorPowerOut,'LineWidth',2)
% plot(tout,drivelinePowerLossOut,'LineWidth',2)
% hold off
% xlabel('Time (s)')
% ylabel('Power (W)')
% legend('Motor Input Power','Motor Output Power','Motor Losses')
% 
% subplot(2,1,2)
% motorEfficiency = motorPowerOut./motorPowerInputOut.*100;
% plot(tout,motorEfficiency,'LineWidth',2)
% xlabel('Time (s)')
% ylabel('Efficiency (%)')