
del client_satec_em_720.exe
del server_satec_em_720.exe

swipl --goal=server_satec_em_720 --stand_alone=true -o server_satec_em_720 -c server_satec_em_720.pl
swipl --goal=client_satec_em_720 --stand_alone=true -o client_satec_em_720 -c client_satec_em_720.pl
pause
