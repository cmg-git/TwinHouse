% Author Christian Ghiaus
% date 21/03/2020

%% N2 House: all 7 zones
% 1) k  kitchen
% 2) d  doorway
% 3) 1b 1st bedroom
% 4) l  livingroom
% 5) c  corridor
% 5) b  bathroom
% 7) 2b 2nd bedroom
clear all
clc

%% Conditions
% LW and SW different: to be treated

%% Read data
% datapath = '/Users/cghiaus/Personel/Recherche/Work/TwinHouse/';
datapath = '';
H = dlmread(strcat(datapath, 'TwinHouse.csv'));   % house
W = dlmread(strcat(datapath, 'TwinWeather.csv')); % weather

% Temperatures in rooms
T1 = H(:,12);   % kitchen
T2 = H(:,13);   % doorway
T3 = H(:,14);   % bedroom 1
T4 = (H(:,6) + H(:,7) + H(:,8))/3; % living mean(67cm, 125cm, 187cm)
T5 = H(:,9);    % corridor
T6 = H(:,10);   % bathroom
T7 = H(:,11);   % bedroom 2 (children)

Ta = H(:,4);    % attic
Tg = H(:,5);    % cellar (groud)
Tv = H(:,30);   % ventilation supply air

% Electrical power in rooms
Q1 = H(:,24) + H(:,25); % kitchen heater + duct losses
Q2 = H(:,26);   % doorway
Q3 = H(:,27);   % bedroom 1
Q4 = H(:,21);   % living
Q5 = zeros(size(Q2)); % corridor
Q6 = H(:,22);   % bathroom 
Q7 = H(:,23);   % bedroom 2 (children)

% Weather
To = W(:,3);    % outdoor
Qn = W(:,6);    % Solar radiation   North wall
Qe = W(:,7);    %                   East wall
Qs = W(:,8);    %                   South wall
Qw = W(:,9);    %                   West wall

%% Physical values
ho = 23;                % outdoor convection coefficient
hi = 8;                 % indoor convection coefficent
rhoa = 1.2; ca = 1000;  % indoor air: density & heat capacity
alphaOut = 0.23;        % short wave absortivity wall out
alphaIn = 0.17;         % short wave absortivity wall in
tau = 0.427;            % short wave windows transmittance
% transmission coefficient function of azimuth & time
tauS = ftau(0, datapath);   % South
tauW = ftau(90, datapath);  % West
tauN = ftau(180, datapath); % North
tauE = ftau(-90, datapath); % East

%% Radiative flow in rooms: windows & heater
Aw = 1.24*1.46;             % window area

%Qrk = alphaIn*Aw*tau*Qw + 0.3*H(:,24);  % kit: West window + k-heater;
Qr1 = alphaIn*Aw*tauW.*Qw + 0.3*Q1; % kitchen: West window + k-heater
Qr2 = 0.3*Q2;                       % doorway
Qr3 = alphaIn*Aw*tauN.*Qn + 0.3*Q3; % bedroom_1
Qr4 = alphaIn*Aw*tauW.*Qw + 0.3*Q4; % livingroom: West window
Qr5 = 0.3*Q5;                       % corridor
Qr6 = alphaIn*Aw*tauE.*Qe + 0.3*Q6; % bathroom    
Qr7 = alphaIn*Aw*tauS.*Qs + 0.3*Q7; % bedroom_2

%% Surfaces & volumes of rooms
S1 = 2*(2.495*(2.83 + 2.62) + 2.83*2.62);   % kitchen
V1 = 2.495*2.83*2.62;
S2 = 2*(2.495*(2.22 + 2.62) + 2.22*2.62);   % doorway
V2 = 2.495*2.22*2.62;
S3 = 2*(2.495*(3.88 + 2.88) + 3.88*2.88);   % bedroom_1
V3 = 2.495*3.88*2.88;
S4 = 2*(2.495*(5.20 + 6.46) + 5.20*6.46);   % livingroom
V4 = 2.495*5.20*6.46;
S5 = 2*(2.495*(1.65 + 3.29) + 1.65*3.29);   % corridor
V5 = 2.495*1.65*3.29;
S6 = 2*(2.495*(2.08 + 3.29) + 2.08*3.29);   % bathroom
V6 = 2.495*2.08*3.29;   
S7 = 2*(2.495*(3.88 + 2.88) + 3.88*2.88);   % bedroom_2
V7 = 2.495*3.88*2.88;

%% Types of walls and doors (Wall1D & Wall1Dbc)
% Type K1: external wall (red)
% 5 layers: [ext.plaster; insulation; plaster; brick; int.plaster]
nm = [0     4       0       8       1]';    % number of meshes
w =  [0.01  0.12    0.03    0.20    0.01]'; % width
lam =[0.80  0.035   1.00    0.22    1]';    % conductivity
rho =[1200  80      1200    800     1200]'; % density
c =  [1000  840     1000    1000    1000]'; % specific heat

T = Wall1D([nm w lam rho c]);               % 1D heat transfer
h = [ho hi];                                % convection outside; inside
b = [1 0];                                  % T-source out
f = [1 1];                                  % Q-source out and in
K1 = Wall1Dbc(T.TC, h, b, f);               % 1D h.t. w/ bound. cond.

% Type K2: internal wall (blue)
% 1 layer: [plaster, brick, plaster]
nm = [1      3       1]';    % number of meshes
nm = [0      1       0]';    % number of meshes
w =  [0.01   0.24    0.01]'; % width
lam =[0.35   0.33    0.35]'; % conductivity
rho =[1200   1000    1200]'; % density
c =  [1000   1000    1000]'; % specific heat

T = Wall1D([nm w lam rho c]);
h = [hi hi];                % convection outside; inside
b = [0 0];                  % T-source out
f = [1 1];                  % Q-source in
K2 = Wall1Dbc(T.TC, h, b, f);

% Type K3: internal wall (green)
% 1 layer: [brick] //plaster is neglected
nm = [1     2   1]';         % number of meshes
w =  [0.01  0.115   0.01]';  % width
lam =[0.35  0.33    0.35]';  % conductivity
rho =[1200  1000    1200]';  % density
c =  [1000  1000    1000]';  % specific heat

T = Wall1D([nm w lam rho c]);
h = [hi hi];                 % convection outside;
b = [0 0];                  % T-source out
f = [1 1];                  % Q-source in
K3 = Wall1Dbc(T.TC, h, b, f);

% Type K4: attic wall
% 5 layers: [screed; insulation; concrete; plaster; int. insulation]
nm = [0     0       3       0       3]';    % number of meshes
w =  [0.04  0.04    0.22    0.01    0.10]'; % width
lam =[1.40  0.04    2.00    1.00    0.035]';% conductivity
rho =[2000  80      2400    1200    80]';   % density
c =  [2000  840     1000    1000    840]';  % specific heat

T = Wall1D([nm w lam rho c]);
h = [hi hi];    % convection outside; inside
b = [1 0];      % T-source out
f = [0 1];      % Q-source in
K4 = Wall1Dbc(T.TC, h, b, f);

% Type K5: cellar wall
% 5 layers: [concrete; fill; insulation; panel; int. screed]
nm = [3     0       1       0       3]';    % number of meshes
w =  [0.22  0.03    0.03    0.03    0.065]';% width
lam =[2.1   0.06    0.025   0.023   1.4]';  % conductivity
rho =[2400  80      80      80      2000]'; % density
c =  [1000  840     840     840     1000]'; % specific heat

T = Wall1D([nm w lam rho c]);
h = [hi hi];    % convection outside; inside
b = [1 0];      % T-source out
f = [0 1];      % Q-source in
K5 = Wall1Dbc(T.TC, h, b, f);

% Type K6: interior door
% 1 layer: [wood]
nm = 1;         % number of meshes
w =  0.04;      % width
lam = 0.13;     % conductivity
rho = 600;      % density
c = 1000;       % specific heat

T = Wall1D([nm w lam rho c]);
h = [hi hi];    % convection outside; inside
b = [0 0];      % T-source out
f = [1 1];      % Q-source in
K6 = Wall1Dbc(T.TC, h, b, f);

% Type K7: exterior door
% 1 layer: [wood]
nm = 1;         % number of meshes
w =  0.04;      % width
lam = 0.13;     % conductivity
rho = 600;      % density
c = 1000;       % specific heat

T = Wall1D([nm w lam rho c]);
h = [ho hi];    % convection outside; inside
b = [1 0];      % T-source out
f = [1 1];      % Q-source in
K7 = Wall1Dbc(T.TC, h, b, f);

% Type K8: Window outdoor with blinds up
nm = 0;
w = 1;
lam = 1.2;
rho = 600;
c = 1000;
T = Wall1D([nm w lam rho c]);
h = [0 hi];     % convection inside
b = [1 0];      % T-source out
f = [0 1];      % Q-source in
K8 = Wall1Dbc(T.TC, h, b, f);

%% Elements constructed from types
% K0    7 thermal zones, i.e. air in rooms, (TCd1..7) of type 0 (in cyan)
% K1    10 external walls (TCd8..17) of type 1 (in red)
% K2    6 indoor walls (TCd18..23) of type 2 (in blue)
% K3    3 indoor walls (TCd24..26) of type 3 (in green)
% K4    7 ceilings (TCd27..33) of type 4 (in orange)
%% K0 Thermal zones (air in rooms)
t0 = 0;                 % start index / object type

ACH50 = 1.62;           % infiltration rate at 50 Pa
Kon = 1e5;              % controller ON;
Koff = 1e-5;            % controller OFF
TCd{t0+1} = AirZPillar(1, V1, ACH50, Koff, [To'; T1'], 0.7*Q1');    % kit
TCd{t0+2} = AirZ(1, V2, ACH50, Koff, [To'; T2'], 0.7*Q2');          % doorw
TCd{t0+3} = AirZPillar(1, V3, ACH50, Koff, [To'; T3'], 0.7*Q3');    % 1bed
TCd{t0+4} = AirZPillar(1, V4, ACH50, Koff, [To'; T4'], 0.7*Q4');    % liv
TCd{t0+5} = AirZ(0, V5, ACH50, Koff, [To'; T5'], 0.7*Q5');          % corr
TCd{t0+6} = AirZ(0, V6, ACH50, Koff, [To'; T6'], 0.7*Q6');          % bath
TCd{t0+7} = AirZPillar(1, V7, ACH50, Koff, [To'; T7'], 0.7*Q7');    % 2bed
nt0 = 7;    % no. of objects of this type

%% K1 External walls (red)
t(1) = nt0;             % start index / object type

S = 2.495*2.62 - 1.24*1.46;
TCd{t(1)+1} = Wall(K1.TC, S, To', [S*alphaOut*Qw'; S/S1*Qr1']); % k W

S = 2.495*2.83;
TCd{t(1)+2} = Wall(K1.TC, S, To', [S*alphaOut*Qn'; S/S1*Qr1']); % k N

S = 2.495*2.22 - 1.00*2.00;
TCd{t(1)+3} = Wall(K1.TC, S, To', [S*alphaOut*Qn'; S/S2*Qr2']); % d N

S = 2.495*3.88 - 1.24*1.46;
TCd{t(1)+4} = Wall(K1.TC, S, To', [S*alphaOut*Qn'; S/S3*Qr3']); % 1b N

S = 2.495*2.88;
TCd{t(1)+5} = Wall(K1.TC, S, To', [S*alphaOut*Qe'; S/S3*Qr3']); % 1b N

S = 2.495*6.46 - 1.24*1.46;
TCd{t(1)+6} = Wall(K1.TC, S, To', [S*alphaOut*Qw'; S/S4*Qr4']); % l W

S = 2.495*3.29 - 1.24*1.46;
TCd{t(1)+7} = Wall(K1.TC, S, To', [S*alphaOut*Qe'; S/S6*Qr6']); % bath E

S = 2.495*2.88;
TCd{t(1)+8} = Wall(K1.TC, S, To', [S*alphaOut*Qe'; S/S7*Qr7']); % 2bed E

S = 2.495*5.20 - 4.46*2.28;
TCd{t(1)+9} = Wall(K1.TC, S, To', [S*alphaOut*Qs'; S/S4*Qr4']); % liv S

S = 2.495*3.88 - 1.24*1.46;
TCd{t(1)+10} = Wall(K1.TC, S, To', [S*alphaOut*Qs'; S/S7*Qr7']);% 2bed S

nt(1) = 10;  % no. of objects of this type

%% K2 Indoor wall (blue)
t(2) = nt0+sum(nt);         % start index / object type

S = 2.495*2.62;
TCd{t(2)+1} = Wall(K2.TC, S, [], [S/S2*Qr2'; S/S1*Qr1']);   % doorw->kit

S = 2.495*2.62;
TCd{t(2)+2} = Wall(K2.TC, S, [], [S/S2*Qr2'; S/S3*Qr3']);   % doorw->1bed

S = 2.495*2.83 - 0.95*1.95;
TCd{t(2)+3} = Wall(K2.TC, S, [], [S/S4*Qr4'; S/S1*Qr1']);   % liv->kit

S = 2.495*2.22 - 0.95*1.95;
TCd{t(2)+4} = Wall(K2.TC, S, [], [S/S2*Qr2'; S/S4*Qr4']);   % dorw->liv

S = 2.495*3.29 - 0.95*1.95;
TCd{t(2)+5} = Wall(K2.TC, S, [], [S/S5*Qr5'; S/S4*Qr4']);   % dorw->liv

S = 2.495*2.88;
TCd{t(2)+6} = Wall(K2.TC, S, [], [S/S7*Qr7'; S/S4*Qr4']);   % 2bed->liv

nt(2) = 6;  % no. of objects of this type

%% K3 Indoor wall (green)
t(3) = nt0+sum(nt);         % start index / object type

S = 2.495*2.08;
TCd{t(3)+1} = Wall(K3.TC, S, [], [S/S3*Qr3'; S/S6*Qr6']);

S = 2.495*3.29 - 0.95*1.95;
TCd{t(3)+2} = Wall(K3.TC, S, [], [S/S5*Qr5'; S/S6*Qr6']); % c-iwall2

S = 2.495*2.08;
TCd{t(3)+3} = Wall(K3.TC, S, [], [S/S3*Qr3'; S/S6*Qr6']);

nt(3) = 3;

%% K4 Ceiling
t(4) = nt0+sum(nt);         % start index / object type
S = 2.83*2.62;
TCd{t(4)+1} = Wall(K4.TC, S, Ta', S/S1*Qr1'); % kit - attic

S = 2.22*2.62;
TCd{t(4)+2} = Wall(K4.TC, S, Ta', S/S2*Qr2');   % doorw - attic

S = 3.88*2.88;
TCd{t(4)+3} = Wall(K4.TC, S, Ta', S/S3*Qr3');  % 1bed - attic

S = 5.20*6.46;
TCd{t(4)+4} = Wall(K4.TC, S, Ta', S/S4*Qr4');    % liv - attic

S = 1.65*3.29;
TCd{t(4)+5} = Wall(K4.TC, S, Ta', S/S5*Qr5');    % corr - attic

S = 2.08*3.29;
TCd{t(4)+6} = Wall(K4.TC, S, Ta', S/S6*Qr6');    % bath - attic

S = 3.88*2.88;
TCd{t(4)+7} = Wall(K4.TC, S, Ta', S/S7*Qr7');    % 2bed - attic

nt(4) = 7;  % no. of objects of this type

%% K5 Floor
t(5) = nt0+sum(nt);         % start index / object type
S = 2.83*2.62;
TCd{t(5)+1} = Wall(K5.TC, S, Tg', S/S1*Qr1');   % kit - ground

S = 2.22*2.62;
TCd{t(5)+2} = Wall(K5.TC, S, Tg', S/S2*Qr2');   % kit - ground

S = 3.88*2.88;
TCd{t(5)+3} = Wall(K5.TC, S, Tg', S/S3*Qr3');   % kit - ground

S = 5.20*6.46;
TCd{t(5)+4} = Wall(K5.TC, S, Tg', S/S4*Qr4');   % liv - ground

S = 1.65*3.29;
TCd{t(5)+5} = Wall(K5.TC, S, Tg', S/S5*Qr5');   % corr - ground

S = 2.08*3.29;
TCd{t(5)+6} = Wall(K5.TC, S, Tg', S/S6*Qr6');   % bath - ground

S = 3.88*2.88;
TCd{t(5)+7} = Wall(K5.TC, S, Tg', S/S7*Qr7');   % 2bed - attic

nt(5) = 7;  % no. of objects of this type

%% K6 Door interior
t(6) = nt0+sum(nt);         % start index / object type

S = 0.93*1.95;
TCd{t(6)+1} = Wall(K6.TC, S, [], [S/S4*Qr4'; S/S1*Qr1']);   % l->k
TCd{t(6)+2} = Wall(K6.TC, S, [], [S/S4*Qr4'; S/S2*Qr2']);   % l->d
TCd{t(6)+3} = Wall(K6.TC, S, [], [S/S3*Qr3'; S/S5*Qr5']);   % 1b->c

nt(6) = 3;  % no objects of this type

%% K7 Door exterior
t(7) = nt0+sum(nt);         % start index / object type

S = 1.00*2.00;
TCd{t(7)+1} = Wall(K7.TC, S, To', [S*Qn'; S/S2*Q2']);       % doorw N

nt(7) = 1;  % no. of objects of this type

%% K8 Window
t(8) = nt0+sum(nt);         % start index / object type

S = 1.24*1.46;
TCd{t(8)+1} = Wall(K8.TC, S, To', S/S1*Qr1');               % kit W
TCd{t(8)+2} = Wall(K8.TC, S, To', S/S3*Qr3');               % 1bed N
TCd{t(8)+3} = Wall(K8.TC, S, To', S/S4*Qr4');               % liv W
TCd{t(8)+4} = Wall(K8.TC, S, To', S/S6*Qr6');               % bath E
S = 4.46*2.28;
TCd{t(8)+5} = Wall(K8.TC, S, To', S/S4*Qr4');               % liv S
S = 1.24*1.46;
TCd{t(8)+6} = Wall(K8.TC, S, To', S/S7*Qr7');               % 2bed S

nt(8) = 6;  % no. of objects of this type

%% K9 Infiltration between zones
t(9) = nt0+sum(nt);         % start index / object type

ACH = 0.5;
Vinf = ACH*V1/3600;         % infiltration vol. flow rate
G = rhoa*ca*Vinf;   
TCd{t(9)+1} = InfilTB(G);   % liv - kit

Vinf = ACH*V2/3600;         % infiltration vol. flow rate
G = rhoa*ca*Vinf;   
TCd{t(9)+2} = InfilTB(G);   % doorw-liv

Vinf = ACH*V3/3600;         % infiltration vol. flow rate
G = rhoa*ca*Vinf;   
TCd{t(9)+3} = InfilTB(G);   % 1bed-corr

ACH = 6;
Vinf = ACH*V4/3600;         % infiltration vol. flow rate
G = rhoa*ca*Vinf;   
TCd{t(9)+4} = InfilTB(G);   % liv-corr

Vinf = ACH*V4/2/3600;       % infiltration vol. flow rate
G = rhoa*ca*Vinf;   
TCd{t(9)+5} = InfilTB(G);   % corr-bath

Vinf = ACH*V4/2/3600;       % infiltration vol. flow rate
G = rhoa*ca*Vinf;   
TCd{t(9)+6} = InfilTB(G);   % corr-bath

nt(9) = 6;  % no. of objects of this type

%% K10 Mechanical ventilation
t(10) = nt0+sum(nt);        % start index / object type

A = 1;
Va = 120/3600;              % air-flow rate 120 m3/h
G = rhoa*ca*Va;
b = 1;
C = 0;
f = 0;
y = 0;
TC10 = {A, diag(G), b, diag(C), f, y};
TCd{t(10)+1} = ThermCirc(TC10, Tv', []);

% n = n0+1;
% A = TCd{n}.TC{1}; G = TCd{n}.TC{2}; b = TCd{n}.TC{3};
% C = TCd{n}.TC{4}; f = TCd{n}.TC{5}; y = TCd{n}.TC{6};
% A'*G*A*f + A'*G*b + f + y


%% Assembling
%     Type+# node Type+# node
AssX = [t0+1  1  t(1)+1  TCd{t(1)+1}.e();...    % k:ewall W
        t0+1  1  t(1)+2  TCd{t(1)+2}.e();...    % k:ewall N
        t0+2  1  t(1)+3  TCd{t(1)+3}.e();...    % d:ewall N
        t0+3  1  t(1)+4  TCd{t(1)+4}.e();...    % 1b:ewall
        t0+3  1  t(1)+5  TCd{t(1)+5}.e();...    % 1b:ewall E
        t0+4  1  t(1)+6  TCd{t(1)+6}.e();...    % l:ewall W
        t0+6  1  t(1)+7  TCd{t(1)+7}.e();...    % b:ewall E
        t0+7  1  t(1)+8  TCd{t(1)+8}.e();...    % 2b:ewall E
        t0+4  1  t(1)+9  TCd{t(1)+9}.e();...    % l:ewall S
        t0+7  1  t(1)+10 TCd{t(1)+10}.e();...   % 2b:ewall S
        
        t0+2  1  t(2)+1  1;...                  % d -iwallb
        t0+1  1  t(2)+1  TCd{t(2)+1}.e();...    % k -iwallb
        t0+2  1  t(2)+2  1;...                  % d -iwall1
        t0+3  1  t(2)+2  TCd{t(2)+2}.e();...    % 1b-iwall1
        t0+4  1  t(2)+3  1;...                  % l -iwall1
        t0+1  1  t(2)+3  TCd{t(2)+3}.e();...    % k -iwall1
        t0+2  1  t(2)+4  1;...                  % d -iwall1
        t0+4  1  t(2)+4  TCd{t(2)+4}.e();...    % l -iwall1
        t0+5  1  t(2)+5  1;...                  % c -iwall1
        t0+4  1  t(2)+5  TCd{t(2)+5}.e();...    % l -iwall1
        t0+7  1  t(2)+6  1;...                  % 2b-iwall1
        t0+4  1  t(2)+6  TCd{t(2)+6}.e();...    % l -iwall1

        t0+3  1  t(3)+1  1;...                  % 1b-iwall2
        t0+6  1  t(3)+1  TCd{t(3)+1}.e();...    % b -iwall2
        t0+5  1  t(3)+2  1;...                  % c -iwall2
        t0+6  1  t(3)+2  TCd{t(3)+2}.e();...    % b -iwall2
        t0+7  1  t(3)+3  1;...                  % 2b-iwall2
        t0+6  1  t(3)+3  TCd{t(3)+2}.e();...    % b -iwall2
        
        t0+1  1  t(4)+1  TCd{t(4)+1}.e();...    % k:ceiling
        t0+2  1  t(4)+2  TCd{t(4)+2}.e();...    % d:celing
        t0+3  1  t(4)+3  TCd{t(4)+3}.e();...    % 1b:celing
        t0+4  1  t(4)+4  TCd{t(4)+4}.e();...    % l:ceiling
        t0+5  1  t(4)+5  TCd{t(4)+5}.e();...    % c:ceiling
        t0+6  1  t(4)+6  TCd{t(4)+6}.e();...    % b:ceiling
        t0+7  1  t(4)+7  TCd{t(4)+7}.e();...    % 1b:ceiling
        
        t0+1  1  t(5)+1  TCd{t(5)+1}.e();...    % k:floor
        t0+2  1  t(5)+2  TCd{t(5)+2}.e();...    % d:floor
        t0+3  1  t(5)+3  TCd{t(5)+3}.e();...    % 1b:celing
        t0+4  1  t(5)+4  TCd{t(5)+4}.e();...    % l:floor
        t0+5  1  t(5)+5  TCd{t(5)+5}.e();...    % c:floor
        t0+6  1  t(5)+6  TCd{t(5)+6}.e();...    % b:floor
        t0+7  1  t(5)+7  TCd{t(5)+7}.e();...    % 1b:floor
        
        t0+4  1  t(6)+1  1;...                  % l-idoor
        t0+1  1  t(6)+1  TCd{t(6)+1}.e();...    % k-idoor
        t0+4  1  t(6)+2  1;...                  % l-idoor
        t0+2  1  t(6)+2  TCd{t(6)+2}.e();...    % d-idoor
        t0+3  1  t(6)+3  1;...                  % 1b-idoor
        t0+5  1  t(6)+3  TCd{t(6)+3}.e();...    % c-idoor
        
        t0+2  1  t(7)+1  TCd{t(7)+1}.e();...    % d:edoor N
        
        t0+1  1  t(8)+1  TCd{t(8)+1}.e();...    % k:win W
        t0+3  1  t(8)+2  TCd{t(8)+2}.e();...    % 1b:win N
        t0+4  1  t(8)+3  TCd{t(8)+3}.e();...    % l:win W
        t0+6  1  t(8)+4  TCd{t(8)+4}.e();...    % b:win E
        t0+4  1  t(8)+5  TCd{t(8)+5}.e();...    % l:win S
        t0+7  1  t(8)+6  TCd{t(8)+6}.e();...    % 2b:win S
        
        t0+4  1  t(9)+1  1;...                  % l-infilt
        t0+1  1  t(9)+1  TCd{t(9)+1}.e();...    % k-infilt
        t0+2  1  t(9)+2  1;...                  % d-infilt
        t0+4  1  t(9)+2  TCd{t(9)+2}.e();...    % l-infilt
        t0+3  1  t(9)+3  TCd{t(9)+3}.e();...    % 1b-infilt
        t0+5  1  t(9)+3  1;...                  % c-infilt
        t0+4  1  t(9)+4  1;...                  % l-infilt
        t0+5  1  t(9)+4  TCd{t(9)+4}.e();...    % c-infilt
        t0+5  1  t(9)+5  1;...                  % c-infilt
        t0+6  1  t(9)+5  TCd{t(9)+5}.e();...    % b-infilt
        t0+5  1  t(9)+6  1;...                  % c-infilt
        t0+7  1  t(9)+6  TCd{t(9)+6}.e();...    % b-infilt
        
        t0+4  1  t(10)+1 1;...                  % l-mecvent
        ]
% Assemble the circuits
[TCa, Idx] = fTCAssAll(TCd, AssX);
A = TCa.TC{1}; G = TCa.TC{2}; b = TCa.TC{3}; C = TCa.TC{4}; 
f = TCa.TC{5}; y = TCa.TC{6};
u = [TCa.T; TCa.Q];
if size(u,1) ~= (sum(b)+sum(f))
    error('Flow sources need to be given only once in a common node')
end

%% State-space and simulation
% corridor, bathroom, bedroom1: change input vector at each time step to
% model ventilation from liv -> corrid -> bath/bedroom2

% Model
[A,B,C,D] = fTC2SS(A,G,b,C,f,y);

disp(['max dt = ',num2str(min(-2./eig(A))),'[s]'])

dt = 10*60;                     % time step: 10 min
n = length(H(:,1));
Time = 0:dt:(n-1)*dt;           % time
nth = size(A,1);                % no states
% initial conditions
th = 29*ones(nth,n); thi = th; the = th;
Ae = (eye(nth) + dt*A);         % Euler explicit
Ai = inv((eye(nth) - dt*A));    % Euler implicit
Ad = expm(A*dt);                % exp. matrix
Bd = (Ad-eye(size(A)))*inv(A)*B;
for k = 1:n-1
 th(:,k+1) = Ae*th(:,k) + dt*B*u(:,k);      % Euler explicit
 thi(:,k+1) = Ai*(thi(:,k) + dt*B*u(:,k));  % Euler implicit
 the(:,k+1) = Ad*the(:,k)+Bd*u(:,k);        % matrix exponential
end
ye = C*th + D*u;        % Euler explicit
yi = C*thi + D*u;       % Euler implicit
yE = C*the + D*u;       % matrix exponential

%% Results (postprocessing)
Time = Time/3600/24;

np = 7;                 % num. panels in plot

nbins = [-5:0.1:5];     % bins for histogram
AxisLimits = [0 600 min(nbins) max(nbins)];

% Kitchen
subplot(np,9,1:6)
plot(Time,yi(1,:),'r', Time,T1,'k', Time,To,'b')
ylabel('Temperature [°C]')
legend('T_s_i_m','T_i','T_o')
title('1 Kitchen')
% Histogram of errors
delta = yi(1,:)' - T1;
subplot(np,9,8:9)
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
title('Error histogram')
%xlabel('Frecuency')
% Statistics of error
disp('      mean            std         max         min')
disp('Kitchen')
disp([mean(delta) std(delta) max(delta) min(delta)])

% Doorway
subplot(np,9,9+[1:6])
plot(Time,yi(2,:),'r', Time,T2,'k', Time,To,'b')
ylabel('Temperature [°C]')
%legend('T_s_i_m','T_i','T_o')
title('2 Doorway')
% Histogram of errors
delta = yi(2,:)' - T2;
subplot(np,9,9+[8:9])
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
%xlabel('Frecuency')
% Statistics of error
disp('Doorway')
disp([mean(delta) std(delta) max(delta) min(delta)])

% Bedroom 1
subplot(np,9,2*9+[1:6])
plot(Time,yi(3,:),'r', Time,T3,'k', Time,To,'b')
ylabel('Temperature [°C]')
%legend('T_s_i_m','T_i','T_o')
title('3 Bedroom 1')
% Histogram of errors
delta = yi(3,:)' - T3;
subplot(np,9,2*9+[8:9])
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
%xlabel('Frecuency')
% Statistics of error
disp('Bedroom 1')
disp([mean(delta) std(delta) max(delta) min(delta)])

% Livingroom
subplot(np,9,3*9+[1:6])
plot(Time,yi(4,:),'r', Time,T4,'k', Time,To,'b')
ylabel('Temperature [°C]')
%legend('T_s_i_m','T_i','T_o')
title('4 Living')
% Histogram of errors
delta = yi(4,:)' - T4;
subplot(np,9,3*9+[8:9])
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
%xlabel('Frecuency')
% Statistics of error
disp('Living')
disp([mean(delta) std(delta) max(delta) min(delta)])

% Corridor
subplot(np,9,4*9+[1:6])
plot(Time,yi(5,:),'r', Time,T5,'k', Time,To,'b')
ylabel('Temperature [°C]')
%legend('T_s_i_m','T_i','T_o')
title('5 Corridor')
% Histogram of errors
delta = yi(5,:)' - T5;
subplot(np,9,4*9+[8:9])
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
%xlabel('Frecuency')
% Statistics of error
disp('Corridor')
disp([mean(delta) std(delta) max(delta) min(delta)])

% Bathroom
subplot(np,9,5*9+[1:6])
plot(Time,yi(6,:),'r', Time,T6,'k', Time,To,'b')
ylabel('Temperature [°C]')
%legend('T_s_i_m','T_i','T_o')
title('6 Bathroom')
% Histogram of errors
delta = yi(6,:)' - T6;
subplot(np,9,5*9+[8:9])
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
%xlabel('Frecuency')
% Statistics of error
disp('Bathroom')
disp([mean(delta) std(delta) max(delta) min(delta)])

% Bedroom 2
subplot(np,9,6*9+[1:6])
plot(Time,yi(7,:),'r', Time,T7,'k', Time,To,'b')
xlabel('Time (days)')
ylabel('Temperature [°C]')
%legend('T_s_i_m','T_i','T_o')
title('7 Bedroom 2')
% Histogram of errors
delta = yi(7,:)' - T7;
subplot(np,9,6*9+[8:9])
[counts, bins] = hist(delta,nbins);
barh(bins, counts); axis(AxisLimits);
xlabel('Frecuency')
% Statistics of error
disp('Bedroom 2')
disp([mean(delta) std(delta) max(delta) min(delta)])

scr = get(0,'ScreenSize');
set(gcf, 'Position',  [scr(3)/2, 1, scr(3)/2, scr(4)]);

