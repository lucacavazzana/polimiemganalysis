function EN = emgnet(net)
%EMGNET custom neural network
%   EMGNET(NET) receives an network class NET. It will use his custom
%   sim function, faster since it since bypasses most of the useless
%   initializations of the original one.
%
%   See also SIM

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

net = nn.hints(net);
if net.hint.zeroDelay, nnerr.throw('Network contains a zero-delay loop.'); end

EN.strNet = struct(net);
EN = class(EN, 'emgnet', net);

end