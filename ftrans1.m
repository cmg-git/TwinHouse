function trns1=ftrans1(Z)
 %= fSolRadTiltSurf(month, day, hour, minute, DirNRad, RadHDif, B, Z, L, albedo)
% J.A. Duffie, W. A. Beckman (2013) Solar Engineering of Thermal Processes
%
% Data = [month day hour minute HorizRad]
% month   number of the month, from 1 to 12
% day     day in the month, from 1 to 31 
% hour    hour in the 24 hour system (e.g. 13 for 1 p.m.)
% minute  minute from 0 to 59
% DirNRad direct normal radiation, Wh/m2
% DifHRad  diffuse horizontal radiation, Wh/m2
%
H = dlmread('TwinHouse.csv');   % house
W = dlmread('TwinWeather.csv'); % weather
L =47.874;      %local latitude in deg: [-90 90], north positive
B=90;       %slope (tilt) angle in deg: [0 180]; 90-vertical; >90-downward facing
%Z=90;       %surface azimuth in deg: [-180 180]; 0-south; west-positive
% albedo  albedo of ground = 0.2 Th-CE 2005 pg. 50
%
% Outputs
% PhiDir  direct radiation on the surface in Wh/m2
% PhiDif  diffuse radiation on the surfaca in Wh/m2

B = B*pi/180; % slope
Z = Z*pi/180; % azimuth
L = L*pi/180; % latitude
% v = 0:1:23;
% u = repelem(v,6);
% b=repmat(u,1,41);
% x=0:10:50;
% z=repmat(x,1,24*41);
% b=b';
% b=[b;0];
% z=z';
% z=[z;0];
% a=21:1:31;
% a=a';
% c=1:30;
% c=c';
% d=[a;c];
% e=repelem(d,144);
% e=[e;1];
% m=[8 9];
% month=repelem(m,[11*24*6 30*24*6+1]);
% month=month';
% day=e;
% hour=b;
% minute=z;
de=datestr(H(:,1)+H(:,2));
[Y, M, D, H, MI, S] = datevec(de);
n = datenum(0, M, D); % day number in the year
%n=H(:,1);
declination_angle=23.45*sin(360*(284+n)/365*pi/180); % eq. 1.6.1a 
d=declination_angle*pi/180;

hour_angle=((H+MI/60)-12)*15; % Example 1.6.1
h=hour_angle*pi/180;
trns=[0.512 0.515 0.508 0.498 0.484 0.458 0.401 0.293 0.136 0];
theta = acos(sin(d)*sin(L)*cos(B) - sin(d)*cos(L)*sin(B)*cos(Z) ...
  + cos(d)*cos(L)*cos(B).*cos(h) + cos(d)*sin(L)*sin(B)*cos(Z).*cos(h)...
  + cos(d)*sin(B)*sin(Z).*sin(h)); % incidence angle eq. 1.6.2

theta=theta*180/pi;
trns1=zeros(5905,1);
for n=1:5905
if theta(n,1)>0 & theta(n,1)<20
    trns1(n,1)=0.515;
elseif theta(n,1)>20 & theta(n,1)<30
    trns1(n,1)=0.508;
elseif theta(n,1)>30 & theta(n,1)<50
    trns1(n,1)=0.490;
elseif theta(n,1)>50 & theta(n,1)<60
    trns1(n,1)=0.401;
elseif theta(n,1)>60 & theta(n,1)<70
    trns1(n,1)=0.293;
elseif theta(n,1)>70 & theta(n,1)<80
    trns1(n,1)=0.136;
elseif theta(n,1)>90 & theta(n,1)<90
    trns1(n,1)=0;
end
end
    
