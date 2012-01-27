function [Y,Xf,Af,E,perf] = sim(net,varargin)
%SIM Simulate a neural network.
%
%  This is a custom-made time-performance-oriented rewrite of the original
%  SIM function.
%
%  SIM(NET,X) takes a network NET and inputs X and returns the outputs
%  Y generated by the network.  This syntax is equivalent to NET(X).
%
%  <a href="matlab:doc sim">sim</a> arguments can have two formats: matrices, for static
%  problems and networks with single inputs and outputs, and cell arrays
%  for multiple timesteps and networks with multiple inputs and outputs.
%
%  The matrix format is as follows:
%    X  - RxQ matrix
%    Y  - UxQ matrix.
%  Where:
%    Q  = number of samples
%    R  = number of elements in the network's input
%    U  = number of elements in the network's output
%
%  The cell array format is most general:
%    X  - NixTS cell array, each element X{i,ts} is an RixQ matrix.
%    Y  - NOxTS cell array, each element Y{i,ts} is a UixQ matrix.
%  Where:
%    TS = number of time steps
%    Ni = NET.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    No = NET.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>
%    Ri = NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Ui = NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%
%  See also SIM, INIT, REVERT, ADAPT, TRAIN

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.19.2.9.2.1 $
%   commenting out by Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

% CHECK AND FORMAT ARGUMENTS
% --------------------------

% nnassert.minargs(nargin,1);
% nntype.network('assert',net,'NET');
[X,Xi,Ai,T,EW] = nnmisc.defaults(varargin,{},{},{},{},{1});

% Convert explicit timesteps to inputs
xMatrix = ~iscell(X);
% supposing already init-ed NET
% if (netStr.numInputs == 0)
%   if xMatrix && isscalar(X)
%     % Q
%     X = {zeros(0,X)};
%   elseif ~xMatrix && isscalar(X) && isscalar(X{1})
%     % {TS}
%     X = cell(1,X{1});
%   elseif xMatrix && (ndims(X)==2) && all(size(X)==[1 2])
%     % [Q TS]
%     Q = X(1);
%     TS = X(2);
%     X = cell(1,TS);
%     for i=1:TS,X{i} = zeros(1,Q); end
%     xMatrix = false;
%   elseif ~xMatrix && (ndims(X)==2) && all(size(X)==[1 2]) ...
%       && isscalar(X{1}) && isscalar(X{2})
%     % {Q TS}
%     Q = X{1}; TS = X{2};
%     X = cell(1,TS);
%     for i=1:TS,X{i} = zeros(1,Q); end
%     xMatrix = false;
%   end
% end
X = nntype.data('format',X,'Inputs');

% tMatrix = ~iscell(T);
% xiMatrix = ~iscell(Xi) || isempty(Xi);
% aiMatrix = ~iscell(Ai) || isempty(X);
% if isempty(Xi), Xi = {}; end
% if isempty(Ai), Ai = {}; end
% if ~isempty(T), T = nntype.data('format',T,'Targets'); end
% if ~isempty(Xi), Xi = nntype.data('format',Xi,'Input delay states'); end
% if ~isempty(Ai), Ai = nntype.data('format',Ai,'Layer delay states'); end


% [X,Xi,Ai,T,EW,Q,TS,err] = nnsim.prep(net,X,Xi,Ai,T,EW);

% == added ==
% no need to modify X
Xi = cell(1,0);
Ai = cell(2,0);
% T = {nan(net.outputs{2}.size,1)};
Q = 1;
% EW = 1;
% == ==
% if ~isempty(err), nnerr.throw(err), end

% Hints
% net = nn.hints(net);
% if net.hint.zeroDelay, nnerr.throw('Network contains a zero-delay loop.'); end

% net = struct(net);

% SIMULATE NETWORK
% ----------------

[Y,Xf,Af] = nnsim.y(net.strNet,X,Xi,Ai,Q);

% Optional arguments
% if nargout >= 4, E = gsubtract(T,Y); end
% if nargout >= 5
%   perf = feval(net.performFcn,net,T,Y,EW,net.performParam);
% end

% FORMAT OUTPUT ARGUMENTS
% -----------------------

if (xMatrix)
%   if (netStr.numOutputs == 0)
%     Y = zeros(0,Q);
%   else
    Y = cell2mat(Y);
%   end
end
% if (xiMatrix), Xf = cell2mat(Xf); end
% if (aiMatrix), Af = cell2mat(Af); end
% if (nargout>4) && (tMatrix)
%   if (net.numOutputs == 0)
%     E = zeros(0,Q);
%   else
%     E = cell2mat(E);
%   end
% end
