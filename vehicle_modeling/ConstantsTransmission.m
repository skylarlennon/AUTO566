run("ConstantsMotor.m")
% Transmission
r_wheel = 0.277;
Crr = 0.002; % TODO: Get better estimate
% TODO: Next model has non-static gear ratio
Ndriving = 8; 
Ndriven = [24, 45, 80];
GRs = Ndriven/Ndriving;
GR = GRs(end); %temporary
numRatios = length(GRs);
transmission_efficiency = ones(1,numRatios) * .98; %Baseline efficiency of motor to trans
transmission_efficiency = transmission_efficiency - (0:0.01:0.01*(numRatios-1)); % Higher gears slightly less efficient
maxBrakeForce = 990; %N

% VCarMax = motorMaxSpeed*r_wheel/GRs(1);
VCarMax = 17; % 38 mph (arbitrary-ish)

GRSelectionTorqueBPs = linspace(0,motorMaxTorque,100);
GRSelectionSpeedBPs = linspace(0,VCarMax,100);


