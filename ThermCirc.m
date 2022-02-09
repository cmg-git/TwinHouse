classdef ThermCirc
  % Thermal circuit with input data
  properties
    TC  % Thermal Circuit cell array {A, G, b, C, f, y}
    T   % input vector u = [T; Q]
    Q   % input vector u = [T; Q]
  end
  methods
    function obj = ThermCirc(TC, T, Q)  % constructor
%         TC{2} = diag(TC{2});    % G <- diag(G)
%         TC{4} = diag(TC{4});    % C <- diag(C)
        obj.TC = TC;            % therm. circuit
        obj.T = T;              % temp. sources
        obj.Q = Q;              % flow sources
    end % function
    function nf = e(obj)
        nf = length(obj.TC{5}); 
    end % number of end-node
  end % methods
end % classdef
