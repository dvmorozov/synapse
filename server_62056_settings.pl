%% Автор:
%% Дата: 30.03.2011

:-thread_local protocol_62056_mode/1.
:-thread_local manufact_ident_62056/1.
:-thread_local identification_62056/1.
:-thread_local identification_baudrate_62056/1.
:-thread_local device_62056_address/1.

/*Режим работы по-умолчанию.*/
read_server_62056_settings:-
    /*Предикаты удалять не нужно, поскольку они определяются для текущего потока.*/
    /*Пока у всех потоков одинаковые режимы.*/
    global_protocol_62056_mode(Mode),
    assert(protocol_62056_mode(Mode)),
    global_manufact_ident_62056(ManufactIdent),
    assert(manufact_ident_62056(ManufactIdent)),
    global_identification_62056(Identification),
    assert(identification_62056(Identification)),
    global_identification_baudrate_62056(BR),
    assert(identification_baudrate_62056(BR)),
    global_device_62056_address(SA),
    assert(device_62056_address(SA)).

/*Включается серверный режим работы драйвера 62056.*/
server_62056_mode.
client_62056_mode:-fail.

