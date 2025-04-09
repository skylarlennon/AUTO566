% Motor (KDE Direct 7208XF)
rawMotorEff = readmatrix("csv/motorEffOut.csv");
motorEff = rawMotorEff(2:end, 2:end);
torqueBreakpoints = rawMotorEff(2:end,1);
omegaBreakpoints = rawMotorEff(1,2:end);
motorMaxTorque = torqueBreakpoints(end);
motorMaxSpeed = omegaBreakpoints(end); % [radps]
motorMaxPower = 2e3;
Kv = 135; % [RPM/V]
R_ph = 0.11;