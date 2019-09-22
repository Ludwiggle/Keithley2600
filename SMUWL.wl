

k = SocketConnect @ "172.19.227.203:5025"


"Write to socket"
kw = WriteString[k, "\n"<>#<>"\n"]&


"Pressing read"
kr := If[ SocketReadyQ @ k
         , Sow @ SocketReadMessage @ k
         , kr ]
         
                
"Request measured data and read"
krm@s_ :=  Block[{$RecursionLimit = 100}
                 , "print(" <> s <> ")" // kw;
                    kr@s 
                ] 


Do[ "smua.measure.i()" // krm
] // Reap



"______________________________________________________________"


Remove@kr
kr[s_, l_] := 
 If[y = RandomChoice[{1, 2} -> {True, False}]; y
  , Print@"\tREADY"; Sow[{AbsoluteTime[] - t0, s <> ToString@y}, l]
  , Print@y;  kr[s, l]]

Remove@krm;
krm[s_, l_] :=
 Block[{$RecursionLimit = 20},
   "'print(" <> s <> ")' sent to k" // Print;
   kr[s, l]
   ] // Quiet

channels = 
  Thread[#1 -> #2] & @@ {{4, 17, 22}, #} & /@ Tuples[{0, 1}, 3];

signals = "Ia" <> # & /@ ToString /@ Range@8;


t0 = AbsoluteTime[];

res = Do[(
       Print["switch to " <> #2];
       devWrite["GPIO", #1]; 
       Pause@.01; 
       krm["smua.measure.i() ", #2]
       ) &~MapThread~{channels, signals};
    Pause@1
    , {4}] // Reap;
