%% Автор:
%% Дата: 10.09.2011
%% Предикаты, базовые для клиентов всех типов.

/*Идентификаторы используются только при обновлении данных в БД.*/
:-thread_local data_identifier/1.

:-dynamic sg_master_base/2.
sg_odbc_connect(Connection):-
    sg_master_base(Connection, X), !,
    Y is X + 1,
    retractall(sg_master_base(Connection, _)),
    assert(sg_master_base(Connection, Y)),
    print('Y='), print(Y), nl.
sg_odbc_connect(Connection):-
    sgs_user(UserName), sgs_password(Password),
    odbc_connect('SGS', Connection, [user(UserName), password(Password), alias(sgs), open(once)]),
    assert(sg_master_base(Connection, 1)).

/*odbc_disconnect закрывает все подключения - open(once).*/
sg_odbc_disconnect(Connection):-
    sg_master_base(Connection, 1), !,
    odbc_disconnect(Connection),
    retractall(sg_master_base(Connection, _)).
sg_odbc_disconnect(Connection):-
    sg_master_base(Connection, X), !,
    Y is X - 1,
    retractall(sg_master_base(Connection, _)),
    assert(sg_master_base(Connection, Y)).

/*Получает идентификаторы элементов данных, ассоциированных с устройством.*/
get_device_identifiers(DeviceID):-
    not(data_to_console), string_concat('Client gets data item identifiers for device ', DeviceID, Out), out_debug_message(Out),
    sg_odbc_connect(Connection),
    odbc_prepare(Connection, 'EXECUTE GetDeviceIdentifiers ?',
                             [default], Statement, [fetch(fetch)]),
    odbc_execute(Statement, [DeviceID]),
    retractall(data_identifier(_)),
    get_identifiers(Statement),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection),
    out_data_identifiers(DeviceID).
get_device_identifiers(DeviceID):-data_to_console.

get_identifiers(Statement):-

    odbc_fetch(Statement, Row, next),
    (Row == end_of_file
    -> true
    ;
    assert_data_identifier(Row),
    get_identifiers(Statement)
    ).

assert_data_identifier(row(Row)):-
    assert(data_identifier(Row)).

out_data_identifiers(DeviceID):-
    string_concat('Data identifiers associated with device ', DeviceID, Out),
    out_debug_message(Out), !, print_data_identifiers.
out_data_identifiers(_).

print_data_identifiers:-data_identifier(ID), out_debug_message(ID), fail.
print_data_identifiers.

/*Обновление только текущего состояния.*/
prepare_update_current_state(Connection, Statement):-
    not(data_to_console), only_current_state,
    out_debug_message('Client is preparing to current state updating.'),
    sg_odbc_connect(Connection),
    odbc_prepare(Connection, 'EXECUTE UpdateCurrentStateStr ?, ?, ?, ?, ?, ?, ?',
        [default, default, default, default, default, default, default],
        Statement, []).
/*Загрузка с заполнением истории.
  https://www.evernote.com/shard/s132/nl/14501366/7601ce0c-6881-4818-8bc7-c4f3a3af28ae*/
prepare_update_current_state(Connection, Statement):-
    not(data_to_console), 
    out_debug_message('Client is preparing to history updating.'),
    sg_odbc_connect(Connection),
    odbc_prepare(Connection, 'EXECUTE PutExtendedRegisterIntoBaseDev ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?',
        [default, default, default, default, default, default, default, default, default, default, default, default, default, default],
        Statement, []).
prepare_update_current_state(_, _)/*:-data_to_console*/.
        
free_update_current_state(Connection, Statement):-
    not(data_to_console), out_debug_message('Client is finishing data updating.'),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection).
free_update_current_state(_, _):-
    data_to_console.

update_current_state(Statement, DeviceID, Identifier,
    /*MeasurementTime*/_, /*AcquisitionTime*/_, Value, Units, QualityBad):-
    not(data_to_console), only_current_state,
    out_debug_message('Client begins updating the item current state.'),
    /*Проверка наличия переданного идентификатора в списке
    идентификаторов данных устройства, которые нужно обновлять.*/
    data_identifier(Identifier), string_concat('Updating item: ', Identifier, Out), out_debug_message(Out),
    get_sql_timestamp_string(TimeString), string_concat('Timestamp: ', TimeString, Out1), out_debug_message(Out1), !,
    odbc_execute(Statement, [DeviceID, Identifier,
        /*Время сбора и появления данных установлено одинаковым!*/
        TimeString, TimeString, Value, Units, QualityBad]).
/*Загрузка с заполнением истории.
  https://www.evernote.com/shard/s132/nl/14501366/7601ce0c-6881-4818-8bc7-c4f3a3af28ae*/
update_current_state(Statement, DeviceID, Identifier,
    /*MeasurementTime*/_, /*AcquisitionTime*/_, Value, Units, QualityBad):-
    not(data_to_console),
    out_debug_message('Client begins updating the item history.'),
    /*Проверка наличия переданного идентификатора в списке
    идентификаторов данных устройства, которые нужно обновлять.*/
    data_identifier(Identifier), string_concat('Updating item: ', Identifier, Out), out_debug_message(Out),
    get_time(S),
    stamp_date_time(S, date(Year, Month, Day, Hour, Min, SecMSec, _, _, _), 'UTC'), !,
    /*
	@DeviceID BIGINT,
	@Identifier NCHAR(20),
	@Units NCHAR(36),
	@IntValue INT,
	@StringValue VARCHAR(MAX),
	@IntStatus INT,
	@Year INT,
	@Month INT,
	@DayOfMonth INT,
	@DayOfWeek NVARCHAR(MAX),
	@Hour INT,
	@Minute INT,
	@Second INT,
	@HundredthsOfSecond INT
    */
    IntValue is round(Value), Second is floor(SecMSec), HundredthsOfSecond is floor(float_fractional_part(SecMSec) * 100),
    odbc_execute(Statement, [DeviceID, Identifier,
        Units, IntValue, '', QualityBad, Year, Month, Day, '', Hour, Min, Second, HundredthsOfSecond]).
update_current_state(_, DeviceID, Identifier,
    /*MeasurementTime*/_, /*AcquisitionTime*/_, Value, Units, QualityBad):-
    /*TODO: Вывод данных.*/
    data_to_console.
/*Предикат должен всегда согласовываться, иначе возникают сильные задержки
и, в конечном итоге, неправильный разбор всего массива данных.*/
update_current_state(_, _, _, _, _, _, _, _):-
    out_debug_message('Data item is not found.').

