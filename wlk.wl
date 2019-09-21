

kAddr = "172.19.227.203:5025"

k = SocketConnect@kAddr

kw = WriteString[k, "\n"<>#<>"\n"]&

kr := If[SocketReadyQ@k
         , Sow @ SocketReadMessage@k
         , kr
        ]
                

krm@s_ := ( "print(" <> s <> ")" // kw; 
            Block[{$RecursionLimit = 100}, kr] 
          ) 


Do[ "smua.measure.i()" // krm
] // Reap


