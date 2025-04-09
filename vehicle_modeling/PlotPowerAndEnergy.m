figure;
%Tractive Power Out kW
subplot(2,2,1)
plot(simTime, tractivePowerOut)
xlabel('Time (s)')
ylabel('Tractive Power (kW)')
grid on

%Cumulative Tractive Energy kWh
subplot(2,2,2)
plot(simTime, totalTractiveEnergyOutkWh)
xlabel('Time (s)')
ylabel('Tractive Energy (kWh)')
grid on

%Cumulative Propelling Energy J
subplot(2,2,3)
plot(simTime, propellingEnergyOut)
xlabel('Time (s)')
ylabel('Propelling Energy (kWh)')
grid on

%Cumulative Braking Energy
subplot(2,2,4)
plot(simTime, brakingEnergyOut)
xlabel('Time (s)')
ylabel('Braking Energy (kWh)')
grid on

figure
plot(simTime,batteryCurent)
xlabel('Time (s)')
ylabel('Current (A)')
title("Battery Current vs Time")
grid on