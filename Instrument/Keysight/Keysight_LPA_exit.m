function Keysight_LPA_exit(lpa)

    lpa.GoOffline

    lpa.Close;

    lpa.Exit;

end
