function EN = emgnet(net)

net = nn.hints(net);
if net.hint.zeroDelay, nnerr.throw('Network contains a zero-delay loop.'); end

EN.strNet = struct(net);
EN = class(EN, 'emgnet', net);

end