%% Автор:
%% Дата: 16.09.2011

%% Предикаты для записи трассировочных сообщений в БД.

:-dynamic process_log_connection/1.
:-dynamic process_log_statement/1.
:-thread_local contents_id/1.

prepare_add_message_to_process_log:-
    retractall(process_log_connection(_)),
    retractall(process_log_statement(_)),
    prepare_log_connection,
    assert(process_log_connection(Connection)),
    assert(process_log_statement(Statement)).

prepare_log_connection:-
    not(log_to_console),
    sg_odbc_connect(Connection),
    print('before prepare_add_message ...'), nl,
    odbc_prepare(Connection, 'EXECUTE AddMessageToProcessLog ?, ?, ?',
        [default, default, default],
        Statement, []).
prepare_log_connection:-log_to_console.

free_add_message_to_process_log:-
    free_log_connection,
    retractall(process_log_connection(_)),
    retractall(process_log_statement(_)).

free_log_connection:-
    not(log_to_console),
    process_log_connection(Connection),
    process_log_statement(Statement),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection).
free_log_connection:-log_to_console.

add_message_to_process_log(Message):-
    not(log_to_console),
    process_log_statement(Statement),
    contents_id(ContentsID), !,
    get_time(T), timestamp_to_sql_string(T, MessageTimestamp),
    odbc_execute(Statement, [ContentsID, Message, MessageTimestamp]).
/*Вывод в консоль, если нет подключения к БД.*/
add_message_to_process_log(Message):-
    log_to_console,
    print(Message), nl.

create_process_log(PID, CmdLine):-
    not(log_to_console),
    sg_odbc_connect(Connection),
    print('before create_process_log::odbc_prepare'), nl,
    odbc_prepare(Connection, 'EXECUTE CreateProcessLog ?, ?',
        [default, default],
        Statement, [fetch(fetch)]),
    odbc_execute(Statement, [PID, CmdLine]),
    odbc_fetch(Statement, row(ContentsID), next),
    retractall(contents_id(_)),
    assert(contents_id(ContentsID)),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection).
create_process_log(PID, CmdLine):-
    retractall(contents_id(_)),
    assert(contents_id(0)),
    log_to_console.

delete_process_log:-
    not(log_to_console),
    contents_id(ContentsID),
    sg_odbc_connect(Connection),
    print('before delete_process_log::odbc_prepare'), nl,
    odbc_prepare(Connection, 'EXECUTE DeleteProcessLog ?',
        [default],
        Statement, []),
    odbc_execute(Statement, [ContentsID]),
    odbc_free_statement(Statement),
    sg_odbc_disconnect(Connection),
    retractall(contents_id(_)).
delete_process_log:-log_to_console.
    
start_process_log:-
     create_process_log(1, ''),
     prepare_add_message_to_process_log.

/*Завершение записи в лог без удаления из БД.*/
stop_process_log:-
    free_add_message_to_process_log,
    retractall(contents_id(_)).

