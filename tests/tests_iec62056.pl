%% �����:
%% ����: 06.03.2011

/*dynamic ������ ����������� � ������ �����*/
:-thread_local protocol_62056_mode/1.

/***************************** ����� 62056 ************************************/
/*�������� �������� ����: ����� ���������, ���������, �������������� ��������
����, ��������� ��������� �����; !!! �������� ���� ��� �������� �����������
������� !!!*/
/*�������� ����, ���������� ������������ �������*/
test_address_part_62056(1, R, [], failed):-
    request_tail_62056(RT), append(['1', '0', '?', '0'], RT, R).
/*�������� ����, ���������� ���� � ������*/
test_address_part_62056(2, R, ['1', '2', '3'], passed):-
    request_tail_62056(RT), append(['0', '0', '0', '1', '2', '3'], RT, R).
/*�������� ���� ������������ �����, ���������� ��� 1*/
test_address_part_62056(3, R, [], passed):-max_address_len_62056(MaxLen),
    make_list_of_length(MaxLen, R1, '1'), request_tail_62056(RT),
    append(R1, RT, R).
/*�������� ���� ����� ������ ������������, ���������� ��� 2*/
test_address_part_62056(4, R, [], failed):-max_address_len_62056(MaxLen),
    ML is MaxLen + 7, make_list_of_length(ML, R1, '2'), request_tail_62056(RT),
    append(R1, RT, R).
/*���������� �������� ����*/
test_address_part_62056(5, R, ['S', 'G', 'S', '1', '2', '3'], passed):-
    request_tail_62056(RT), append(['S', 'G', 'S', '1', '2', '3'], RT, R).

/*�������� ��������� ����������� 3-�� ��������� ���������*/
test_request_62056(1,
    ['/', '?', 'x', 'y', 'z', '!', '\x0d', '\x0a', 'e', 'b', 'l'],
    passed).
/*�������� ��������� ��� ��������� ���� */
test_request_62056(2, ['/', '?', '!', '\x0d', '\x0a', 'e', 'b', 'l'],
    passed).
/*�������� ��������� � �������� ����� ������������ �����*/
test_request_62056(3, Result, passed):-test_address_part_62056(3, R, [], _),
    request_head_62056(Head), append(Head, R, Result).

/*����� ��� identification message*/
/*�������� ��������� ��� ��������������*/
test_identification_62056(1, ['/', 'S', 'G', 'S', 'Z', '\x0d', '\x0a'], passed).
/*�������� ��������� � ��������������� ������� �����������*/
test_identification_62056(2, ['/', 'S', 'G', 'S', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '0', '\x0d', '\x0a'], failed).
/*�������� ��������� � ��������������� ������������ �����*/
test_identification_62056(3, ['/', 'S', 'G', 'S', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed).
/*�������� ��������� � ������������ baud*/
test_identification_62056(4, ['/', 'S', 'G', 'S', '/',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed).
/*�������� ��������� � ������������� ��������� � ��������������*/
test_identification_62056(5, ['/', 'S', 'G', 'S', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '/', '9', '!', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed).
/*�������� ��������� � Esc-��������������������*/
test_identification_62056(6, ['/', 'S', 'G', 'S', 'Z',
    '0', '\\', '2', '3', '4', '5', '6', '7', '\\', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed).
/*�������� ��������� � ��������������� ������������ ����� � ������ e,
� ���������� ��������� baud rate*/
test_identification_62056(7, ['/', 'S', 'G', 'S', '6',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(e)).
/*�������� ��������� � ��������������� ������������ ����� � ������ e,
� ������������ ��������� baud rate*/
test_identification_62056(8, ['/', 'S', 'G', 'S', '?',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(e)).
/*�������� ��������� � ��������������� ������������ ����� � ������ d,
� ���������� ��������� baud rate*/
test_identification_62056(9, ['/', 'S', 'G', 'S', '3',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(d)).
/*�������� ��������� � ��������������� ������������ ����� � ������ d,
� ������������ ��������� baud rate*/
test_identification_62056(10, ['/', 'S', 'G', 'S', '4',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(d)).
/*�������� ��������� � ��������������� ������������ ����� � ������ c,
� ���������� ��������� baud rate*/
test_identification_62056(11, ['/', 'S', 'G', 'S', '0',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(c)).
/*�������� ��������� � ��������������� ������������ ����� � ������ c,
� ������������ ��������� baud rate*/
test_identification_62056(12, ['/', 'S', 'G', 'S', 'A',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(c)).
/*�������� ��������� � ��������������� ������������ ����� � ������ b,
� ���������� ��������� baud rate*/
test_identification_62056(13, ['/', 'S', 'G', 'S', 'A',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(b)).
/*�������� ��������� � ��������������� ������������ ����� � ������ b,
� ������������ ��������� baud rate*/
test_identification_62056(14, ['/', 'S', 'G', 'S', 'J',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(b)).
/*�������� ��������� � ��������������� ������������ ����� � ������ a,
� ������������ ��������� baud rate*/
test_identification_62056(15, ['/', 'S', 'G', 'S', 'A',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(a)).

/*����� ��� acknowlegemetn/option select message*/
/*���������� baud rate ��� ������ c*/
test_ack_opt_62056(1, ['\x06', '0', '1', '0', '\x0d', '\x0a'], passed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(c)).
/*���������� baud rate ��� ������ e*/
test_ack_opt_62056(2, ['\x06', '0', '2', '0', '\x0d', '\x0a'], passed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*������������ baud rate ��� ������ e*/
test_ack_opt_62056(3, ['\x06', '0', 'A', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*������������ V ��� ������ e*/
test_ack_opt_62056(4, ['\x06', '3', '1', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*������������ Y ��� ������ e*/
test_ack_opt_62056(5, ['\x06', '0', '1', '3', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*������������ V ��� ������ c*/
test_ack_opt_62056(6, ['\x06', '3', '1', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(c)).
/*������������ Y ��� ������ c*/
test_ack_opt_62056(7, ['\x06', '0', '1', '3', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(c)).
/*������������ �����*/
test_ack_opt_62056(8, ['\x06', '0', '1', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(a)).
    
/*����� ��� data message*/

/*������� manual_input �...*/
test_62056:-retractall(manual_input), make_all_tests_62056.
test_62056:-make_all_tests_62056.
/*...��������� ��� ����� 62056; fail �������� � �������� ���������*/
make_all_tests_62056:-nl, write('request message tests'),
    test_request_62056(N, S, _), nl, write(N),
    write(' ? '), request_message_62056(S), write('passed.'), fail.
/*...��������� ��� ����� ��������� ����; fail �������� � �������� ���������...*/
make_all_tests_62056:-nl, write('address part tests'),
    test_address_part_62056(N, S, _, Result),
    nl, write(N), write(' ? '), check_address_part(S, Result), fail.
/*...��������� ��� ����� ������������������ ���������; fail �������� �
�������� ���������...*/
make_all_tests_62056:-nl, write('identification message tests'),
    test_identification_62056(N, S, Result),
    nl, write(N), write(' ? '), check_identification_62056(S, Result), fail.
/*...��������� ��� ����� acknowledgement/option select message; fail �������� �
�������� ���������...*/
make_all_tests_62056:-nl, write('ack/opt select message message tests'),
    test_ack_opt_62056(N, S, Result),
    nl, write(N), write(' ? '), check_ack_opt_62056(S, Result), fail.
make_all_tests_62056:-nl, write('all tests 62056 finished.').

/*����������� ������������� � ������������� ���������� ������� �������� �����*/
check_address_part(S, Result):-
    Result == passed, address_part_62056(S, _), write('passed.').
check_address_part(S, Result):-
    not(Result == passed), not(address_part_62056(S, _)), write('passed.').

/*����������� ������������� � ������������� ���������� �������
������������������ ���������*/
check_identification_62056(S, Result):-
    Result == passed, identification_message_62056(S), write('passed.').
check_identification_62056(S, Result):-
    not(Result == passed), not(identification_message_62056(S)), write('passed.').

check_ack_opt_62056(S, Result):-
    Result == passed, ack_opt_62056(S), write('passed.').
check_ack_opt_62056(S, Result):-
    not(Result == passed), not(ack_opt_62056(S)), write('passed.').

test_N_requests_62056_parsing_time:-
    get_min_sec(StartHour, StartMin, StartSecMSec),
    test_request_62056(3, S, passed), test_N_requests_62056_loop(100, S),
    get_min_sec(FinishHour, FinishMin, FinishSecMSec),
    nl, write('StartHour :'), write(StartHour),
    nl, write('StartMin :'), write(StartMin),
    nl, write('StartSecMSec: '), write(StartSecMSec),
    nl, write('FinishHour: '), write(FinishHour),
    nl, write('FinishMin: '), write(FinishMin),
    nl, write('FinishSecMSec: '), write(FinishSecMSec).

test_N_requests_62056_loop2(N, S):-int(I), request_message_62056(S),
    /*write(I), nl, */ I >= N. /*, nl.*/

test_N_requests_62056_loop(0, _).
test_N_requests_62056_loop(N, S):-request_message_62056(S), N1 is N - 1,
    test_N_requests_62056_loop(N1, S).


