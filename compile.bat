rmdir /s /q bin
mkdir bin

swipl --goal=server_62056 --stand_alone=true -o bin/server62056 -c server_sgs_main.pl
swipl --goal=client_62056 --stand_alone=true -o bin/client62056 -c client_sgs_main.pl
swipl --goal=scheduler_service --stand_alone=true -o bin/scheduler_service -c scheduler_service_main.pl
swipl --goal=server_launcher --stand_alone=true -o bin/server_launcher -c tests/server_launcher.pl

pause
