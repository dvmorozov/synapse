%% �����:
%% ����: 03.09.2011

global_protocol_62056_mode(a).
global_manufact_ident_62056(['S', 'G', 'S']).
global_identification_62056(['S', 'G', 'S',
        '-', 'S', 'Y', 'N', 'A', 'P', 'S', 'E']).

/*� ������ � ����� ������������ ����� ������, ����� �����������������.*/
global_identification_baudrate_62056(['S']):-protocol_62056_mode(a).

/*����� ����������. ����� ������ ���������� ��� ���������� �����.*/
global_device_62056_address(['1', '2', '3']).
