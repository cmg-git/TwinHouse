classdef InfilTB
    % Infiltration and thermal bridge between two zones
    properties
        TC  % Thermal Circuit cell array {A, G, b, C, f, y}
        T   % input vector u = [T; Q]
        Q   % input vector u = [T; Q]
    end
    methods
        function obj = InfilTB(G)
            rhoa = 1.2; ca = 1000;  % indoor air density; heat capacity
            obj.TC{1} = [-1 1];         % A
            obj.TC{2} = diag(G);        % G
            obj.TC{3} = 0;              % b
            obj.TC{4} = diag([0; 0]);   % C
            obj.TC{5} = [0; 0];         % f
            obj.TC{6} = [0; 0];         % y
            obj.T = [];  % T = [] no temperature sources
            obj.Q = [];  % Q = [] no flow sources
        end % constructor
        function nf = e(obj)
            nf = length(obj.TC{5}); 
        end % number of end-node
    end % methods
end % classdef