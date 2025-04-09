figure;
grid on
hold on

yyaxis left
% plot(tout, speedCommand,'-b')
plot(time, speedCommand,'-b')
plot(tout, speedVehicle,'-r')
ylabel('Velocity (m/s)')

yyaxis right
% plot(tout,elevation,'-k')
plot(time,elevation,'-k')
h = ylabel('Elevation (m)');
set(h,'Color','black')
ax = gca;
ax.YColor = 'black';

hold off
xlim([0 tout(end)])
xlabel('Time (s)')
legend('Drive Cycle Velocity','Simulated Velocity','Elevation')
title('EV Simple Drive Cycle Adherance Over Time')
% calculate the drive cycle adherance %
total_error = sum(abs(speedCommand - speedVehicle));
total_adherance = sum(abs(speedCommand));
total_drive_cycle_adherance = (1-(total_error/total_adherance))*100;

fprintf("Drive Cycle Adherance:\t%.4f %%\n",total_drive_cycle_adherance)