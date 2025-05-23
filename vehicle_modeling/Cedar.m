%% EV Simple
%TODO: ADD DESCRIPTION HERE
clc;clear;close all;
%% Load Model Parameters
LoadDriveCycle;

ConstantsEnvironment;
ConstantsVehicleBody;
ConstantsBattery;
ConstantsInverter;
ConstantsMotor;
ConstantsTransmission;
ConstantsAccessoryLoad;
ConstantsMisc;

%% Simulate
sim('CedarSim.slx')
GatherResults;

%% Important Stats
total_Energy_Consumed_kWh = bateryEnergyAtTerminals(end)*(1/1000)*(1/3600);
total_dist_mi = distanceX(end)*0.000621371; %0.000621371 mi/m
total_efficiency_miles_per_kWh = total_dist_mi/total_Energy_Consumed_kWh;
total_efficiency_mpge = total_efficiency_miles_per_kWh*33.705;

fprintf("Total Energy Consumed:\t%.4f (kWh)\n",total_Energy_Consumed_kWh)
fprintf("Distance Traveled:\t%.4f (mi)\n",total_dist_mi)
fprintf("Total Race Time:\t%.4f (min)\n",tout(end)/60)
fprintf("Efficiency:\t\t%.4f (mi/kWh)\n",total_efficiency_miles_per_kWh)
fprintf("Efficiency:\t\t%.4f (MPGe)\n",total_efficiency_mpge)
fprintf("Max Current:\t\t%.4f (A)\n",max(batteryCurent))
fprintf("Max Tractive Power:\t%.4f (kW)\n",max(tractivePowerOut))
fprintf("Max Braking Force:\t%.4f (N)\n",-min(frictionBrakingForceOut))


%% Plot Drive Cycle Adherance Over Time
PlotDriveCycleAdherance;

%% Plot Motor Torque Speed Operating Points
PlotTorqueSpeedOPs;

%% Plot Tractive & Braking Forces Over Time
PlotTractiveForces;

%% Plot Output Power & Energy Over Time
PlotPowerAndEnergy;

%% Plot Driveline Efficiencies Over Time
PlotDrivelineEff;

%% Plot Total Vehicle Efficiency Over Time
PlotTotalVehicleEfficiency;