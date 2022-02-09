classdef AirZPillar
    % Air in thermal zone with pillar: liv, kit, 1bed, 2bed
    properties
        TC  % Thermal Circuit cell array {A, G, b, C, f, y}
        T   % input vector u = [T; Q]
        Q   % input vector u = [T; Q]
    end
    methods
        function obj = AirZPillar(c, V, ACH50, n, T, Q)
            % c         0 if air capacity neglected 
            % V         air volume
            % ACH50     air changes per hour at 50 Pa
            % n         % times infiltration for controller Kp
            % T         T-sources: ventilation; controller
            % Q         flow source in air node
            rhoa = 1.2; ca = 1000;  % indoor air density; heat capacity
            
            % Pillar: conductance air-pillar
           
            lamc = 2.00; rhoc = 2400; cc = 1000;    % concrete pillar
            h = 2.495; l = 0.30; w = 0.23;          % dims pillar
            hi = 8;                 % cv. coeff in
            
            n_factor = 23;          % correct infiltration @ 50Pa --> unmethours.com/
            ACH = ACH50/n_factor;   % LBL-factor correction nat. cond.
            Vinf = ACH*V/3600;      % vol air infiltration rate
            G(1) = rhoa*ca*Vinf;    % ventilation
            
            Kp = n*G(1);            % controller SetPoint = T_zone
            G(2) = Kp;

            G(3) = 1/(1/hi + w/lamc)*(h*l);         % pillar
            
            C(1) = any(c)*rhoa*ca*V;% air (can be set to 0)
            C(2) = rhoc*cc*h*l*w;   % pillar capacity
            
            obj.TC{1} = [1 0; 1 0; -1 1] ;    % A
            obj.TC{2} = diag(G);    % G
            obj.TC{3} = [1; 1; 0];  % b T-sources: infiltration, zone-SP
            obj.TC{4} = diag(C);    % C
            obj.TC{5} = [1; 0];     % f Q in air; 0 in pillar
            obj.TC{6} = [1; 0];     % y
            obj.T = T;              % T-sources: infiltration, zone-SP
            obj.Q = Q;              % Q-sources: heat in air
        end % constructor
        function nf = e(obj)
            nf = length(obj.TC{5}); 
        end % number of end-node
    end % methods
end % classdef