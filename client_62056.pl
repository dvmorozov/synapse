%% Автор: D.V.Morozov
%% Дата: 14.03.2011 

:-thread_local protocol_62056_mode/1.
:-thread_local baud_rate_62056/1.
:-thread_local device_62056_address/1.
:-thread_local device_id/1.
:-thread_local long_message_62056/0.
:-thread_local parsing_mode_62056/1.
:-thread_local update_current_state_statement/1.
/*Идентификатор журнала трассировки.*/
:-thread_local contents_id/1.

handle_client_62056_message(Message, Out):-
    handle_data_message_pro_62056(Message, Out).
handle_client_62056_message(Message, Out):-
    handle_error_message_62056(Message, Out).
handle_client_62056_message(Message, Out):-
    handle_identification_message_62056(Message, Out).
handle_client_62056_message(Message, Out):-
    handle_data_message_62056(Message, Out).

/*Одиночное сообщение.*/
handle_data_message_pro_62056(Message, /*Out*/ _):-
    data_message_pro_62056(Message, Address, Value, Unit, '\x03'),
    check_data_set_62056(Address, Value, Unit), !,
    atom_chars(AddressAtom, Address),
    atom_chars(ValueAtom, Value),
    atom_chars(UnitAtom, Unit),
    atomic_list_concat(
        ['Data message (programming mode). Address=', AddressAtom,
         'Value=', ValueAtom, 'Unit=', UnitAtom], ', ', M),
    add_message_to_process_log(M).

/*Предикаты для временного сохранения длинного сообщения.*/
:-thread_local data_message_opt_62056/3.

/*Первый блок длинного сообщения. Только в этом блоке м.б. адрес!*/
handle_data_message_pro_62056(Message, /*Out*/ _):-
    data_message_pro_first_62056(Message, Address, Value),
    check_data_set_62056(Address, Value, []),
    retractall(data_message_opt_62056(_, _, _)),
    assert(data_message_opt_62056(Address, Value, [])), !,
    atom_chars(AddressAtom, Address),
    atom_chars(ValueAtom, Value),
    atomic_list_concat(
        ['Data message with partial block (first). Address=', AddressAtom,
         'Value=', ValueAtom], ', ', M),
    add_message_to_process_log(M).

/*Последующие блоки длинного сообщения.*/
handle_data_message_opt_62056(Message, /*Out*/ _):-
    data_message_pro_middle_62056(Message, Value),
    check_data_set_62056([], Value, []),
    data_message_opt_62056(Address, PrevValue, _),
    retractall(data_message_opt_62056(_, _, _)),
    append(PrevValue, Value, NewValue),
    assert(data_message_opt_62056(Address, NewValue, [])), !,
    atom_chars(ValueAtom, Value),
    atomic_list_concat(
        ['Data message with partial block (middle). Value=',
         ValueAtom], M),
    add_message_to_process_log(M).

/*Последний блок длинного сообщения.*/
handle_data_message_opt_62056(Message, /*Out*/ _):-
    data_message_pro_last_62056(Message, Value, Unit),
    check_data_set_62056([], Value, Unit),
    data_message_opt_62056(Address, PrevValue, _),
    retractall(data_message_opt_62056(_, _, _)),
    append(PrevValue, Value, NewValue),
    assert(data_message_opt_62056(Address, NewValue, Unit)), !,
    atom_chars(ValueAtom, Value),
    atom_chars(UnitAtom, Unit),
    atomic_list_concat(
        ['Data message with partial block (last). Value=', ValueAtom,
         'Unit=', UnitAtom], ', ', M),
    add_message_to_process_log(M).

handle_error_message_62056(Message, /*Out*/ _):-
    error_message_pro_62056(Message, ErrMsg),
    check_error_message(ErrMsg), !,
    atom_chars(ErrMsgAtom, ErrMsg),
    atomic_list_concat(
        ['Errorm message: ', ErrMsgAtom], M),
    add_message_to_process_log(M).

handle_identification_message_62056(Message, /*Out*/ _):-
    identification_message_62056(Message, ManufactIdent, Identification, BaudRate),
    /*Выполняются проверки.*/
    /* ??? сделать проверки для клиентов специального типа
    client_manufact_ident_62056(ManufactIdent),
    ident_62056(Identification),
    */
    check_baud_ident_62056(BaudRate),
    retractall(minimum_reaction_time_62056(_)),
    /*???assert(minimum_reaction_time_62056()),*/
    /*??? вывод перенести в предикаты проверки.*/
    atom_chars(ManufactIdentAtom, ManufactIdent),
    atom_chars(IdentificationAtom, Identification),
    atomic_list_concat(
        ['Identification message. ManufactIdent=', ManufactIdentAtom,
         ', Identification=', IdentificationAtom], M),
    add_message_to_process_log(M).

client_manufact_ident_62056(MI):-equal_lists(MI, [I1, I2, I3]),
    check_manufact_ident_62056(I1, I2, I3).
/*Manufacturer's identification comprising three upper case letters except as
noted below. If a tariff device transmits the third letter in lower case, the
minimum reaction time tr for the device is 20 ms instead of 200 ms. Even though
a tariff device transmits an upper case third letter, this does not preclude
supporting a 20 ms reaction time. These letters shall be registered with the
administrator.*/
check_manufact_ident_62056(I1, I2, I3):-upper_case_letters(U),
    sgs_member(I1, U), sgs_member(I2, U), sgs_member(I3, U),
    assert(minimum_reaction_time_62056(20)), !.
check_manufact_ident_62056(I1, I2, I3):-upper_case_letters(U),
    lower_case_letters(L), sgs_member(I1, U), sgs_member(I2, U),
    sgs_member(I3, L), assert(minimum_reaction_time_62056(20)), !.
    
/*Normal response of a tariff device, for example the full data set
(not used in protocol mode E).*/
/*Пустое сообщение данных (readout mode).*/
handle_data_message_62056(Message, _):-
    empty_data_message_62056(Message), !,
    add_message_to_process_log('Empty data message').
/*Пустое сообщение без BCC.*/
handle_data_message_62056(['!', '\x0d', '\x0a'], _):-
    not(long_message_62056), !,
    add_message_to_process_log('Empty data message without BCC').
/*Сообщение с одной строкой данных.*/
handle_data_message_62056(['\x02'|DataBlockPart], _):-
    append(DataBlock, ['!', '\x0d', '\x0a', '\x03', Bcc], DataBlockPart),
    append(DataBlock, ['!', '\x0d', '\x0a', '\x03'], R),
    init_bcc_62056('\x0'), bcc_62056(R, Bcc),
    data_block_client_62056(DataBlock), !,
    add_message_to_process_log('Single line data message').
/*Сообщение с одной строкой данных без BCC.*/
handle_data_message_62056(Message, _):-
    append(DataBlock, ['!', '\x0d', '\x0a'], Message),
    data_block_client_62056(DataBlock), !,
    add_message_to_process_log('Single line data message without BCC').
/*Первое сообщение блока данных.*/
handle_data_message_62056(['\x02'|DataBlock], _):-
    not(long_message_62056),
    data_block_client_62056(DataBlock),
    retract_long_message_62056, assert(long_message_62056),
    init_bcc_62056('\x0'), bcc_62056(DataBlock, _), !,
    atom_chars(DataBlockAtom, DataBlock),
    atomic_list_concat(
        ['First line of data message: ', DataBlockAtom], M),
    add_message_to_process_log(M).
/*Проверяется флаг завершения сообщения*/
handle_data_message_62056(['!', '\x0d', '\x0a', '\x03', Bcc], _):-
    long_message_62056, parsing_mode_62056(from_begin),
    bcc_62056(['!', '\x0d', '\x0a', '\x03'], Bcc),
    retract_long_message_62056, !,
    atom_chars(BccAtom, [Bcc]),
    atomic_list_concat(
        ['Data message ended. Bcc=', BccAtom], M),
    add_message_to_process_log(M).
/*Проверяется формат блока данных (распознается только первый блок,
следующий - в следующем цикле)*/
handle_data_message_62056(DataBlock, _):-
    long_message_62056, parsing_mode_62056(from_begin),
    data_block_client_62056(DataBlock), bcc_62056(DataBlock, _), !. /*,
    write('Block of data message: '), print_list(DataBlock), nl.*/

/*Data block with the measured values. All printable characters may be used in
the data block, as well as LF and CR, except for "/" and "!".*/
/*Допускается последовательность data line, разделенных символами CR, LF;
следующие data line распознаются в следующем цикле.*/
/*Проверка допустимости символов должна делаться после нахождения завершающей
комбинации, поскольку за ней могут находиться произвольные символы!*/
/*Строка data line с CR, LF.*/
data_block_client_62056(DB):-append(DataLine, ['\x0d', '\x0a'], DB), !,
    check_data_line_62056(DataLine),
    data_line_client_62056(DataLine).
/*Строка data line без CR, LF.*/
/*??? Блок данных должен иметь ограничители,
иначе это правило всегда срабатывает!
data_block_client_62056(DataLine):-
    check_data_line_62056(DataLine),
    data_line_client_62056(DataLine).
*/

/*Необходимое условие завершения.*/
data_line_client_62056([]).
data_line_client_62056(DL):-append(DataSet, Tail, DL),
    data_set_62056(DataSet, Address, Value, Units),
    check_data_set_62056(Address, Value, Units), !,
    /*???extract_data_set здесь вызывать нельзя*/
    put_data_into_base(Address, Value, Units),
    data_line_client_62056(Tail).
    
/*Должен всегда согласовывться, для того, чтобы были переданы все данные,
какие возможно!*/
put_data_into_base(Address, Value, Units):-
    device_id(DeviceID),
    atom_chars(Address_, Address),
    catch(number_codes(Value_, Value), _,
        (print_invalid_number_message(Value), fail)),
    atom_chars(Units_, Units),
    update_current_state_statement(Statement), !,
    update_current_state(Statement, DeviceID, Address_,
      _, %%MeasurementTime
      _, %%AcquisitionTime
      Value_, Units_, 0),
    atomic_list_concat(
        [Address_, Value_, Units_], ' ', M),
    add_message_to_process_log(M).
put_data_into_base(_, _, _).

print_invalid_number_message(/*Value*/_). /*:-
    atom_chars(Value_, Value),
    atomic_list_concat(
        ['Non-numeric value ', Value_, ' ignored.'], M),
    add_message_to_process_log(M).*/

/*Извлекает данные и выполняет необходимые действия.*/
/*NOTE 1 Remarks regarding items a), e) and f) to reduce the quantity of data,
the identification code a) and/or the nit information e) and f) can be dispensed
with, provided that an unambiguous correlation exists For example, the
dentification code or the unit information is not necessary for a sequence of
similar values (sequence of historical alues) on condition that the evaluation
unit can clearly establish the identification code and unit of the succeeding
alues from the first value of a sequence*/
/*Т.е. за первым data set с полной информацией могут следовать data set без
адреса и единиц измерения!*/
extract_data_set_62056(DS):-
    data_set_62056(DS, Address, Value, Unit),
    check_data_set_62056(Address, Value, Unit), !,
    /*??? Добавить заполнение адреса устройства.*/
    assert(data_item_62056([], Address, Value, Unit)) /*,
    write(data_item_62056([], Address, Value, Unit)), nl*/.

/******************************************************************************/

sg_tcp_connect_internal(Socket, Host, Port):-
    tcp_connect(Socket, Host:Port).

sg_tcp_connect(Socket, Host, Port):-
    setup_call_catcher_cleanup(
        true, sg_tcp_connect_internal(Socket, Host, Port), fail, (
        atomic_concat('TCP connection failed. Host=', Host, S1),
        atomic_concat(S1, ', Port', S2),
        atomic_concat(S2, Port, S3),
        add_message_to_process_log(S3)
    )).
/******************************************************************************/

/*Работа в ручном режиме.*/
do_client_work(In, Out, _):-
    not(poll_mode), 
    add_message_to_process_log('Client is running in manual mode.'),
    manual_input,
    /*Создается поток для приема данных...*/
    thread_create(get_data_60256_thread(In, Out), _, []),
    /*...клиент замыкается в цикле чтения ввода от пользователя.*/
    chat_to_server(In, Out),
    close_connection(In, Out).
/*Работа в автоматическом режиме по расписанию.*/
do_client_work(In, Out, DevID):-
    not(poll_mode),
    add_message_to_process_log('Client is running in schedule mode.'),
    /*Создается поток для однократной посылки запроса и приема ответа.*/
    %%thread_create(
    request_data_60256_thread(In, Out, DevID) %%, Id, []),
    %%assert(client_thread_running(Id))
    /*Точка должна быть на следующей строке!*/
    .
/*Работа в режиме циклического опроса сервера.*/
do_client_work(In, Out, DevID):-
    poll_mode,
    add_message_to_process_log('Client is running in poll mode.'),
    /*Создается поток для однократной посылки запроса и приема ответа.*/
    %%thread_create(
    request_data_60256_thread(In, Out, DevID) %%, Id, []),
    %%assert(client_thread_running(Id))
    /*Оператор должен быть на следующей строке!*/
    /*TODO: сделать ожидание завершения потока.*/
    .

create_client_62056(Host, Port, DevID) :-
    start_process_log,
    contents_id(ContentsID), print('ContentsID = '), print(ContentsID), nl,
    tcp_socket(Socket),
    sg_tcp_connect(Socket, Host, Port),
    tcp_open_socket(Socket, In, Out),
    atomic_concat('Host=', Host, S1),
    atomic_concat(S1, ', Port=', S2),
    atomic_concat(S2, Port, S3),
    atomic_concat(S3, ', Device id=', S4),
    atomic_concat(S4, DevID, S5),
    add_message_to_process_log(S5), !,
    do_client_work(In, Out, DevID),
    run_client_again(Host, Port, DevID).

run_client_again(_, _, _):-not(poll_mode), stop_process_log.
run_client_again(_, _, _):-poll_mode, single_debug_poll.
run_client_again(Host, Port, DevID):-poll_mode,  not(single_debug_poll), sleep(10), create_client_62056(Host, Port, DevID).

close_connection(In, Out) :-
    close(In, [force(true)]),
    close(Out, [force(true)]).
        
get_data_60256_thread(In, Out):-
    thread_self(Id),
    call_cleanup(
        get_data_60256(In, Out),
    (
        thread_detach(Id)
    )).
    
get_data_60256(In, Out):-
    init_fifo_62056(FIFO),
    get_data_60256_loop(FIFO, In, Out).
/*Всегда д. завершаться успешно, чтобы не было сообщения об ошибке.*/
get_data_60256(_, _).

get_data_60256_loop(FIFO, In, Out):-
    wait_for_input([In], Ready, 0.5),
    client_62056_handle_streams(Ready, FIFO, Out, NewFIFO),
    get_data_60256_loop(NewFIFO, In, Out).
    
/*Нет символа (таймаут).*/
client_62056_handle_streams([], FIFO, _, FIFO):-manual_input, !.
client_62056_handle_streams([], FIFO, _, FIFO):-
    add_message_to_process_log('Receiving finished'), fail.
client_62056_handle_streams([In|_], FIFO, Out, NewFIFO2):-
    /*Сокет закрыт - завершение цикла.*/
    not(at_end_of_stream(In)),
    get_char(In, C),
    /*write(C), flush_output,*/
    push_fifo_62056(FIFO, C, NewFIFO),
    parse_fifo_62056(NewFIFO, Out, NewFIFO2).
    
/*Должна быть dynamic, поскольку устанавливается в одном потоке,
а проверяется в другом.*/
:-dynamic client_thread_running/1.

request_data_60256_thread(In, Out, DevID):-
    thread_self(/*Id - Warning!*/_),
    read_client_62056_settings,
    device_62056_address(DeviceAddress),
    request_message_62056(Message, DeviceAddress),
    /*Отправка запроса данных.*/
    write_list(Message, Out),
    atom_chars(MessageAtom, Message),
    atomic_list_concat(
        ['Request: ', MessageAtom], M),
    add_message_to_process_log(M),
    /*Необходимо для правильного обновления в однопоточном режиме.*/
    retractall(device_id(_)), assert(device_id(DevID)),
    /*Должно быть завершение потока в любом случае.*/
    get_device_identifiers(DevID),
    prepare_update_current_state(Connection, Statement),
    retractall(update_current_state_statement(_)),
    assert(update_current_state_statement(Statement)),
    call_cleanup(get_data_60256(In, Out),
    (
        add_message_to_process_log('Client task done'),
        free_update_current_state(Connection, Statement),
        
        close_connection(In, Out) %%,
        %%thread_detach(Id),
        /*Из дополнительного потока нельзя вызывать halt.*/
        %%retract(client_thread_running(Id))
    )).

check_working_thread_status:-not(client_thread_running(_)).
check_working_thread_status:-client_thread_running(_), 
    out_debug_message('Client thread is running.'), sleep(5),
    check_working_thread_status.

chat_to_server(In, Out) :- get_char(S),
    write(Out, S), flush_output(Out),
    chat_to_server(In, Out).
    
optspec_client_62056([
    [opt('devid'), type(integer), default(0),
    shortflags([]), longflags(['devid']),
    help(['device identificator to get device description from the database'])],
    [opt('ipaddr'), type(atom), default(''),
    shortflags([]), longflags(['ipaddr']),
    help(['device ip address'])],
    [opt('ipport'), type(integer), default(0),
    shortflags([]), longflags(['ipport']),
    help(['device ip port'])]
    ]).

/*Стартовый предикат для отдельного приложения-клиента.*/
client_62056:-
    not(params_from_config),
    add_message_to_process_log('Client is running with command line options.'),
    optspec_client_62056(OptSpec),
    opt_arguments(OptSpec, Opts, _),
    check_client_62056_opts(OptSpec, Opts),
    check_working_thread_status. /*Завершать процесс пока не требуется!*//*,
    halt.*/
client_62056:-
    params_from_config,
    add_message_to_process_log('Client is running with configuration options.'),
    device_ip(DeviceIP), device_port(DevicePort), device_id(DeviceID),
    create_client_62056(DeviceIP, DevicePort, DeviceID),
    check_working_thread_status. /*Завершать процесс пока не требуется!*//*,
    halt.*/
    
check_client_62056_opts(_, Opts):-
    sgs_member(devid(DevID), Opts), not(DevID == 0),
    sgs_member(ipaddr(IPAddr), Opts), not(IPAddr == ''),
    sgs_member(ipport(IPPort), Opts), not(IPPort == 0),
    /*запуск опроса по расписанию*/
    /*sheduled_data_acquisition.*/
    create_client_62056(IPAddr, IPPort, DevID).
check_client_62056_opts(OptSpec, _):-optspec_client_62056(OptSpec),
    opt_help(OptSpec, HelpText), print(HelpText), nl.

