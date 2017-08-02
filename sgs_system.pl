%% Автор:
%% Дата: 18.02.2011

read_delimiter('\\').

/*Должен всегда согласовываться и возвращать символ,
чтобы буфер FIFO продвигался*/
/*Вычитывается символ '\r', следующий за вводимым*/
/*Должен через заданный период (таймаут) символ*/
read_symbol(S):-get_char(S), get_char(_).

get_min_sec(Hour, Min, SecMSec):-get_time(S),
    stamp_date_time(S, date(_, _, _, Hour, Min, SecMSec, _, _, _), 'UTC').

/*По номеру недели, месяцу, году определяется дата и день недели первого дня
данной недели. Первая неделя может быть неполной. С помощью предиката нельзя
получить дату понедельника последней неполной недели (5-й), если она есть!*/
get_week_begin(Year, Month, 1, 1, WeekDay):-
    Year >= 1970, Month >= 1, Month =< 12,
    day_of_the_week(date(Year, Month, 1), WeekDay), !.
/*Начало следующей недели - всегда понедельник.*/
get_week_begin(Year, Month, WeekNum, Day, 1):-
    WeekNum =< 4, Month >= 1, Month =< 12,
    /*Не решается относительно даты первого понедельника месяца...*/
    day_of_the_week(date(Year, Month, 1), DW),
    Day is WeekNum * 7 - 7 + 2 - DW, !.
get_week_begin(Year, Month, WeekNum, _, _):-
    write('Invalid parameters to get_week_begin: '),
    write('Year='), write(Year), write(', Month='), write(Month),
    write(', WeekNum='), write(WeekNum),
    nl, fail.

out_debug_message(Message):-
    print(Message), nl, flush_output.
