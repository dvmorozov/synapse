%% �����:
%% ����: 03.09.2011

global_protocol_62056_mode(c).
global_manufact_ident_62056(['S', 'A', 'T']).
global_identification_62056(['E', 'M', '7', '2', '0', '0',
    '0', '6', '5', '6', '6', '2', '1']).

/*� ������ � ����� ������������ ����� ������, ����� �����������������.*/
global_identification_baudrate_62056(['6']):-protocol_62056_mode(c).
global_identification_baudrate_62056(['6']):-protocol_62056_mode(d).

/*����� ������ ���������� ��� ���������� �����.*/
global_device_62056_address(['1']).

