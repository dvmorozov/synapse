%% Автор:
%% Дата: 30.03.2011

/*Предикаты, обеспечивающие опрос счетчиков по расписанию.*/

sheduled_data_acquisition:-
    read_sheduler_settings,
    sheduled_data_acquisition_loop.

sheduled_data_acquisition_loop:-
    sleep(1), check_shedule,
    sheduled_data_acquisition_loop.
    
check_shedule:-
    get_time(S),
    stamp_date_time(S,
        date(Year, Month, Day, Hour, Min, SecMSec, _, _, _), 'UTC'),
    Sec is floor(SecMSec), check_all_steps(Year, Month, Day, Hour, Min, Sec).
        
check_all_steps(Year, Month, Day, Hour, Min, Sec):-
    check_step(Year, Month, Day, Hour, Min, Sec).
check_all_steps(_, _, _, _, _, _).

check_step(Year, Month, Day, Hour, Min, Sec):-
    /*Выбираются все подходящие пункты расписания.*/
    write(Hour), write(' '), write(Min), write(' '), write(Sec), nl,
    shedule_step(sheduler_date(
        year(Year), month(Month), day(Day), hour(Hour), minute(Min), sec(Sec)
        ), DevicesList),
    start_data_acqusition(DevicesList), fail.

start_data_acqusition([]).
start_data_acqusition([device(
        user_id(UserId), group_id(GroupId), device_id(DeviceId),
        ip(_), port(_), device_address(_),
        status(_),
        prot(Prot)
        )|T]):-
        start_acqusition_clients(UserId, GroupId, DeviceId, Prot),
    start_data_acqusition(T).
    
/*В расписании устройство может быть задано маской - требуется
перебор всех подходящих устройств.*/
start_acqusition_clients(UserId, GroupId, DeviceId, iec62056):-
    device(user_id(UserId), group_id(GroupId), device_id(DeviceId),
        ip(IP), port(Port), device_address(_), status(_), prot(_)),
    create_client_62056(IP, Port),
    write('Acqusition started for device: '),
    write('user_id='), write(UserId),
    write(' , group_id='), write(GroupId),
    write(' , device_id='), write(DeviceId),
    write(' , IP='), write(IP),
    write(' , port='), write(Port), nl,
    fail.
start_acqusition_clients(_, _, _, _).

