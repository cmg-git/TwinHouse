classdef Wall1Dbc
    % Wall 1D with boundary conditions
    properties
        TC   % TC: thermal circuit {A, G, b, C, f, y}
    end
    methods
         function obj = Wall1Dbc(TC, h, bb, bf) % constructor
             % TC: thermal circuit {A, G, b, C, f, y}
             % [bb1 bb2]: temp. sources; values 0: if not; 1: if yes
             % [bf1 bf2]: flow sources; values 0: if not; 1: if yes
             % [h1 h2]:  convection
             A = TC{1};
             G = TC{2};
             b = TC{3};
             C = TC{4};
             f = TC{5};
             y = TC{6};
             % left side
             if h(1)==0    % no convection
                 if bb(1)==0 && bf(1)==0
                     % node w/o source: nothing change
                 elseif bb(1)==0 && bf(1)==1
                     % node with flow source: add flow
                     f(1) = 1;
                 elseif bb(1)==1 && bf(1)==0
                     % remove node#1
                     A(:,1) = []; C(1) = []; f(1) = []; y(1) = [];
                     b(1) = 1;  % add source on branch#1
                 elseif bb(1)==1 && bf(1)==1
                     error('T-source and Q-source in the same node')
                 else
                     error('b and f need to be in {0, 1}')
                 end
             elseif h(1)~=0    % convection
                 A = [zeros(1, size(A,2)); A]; A(1) = 1; % add 1 branch
                 G = [h(1); G]; % add 1 branch
                 b = [0; b];
                 if bb(1)==0
                     % add 1 node
                     A = [zeros(size(A,1),1) A];% add 1 node
                     A(1,1) = -1;
                     C = [0; C];    % add 1 node
                     f = [0; f];    
                     y = [0; y];
                     if bf(1)==1    
                         f(2) = 1;  % Q-source in node 1
                     end
                 elseif bb(1)==1    % do not add node
                     b(1) = 1;      % T-source
                     if bf(1)==1    
                         f(1) = 1;  % Q-source in node 1
                     end
                 end      
             end 
             %
             %right side
             if h(2)==0    % no convection
                  if bb(2)==0 && bf(2)==0
                      % node w/o source: nothing change
                  elseif bb(2)==0 && bf(2)==1
                      % node with flow source: add flow
                      f(end) = 1;
                  elseif bb(2)==1 && bf(2)==0
                      % remove node#end
                      A(:,end) = []; C(end) = []; f(end) = []; y(end) = [];
                      b(end) = 1;  % add source on branch#1
                  elseif bb(2)==1 && bf(2)==1
                      error('T-source and Q-source in the same node')
                  else
                      error('b and f need to be in {0, 1}')
                  end % bb(2)==0
              elseif h(2)~=0    % convection
                  A = [A; zeros(1, size(A,2))]; % add 1 branch
                  G = [G; h(2)]; % add 1 branch
                  b = [b; 0];
                  if bb(2)==0
                      % add 1 node
                      A = [A zeros(size(A,1),1)];% add 1 node
                      A(end,end-1:end) = [-1 1];
                      C = [C; 0];       % add 1 node
                      f = [f; 0];    
                      y = [y; 0];
                      if bf(2)==1    
                          f(end-1) = 1; % Q-source in node 1
                      end
                  elseif bb(2)==1       % do not add node
                      b = [b; 1];       % T-source
                      if bf(2)==1    
                          f(end) = 1; % Q-source in node end
                      end
                  end  % h(2)~=0 
             end % right side
             % check if the dimenssions are coherents
             A'*diag(G)*A + A'*diag(G)*b + diag(C)*f + y;

             obj.TC{1} = A; obj.TC{2} = G; obj.TC{3} = b;
             obj.TC{4} = C; obj.TC{5} = f; obj.TC{6} = y;
         end % constructor
             
    end % methods
end % class