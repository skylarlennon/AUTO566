%% EV Simple
%TODO: ADD DESCRIPTION HERE
clc;clear;close all
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
massVehVec = [130:1:150];
cdafVec = [0.13:0.005:0.18];
massVehCdAfEffMap = zeros(length(massVehVec),length(cdafVec));

for massIdx = 1:length(massVehVec)
    for cdafIdx = 1:length(cdafVec)
        
        clearvars -except massVehVec cdafVec massVehCdAfEffMap massIdx cdafIdx
            
        LoadDriveCycle;
        ConstantsEnvironment;
        ConstantsVehicleBody;
        ConstantsBattery;
        ConstantsInverter;
        ConstantsMotor;
        ConstantsTransmission;
        ConstantsAccessoryLoad;
        ConstantsMisc;

        massVeh = massVehVec(massIdx);
        cdaf = cdafVec(cdafIdx);

        sim('CedarSim.slx')
        GatherResults;
        
        total_Energy_Consumed_kWh = bateryEnergyAtTerminals(end)*(1/1000)*(1/3600);
        total_dist_mi = distanceX(end)*0.000621371; %0.000621371 mi/m
        total_efficiency_miles_per_kWh = total_dist_mi/total_Energy_Consumed_kWh;
        total_efficiency_mpge = total_efficiency_miles_per_kWh*33.705;

        massVehCdAfEffMap(massIdx,cdafIdx) = total_efficiency_mpge;

    end
end

% Create meshgrid from mass and CdA vectors
[CdAfGrid, MassVehGrid] = meshgrid(cdafVec, massVehVec);

% Create the contour plot
figure;
contourf(CdAfGrid, MassVehGrid, massVehCdAfEffMap, 20);  % 20 contour levels
colorbar;
xlabel('CdA (m^2)');
ylabel('Vehicle Mass (kg)');
title('MPGe vs. CdA and Vehicle Mass');
grid on;

%% Important Stats
% total_Energy_Consumed_kWh = bateryEnergyAtTerminals(end)*(1/1000)*(1/3600);
% total_dist_mi = distanceX(end)*0.000621371; %0.000621371 mi/m
% total_efficiency_miles_per_kWh = total_dist_mi/total_Energy_Consumed_kWh;
% total_efficiency_mpge = total_efficiency_miles_per_kWh*33.705;
% 
% fprintf("Total Energy Consumed:\t%.4f (kWh)\n",total_Energy_Consumed_kWh)
% fprintf("Distance Traveled:\t%.4f (mi)\n",total_dist_mi)
% fprintf("Total Race Time:\t%.4f (min)\n",tout(end)/60)
% fprintf("Efficiency:\t\t%.4f (mi/kWh)\n",total_efficiency_miles_per_kWh)
% fprintf("Efficiency:\t\t%.4f (MPGe)\n",total_efficiency_mpge)

%% Plot Drive Cycle Adherance Over Time
% PlotDriveCycleAdherance;

%% Plot Motor Torque Speed Operating Points
% PlotTorqueSpeedOPs;

%% Plot Tractive & Braking Forces Over Time
% PlotTractiveForces;

%% Plot Output Power & Energy Over Time
% PlotPowerAndEnergy;

%% Plot Driveline Efficiencies Over Time
% PlotDrivelineEff;

%% Plot Total Vehicle Efficiency Over Time
% PlotTotalVehicleEfficiency;