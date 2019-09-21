

kAddr = "172.19.227.203:5025"

k = SocketConnect@kAddr

kw = WriteString[k, "\n"<>#<>"\n"]&

kr = Block[{$RecursionLimit = 20},
           If[SocketReadyQ@k
              , SocketReadMessage@k~Sow~#
              , Wait@.01; kr]
          ]&

krm = ( kw["print(" <> #1 <> ")"]; kr@#2) &


Do[ "smua.measure.i()" // krm
] // Reap
