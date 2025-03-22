function [F_step, E_step, v_step] = get_road_load_CdA(CdA, T_seg, v_start, accel, grav, incline, mass)
v_current = v_start;
F_step = 0;
E_step = 0;
rho = 1.17;
P = 500;
alpha = -0.47779236;
beta = 1.13554136;
a = 0.01007019;
b = 0.00004361;
c = 0.00000017;

if(T_seg < 1)
    Aero_Drag = 0.5 * rho * CdA * (v_current)^2;
    Incline_Force = mass * sin(incline*pi/180) * grav;
    Rolling_Res = 2 * P^alpha*(mass*0.35 * grav)^beta *(a + b*v_current + c*v_current^2)...
        + P^alpha*(mass*0.3 * grav)^beta *(a + b*v_current + c*v_current^2);
    Accel_Force = accel * mass*1.1;
    F_step = Aero_Drag + Rolling_Res + Incline_Force + Accel_Force + 4.5;
    E_step = (v_current)*F_step*T_seg;
    v_step = v_current;
else
for i = 1:T_seg
    Aero_Drag = 0.5 * rho * CdA * (v_current + 1.5)^2;
    Incline_Force = mass * sin(incline*pi/180) * grav;
    Rolling_Res = 2 * P^alpha*(mass*0.35 * grav)^beta *(a + b*v_current + c*v_current^2)...
        + P^alpha*(mass*0.3 * grav)^beta *(a + b*v_current + c*v_current^2);
    Accel_Force = accel * mass;
    F_step(i, 1) = Aero_Drag + Rolling_Res + Incline_Force + Accel_Force + 4.5;
    E_step(i, 1) = (v_current)*F_step(i);
    v_step(i, 1) = v_current;
    v_current = v_current + accel;
end
end