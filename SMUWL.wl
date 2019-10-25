#!/usr/bin/wolframscript

k = SocketConnect @ "172.19.227.177:5025"

kw = WriteString[k, #<>"\n"]&

srm := SocketReadMessage @ k // ByteArrayToString // StringTrim //  Internal`StringToDouble 


krm@s_ := 
("print("<>s<>")" // kw;
  If[SocketReadyQ @ k
     , srm
     , While[Not @ SocketReadyQ @ k, Pause@0.001]; 
       srm]
)
              
              
