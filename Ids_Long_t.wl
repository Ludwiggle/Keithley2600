#!/usr/bin/wolframscript
(********************************************************************************************************)

T = 180
dt = 0

dtc = 0.8

Vds = 0.2
Vref = 1.408

flname = "Ids_Ch4" //
         "res2/"<>DateString[{"Day", "_", "Month", "_", "Year","__","Hour","_","Minute","_","Second"}]<>
         "___"<>#<>".wl"&
         

(********************************************************************************************************)

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
           Thread @ {#, "Ia" <> # & /@ ToString /@ Range[0,Length@#-1]} &
           
pinStates = pinStates~Part~5 // List

measure = (DeviceWrite["GPIO", First@#]; Pause@dtc; 
            N@{AbsoluteTime[]-t0, krm@"smua.measure.i()"}
           )&

progress = Run["echo -n '   "<>ToString@#<>"/"<>ToString@T<>" ("<>ToString[Floor[100 t/T]]<>"%)\r'"]&


"display.smua.measure.func = display.MEASURE_DCAMPS" // kw
"smua.source.func = smua.OUTPUT_DCVOLTS" // kw
"smua.source.levelv = "<>ToString@Vds // kw
"smua.source.output = smua.OUTPUT_ON" // kw

"smub.source.func = smua.OUTPUT_DCVOLTS" // kw
"smub.source.levelv = "<>ToString@Vref // kw
"smub.source.output = smua.OUTPUT_ON" // kw

t0 = AbsoluteTime[]


(*******************************************************************************************************)

Do[ 
 
 Table[measure@i, {i,pinStates}]~PutAppend~flname;
 
 If[t==Round[3/5 T],"smub.source.levelv = "<>ToString[Vref+0.001] // kw];
 If[t==Round[4/5 T],"smub.source.levelv = "<>ToString[Vref] // kw];
 
 Pause@dt; progress@t

, {t,1,T}] 
   
   
(*******************************************************************************************************)

"smua.source.output = smua.OUTPUT_OFF" // kw
"smub.source.output = smua.OUTPUT_OFF" // kw



