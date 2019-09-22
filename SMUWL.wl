#!/usr/bin/wolframscript

k = SocketConnect @ "172.19.227.177:5025"

Echo@k
Echo@FindDevices@"GPIO"


kw = WriteString[k, #<>"\n"]&

srm := SocketReadMessage @ k // ByteArrayToString // StringTrim //  Internal`StringToDouble 


krm@s_ := ("print("<>s<>")" // kw;

           If[SocketReadyQ @ k
              , srm
              , While[Not @ SocketReadyQ @ k, Pause@0.001]; 
                srm]
          )
              
              
pinStLab = Thread[#1 -> #2] & @@ {{4, 17, 22}, #} & /@ Tuples[{0, 1}, 3] // 
        Thread @ {#, "Ia" <> # & /@ ToString /@ Range@Length@#} &


"display.smua.measure.func = display.MEASURE_DCAMPS" // kw
"smua.source.func = smua.OUTPUT_DCVOLTS" // kw
"smua.source.levelv = 0.1" // kw

"smua.source.output = smua.OUTPUT_ON" // kw


Echo@"measure start"

t0 = AbsoluteTime[]

res = 
 Do[(DeviceWrite["GPIO", First@#]; Pause@.1; 
     N@{AbsoluteTime[]-t0, krm@"smua.measure.i()"}~Sow~Last@#
    )& ~Scan~ pinStLab;
    
   , 100] // Reap // Last
   
   
Export["res.wl",res]


"smua.source.output = smua.OUTPUT_OFF" // kw


