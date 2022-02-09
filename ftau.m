function trns1=ftau(Z, datapath)
% Transmission coefficient as a function of incidence angle
% J.A. Duffie, W. A. Beckman (2013) Solar Engineering of Thermal Processes
%
% Inputs:
% Z         surface azimuth in deg: [-180 180]; 0-south; west-positive
% datapath  path for the folder containing the data
%
% Variables:
% Data = [month day hour minute HorizRad]
% month     number of the month, from 1 to 12
% day       day in the month, from 1 to 31 
% hour      hour in the 24 hour system (e.g. 13 for 1 p.m.)
% minute    minute from 0 to 59
% DirNRad   direct normal radiation, Wh/m2
% DifHRad   diffuse horizontal radiation, Wh/m2
%
% Output:
% trns1     transmission coefficient corresponding to each data record

H = dlmread(strcat(datapath, 'TwinHouse.csv'));   % house
% W = dlmread(strcat(datapath, 'TwinWeather.csv')); % weather
L = 47.874;     % local latitude in deg: [-90 90], north positive
B = 90;         % slope (tilt) angle in deg: [0 180];
                % 90    - vertical;
                % >90   - downward facing.

de = datestr(H(:,1)+H(:,2));
[Y, M, D, H, MI, S] = datevec(de);
n = datenum(0, M, D); % day number in the year

declination_angle=23.45*sin(360*(284+n)/365*pi/180); % eq. 1.6.1a 
d=declination_angle*pi/180;

hour_angle = ((H+MI/60)-12)*15; % Example 1.6.1
h = hour_angle*pi/180;

% Incidence angle [rad]
theta = acos(sin(d)*sin(L)*cos(B) - sin(d)*cos(L)*sin(B)*cos(Z) ...
  + cos(d)*cos(L)*cos(B).*cos(h) + cos(d)*sin(L)*sin(B)*cos(Z).*cos(h)...
  + cos(d)*sin(B)*sin(Z).*sin(h)); % incidence angle eq. 1.6.2

theta=theta*180/pi; % incidence angle [deg]

% Transmission coefficient as a function of angle
no_records = 5905;      % number of records in data file
trns1=zeros(no_records,1);
for n=1:no_records
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
    elseif theta(n,1)>80 & theta(n,1)<90
        trns1(n,1)=0;
    end
end
    
