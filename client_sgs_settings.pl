%% Автор:
%% Дата: 30.03.2011

global_protocol_62056_mode(a).
/*Адрес опрашиваемого клиентом устройства.*/
global_device_62056_address(['1', '2', '3']).

/*Вывод данных в консоль, а не в БД.*/
:-dynamic data_to_console/0.
%%data_to_console.

/*Реквизиты для доступа к БД.*/
:-dynamic sgs_user/1.
:-dynamic sgs_password/1.
sgs_user('SGSDeviceClient').
sgs_password('3975716').

%%  https://www.evernote.com/shard/s132/nl/14501366/7601ce0c-6881-4818-8bc7-c4f3a3af28ae
:-dynamic only_current_state/0.
%%only_current_state.
