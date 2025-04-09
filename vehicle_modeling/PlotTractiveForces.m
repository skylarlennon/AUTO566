figure;
grid on
hold on

yyaxis left
plot(tout,positiveTractiveForceOut,'-b')
plot(tout,frictionBrakingForceOut,'-r')
ylabel('Tractive Force (N)')

yyaxis right
plot(time,elevation,'-k')
h = ylabel('Elevation (m)');
set(h,'Color','black')
ax = gca;
ax.YColor = 'black';

hold off
xlim([0 tout(end)]) %plot 3 laps
xlabel('Time (s)')
legend('Positive Tractive Force','Friction Braking Force','Elevation')
title('EV Simple Motor Tractive Force Over Time')