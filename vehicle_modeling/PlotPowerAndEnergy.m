figure;
%Tractive Power Out kW
plot(simTime, tractivePowerOut)
xlabel('Time (s)')
ylabel('Tractive Power (kW)')
grid on


figure
%Cumulative Propelling Energy J
subplot(2,1,1)
plot(simTime, propellingEnergyOut.*(1/1000)*(1/3600))
xlabel('Time (s)')
ylabel('Propelling Energy (kWh)')
grid on

%Cumulative Braking Energy
subplot(2,1,2)
plot(simTime, brakingEnergyOut.*(1/1000)*(1/3600))
xlabel('Time (s)')
ylabel('Braking Energy (kWh)')
grid on

figure
plot(simTime,batteryCurent)
xlabel('Time (s)')
ylabel('Current (A)')
title("Battery Current vs Time")
grid on