% initilize Keysight Logic Protocol Analyzer
% input argument:
%       ip: ip address of LPA
%       confi_file: optional; path of config file
% output argument:
%       lpa: struct for controlling LPA
function [lpa] = Keysight_LPA_init(ip, conf_file)

    lpa = actxserver('AgtLAServer.Instrument');

    if(~lpa.IsOnline)
        lpa.GoOnline(ip);
    end

    if(~lpa.IsOnline)
        error(['Keysight LPA: Cannot connect to logic analyzer at ',ip,'. Please go online manually on LPA software.']);
    end
    
    if nargin > 1
        try
            lpa.Open(conf_file);
        catch
            error(['Keysight LPA: Cannot load configuration file at ',conf_file]);
        end
    end

% 
%     

end