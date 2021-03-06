Have two datsets "BASE" and "COMPARE" and I want a short summary of differences

   WORKING CODE
   WPS/SAS (same results)

      proc compare base=class compare=classfit;
      by name;
      run;quit;
      %let savinfo=&sysinfo;

      if sysinfo='...............1'b then do; /* 1 */ msg = 'Data set labels differ'; output; end;
      if sysinfo='..............1.'b then do; /* 2 */ msg = 'Data set types differ'; output; end;
      ...
      if sysinfo='1...............'b then do; /* 16*/ msg = 'Fatal error: comparison not done '; output; end;


HAVE
====

   Two datasets with one observation each

   BASE - Total Obs 1
   ===================
    -- CHARACTER --            Value

   NAME           C    8       Alfred
   SEX            C    1       M
   LOWERMEAN      C    9       CHARACTER

    -- NUMERIC --
   AGE            N    8       14
   HEIGHT         N    8       69
   WEIGHT         N    8       999


   COMPARE - Total Obs 1
   ======================

    -- CHARACTER --            Value          Label

   NAME           C    8       Alfred
   SEX            C    1       M

    -- NUMERIC --
   LOWERMEAN      N    8       116.94168423   Lower Bound of 95% C.I. for Mean
   AGE            N    8       14
   HEIGHT         N    8       69
   WEIGHT         N    8       112.5
   PREDICT        N    8       126.00617011   Predicted Value of Weight

DETAILS

   1. LOWERMEAN is character in BASE and NUMERIC in CLASSFIT
   2. WEIGHT is 999 in BASE ans 112.5 in COMPARE
   3. BASE does not have variable predict


WANT
====

 The WPS System

   Obs    SYSINFO    MSG

    1      14336     Comparison data set has variable not in base
    2      14336     A value comparison was unequal
    3      14336     Conflicting variable types

    Just what I expected


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;


%symdel sysinfo savinfo / nowarn;
proc datasets lib=work kill;
run;quit;

proc sort
    data=sashelp.classfit(where=(name='Alfred') keep=name--lowermean)
    out=compare(label="");
by name;
run;quit;

data base(label="");
  set sashelp.class(where=(name='Alfred'));
  weight=999;
  lowermean="CHARACTER";
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
    libname wrk "%sysfunc(pathname(work))";
    %symdel savinfo sysinfo / nowarn;

    proc compare base=wrk.base compare=wrk.compare;
    by name;
    run;quit;

    data _null_;
      nfo=symget("sysinfo");
      call symputx("savinfo",nfo);
    run;quit;

    data sysinfo;
       sysinfo=input(symget("savinfo"),best.);
       length msg $64;
       if sysinfo =0                   then do; /* 0 */ msg = "All Compared Variables Equal"; output; end;
       if sysinfo="...............1"b then do; /* 1 */ msg = "Data set labels differ"; output; end;
       if sysinfo="..............1."b then do; /* 2 */ msg = "Data set types differ"; output; end;
       if sysinfo=".............1.."b then do; /* 3 */ msg = "Variable has different informat"; output; end;
       if sysinfo="............1..."b then do; /* 4 */ msg = "Variable has different format"; output; end;
       if sysinfo="...........1...."b then do; /* 5 */ msg = "Variable has different length"; output; end;
       if sysinfo="..........1....."b then do; /* 6 */ msg = "Variable has different label"; output; end;
       if sysinfo=".........1......"b then do; /* 7 */ msg = "Base data set has observation not in comparison"; output; end;
       if sysinfo="........1......."b then do; /* 8 */ msg = "Comparison data set has observation not in base"; output; end;
       if sysinfo=".......1........"b then do; /* 9 */ msg = "Base data set has BY group not in comparison "; output; end;
       if sysinfo="......1........."b then do; /* 10*/ msg = "Comparison data set has BY group not in base "; output; end;
       if sysinfo=".....1.........."b then do; /* 11*/ msg = "Base data set has variable not in comparison "; output; end;
       if sysinfo="....1..........."b then do; /* 12*/ msg = "Comparison data set has variable not in base "; output; end;
       if sysinfo="...1............"b then do; /* 13*/ msg = "A value comparison was unequal "; output; end;
       if sysinfo="..1............."b then do; /* 14*/ msg = "Conflicting variable types "; output; end;
       if sysinfo=".1.............."b then do; /* 15*/ msg = "BY variables do not match "; output; end;
       if sysinfo="1..............."b then do; /* 16*/ msg = "Fatal error: comparison not done "; output; end;
    run;

    proc print data=sysinfo;
    run;quit;
');

The WPS System

Obs    sysinfo    msg

 1      14336     Comparison data set has variable not in base
 2      14336     A value comparison was unequal
 3      14336     Conflicting variable types




