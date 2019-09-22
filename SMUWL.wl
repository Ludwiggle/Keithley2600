#!/usr/bin/wolframscript

k = SocketConnect @ "172.19.227.177:5025"

Echo@k

kw = WriteString[k, "\n"<>#<>"\n"]&

srm@l_ := {AbsoluteTime[]-t0, ByteArrayToString @ SocketReadMessage @ k} ~Sow~ l


krm[s_,l_] := ("print("<>s<>")" // kw;

                If[SocketReadyQ @ k
                   , srm@l
                   , While[Not @ SocketReadyQ @ k, Pause@0.001]; 
                     srm@l]
              )
              
              
pinst = Thread[#1 -> #2] & @@ {{4, 17, 22}, #} & /@ Tuples[{0, 1}, 3]
ilab = "Ia" <> # & /@ ToString /@ Range@8


"display.smua.measure.func = display.MEASURE_DCAMPS" // kw
"smua.source.func = smua.OUTPUT_DCVOLTS" // kw
"smua.source.levelv = 0.1" // kw

"smua.source.output = smua.OUTPUT_ON" // kw

Pause@0.5

t0 = AbsoluteTime[]

res = 
 Do[( DeviceWrite["GPIO", First@#]; 
      Pause@.1; 
      krm["smua.measure.i() ", Last@#]
    ) &~Scan~Thread@{pinst, ilab};
    
    Pause@1
    
   , 3] // Reap // Last
   
   
Export["res.wl",res]


"smua.source.output = smua.OUTPUT_OFF" // kw


