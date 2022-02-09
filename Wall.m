classdef Wall
    properties
        TC  % Thermal Circuit cell array {A, G, b, C, f, y}
        T   % input vector u = [T; Q]
        Q   % input vector u = [T; Q]
    end
    methods
        function obj = Wall(TC, S, T, Q)
            obj.TC = TC;
            obj.TC{2} = S*diag(TC{2});  % G <- diag(G)
            obj.TC{4} = S*diag(TC{4});  % C <- diag(C)
            obj.T = T;
            obj.Q = Q;
        end % constructor
        function nf = e(obj)
            nf = length(obj.TC{5}); 
        end % number of end-node
    end % methods
end % classdef