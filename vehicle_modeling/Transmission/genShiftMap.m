engine_speed = [600:200:6000]*2*pi/60;    % rad/sec
Throttle_grid=[0:5:100];
for k = 1:21
    for j = 1:28
       engine_out_power(k,j) = engine_speed(j)*engine_torque(k,j)/1000;    % engine out power (kW)
       bsfc(k,j) = fuel_map(k,j)/engine_out_power(k,j);                     % BSFC = g/sec/kW
       if (bsfc(k,j) < 0)
           bsfc(k,j) = 0.2;
       elseif (bsfc(k,j) > 0.2)
           bsfc(k,j) = 0.2;
       end
    end
end
figure(1)
contour(engine_speed, Throttle_grid, bsfc, 150)
xlabel('Engine speed [600:200:6000] (rpm)')
ylabel('Throttle [0:5:100]')

% Part 2
% Optimal engine speed was obtained by visually examining the plot above
Throttle = [0,5,10,15,20,25,30,35,40,45:5:100]; 
w_e_opt = [600,600,600,600,960,1320,1680,2040,2400, 2420:20:2640];  % RPM!!
% Calculate NV ratio, with unit of RPM/MPH
NV_ratio = FR * gear_torque_ratio(:)/tire_radius*60/(2*pi)*1602/3600;
for k = 1:21
  M_up(k,1) = 0.5*w_e_opt(k)*(1/NV_ratio(1)+1/NV_ratio(2));  % 1 to 2
  M_up(k,2) = 0.5*w_e_opt(k)*(1/NV_ratio(2)+1/NV_ratio(3));  % 2 to 3
  M_up(k,3) = 0.5*w_e_opt(k)*(1/NV_ratio(3)+1/NV_ratio(4));  % 3 to 4
  M_up(k,4) = 300;
   
  M_down(k,1) = 0;
  M_down(k,2) = min(M_up(k,1)*0.85, M_up(k,1)-4);
  M_down(k,3) = min(M_up(k,2)*0.85, M_up(k,2)-4);
  M_down(k,4) = min(M_up(k,3)*0.85, M_up(k,3)-4);
  
end
figure(2)
plot(M_up(:, 1:3), 0:5:100, 'ro-', M_down(:,1:3), 0:5:100, 'bx-.')
xlabel('Vehicle speed (mph)')
ylabel('Throttle (%)')
title('Upshift: red o    Down shift: blue x')