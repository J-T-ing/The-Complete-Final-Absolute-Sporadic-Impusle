clear
clc
close all
format long
rocket.mass_init = 41.996;
rocket.mass_final =30;
g = 9.81;
%at time zero
rocket_vel = 0; %RK4 Variable
rocket.isp = 180;
rocket.alt = 0;
ti = 0;
step = 0.001;
tf = 40;
tSteps = ti:step:tf;
h = 0.1;
time = 0;
rocket_mass = rocket.mass_init;
alt = [];
time = [];
vel = [];
mass = [];
res = [];
mach = [];
hybrid_burn_time = 15;
cd = 0.6;
sref = 0.0201;
rocket.mass_flow = 1000/(g*rocket.isp);
%Takes thrust curves, returns variable holding total thrust over time
booster = readmatrix('K250Curve.csv');
hybrid = readmatrix('HybridCurve.csv');
x = linspace(0,tf,tf/step);
y = 2.*interp1(booster(:,1),booster(:,2),x);
y(isnan(y)== 1) = 0;
hybrid = interp1(hybrid(:,1),hybrid(:,2),x);
hybrid(isnan(hybrid)== 1) = 0;
rocket_thrust = (hybrid + y);

count = 0;

f = @(v,i,rho,a,idx) (rocket_thrust(idx)-(rocket_mass(idx)*g)-(0.5.*rho.*v.^2.*cd.*sref)/(1-(v./a)^2))./rocket_mass(idx);
for i = 1:length(tSteps)-1
    disp(i);
    [~,a,~,rho] = atmosisa(rocket.alt);
    k1 = h*f(rocket_vel(i), tSteps(i),rho,a,i);
    k2 = h*f(rocket_vel(i) + k1/2, tSteps(i)+ h/2,rho,a,i);
    k3 = h*f(rocket_vel(i) + k2/2,tSteps(i)+ h/2,rho,a,i);
    k4 = h*f(rocket_vel(i) + k3, tSteps(i)+ h,rho,a,i);
    rocket_vel(i+1) = rocket_vel(i) + k1/6 + k2/3 + k3/3 + k4/6;
    rocket.alt = rocket.alt + rocket_vel(i)*step;
    if rocket_mass(i) >= rocket.mass_final
        rocket_mass(i+1) = rocket_mass(i) - rocket.mass_flow*step;
    else
        rocket_mass(i+1) = rocket_mass(i);
    end
    alt(end+1) = rocket.alt;
    vel(end+1) = rocket_vel(i);
    time(end+1) = i;
    mass(end+1) = rocket_mass(i);
    mach(end+1) = rocket_vel(i)/a;
    disp(count+1);
end
subplot(2,2,1)
plot(time,alt)
xlabel('Time (s)')
ylabel('Altitude (m)')
%xlim([0 maxT])
title('Altitude vs Time')
grid
subplot(2,2,2)
plot(time,vel)
xlabel('Time (s)')
ylabel('Velocity (m s^-1)')
%xlim([0 maxT])
grid
title('Velocity vs Time')
subplot(2,2,3)
plot(time,res)
xlabel('Time (s)')
ylabel('Resultant acceleration (ms-2)')
%xlim([0 maxT])
grid
title('Resultant acceleration (ms-2)')
subplot(2,2,4)
plot(time,mach)
title('Mach number')
xlabel('Time (s)')
ylabel('Mach number')
grid
% figure
% plot(time,mass)
% title('Mass')
% xlabel('Time (s)')
% ylabel('Mass (kg)')
% grid