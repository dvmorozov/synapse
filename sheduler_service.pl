%% јвтор:
%% ƒата: 08.06.2011

/*служба запуска сбора данных по расписанию (планировщик)*/

:-dynamic completed_action/1.
:-dynamic new_next_action_time/3.
:-dynamic unscheduled_device/1.
:-dynamic scheduled_device/1.    /*’ранит всю полученную из Ѕƒ строку данных.*/

scheduler_service:-
    /*—оздаетс€ соединение с Ѕƒ, которое будет использоватьс€ во всех случа€х.*/
    sg_odbc_connect(Connection),
    scheduler_service_loop,
    sg_odbc_disconnect(Connection).
    
scheduler_service_loop:-
    /*запуск устройств, наход€щихс€ в состо€нии ожидани€.*/
    read_schedule_and_launch_clients,
    /*вычисление момента следующего запуска после успешного завершени€.*/
    /*schedule_next_launch, ???*/
    /*вычисление момента запуска действий после добавлени€ устройств в группу.*/
    schedule_unscheduled_actions,
    /*??? sleep не делать, если врем€ выполнени€ действий превысило 1 с.*/
    sleep(1),
    scheduler_service_loop.
scheduler_service_loop:-
    sleep(1),
    scheduler_service_loop.
    
/*запуск устройств, наход€щихс€ в состо€нии ожидани€.*/
read_schedule_and_launch_clients:-
    retractall(scheduled_device(_)),
    sg_odbc_connect(Connection),
    print('before read_schedule_and_launch_clients::odbc_prepare'), nl,
    odbc_prepare(Connection, 'EXECUTE GetScheduledDevicesAndUpdateExecTime',
                             [], Statement, [fetch(fetch)]),
    odbc_execute(Statement, []),
    assert_scheduled_devices(Statement),
    odbc_free_statement(Statement),
    launch_clients,
    sg_odbc_disconnect(Connection).

assert_scheduled_devices(Statement):-
    odbc_fetch(Statement, Row, next),
    (Row == end_of_file
    -> true
    ;
    assert_scheduled_device(Row),
    assert_scheduled_devices(Statement)
    ).
    
assert_scheduled_device(Row):-assert(scheduled_device(Row)).

launch_clients:-scheduled_device(Row), launch_client(Row), fail.
launch_clients.
    
launch_client(row(/*ID*/ _, DeviceID, /*NextActionTime*/ _,
        /*ExecPID*/ _, /*InternalAddress*/ _, /*AddressType*/ _,
        Port, IP1, IP2, IP3, IP4)):-
    atom_concat(IP1, '.', SIP1_), atom_concat(SIP1_, IP2, SIP2_),
    atom_concat(SIP2_, '.', SIP2__), atom_concat(SIP2__, IP3, SIP3_),
    atom_concat(SIP3_, '.', SIP3__), atom_concat(SIP3__, IP4, IPAddr_),
    atom_chars(IPAddr_, SIPAddr),
    delete(SIPAddr, ' ', SIPAddr2),
    atom_chars(IPAddr, SIPAddr2),

    write('Client IP Addr= '), write(IPAddr),
    write(' IP Port= '), write(Port), nl,
    atom_chars(Port, SPort),
    delete(SPort, ' ', SPort2),
    number_chars(Port_, SPort2),
    ignore(create_client_62056(IPAddr, Port_, DeviceID)).
    /*
    atom_concat('client62056.exe --ipport ', Port, S3),
    atom_concat(S3, ' --devid ', S3_),
    atom_concat(S3_, DeviceID, S4),
    atom_concat(S4, ' --ipaddr ', S5),
    atom_concat(S5, IPAddr, Exe),
    print(Exe), nl,
    win_exec(Exe, showdefault).
    */

/******************************************************************************/
/*вычисление момента запуска действий после добавлени€ устройств в группу.*/
schedule_unscheduled_actions:-
    get_unscheduled_devices,
    add_devices_to_schedule,
    /*обновление таблицы расписани€ в базе.*/
    update_next_action_times,
    retractall(unscheduled_device(_)).

get_unscheduled_devices:-
    sg_odbc_connect(Connection),
    print('before get_unscheduled_devices::odbc_prepare'), nl,
    odbc_prepare(Connection, 'EXECUTE GetUnscheduledDevices',
                             [], Statement, [fetch(fetch)]),
    odbc_execute(Statement, []),
    /*«аписи лучше загружать группами, а не по одной, дл€ реализации оптимизации
    запуска действий.*/
    assert_unscheduled_device(Statement),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection).
    
assert_unscheduled_device(Statement):-
    odbc_fetch(Statement, Row, next),
    (Row == end_of_file
    -> true
    ;
    assert(unscheduled_device(Row)),
    assert_unscheduled_device(Statement)
    ).

add_devices_to_schedule:-
    calc_first_action_times,
    retractall(unscheduled_device(_)).
    
calc_first_action_times:-
    retractall(new_next_action_time(_, _, _)),
    calc_first_action_times_loop.

calc_first_action_times_loop:-
    unscheduled_device(row(
        DeviceID,
        MinutesE,
        MinutesG,
        MinMode,
        HoursE,
        HoursG,
        HourMode,
        DaysE,
        DaysG,
        DayMode,
        WeeksG,
        WeekMode,
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        Saturday,
        Sunday,
        /*GroupID*/_)),
    get_time(L),
    calc_first_action_time(
        L, MinutesE, MinutesG, MinMode,
        HoursE, HoursG, HourMode, DaysE, DaysG, DayMode,
        WeeksG, WeekMode, Monday, Tuesday, Wednesday,
        Thursday, Friday, Saturday, Sunday, S),
    timestamp_to_sql_string(S, TimeStampString),
    assert(new_next_action_time(DeviceID, 0, TimeStampString)),
    fail.
calc_first_action_times_loop.

calc_first_action_time(
    L, MinutesE, MinutesG, MinMode,
    HoursE, HoursG, HourMode, DaysE, DaysG, DayMode,
    WeeksG, WeekMode, Monday, Tuesday, Wednesday,
    Thursday, Friday, Saturday, Sunday, S):-
    add_one_minute(L, S), !.
calc_first_action_time(
    _, _, _, _,
    _, _, _, _, _, _,
    _, _, _, _, _,
    _, _, _, _, S):-S is 0.0.

/******************************************************************************/
/*вычисление момента следующего запуска после успешного завершени€.*/
schedule_next_launch:-
    /*извлечение списка устройств совместно с параметрами расписани€ групп.*/
    get_completed_actions,
    /*вычисление следующего момента запуска.*/
    calc_next_action_time,
    /*обновление таблицы расписани€ в базе.*/
    update_next_action_times,
    retractall(completed_action(_)).

get_completed_actions:-
    sg_odbc_connect(Connection),
    print('before get_completed_actions::odbc_prepare'), nl,
    odbc_prepare(Connection, 'EXECUTE GetCompletedActions',
                             [], Statement, [fetch(fetch)]),
    odbc_execute(Statement, []),
    /*планирование следующего запуска*/
    assert_completed_action(Statement),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection).

assert_completed_action(Statement):-
    odbc_fetch(Statement, Row, next),
    (Row == end_of_file
    -> true
    ;
    assert(completed_action(Row)),
    assert_completed_action(Statement)
    ).
    
calc_next_action_time:-
    retractall(new_next_action_time(_, _, _)),
    calc_next_action_time_loop.

calc_next_action_time_loop:-
    completed_action(row(ScheduleID,
        DeviceID,
        /*NextActionTime*/_,
        LastExecTime,
        /*ExecPID*/_,
        /*ExecStationIP*/_,
        /*DataOwnerID*/_,
        /*Successful*/_,
        /*CompletionTime*/_,
        /*Completed*/_,
        /*ID=DeviceID*/_,
        MinutesE,
        MinutesG,
        MinMode,
        HoursE,
        HoursG,
        HourMode,
        DaysE,
        DaysG,
        DayMode,
        WeeksG,
        WeekMode,
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        Saturday,
        Sunday,
        /*GroupID*/_)),
    sql_string_to_timestamp(LastExecTime, L),
    calc_next_time(
        L, MinutesE, MinutesG, MinMode,
        HoursE, HoursG, HourMode, DaysE, DaysG, DayMode,
        WeeksG, WeekMode, Monday, Tuesday, Wednesday,
        Thursday, Friday, Saturday, Sunday, S),
    timestamp_to_sql_string(S, TimeStampString),
    assert(new_next_action_time(DeviceID, ScheduleID, TimeStampString)),
    fail.
calc_next_action_time_loop.

/**/
calc_next_time(
    L, MinutesE, MinutesG, MinMode,
    HoursE, HoursG, HourMode, DaysE, DaysG, DayMode,
    WeeksG, WeekMode, Monday, Tuesday, Wednesday,
    Thursday, Friday, Saturday, Sunday, S):-
    /*«апрещаетс€ повторное согласование на обратном ходу.*/
    add_one_minute(L, S), !. /*???*/
/*”словие завершени€ поиска.*/
calc_next_time(
    _, _, _, _,
    _, _, _, _, _, _,
    _, _, _, _, _,
    _, _, _, _, S):-S is 0.0.

update_next_action_times:-
    /*ѕроверка, что есть новые записи.*/
    new_next_action_time(_, _, _), !,
    prepare_next_action_time(Connection, Statement),
    update_next_action_time_loop(Statement),
    free_update_next_action_time(Connection, Statement),
    retractall(new_next_action_time(_, _, _)).
/*—огласуетс€, если новых записей нет.*/
update_next_action_times.

prepare_next_action_time(Connection, Statement):-
    sg_odbc_connect(Connection),
    print('before prepare_next_action_time::odbc_prepare'), nl,
    odbc_prepare(Connection, 'EXECUTE UpdateNextActionTime ?, ?, ?',
        [default, default, default],
        Statement, []).

free_update_next_action_time(Connection, Statement):-
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection).

update_next_action_time(Statement, DeviceID, ScheduleID, NextActionTime):-
    odbc_execute(Statement, [ScheduleID, NextActionTime, DeviceID]).
update_next_action_time(_, _, _, _).

update_next_action_time_loop(Statement):-
    new_next_action_time(DeviceID, ScheduleID, TimeStampString),
    update_next_action_time(Statement, DeviceID, ScheduleID, TimeStampString), fail.
update_next_action_time_loop(_).

