% Battery Cell: https://amprius2023.my.salesforce.com/sfc/p/#Dn00000ADl27/a/S6000004DgLh/JaAIkWR7XpALxppUH4K.Uw_ddnppEKIlbsoxI5B9F4A
%% Obtaining a Polynomial Equation for OCV as a function of SOC:

SOC_experimental = [0; 0.006743708; 0.010597361; 0.017341069; 0.023121475; 0.031791936; 0.039499094; 0.048169555; 0.058766916; 0.07032758; 0.080924941; 0.092485605; 0.105973022;
0.119460586; 0.132948002; 0.149325622; 0.165703241; 0.180154108; 0.195568424; 0.210982741; 0.22639691; 0.241811227; 0.255298644; 0.272639713; 0.289017333; 0.304431649; 0.320809269;
0.336223585; 0.351637755; 0.368978824; 0.385356443; 0.39980731; 0.414258177; 0.429672493; 0.44315991; 0.456647474; 0.472061643; 0.48651251; 0.500963376; 0.517341069; 0.53082856; 0.546242803;
0.561657046; 0.578034739; 0.594412358; 0.610789977; 0.62716767; 0.642581913; 0.657996156; 0.672447023; 0.685934513; 0.699422004; 0.71387287; 0.72736036; 0.741811227; 0.756262094; 0.77071296;
0.78709058; 0.802504823; 0.818882516; 0.834296759; 0.850674378; 0.867052071; 0.884393067; 0.902697513; 0.918111756; 0.934489449; 0.948940315; 0.965317935; 0.980732178; 0.994219668; 0.999036624; 1];

OCV_experimental = [2.5; 2.576086835; 2.614130149; 2.657608577; 2.695651891; 2.739130319; 2.777173633; 2.815217154; 2.858695375; 2.899456246; 2.934782417; 2.967391031; 2.999999852; 3.029891116;
3.05978238; 3.092391201; 3.116847558; 3.141304122; 3.163043336; 3.184782343; 3.203804207; 3.222825864; 3.244565078; 3.266304085; 3.285325949; 3.307064956; 3.32608682; 3.345108477; 3.364130341;
3.380434648; 3.402173655; 3.423912869; 3.445652083; 3.46467374; 3.483695397; 3.505434611; 3.527173825; 3.551630182; 3.573369396; 3.59782596; 3.622282524; 3.644021531; 3.665760745; 3.687499752;
3.706521616; 3.722825923; 3.74184758; 3.758152094; 3.774456401; 3.790760708; 3.807065015; 3.820651972; 3.836956279; 3.853260793; 3.8749998; 3.891304107; 3.915760671; 3.932065082; 3.951086842;
3.959238996; 3.967391149; 3.978260756; 3.98641291; 3.994565063; 3.999999867; 4.00815202; 4.016304174; 4.021738977; 4.035325934; 4.054347695; 4.078804259; 4.11956513; 4.182065111];

Polynomial_Eqn = polyfit(SOC_experimental, OCV_experimental, 3);

data = readtable('Battery_Data.xlsx');

Vt_Experimental = data.TerminalVoltage;
time = data.Time;

%%
SOC_0 = 1.0;  % Initial State of Charge [Unitless]
Rs = 0.01;    % Ohmic Resistance [Ohm]
R1 = 0.01;    % Resistance over RC pair [Ohm]
C = 300;      % Capacitance over RC pair [Farad = Charge/Volt]
Q = 4.0*4;    % Cell Capacity * 4 cells in parallel [Ah]

Tspan = (0:1:3599); % [seconds] Simulation Time
Delta_t = 1; % [seconds] Simulation Step Time

I_app = zeros(length(Tspan),1);
I_app(1:250) = 16;  
I_app(251:500) = 0; 
I_app(501:1000) = 3;




I_app = [Tspan.', I_app];

Model_Name = 'SuperMileage_BMS_Simulink_Model.slx';

sim_output = sim(Model_Name, 'SaveTime', 'on', ...
                             'SaveState', 'on', ...
                             'SaveOutput', 'on', ...
                             'TimeSaveName', 'tout', ...
                             'SaveFormat', 'StructureWithTime');

Vt_Simulated = sim_output.Vt;
SOC_Out = sim_output.SOC_Out;
I_Out = sim_output.I_Out;
tout = sim_output.tout;

alpha = [1.1981,   -2.6331,    2.9057,    2.6520];

ocv_vec = polyval(alpha,SOC_Out);

plot(tout,ocv_vec)
% 
y = ocv_vec - Vt_Simulated;
% 
phi = [I_Out(2:end),I_Out(1:end-1),-1*y(1:end-1)];
theta = phi\y(2:end);

plot(tout,Vt_Simulated)
hold on
%plot(tout,ocv_vec)
title('Pack Terminal Voltage [V] vs. Time [s]')
xlabel('Time [s]')
ylabel('Pack Terminal Voltage [V]')
legend('Simulated Voltage','Experimental Voltage')


