%% Plot the vehicle's total efficiency
% (neglecting losses internal to the battery as they are not
% measured by the joulemeter)
figure;
totalEff = positiveTractivePowerOut./batteryPowerAtTerminals;
hold on
plot(tout, totalEff,'LineWidth',2)
grid on
xlabel("Time (s)")
ylabel("Efficiency (%)")
title("Total Vehicle Efficiency")

totalLossesFromDiff = batteryPowerAtTerminals - positiveTractivePowerOut;
% totalLossesFromSum = drivelinePowerLossOut + motorPowerLossesOut + inverterLosses + AccessoryLoad;

figure;
hold on
% plot(tout, positiveTractivePowerOut,'LineWidth',2)
% plot(tout, batteryPowerAtTerminals,'LineWidth',2)
plot(tout, totalLossesFromDiff,'LineWidth',2)
hold off
grid on
xlabel('Time (s)')
ylabel('Power (W)')
title("Total Power Losses Including Overhead")

totalEff = totalEff(~isnan(totalEff));
totalEff = totalEff(~isinf(totalEff));
totalEff = totalEff(totalEff > 0);
avgTotalEff = mean(totalEff);
fprintf('Mean Total Eff:\t\t%.4f %%\n',avgTotalEff*100)