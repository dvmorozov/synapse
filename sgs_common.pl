%% Автор:
%% Дата: 19.02.2011

/********************* upper_case_letters *************************************/
upper_case_letters([
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'A', 'S', 'D',
    'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'X', 'C', 'V', 'B', 'N', 'M']).

/********************* lower_case_letters *************************************/
lower_case_letters([
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd',
    'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm']).

/********************* printable **********************************************/
printable(Symbol):-char_code(Symbol, Code), Code >= 32, Code =< 255.

/********************* all_printable ******************************************/
/*Проверяет, что все символы блока данных печатаемы.*/
all_printable([]).
all_printable([H|T]):-printable(H), all_printable(T).

/********************* all_allowed ********************************************/
/*Проверяет, что ни одного из запрещенных символов нет в списке.*/
/*
all_allowed([], _).
all_allowed([H|T], L):-not(sgs_member(H, L)), all_allowed(T, L).*/

all_allowed(Disabled, Symbols):-intersection(Disabled, Symbols, []).

/********************* conc ***************************************************/
/*объединение списков; объединяются первые 2 аргумента и результат
помещается в третий*/
conc([], L, L).
conc([H|T], L1, [H|L2]):-conc(T, L1, L2).

/********************* copy_stream ********************************************/
copy_stream(SIn, SOut):-
    not(at_end_of_stream(SIn)), !,
    get_char(SIn, C), put_char(SOut, C),
    copy_stream(SIn, SOut).
copy_stream(SIn, SOut):-at_end_of_stream(SIn), flush_output(SOut).

/********************* stream_to_list *****************************************/
stream_to_list(SIn, List):-
    not(at_end_of_stream(SIn)), !,
    get_code(SIn, C), append([C], List1, List),
    stream_to_list(SIn, List1).
stream_to_list(_, []).

/********************* list_to_stream *****************************************/
list_to_stream([], SOut):-!, flush_output(SOut).
list_to_stream([H|T], SOut):-put_code(SOut, H), list_to_stream(T, SOut).

/********************* print_list *********************************************/
print_list([]):-!.
print_list([H|T]):-write_printable_chars(H), print_list(T).

/********************* write_printable_chars **********************************/
write_printable_chars(H):-printable(H), !, put_char(H).
write_printable_chars(H):-char_code(H, Code), format('\\x0~16r', Code).

/********************* write_list *********************************************/
write_list(L, Out):-list_to_stream(L, Out).

/********************* write_list_stdout **************************************/
write_list_stdout([]):-!.
write_list_stdout([H|T]):-put_char(H), write_list_stdout(T).

/********************* codes_to_chars *****************************************/
codes_to_chars([], []).
codes_to_chars([Code|T], Out):-
    char_code(H, Code), append([H], Out1, Out), codes_to_chars(T, Out1).

/********************* sgs_member *********************************************/
sgs_member(Item, [Item|_]).
sgs_member(Item, [_|T]):-sgs_member(Item, T).

/********************* append_new *********************************************/
append_new(In, [], In).
append_new(In, [Item|T], Out):-not(sgs_member(Item, In)),
    append(In, [Item], Out1), append_new(Out1, T, Out).
append_new(In, [Item|T], Out):-sgs_member(Item, In),
    append_new(In, T, Out).

/********************* stack **************************************************/
stack(Top, Stack, [Top|Stack]).

/********************* make_list_of_length ************************************/
/*Создает список заданной длины, заполненный заданным символом*/
make_list_of_length(0, [], _):-!.
make_list_of_length(1, [Symbol], Symbol):-!.
make_list_of_length(N, [Symbol|T], Symbol):-N2 is N-1, N2 > 0,
    make_list_of_length(N2, T, Symbol), !.

/********************* equal_lists ********************************************/
equal_lists([], []).
equal_lists([X|T1], [X|T2]):-equal_lists(T1, T2).

/********************* int ****************************************************/
int(1).
int(N):-int(N1), N is N1 + 1.

/********************* get_sql_timestamp_string *******************************/
/*Строка должна иметь вид '09/11/2011 10:31:00.123'*/
get_sql_timestamp_string(Out):-
    get_time(S),
    timestamp_to_sql_string(S, Out).

/********************* timestamp_to_sql_string ********************************/
timestamp_to_sql_string(S, Out):-
    stamp_date_time(S, date(Year, Month, Day, Hour, Min, SecMSec, _, _, _), 'UTC'),
    atomic_concat(Year, '-', X1), atomic_concat(X1, Month, X2),
    atomic_concat(X2, '-', X3), atomic_concat(X3, Day, X4),
    atomic_concat(X4, ' ', X5), atomic_concat(X5, Hour, X6),
    atomic_concat(X6, ':', X7), atomic_concat(X7, Min, X8),
    %%Ограничение на кол-во знаков после запятой (6) в секундах.
    %%https://www.evernote.com/shard/s132/nl/14501366/6decea19-e386-4ff0-8ae6-7b845376d13b
    TruncSecMSec is round(SecMSec * 1000000.0) / 1000000.0,
    atomic_concat(X8, ':', X9), atomic_concat(X9, TruncSecMSec, Out).

/********************* sql_string_to_timestamp ********************************/
/*Разбор строки формата '2011-15(MM)-09(DD) 10:31:00.1230000'.*/
sql_string_to_timestamp(String, S):-
    atom_concat(X9, SecMSec, String), atom_concat(X8, ':', X9),
    atom_concat(X7, Min, X8), atom_concat(X6, ':', X7),
    atom_concat(X5, Hour, X6), atom_concat(X4, ' ', X5),
    atom_concat(X3, Day, X4), atom_concat(X2, '-', X3),
    atom_concat(X1, Month, X2), atom_concat(Year, '-', X1),
    atom_number(Year, Year_), atom_number(Month, Month_),
    atom_number(Day, Day_), atom_number(Hour, Hour_),
    atom_number(Min, Min_), atom_number(SecMSec, SecMSec_), !,
    date_time_stamp(date(Year_, Month_, Day_, Hour_, Min_, SecMSec_, 0, -, -), S).
/*Разбор строки формата '09(MM)/15(DD)/2011 10:31:00.123'.*/
sql_string_to_timestamp(String, S):-
    atom_concat(X9, SecMSec, String), atom_concat(X8, ':', X9),
    atom_concat(X7, Min, X8), atom_concat(X6, ':', X7),
    atom_concat(X5, Hour, X6), atom_concat(X4, ' ', X5),
    atom_concat(X3, Year, X4), atom_concat(X2, '/', X3),
    atom_concat(X1, Day, X2), atom_concat(Month, '/', X1),
    atom_number(Year, Year_), atom_number(Month, Month_),
    atom_number(Day, Day_), atom_number(Hour, Hour_),
    atom_number(Min, Min_), atom_number(SecMSec, SecMSec_), !,
    date_time_stamp(date(Year_, Month_, Day_, Hour_, Min_, SecMSec_, 0, -, -), S).
sql_string_to_timestamp(_, 0.0). /*??? сделать сообщение об ошибке.*/

one_minute_timestamp(S):-
    date_time_stamp(date(1970, 1, 1, 0, 1, 0, 0, 'UTC', false), S).
    
add_one_minute('$null$', S):-add_one_minute(0, S), !.
add_one_minute(In, Out):-
    one_minute_timestamp(S),
    Out is In + S.

