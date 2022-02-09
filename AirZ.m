classdef AirZ
    % Air in thermal zone
    properties
        TC  % Thermal Circuit cell array {A, G, b, C, f, y}
        T   % input vector u = [T; Q]
        Q   % input vector u = [T; Q]
    end
    methods
        function obj = AirZ(c, V, ACH50, n, T, Q)
            % c         0 if air capacity neglected 
            % V         air volume
            % ACH50     air changes per hour at 50 Pa
            % n         % times infiltration for controller Kp
            % T         T-sources: ventilation; controller
            % Q         flow source in air node
            rhoa = 1.2; ca = 1000;  % indoor air density; heat capacity
            
            n_factor = 23;          % correct infiltration @ 50Pa --> unmethours.com/
            ACH = ACH50/n_factor;   % LBL-factor correction nat. cond.
            Vinf = ACH*V/3600;      % vol air infiltration rate
            G(1) = rhoa*ca*Vinf;    % ventilation
            Kp = n*G(1);            % controller SetPoint = T_zone
            G(2) = Kp;
            
            C = any(c)*rhoa*ca*V;
            
            obj.TC{1} = [1; 1] ;    % A
            obj.TC{2} = diag(G);    % G
            obj.TC{3} = [1; 1];     % b T-sources: infiltration, zone-SP
            obj.TC{4} = diag(C);    % C
            obj.TC{5} = 1;          % f Q-source in air
            obj.TC{6} = 1;          % y
            obj.T = T;              % T-sources: infiltration, zone-SP
            obj.Q = Q;              % Q-sources: heat in air
        end % constructor
        function nf = e(obj)
            nf = length(obj.TC{5}); 
        end % number of end-node
    end % methods
end % classdef