function Keysight_LPA_run(lpa,iswait)

    if(nargin < 2)
        iswait = 0;
    end

    lpa.Run;

    if(iswait>0)
        lpa.WaitComplete(int32(iswait));
    end

end