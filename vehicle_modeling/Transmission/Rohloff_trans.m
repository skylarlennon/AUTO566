% %% Gear Optimization with Constant Power Motor
% clear all
% close all
% 
% % Parameters using targeted mean values
% P = 71.733; % Assume constant power from motor (Watts)
% m = 135; % (kg)
% CdA = .15*.95; % drag coefficient * area (m^2)
% Crr = 0.0018; % Rolling resistance coefficient
% g = 9.81; % Gravity (m/s^2)
% r_wheel = 0.203; % Wheel radius (m)
% rho_air = 1.16; % Air density (kg/m^3)
% dt = 0.1; % Time step (s)
% total_time = 10; % Duration of power application (s)
% coast_time = 20; % Additional time to simulate coasting (s)
% 
% % Gear ratios (internal gear ratios for Rohloff SPEEDHUB 500/14)
% gear_ratios = [0.279, 0.316, 0.360, 0.409, 0.464, 0.528, 0.600, 0.682, ...
%                0.774, 0.881, 1.000, 1.135, 1.292, 1.467];
% 
% % Velocity and distance over time for each gear
% num_steps = (total_time + coast_time) / dt;
% time = linspace(0, total_time + coast_time, num_steps);
% velocities = zeros(length(gear_ratios), num_steps);
% distances = zeros(length(gear_ratios), num_steps);
% 
% for j = 1:length(gear_ratios)
%     v = 0; % Initial velocity (m/s)
%     d = 0; % Initial distance (m)
%     for t = 1:num_steps
%         if time(t) <= total_time
%             T_wheel = (P / max(v, 0.1)) * gear_ratios(j); 
%         else
%             T_wheel = 0;
%         end
% 
%         F_rolling = Crr * m * g; % Rolling resistance force
%         F_aero = 0.5 * rho_air * CdA * v^2; % Aerodynamic drag force
%         F_total = max((T_wheel / r_wheel) - (F_rolling + F_aero), -F_rolling - F_aero); % Net force
%         a = F_total / m; % Acceleration
%         v = max(v + a * dt, 0); % Update velocity, ensuring it doesn't go negative
%         d = d + v * dt; % Integrate velocity to get distance
% 
%         velocities(j, t) = v;
%         distances(j, t) = d;
%     end
% end
% 
% % Plot velocity over time for each gear
% figure;
% subplot(2,1,1); % First subplot for velocity
% hold on;
% for j = 1:length(gear_ratios)
%     plot(time, velocities(j, :), 'LineWidth', 1, 'DisplayName', sprintf('Gear %d', j));
% end
% xlabel('Time (s)');
% ylabel('Velocity (m/s)');
% title('Velocity Over Time for Each Gear with Pulse Power');
% legend show;
% grid on;
% hold off;
% 
% % Plot distance over time for each gear
% subplot(2,1,2); % Second subplot for distance
% hold on;
% for j = 1:length(gear_ratios)
%     plot(time, distances(j, :), 'LineWidth', 1, 'DisplayName', sprintf('Gear %d', j));
% end
% xlabel('Time (s)');
% ylabel('Distance (m)');
% title('Distance Traveled Over Time for Each Gear');
% legend show;
% grid on;
% hold off;