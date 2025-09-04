function [data] = Keysight_LPA_getDataBus(lpa, bus_name, tobin, range)

% cols can be array
% output data is n-row by m-col, m is channel number, n is sample number
% tobin - set to true for returning a binary data array
% range = [st, ed], the range of data captured
% data in bin - MSB left

    if(nargin < 3)
       tobin = 0;
    end

    bus = lpa.Modules.Item(int32(0)).BusSignals.Item(bus_name);
    bdata = bus.BusSignalData;

    if(nargin < 4)
        st = bdata.StartSample;
        ed = bdata.EndSample;
    else
        st = range(1);
        ed = range(2);
    end    
   
    data = bdata.GetDataBySample(st, ed, 'AgtDataLong')';

    if(tobin)
        data = dec2bin(data,bus.bitSize)-'0';
    end

    
end