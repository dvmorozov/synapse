%% Автор:
%% Дата: 14.03.2011

:-thread_local protocol_62056_mode/1.
:-thread_local manufact_ident_62056/1.
:-thread_local identification_62056/1.
:-thread_local long_message_62056/0.
:-thread_local parsing_mode_62056/1.
:-thread_local identification_baudrate_62056/1.
:-thread_local device_62056_address/1.
:-thread_local baud_rate_62056/1.

handle_server_62056_message(Message, Out):-
    /*Обработчики не должны согласовываться, если ничего не распознано!*/
    handle_prog_com_message_62056(Message, Out).
handle_server_62056_message(Message, Out):-
    handle_request_message_62056(Message, Out).
handle_server_62056_message(Message, Out):-
    handle_ack_message_62056(Message, Out).

/*Data is operand for secure algorithm.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    password_62056(Message, '0', Password),
    /*Делаются все необходимые проверки.*/
    !,
    write('Password 0 message. Password: '), print_list(Password), nl.

/*Data is operand for comparison with internally held password.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    password_62056(Message, '1', Password),
    /*Делаются все необходимые проверки.*/
    all_printable(Password),
    length(Password, L), L=<32, all_allowed(['(', ')', '*', '/', '!'], Password), !,
    write('Password 1 message. Password: '), print_list(Password), nl.

/*Data is result of secure algorithm (manufacturer-specific).*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    password_62056(Message, '2', Password),
    !,
    write('Password 2 message. Password: '), print_list(Password), nl.

handle_prog_com_message_62056(Message, /*Out*/ _):-
    password_62056(Message, Command, Password), !,
    write('Unknown password message. Password: '), print_list(Password),
    write('; command: '), write(Command), nl.

/*Write ASCII-coded data.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_62056(Message, '1', Address, Value, Unit),
    check_data_set_62056(Address, Value, Unit), !,
    write('Write ASCII-coded data. Address='), print_list(Address),
    write(', Value='), print_list(Value), write(', Unit='),
    print_list(Unit), nl.

/*Formatted communication coding method write (optional, see Annex C).*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_62056(Message, '2', Address, Value, Unit),
    check_data_set_62056(Address, Value, Unit), !,
    write('Write formatted data. Address='), print_list(Address),
    write(', Value='), print_list(Value), write(', Unit='),
    print_list(Unit), nl.
    
/*Предикаты для временного сохранения длинного сообщения.*/
:-thread_local write_opt_62056/3.
:-thread_local write_format_opt_62056/3.

/*Write ASCII-coded with partial block (optional).*/
/*Первый блок длинного сообщения. Только в этом блоке м.б. адрес!*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_first_62056(Message, '3', Address, Value),
    check_data_set_62056(Address, Value, []),
    retractall(write_opt_62056(_, _, _)),
    assert(write_opt_62056(Address, Value, [])), !,
    write('Write ASCII-coded with partial block (first). Address='),
    print_list(Address), write(', Value='), print_list(Value), nl.

/*Последующие блоки длинного сообщения.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_middle_62056(Message, '3', Value),
    check_data_set_62056([], Value, []),
    write_opt_62056(Address, PrevValue, _), retractall(write_opt_62056(_, _, _)),
    append(PrevValue, Value, NewValue),
    assert(write_opt_62056(Address, NewValue, [])), !,
    write('Write ASCII-coded with partial block (middle).'),
    write('Value='), print_list(Value), nl.

/*Последний блок длинного сообщения.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_last_62056(Message, '3', Value, Unit),
    check_data_set_62056([], Value, Unit),
    write_opt_62056(Address, PrevValue, _), retractall(write_opt_62056(_, _, _)),
    append(PrevValue, Value, NewValue),
    assert(write_opt_62056(Address, NewValue, Unit)), !,
    write('Write ASCII-coded with partial block (last).'),
    write('Value='), print_list(Value), write(', Unit='),
    print_list(Unit), nl.

/*Formatted communication coding method write (optional, see Annex C)
with partial block.*/
/*Первый блок длинного сообщения. Только в этом блоке м.б. адрес!*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_first_62056(Message, '4', Address, Value),
    check_data_set_62056(Address, Value, []),
    retractall(write_format_opt_62056(_, _, _)),
    assert(write_format_opt_62056(Address, Value, [])), !,
    write('Write formatted with partial block (first). Address='),
    print_list(Address), write(', Value='), print_list(Value), nl.

/*Последующие блоки длинного сообщения.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_middle_62056(Message, '4', Value),
    check_data_set_62056([], Value, []),
    write_format_opt_62056(Address, PrevValue, _),
    retractall(write_format_opt_62056(_, _, _)),
    append(PrevValue, Value, NewValue),
    assert(write_format_opt_62056(Address, NewValue, [])), !,
    write('Write formatted with partial block (middle).'),
    write('Value='), print_list(Value), nl.

/*Последний блок длинного сообщения.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    write_last_62056(Message, '4', Value, Unit),
    check_data_set_62056([], Value, Unit),
    write_format_opt_62056(Address, PrevValue, _),
    retractall(write_format_opt_62056(_, _, _)),
    append(PrevValue, Value, NewValue),
    assert(write_format_opt_62056(Address, NewValue, Unit)), !,
    write('Write formatted with partial block (last).'),
    write('Value='), print_list(Value), write(', Unit='),
    print_list(Unit), nl.
    
/*Неизвестная команда записи.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    member(OptId, ['\x03', '\x04']),
    command_62056(Message, 'W', SubCommand, _, _, _, OptId), !,
    write('Unknown write command '), write(SubCommand), nl.

/*Read ASCII-coded data.*/
/*Поле Value может быть непустым и содержать, например, длину считываемого
массива.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    read_62056(Message, '1', Address, Value, []),
    check_data_set_62056(Address, Value, []),
    /*Здесь должна быть обработка чтения.*/
    !,
    write('Read ASCII-coded data. Address='), print_list(Address),
    write('; Value='), print_list(Value), nl.

/*Formatted communication coding method read (optional, see Annex C).*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    read_62056(Message, '2', Address, Value, []),
    check_data_set_62056(Address, Value, []), !,
    write('Read formatted data. Address='), print_list(Address),
    write('; Value='), print_list(Value), nl.

/*Read ASCII-coded with partial block (optional).*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    read_62056(Message, '3', Address, Value, []),
    check_data_set_62056(Address, Value, []),
    /*Здесь должна быть обработка чтения.*/
    !,
    write('Read ASCII-coded with partial block (first). Address='),
    print_list(Address), write(', Value='), print_list(Value), nl.

/*Formatted communication coding method read (optional, see Annex C)
with partial block.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    read_62056(Message, '4', Address, Value, []),
    check_data_set_62056(Address, Value, []),
    /*Здесь должна быть обработка чтения.*/
    !,
    write('Read formatted with partial block (first). Address='),
    print_list(Address), write(', Value='), print_list(Value), nl.

handle_prog_com_message_62056(Message, /*Out*/ _):-
    member(OptId, ['\x03', '\x04']),
    command_62056(Message, 'R', SubCommand, _, _, _, OptId), !,
    write('Unknown read command '), write(SubCommand), nl.

handle_prog_com_message_62056(Message, /*Out*/ _):-
    formatted_execution_62056(Message, Code, Data),
    check_data_set_62056(Code, Data, []), !,
    write('Formatted execution; code='), write(Code),
    write(' ,data='), write(Data), nl.
    
handle_prog_com_message_62056(Message, /*Out*/ _):-
    command_62056(Message, 'E', SubCommand, _, _, _, '\x03'), !,
    write('Unknown execution command '), write(SubCommand), nl.

/*Complete sign-off.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    exit_62056(Message, '0'),
    /*Здесь должна быть обработка*/
    !,
    write('Complete sign-off'), nl.
    
/*Complete sign-off for battery operated devices using the fast wake-up method.*/
handle_prog_com_message_62056(Message, /*Out*/ _):-
    exit_62056(Message, '1'),
    /*Здесь должна быть обработка*/
    !,
    write('Complete sign-off for battery operated devices'), nl.
    
handle_prog_com_message_62056(Message, /*Out*/ _):-
    command_62056(Message, 'B', SubCommand, [], [], [], '\x03'), !,
    write('Unknown break command '), write(SubCommand), nl.
    
/*Получен запрос.*/
:-thread_local request_message_62056_received/1.
/*Ожидание квитанции.*/
:-thread_local ack_62056_waiting/0.
/*Получена квитанция.*/
:-thread_local ack_62056_received/0.

handle_ack_message_62056(Message, _):-
    ack_opt_62056(Message),
    write('Ack received'), nl,
    assert(ack_62056_received).

handle_request_message_62056(Message, Out):-
    request_message_62056(Message, Address),
    /*Проверяется длина адресного поля*/
    length(Address, Len), max_address_len_62056(MaxLen), Len=<MaxLen,
    /*Проверяется допустимость символов.*/
    check_address_symbols_62056(Address),
    /*Удаляются все начальные нули*/
    remove_leading_address_zeros_62056(Address, RealAddress), !,
    write('Request received, address :'), print_list(RealAddress), nl,
    check_address_62056(RealAddress, /*Out*/_),
    reset_62056_server, /*???*/
    assert(request_message_62056_received(RealAddress)).

/*Предикат должен согласовываться, чтобы обеспечить удаление сообщения.*/
/*As a missing address field is considered as a general address (/ ? ! CR LF),
the tariff device shall respond.*/
check_address_62056([], _):-!.
check_address_62056(Address, _):-device_62056_address(Address), !.
/*Сюда входит при нарушении первого условия.*/
check_address_62056(Address, _):-
    write('Address is incorrect :'), print_list(Address), nl.
    
/*Должна всегда согласовываться, чтобы не прерывать основного цикла и
обеспечить удаление распознанной части сообщения.*/
/*Возврат ответа.*/
server_62056_reply(Out):-protocol_62056_mode(a), !,
    request_message_62056_received(Address), out_debug_message('Server replies in mode A.'),
    send_62056_identification(Out),
    /*Отдаем имеющиеся в базе данные.*/
    send_all_data_62056(Address, Out),
    reset_62056_server.
server_62056_reply(Out):-
    protocol_62056_mode(c), ack_62056_received, !,
    request_message_62056_received(Address), out_debug_message('Server replies in mode C (ack received).'),
    send_all_data_62056(Address, Out),
    reset_62056_server.
server_62056_reply(Out):-
    protocol_62056_mode(c), not(ack_62056_waiting), !,
    request_message_62056_received(_), out_debug_message('Server replies in mode C (ack waiting).'),
    send_62056_identification(Out),
    assert(ack_62056_waiting).

/*Сброс состояний приема.*/
reset_62056_server:-
    retractall(ack_62056_received),
    retractall(request_message_62056_received(_)),
    retractall(ack_62056_waiting).

send_62056_identification(Out):-out_debug_message('Server sends its identification.'),
    manufact_ident_62056(ManufactIdent),
    identification_62056(Identification),
    identification_baudrate_62056(BaudRate),
    identification_message_62056(Reply, ManufactIdent, Identification, BaudRate),
    write_list(Reply, Out).
    
send_test_file(S, Out):-
/*
    empty_data_message_62056(Reply),
    write_list(Reply, Out).
*/
    stream_to_list(S, C),
    codes_to_chars(C, L),
    append(L, ['\x03'], L1),
    init_bcc_62056('\x0'),
    put_char(Out, '\x02'),
    bcc_62056(L1, Bcc),
    list_to_stream(L1, Out),
    list_to_stream([Bcc], Out),
    write('File transmitted. Bcc='), write(Bcc), nl.

/*Отдаем имеющиеся в базе данные.*/
send_all_data_62056(DeviceAddress, Out):-
    not(data_list_62056(DeviceAddress, _)), out_debug_message('Server replies with sample text data.'),
    setup_call_cleanup(
        /*Должен быть "binary", иначе не передает символ x0d.*/
        open('satec data.txt', read, S, [type(binary)]),
        send_test_file(S, Out),
        close(S)).
send_all_data_62056(DeviceAddress, Out):-out_debug_message('Server replies with internal data.'),
    init_bcc_62056('\x0'),
    put_char(Out, '\x02'), send_data_items_62056(DeviceAddress, Out),
    bcc_62056(['\x0d', '\x0a', '!', '\x0d', '\x0a', '\x03'], Bcc),
    write_list(['\x0d', '\x0a', '!', '\x0d', '\x0a', '\x03', Bcc], Out), !.
/*Предикат всегда согласуется.*/
send_all_data_62056(_, _).

send_data_items_62056(DeviceAddress, Out):-
    data_list_62056(DeviceAddress, Items),
    send_data_set_62056(Out, Items, 0),
    out_debug_message('Before database modification.'),
    modify_demo_data(Items, NewItems), 
    retractall(data_list_62056(DeviceAddress, Items)),
    assert(data_list_62056(DeviceAddress, NewItems)),
    out_debug_message('Demo database has been modified.').
send_data_items_62056(_, _):-
    out_debug_message('Send data failed.').

send_data_set_62056(_, [], _):-!.
send_data_set_62056(Out, [data_item_62056(_, Address, Value, Unit)|T], LineLen):-
    atom_chars(Address, AddressChars), atom_chars(Value, ValueChars), atom_chars(Unit, UnitChars),
    data_set_62056(DS, AddressChars, ValueChars, UnitChars), !,
    check_line_len_62056(LineLen, DS, Out, NewLineLen),
    bcc_62056(DS, _), write_list(DS, Out),
    print_list(DS), nl,
    send_data_set_62056(Out, T, NewLineLen).
    
/*NewLineLen принимает значение длины строки, получаемой ПОСЛЕ вывода DS
(новой или предыдущей)!*/
add_list_len(LineLen, List, NewLineLen):-
    /*Здесь должно быть отсечение, иначе зависает при попытке повторного
    согласования is!*/
    length(List, L), NewLineLen is L + LineLen, !.

check_line_len_62056(LineLen, DS, _, NewLineLen):-
    /*Нельзя использовать is - зависает при отказе сравнения!*/
    add_list_len(LineLen, DS, NewLineLen), NewLineLen =< 78.
check_line_len_62056(_, DS, Out, NewLineLen):-
    length(DS, NewLineLen),
    bcc_62056(['\x0d', '\x0a'], _), write_list(['\x0d', '\x0a'], Out).

/******************************************************************************/
server_62056_init.
:-dynamic server_port/1.

server_62056_run(ServerSocket, Options):-manual_input,
    write('server 62056 started in manual input mode'), nl,
    server_62056_loop(ServerSocket, Options).
server_62056_run(ServerSocket, Options):-not(manual_input),
    server_port(Port),
    write('server 62056 started on port '), write(Port), nl,
    server_62056_loop(ServerSocket, Options).

server_62056_main(Port, Options) :-
    retractall(server_port(_)), assert(server_port(Port)),
    server_62056_init,
    /*Подготовка к запуску сервера.*/
    tcp_socket(ServerSocket),
    %%tcp_setopt(ServerSocket, reuseaddr),
    tcp_bind(ServerSocket, Port),
    tcp_listen(ServerSocket, 5),
    server_62056_run(ServerSocket, Options).

/*???Должен быть предусмотрен выход из цикла.*/
server_62056_loop(ServerSocket, Options) :-
    tcp_accept(ServerSocket, Slave, Peer),
    /*Это может отнимать до 10 секунд!*/
    /*tcp_host_to_address(Host, Peer),*/
    /*Использование alias как в примере мешает повторно открывать подключения
    от одного хоста!*/
    thread_create(service_62056_client(
        Slave, Peer, /*Host*/Peer, Options), _, [detached(true)]),
    server_62056_loop(ServerSocket, Options).

service_62056_client(Slave, Peer, Host, Options) :-
    write('Connection accepted: '), write(Peer),
    write(', host: '), write(Host), nl,
    allow_client_62056(Peer, Options), !,
    read_server_62056_settings,
    thread_self(Id),
    init_fifo_62056(FIFO),
    tcp_open_socket(Slave, InStream, OutStream),
    call_cleanup(
    handle_service_62056(FIFO, InStream, OutStream),
    (
        /*Сообщение выводится только если его поместить до закрытия потоков!
        flush_output вызывать обязательно!*/
        write('Connection closed: '), write(Peer), nl, flush_output,
        close(InStream),
        close(OutStream),
        tcp_close_socket(Slave),
        thread_detach(Id),
        thread_exit(success)
    )).
service_62056_client(Slave, _, _, _):-
    thread_self(Id),
    tcp_open_socket(Slave, InStream, OutStream),
    format(OutStream,
        'Server 62056 is too busy now. Please try again later!~n', []),
    close(InStream),
    close(OutStream),
    tcp_close_socket(Slave),
    thread_detach(Id),
    thread_exit(failure).
  
handle_service_62056(FIFO, In, Out):-
    server_62056_get_char(In, C),
    server_62056_handle_char(In, C, FIFO, Out).

/*end_of file является признаком закрытия клиента и должен прерывать цикл.*/
server_62056_handle_char(_, end_of_file, _, _).
server_62056_handle_char(In, C, FIFO, Out):-
    write(C), flush_output,
    /*Обратного вывода нет!*/
    /*write(Out, C),*/
    /*Требуется, чтобы данные отправлялись без задержки,
    tcp_setopt(ServerSocket, nodelay) в этом не помогает!*/
    /*flush_output(Out),*/
    push_fifo_62056(FIFO, C, NewFIFO),
    parse_fifo_62056(NewFIFO, Out, NewFIFO2),
    handle_service_62056(NewFIFO2, In, Out).

server_62056_get_char(In, S):-
    manual_input, get_char(In, S), not(read_delimiter(S)), !.
server_62056_get_char(In, S):-get_char(In, S).

/*Проверяет допустимость присоединения клиента 62056.*/
allow_client_62056(_, _).

optspec_server_62056([[opt('ipport'), type(integer), default(0),
    shortflags([]), longflags(['ipport']),
    help(['ip-port number to listen'])]]).

server_62056:-optspec_server_62056(OptSpec),
    opt_arguments(OptSpec, Opts, _),
    check_server_62056_port(OptSpec, Opts).

/*Проверяет допустимость номера ip-порта.*/
check_server_62056_port(_, Opts):-
    sgs_member(ipport(IPPort), Opts), not(IPPort == 0),
    server_62056_main(IPPort, []).
check_server_62056_port(OptSpec, _):-optspec_server_62056(OptSpec),
    opt_help(OptSpec, HelpText), print(HelpText), nl.

