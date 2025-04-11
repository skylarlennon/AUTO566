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

