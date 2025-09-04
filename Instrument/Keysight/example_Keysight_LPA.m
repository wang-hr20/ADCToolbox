IP_LPA = '101.6.64.226';

% LPA_config = '/20250820.ala';
% if no config file is provided, please set up LPA manually in LPA software
LPA = Keysight_LPA_init(IP_LPA);
Keysight_LPA_run(LPA);
[data] = Keysight_LPA_getDataBus(LPA,'My Bus 1',1,[1,4116*200]);
Keysight_LPA_stop(LPA);
rawData = fliplr(data);
fprintf('data acquired!\n');