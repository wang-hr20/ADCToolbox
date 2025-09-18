function [emean, erms, phase_code, edata, err, xx] = errHistSine(data, varargin)

    % mode = 0 : phase as x axis; 
    % mode >= 1 : code as axis;

    p = inputParser;
    addOptional(p, 'bin', 100, @(x) isnumeric(x) && isscalar(x) && (x > 0));
    addOptional(p, 'fin', 0, @(x) isnumeric(x) && isscalar(x) && (x > 0) && (x < 1));
    addOptional(p, 'disp', 1);
    addOptional(p, 'mode', 0, @(x) isnumeric(x));
    addParameter(p, 'erange', []);
    addParameter(p, 'coAvg', 0, @(x) ismember(x,[0,1]));
    parse(p, varargin{:});
    bin = round(p.Results.bin);
    fin = p.Results.fin;
    disp = p.Results.disp;
    codeMode = p.Results.mode;
    erange = p.Results.erange;
    coAvg = p.Results.coAvg;

    [N,M] = size(data);
    n_groups = N;
    n_data = M;
    if (N > M)
        data = data';
        n_groups = M;
        n_data = N;
    end

    if n_groups > 1 
        if coAvg == 0
            warning('Input multiple groups of samples, only using first column!\n');
            n_groups = 1;
        elseif codeMode
            error('Do not support co-averaging when using code mode. Set either mode or coAvg to 0.');
        end
    end

    emean_all = zeros([n_groups,bin]);
    erms_all  = zeros([n_groups,bin]);

    for iter_groups = 1 : n_groups
        data_iter = data(iter_groups,:);
        if(fin == 0)
            [data_fit,fin,~,~,phi] = sineFit(data_iter);
        else
            [data_fit,~,~,~,phi] = sineFit(data_iter,fin);
        end
    
        err = data_fit-data_iter;
        
        if(codeMode)
            xx = data_iter;
            dat_min = min(data_iter);
            dat_max = max(data_iter);
            bin_wid = (dat_max-dat_min)/bin;
            phase_code =  min(data_iter) + [1:bin]*bin_wid - bin_wid/2;
            
            enum_iter = zeros([1,bin]);
            esum_iter = zeros([1,bin]);
            erms_iter = zeros([1,bin]);
        
            for ii = 1:n_data
                b = min(floor((data_iter(ii)-dat_min)/bin_wid)+1,bin);
                esum_iter(b) = esum_iter(b) + err(ii);
                enum_iter(b) = enum_iter(b) + 1;
            end
            emean_iter = esum_iter./enum_iter;
            for ii = 1:n_data
                b = min(floor((data_iter(ii)-dat_min)/bin_wid)+1,bin);
                erms_iter(b) = erms_iter(b) + (err(ii) - emean_iter(b))^2;
            end
            erms_iter = sqrt(erms_iter./enum_iter);
    
            if(~isempty(erange))
                eid = (data_iter >= erange(1)) & (data_iter <= erange(2));
                edata = err(eid);
            end
    
            if(disp)
                subplot(2,1,1);
                hold on;
                plot(data_iter,err,'r.');
                plot(phase_code,emean_iter,'b-');
                axis([dat_min,dat_max,min(err),max(err)]);
                ylabel('error');
                xlabel('code');
                
                if(~isempty(erange))
                    plot(data_iter(eid),err(eid),'m.');
                end

                subplot(2,1,2);
                bar(phase_code,erms_iter);
                axis([dat_min,dat_max,0,max(erms_iter)*1.1]);
                xlabel('code');
                ylabel('RMS error');
            end
    
        else
            xx = mod(phi/pi*180 + (0:n_data-1)*fin*360,360);
            phase_code = (0:bin-1)/bin*360;
    
            enum_iter = zeros([1,bin]);
            esum_iter = zeros([1,bin]);
            erms_iter = zeros([1,bin]);
        
            for ii = 1:n_data
                b = mod(round(xx(ii)/360*bin),bin)+1;
                esum_iter(b) = esum_iter(b) + err(ii);
                enum_iter(b) = enum_iter(b) + 1;
            end
            emean_iter = esum_iter./enum_iter;
            for ii = 1:n_data
                b = mod(round(xx(ii)/360*bin),bin)+1;
                erms_iter(b) = erms_iter(b) + (err(ii) - emean_iter(b))^2;
            end
            erms_iter = sqrt(erms_iter./enum_iter);
    
            if(~isempty(erange))
                eid = (xx >= erange(1)) & (xx <= erange(2));
                edata = err(eid);
            end
            
            if(disp)
                subplot(2,1,1);
                hold on;
                yyaxis left;
                plot(xx,data_iter,'k.');
                axis([0,360,min(data_iter),max(data_iter)]);
                ylabel('data');
    
                yyaxis right;
                plot(xx,err,'r.');
    
                if(~isempty(erange))
                    plot(xx(eid),err(eid),'m.');
                end
            end
        end
        emean_all(iter_groups,:) = emean_iter;
        erms_all(iter_groups,:) = erms_iter;
    end

    emean = mean(emean_all,1);
    erms = mean(erms_all,1);

    if disp && codeMode == 0
        subplot(2,1,1);
        hold on;
        plot(phase_code,emean,'b-');
        axis([0,360,min(err),max(err)]);
        ylabel('error');

        legend('data','error');
        xlabel('phase(deg)');
        hold off;

        subplot(2,1,2)
        bar(phase_code,erms);
        axis([0,360,0,max(erms)*1.1]);
        xlabel('phase(deg)');
        ylabel('RMS error');
    end

    if(isempty(erange))
        edata = [];
    end

end