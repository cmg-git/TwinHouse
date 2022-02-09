classdef Wall1D
    % Wall without convection
    % flow sources on the surfaces (Neumann - Neumann, w/o internal sources)
    properties
        meshes  % [nm w lam rho c]
        TC      % Thermal Circuit cell array {A, G, b, C, f, y}
                % G and C are vectors (need diagonalization)
    end
    methods
        function obj = Wall1D(meshes) % constructor
            obj.meshes = meshes;
            nm = meshes(:, 1);      % number of meshes in each layer
            w = meshes(:, 2);       % width of each layer
            lam = meshes(:, 3);     % conductivity of each layer
            rho = meshes(:, 4);     % density of each layer
            c = meshes(:, 5);       % specific heat of each layer 

            G = [];
            C = [];
            Glayer = lam./w;        % conductance of a layer
            Clayer = rho.*c.*w;     % capacity of a layer
            for i = 1:length(nm)
                if nm(i) == 0
                    Gm = Glayer(i);
                    Cm = 0;
                else
                    Gm = 2*nm(i)*Glayer(i)*ones(2*nm(i),1);   % meshed G
                    Cm = Clayer(i)/nm(i)*mod(0:2*nm(i)-1,2)'; % meched C
                end
                G = [G; Gm];
                C = [C; Cm];
            end
            C = [C; 0];
            A = diff(eye(length(G)+1));
            [r, c] = size(A);
            b = zeros(r, 1);
            f = zeros(c, 1);
            y = zeros(c, 1);
            obj.TC = {A, G, b, C, f, y};
        end % constructor
    end % methods
end % class