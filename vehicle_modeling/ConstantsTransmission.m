% Transmission
r_wheel = 0.3048;
rollingResistCoeff = 0.01; % TODO: Get better estimate
% TODO: Next model has non-static gear ratio
Ndriving = 1; 
Ndriven = 15;
GR = Ndriven/Ndriving;
Spinloss = 0.1; % [N-m] TODO: Get better estimate & model of transmission losses
maxBrakeForce = 400; %N