%% EV Simple
%TODO: ADD DESCRIPTION HERE
clc;clear;close all
%% Load Model Parameters
% LoadDriveCycle;
% 
% ConstantsEnvironment;
% ConstantsVehicleBody;
% ConstantsBattery;
% ConstantsInverter;
% ConstantsMotor;
% ConstantsTransmission;
% ConstantsAccessoryLoad;
% ConstantsMisc;

%% Simulate
GearRatios = 3:1:12;
effAtGRs = zeros(size(GearRatios));  % Safer

for k = 1:length(GearRatios)

    % Clear inner variables, but not effAtGRs or GearRatios
    clearvars -except GearRatios effAtGRs k GR

    % Re-load everything else
    LoadDriveCycle;
    ConstantsEnvironment;
    ConstantsVehicleBody;
    ConstantsBattery;
    ConstantsInverter;
    ConstantsMotor;
    ConstantsTransmission;
    ConstantsAccessoryLoad;
    ConstantsMisc;

    GR = GearRatios(k);
    sim('CedarSim.slx')
    GatherResults;
    PlotTorqueSpeedOPs;

    total_error = sum(abs(speedCommand - speedVehicle));
    total_adherance = sum(abs(speedCommand));
    total_drive_cycle_adherance = (1 - (total_error / total_adherance)) * 100;

    if total_drive_cycle_adherance > 98
        total_Energy_Consumed_kWh = bateryEnergyAtTerminals(end) / 1000 / 3600;
        total_dist_mi = distanceX(end) * 0.000621371;
        total_efficiency_mpge = total_dist_mi / total_Energy_Consumed_kWh * 33.705;
        effAtGRs(k) = total_efficiency_mpge;
    else
        effAtGRs(k) = NaN;
    end
    motorEfficiency = motorPowerOut./motorPowerInputOut.*100;
    motorEfficiency = motorEfficiency(~isnan(motorEfficiency));
    avgMotorEff = mean(motorEfficiency);
    fprintf('Mean Motor Eff:\t\t%.4f %%\n',avgMotorEff)
end


figure;
plot(GearRatios,effAtGRs,'LineWidth',2)
xlabel('Gear Ratio')
ylabel('MPGe')
grid on



% %% Important Stats
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
% 
% %% Plot Drive Cycle Adherance Over Time
PlotDriveCycleAdherance;
% 
% %% Plot Motor Torque Speed Operating Points
% PlotTorqueSpeedOPs;
% 
% %% Plot Tractive & Braking Forces Over Time
% PlotTractiveForces;
% 
% %% Plot Output Power & Energy Over Time
% PlotPowerAndEnergy;
% 
% %% Plot Driveline Efficiencies Over Time
% PlotDrivelineEff;
% 
% %% Plot Total Vehicle Efficiency Over Time
% PlotTotalVehicleEfficiency;