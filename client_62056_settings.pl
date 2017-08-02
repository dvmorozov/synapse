%% �����:
%% ����: 30.03.2011

:-thread_local protocol_62056_mode/1.
:-thread_local device_62056_address/1.

read_client_62056_settings:-
    global_protocol_62056_mode(Mode),
    assert(protocol_62056_mode(Mode)),
    global_device_62056_address(Address),
    assert(device_62056_address(Address)).

/*���������� ��������� ����� ������ �������� 62056.*/
server_62056_mode:-fail.
client_62056_mode.

/*�������� ������ ������� �� ������������ ������.*/
:-dynamic poll_mode/0.
poll_mode.

/*������ ����� ��������� �� �������, � �� �� ��������� ������.*/
:-dynamic params_from_config/0.
%%params_from_config.

/*������ �������� � ����������� ������, �� ����������� ���� ��� ��� �������� �������.*/
:-dynamic single_debug_poll/0.
%%single_debug_poll.

/*��������� ��� ������� � ����������.*/
:-dynamic device_ip/1.
device_ip('127.0.0.1').

:-dynamic device_port/1.
device_port(1111).

:-dynamic device_id/1.
device_id(83400).

