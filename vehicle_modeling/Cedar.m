%% EV Simple
%TODO: ADD DESCRIPTION HERE
clc;clear;close all
%% Load Model Parameters
Drive_Cycle;
Environment;
Vehicle_Body;
Battery;
Inverter;
Motor;
Transmission;
Accessory_Load;
Constants;

%% Simulate
sim('CedarSim.slx')

GatherResults;

%% Important Stats
total_Energy_Consumed_kW = bateryEnergyAtTerminals(end)*(1/1000)*(1/3600);
total_dist_mi = distanceX(end)*0.000621371; %0.000621371 mi/m
total_efficiency_miles_per_kWh = total_dist_mi/total_Energy_Consumed_kW;
total_efficiency_mpge = total_efficiency_miles_per_kWh*33.705;

fprintf("Total Energy Consumed:\t%.4f (kW)\n",total_Energy_Consumed_kW)
fprintf("Distance Traveled:\t%.4f (mi)\n",total_dist_mi)
fprintf("Efficiency:\t\t%.4f (mi/kWh)\n",total_efficiency_miles_per_kWh)
fprintf("Efficiency:\t\t%.4f (MPGe)\n",total_efficiency_mpge)

%% Plot Drive Cycle Adherance Over Time
PlotDriveCycleAdherance;

%% Plot Motor Torque Speed Operating Points
PlotTorqueSpeedOPs;

%% Plot Tractive & Braking Forces Over Time
PlotTractiveForces;

%% Plot Output Power & Energy Over Time
PlotPowerAndEnergy;