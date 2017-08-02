%% Автор:
%% Дата: 30.03.2011

:-thread_local protocol_62056_mode/1.
:-thread_local device_62056_address/1.

read_client_62056_settings:-
    global_protocol_62056_mode(Mode),
    assert(protocol_62056_mode(Mode)),
    global_device_62056_address(Address),
    assert(device_62056_address(Address)).

/*Включается серверный режим работы драйвера 62056.*/
server_62056_mode:-fail.
client_62056_mode.

/*Включает работу клиента по циклическому опросу.*/
:-dynamic poll_mode/0.
poll_mode.

/*Клиент берет параметры из конфига, а не из командной строки.*/
:-dynamic params_from_config/0.
%%params_from_config.

/*Клиент работает в циклическом режиме, но запускается один раз для удобства отладки.*/
:-dynamic single_debug_poll/0.
%%single_debug_poll.

/*Реквизиты для доступа к устройству.*/
:-dynamic device_ip/1.
device_ip('127.0.0.1').

:-dynamic device_port/1.
device_port(1111).

:-dynamic device_id/1.
device_id(83400).

