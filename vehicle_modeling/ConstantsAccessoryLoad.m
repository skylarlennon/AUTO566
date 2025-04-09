% Accessory Load 
% From 'Measured Power Consumption' https://docs.google.com/spreadsheets/d/190vT6v-ePRVMgp5U1tI9A5KcsTzH5T2C7pJzoJzDnBM/edit?gid=5188018#gid=5188018
Comms = 1.55;
DAQ	= 0.67;
Inverter_Overhead = 1.692;

AccessoryLoad = Comms+DAQ+Inverter_Overhead; % (W) 