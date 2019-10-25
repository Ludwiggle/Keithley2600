#!/usr/bin/wolframscript

flname = "IdsVgs"//
         "res_F7/"<>DateString[{"Day", "_", "Month", "_", "Year","__","Hour","_","Minute","_","Second"}]<>
         "___"<>#<>".wl"&

flname = "res_F7/IdsVgs_funz.wl"

n = 20
dt = 0

Vds = 0.2

{Vmin, Vmax} = {1, 2}


k = SocketConnect @ "172.19.227.177:5025"

Echo[k,"Keithley at "]
Echo[First@FindDevices@"GPIO", "Raspberry GPIO activated on "]


kw = WriteString[k, #<>"\n"]&

srm := SocketReadMessage @ k // ByteArrayToString // StringTrim //  Internal`StringToDouble 

krm@s_ := ("print("<>s<>")" // kw;

           If[SocketReadyQ @ k
              , srm
              , While[Not @ SocketReadyQ @ k, Pause@0.001]; 
                srm]
          )
              
              
pinStates = Thread[#1 -> #2] & @@ {{4, 17, 22}, #} & /@ Tuples[{0, 1}, 3] // 
           Thread @ {#, "Ia" <> # & /@ ToString /@ Range@Length@#} &


measure = (DeviceWrite["GPIO", First@#]; Pause@0.1; 
           N @ {v, krm@"smua.measure.i()"} ~Sow~ Last@#
           )&


"display.smua.measure.func = display.MEASURE_DCAMPS" // kw
"smua.source.func = smua.OUTPUT_DCVOLTS" // kw
"smua.source.levelv = "<>ToString@Vds // kw
"smua.source.output = smua.OUTPUT_ON" // kw

"smub.source.func = smua.OUTPUT_DCVOLTS" // kw
"smub.source.levelv = "<>ToString@Vmin // kw
"smub.source.output = smua.OUTPUT_ON" // kw


Vrange = Array[# &, n, {Vmin, Vmax}]~SetPrecision~4

Do[
 
 "smub.source.levelv = "<>ToString@v // kw;
 Scan[measure, pinStates];
 Run["echo -n '  "<>ToString@v<>" \r '"];

, {v,Vrange}] // Reap // Last // Set[res,#]&
   
   
Export[flname,res]

"smua.source.output = smua.OUTPUT_OFF" // kw
"smub.source.output = smua.OUTPUT_OFF" // kw



