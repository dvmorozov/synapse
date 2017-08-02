%% Автор:
%% Дата: 06.03.2011

/*dynamic должны повторяться в каждом файле*/
:-thread_local protocol_62056_mode/1.

/***************************** Тесты 62056 ************************************/
/*Тестовые адресные поля: номер сообщения, сообщение, результирующее адресное
поле, ожидаемый результат теста; !!! Адресное поле уже содержит завершающие
символы !!!*/
/*Адресное поле, содержащее недопустимые символы*/
test_address_part_62056(1, R, [], failed):-
    request_tail_62056(RT), append(['1', '0', '?', '0'], RT, R).
/*Адресное поле, содержащее нули в начале*/
test_address_part_62056(2, R, ['1', '2', '3'], passed):-
    request_tail_62056(RT), append(['0', '0', '0', '1', '2', '3'], RT, R).
/*Адресное поле максимальной длины, содержащее все 1*/
test_address_part_62056(3, R, [], passed):-max_address_len_62056(MaxLen),
    make_list_of_length(MaxLen, R1, '1'), request_tail_62056(RT),
    append(R1, RT, R).
/*Адресное поле длины больше максимальной, содержащее все 2*/
test_address_part_62056(4, R, [], failed):-max_address_len_62056(MaxLen),
    ML is MaxLen + 7, make_list_of_length(ML, R1, '2'), request_tail_62056(RT),
    append(R1, RT, R).
/*Корректное адресное поле*/
test_address_part_62056(5, R, ['S', 'G', 'S', '1', '2', '3'], passed):-
    request_tail_62056(RT), append(['S', 'G', 'S', '1', '2', '3'], RT, R).

/*Тестовое сообщение дополненное 3-мя мусорными символами*/
test_request_62056(1,
    ['/', '?', 'x', 'y', 'z', '!', '\x0d', '\x0a', 'e', 'b', 'l'],
    passed).
/*Тестовое сообщение без адресного поля */
test_request_62056(2, ['/', '?', '!', '\x0d', '\x0a', 'e', 'b', 'l'],
    passed).
/*Тестовое сообщение с адресным полем максимальной длины*/
test_request_62056(3, Result, passed):-test_address_part_62056(3, R, [], _),
    request_head_62056(Head), append(Head, R, Result).

/*Тесты для identification message*/
/*Тестовое сообщение без идентификатора*/
test_identification_62056(1, ['/', 'S', 'G', 'S', 'Z', '\x0d', '\x0a'], passed).
/*Тестовое сообщение с идентификатором длиннее допустимого*/
test_identification_62056(2, ['/', 'S', 'G', 'S', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '0', '\x0d', '\x0a'], failed).
/*Тестовое сообщение с идентификатором максимальной длины*/
test_identification_62056(3, ['/', 'S', 'G', 'S', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed).
/*Тестовое сообщение с недопустимым baud*/
test_identification_62056(4, ['/', 'S', 'G', 'S', '/',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed).
/*Тестовое сообщение с недопустимыми символами в идентификаторе*/
test_identification_62056(5, ['/', 'S', 'G', 'S', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '/', '9', '!', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed).
/*Тестовое сообщение с Esc-последовательностями*/
test_identification_62056(6, ['/', 'S', 'G', 'S', 'Z',
    '0', '\\', '2', '3', '4', '5', '6', '7', '\\', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed).
/*Тестовое сообщение с идентификатором максимальной длины в режиме e,
с допустимым значением baud rate*/
test_identification_62056(7, ['/', 'S', 'G', 'S', '6',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(e)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме e,
с недопустимым значением baud rate*/
test_identification_62056(8, ['/', 'S', 'G', 'S', '?',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(e)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме d,
с допустимым значением baud rate*/
test_identification_62056(9, ['/', 'S', 'G', 'S', '3',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(d)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме d,
с недопустимым значением baud rate*/
test_identification_62056(10, ['/', 'S', 'G', 'S', '4',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(d)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме c,
с допустимым значением baud rate*/
test_identification_62056(11, ['/', 'S', 'G', 'S', '0',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(c)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме c,
с недопустимым значением baud rate*/
test_identification_62056(12, ['/', 'S', 'G', 'S', 'A',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(c)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме b,
с допустимым значением baud rate*/
test_identification_62056(13, ['/', 'S', 'G', 'S', 'A',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], passed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(b)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме b,
с недопустимым значением baud rate*/
test_identification_62056(14, ['/', 'S', 'G', 'S', 'J',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(b)).
/*Тестовое сообщение с идентификатором максимальной длины в режиме a,
с недопустимым значением baud rate*/
test_identification_62056(15, ['/', 'S', 'G', 'S', 'A',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E',
    'F', '\x0d', '\x0a'], failed):-retractall(protocol_62056_mode(_)),
    assert(protocol_62056_mode(a)).

/*Тесты для acknowlegemetn/option select message*/
/*Корректный baud rate для режима c*/
test_ack_opt_62056(1, ['\x06', '0', '1', '0', '\x0d', '\x0a'], passed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(c)).
/*Корректный baud rate для режима e*/
test_ack_opt_62056(2, ['\x06', '0', '2', '0', '\x0d', '\x0a'], passed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*Некорректный baud rate для режима e*/
test_ack_opt_62056(3, ['\x06', '0', 'A', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*Некорректный V для режима e*/
test_ack_opt_62056(4, ['\x06', '3', '1', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*Некорректный Y для режима e*/
test_ack_opt_62056(5, ['\x06', '0', '1', '3', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(e)).
/*Некорректный V для режима c*/
test_ack_opt_62056(6, ['\x06', '3', '1', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(c)).
/*Некорректный Y для режима c*/
test_ack_opt_62056(7, ['\x06', '0', '1', '3', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(c)).
/*Некорректный режим*/
test_ack_opt_62056(8, ['\x06', '0', '1', '0', '\x0d', '\x0a'], failed):-
    retractall(protocol_62056_mode(_)), assert(protocol_62056_mode(a)).
    
/*Тесты для data message*/

/*Удаляет manual_input и...*/
test_62056:-retractall(manual_input), make_all_tests_62056.
test_62056:-make_all_tests_62056.
/*...запускает все тесты 62056; fail приводит к перебору сообщений*/
make_all_tests_62056:-nl, write('request message tests'),
    test_request_62056(N, S, _), nl, write(N),
    write(' ? '), request_message_62056(S), write('passed.'), fail.
/*...запускает все тесты адресного поля; fail приводит к перебору сообщений...*/
make_all_tests_62056:-nl, write('address part tests'),
    test_address_part_62056(N, S, _, Result),
    nl, write(N), write(' ? '), check_address_part(S, Result), fail.
/*...запускает все тесты идентификационного сообщения; fail приводит к
перебору сообщений...*/
make_all_tests_62056:-nl, write('identification message tests'),
    test_identification_62056(N, S, Result),
    nl, write(N), write(' ? '), check_identification_62056(S, Result), fail.
/*...запускает все тесты acknowledgement/option select message; fail приводит к
перебору сообщений...*/
make_all_tests_62056:-nl, write('ack/opt select message message tests'),
    test_ack_opt_62056(N, S, Result),
    nl, write(N), write(' ? '), check_ack_opt_62056(S, Result), fail.
make_all_tests_62056:-nl, write('all tests 62056 finished.').

/*Проверяются положительные и отрицательные результаты разбора адресной части*/
check_address_part(S, Result):-
    Result == passed, address_part_62056(S, _), write('passed.').
check_address_part(S, Result):-
    not(Result == passed), not(address_part_62056(S, _)), write('passed.').

/*Проверяются положительные и отрицательные результаты разбора
идентификационного сообщения*/
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


