%% Автор:
%% Дата: 24.04.2011

/*There are all tests for sheduler predicates.*/

/************************* test_every_nmin_loop *******************************/
test_every_nmin_loop(1, _, _, [], [], _, 0, failed).
test_every_nmin_loop(2, _, _, [],
    [sheduler_date(year(_), month(_), day(_), hour(_),
        minute(59), sec(_))], 59, 3, passed).
test_every_nmin_loop(3, 12, 12, [],
    [sheduler_date(year(_), month(_), day(12), hour(12),
        minute(50), sec(_)),
     sheduler_date(year(_), month(_), day(12), hour(12),
        minute(53), sec(_)),
     sheduler_date(year(_), month(_), day(12), hour(12),
        minute(56), sec(_)),
     sheduler_date(year(_), month(_), day(12), hour(12),
        minute(59), sec(_))
     ], 50, 3, passed).
test_every_nmin_loop(4, _, _, [], [], _, -1, failed).
test_every_nmin_loop(5, _, _, [], [], -1, _, failed).

/************************* check_every_nmin_loop ******************************/
check_every_nmin_loop(Day, Hour, DatesIn, DatesOut, Start, Step, Result):-
    Result == passed, every_nmin_loop(
        Day, Hour, DatesIn, DatesOut, Start, Step), write('passed'), !.
check_every_nmin_loop(Day, Hour, DatesIn, DatesOut, Start, Step, Result):-
    Result == failed, not(every_nmin_loop(
        Day, Hour, DatesIn, DatesOut, Start, Step)), write('passed'), !.
check_every_nmin_loop(_, _, _, _, _, _, _):-write('failed').

/************************* test_every_nhour_loop ******************************/
test_every_nhour_loop(1, [], _, 0, failed).
test_every_nhour_loop(2, [sheduler_date(year(_), month(_), day(_), hour(23),
        minute(_), sec(_))], 23, 3, passed).
test_every_nhour_loop(3,
    [
        sheduler_date(year(_), month(_), day(_), hour(0), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(5), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(10), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(15), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(20), minute(_), sec(_))
    ], 0, 5, passed).
test_every_nhour_loop(4, [], _, -1, failed).
test_every_nhour_loop(5, [], -1, _, failed).

/************************* check_every_nhour_loop *****************************/
check_every_nhour_loop(DatesOut, Start, Step, Result):-
    Result == passed, every_nhour_loop(
        [], DatesOut, Start, Step), write('passed'), !.
check_every_nhour_loop(DatesOut, Start, Step, Result):-
    Result == failed, not(every_nhour_loop(
        [], DatesOut, Start, Step)), write('passed'), !.
check_every_nhour_loop(_, _, _, _):-write('failed').

/************************* test_every_nday_loop *******************************/
test_every_nday_loop(1, [], _, 0, failed).
test_every_nday_loop(2, [sheduler_date(year(_), month(_), day(_), hour(30),
        minute(_), sec(_))], 30, 3, passed).
test_every_nday_loop(3,
    [
        sheduler_date(year(_), month(_), day(_), hour(1), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(6), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(11), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(16), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(21), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(26), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(31), minute(_), sec(_))
    ], 1, 5, passed).
test_every_nday_loop(4, [], _, -1, failed).
test_every_nday_loop(5, [], -1, _, failed).
test_every_nday_loop(6, [], 0, _, failed).

/************************* check_every_nday_loop ******************************/
check_every_nday_loop(DatesOut, Start, Step, Result):-
    Result == passed, every_nday_loop(
        [], DatesOut, Start, Step), write('passed'), !.
check_every_nday_loop(DatesOut, Start, Step, Result):-
    Result == failed, not(every_nday_loop(
        [], DatesOut, Start, Step)), write('passed'), !.
check_every_nday_loop(_, _, _, _):-write('failed').

/************************* test_search_minute_element *************************/
test_search_minute_element(1, [element('EveryNMin', _, [10])],
    [
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(0), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(10), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(20), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(30), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(40), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(50), sec(_))
    ]).
test_search_minute_element(2,
    [
        element('Dummy1', _, [10]),
        element('EveryNMin', _, [10]),
        element('Dummy2', _, [10])
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(0), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(10), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(20), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(30), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(40), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(50), sec(_))
    ]).
test_search_minute_element(3,
    [
        element('Dummy1', _, [10]),
        element('Dummy2', _, [10]),
        element('EveryNMin', _, [10])
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(0), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(10), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(20), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(30), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(40), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(50), sec(_))
    ]).
test_search_minute_element(4,
    [
        element('Dummy1', _, [10]),
        element('Dummy2', _, [10])
    ],
    []).
test_search_minute_element(5,
    [
        element('AtGivenMin', _, [11])
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(_),
            minute(11), sec(_))
    ]).
/*Inadmissible minute.*/
test_search_minute_element(6, [element('AtGivenMin', _, [60])], []).

/************************* check_search_minute_element ************************/
check_search_minute_element(Elements, RightDates):-
    search_minute_element(Elements, Dates), equal_lists(RightDates, Dates),
    write('passed'), !.
check_search_minute_element(_, _):-write('failed').

/************************* test_search_hour_element ***************************/
test_search_hour_element(1, [element('EveryNHour', _, [10])],
    [
        sheduler_date(year(_), month(_), day(_), hour(0), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(10), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(20), minute(_), sec(_))
    ]).
test_search_hour_element(2,
    [
        element('Dummy1', _, [10]),
        element('EveryNHour', _, [10]),
        element('Dummy2', _, [10])
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(0), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(10), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(20), minute(_), sec(_))
    ]).
test_search_hour_element(3,
    [
        element('Dummy1', _, [10]),
        element('Dummy2', _, [10]),
        element('EveryNHour', _, [10])
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(0), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(10), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(20), minute(_), sec(_))
    ]).
test_search_hour_element(4,
    [
        element('Dummy1', _, [10]),
        element('Dummy2', _, [10])
    ],
    []).
test_search_hour_element(5,
    [
        element('EveryNHour', _, [11])
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(11),
            minute(_), sec(_))
    ]).
/*Inadmissible hour.*/
test_search_hour_element(6, [element('EveryNHour', _, [24])], []).

/************************* check_search_hour_element **************************/
check_search_hour_element(Elements, RightDates):-
    search_hour_element(Elements, Dates), equal_lists(RightDates, Dates),
    write('passed'), !.
check_search_hour_element(_, _):-write('failed').

/************************* test_search_day_element ****************************/

test_search_day_element(1, [element('EveryNDay', _, [10])],
    [
        sheduler_date(year(_), month(_), day(1), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(11), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(21), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(31), hour(_), minute(_), sec(_))
    ]).
test_search_day_element(2,
    [
        element('Dummy1', _, [10]),
        element('EveryNDay', _, [10]),
        element('Dummy2', _, [10])
    ],
    [
        sheduler_date(year(_), month(_), day(1), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(11), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(21), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(31), hour(_), minute(_), sec(_))
    ]).
test_search_day_element(3,
    [
        element('Dummy1', _, [10]),
        element('Dummy2', _, [10]),
        element('EveryNDay', _, [10])
    ],
    [
        sheduler_date(year(_), month(_), day(1), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(11), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(21), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(31), hour(_), minute(_), sec(_))
    ]).
test_search_day_element(4,
    [
        element('Dummy1', _, [10]),
        element('Dummy2', _, [10])
    ],
    []).
test_search_day_element(5,
    [
        element('AtGivenDay', _, [11])
    ],
    [
        sheduler_date(year(_), month(_), day(11), hour(_), minute(_), sec(_))
    ]).
/*Inadmissible day.*/
test_search_day_element(6, [element('AtGivenMin', _, [32])], []).

/************************* check_search_day_element ***************************/
check_search_day_element(Elements, RightDates):-
    search_day_element(Elements, Dates), equal_lists(RightDates, Dates),
    write('passed'), !.
check_search_day_element(_, _):-write('failed').

/************************* test_day_of_week_numbers ***************************/
test_day_of_week_numbers(1,
    [
        element('Monday', _, _),
        element('Tuesday', _, _),
        element('Wednesday', _, _),
        element('Thursday', _, _),
        element('Friday', _, _),
        element('Saturday', _, _),
        element('Sunday', _, _)
    ],
    [1, 2, 3, 4, 5, 6, 7]).
test_day_of_week_numbers(2, [], []).
test_day_of_week_numbers(3,
    [
        element('Monday', _, _),
        element('Tuesday', _, _),
        element('Wednesday', _, _),
        element('Wednesday', _, _),
        element('Thursday', _, _),
        element('Friday', _, _),
        element('Saturday', _, _),
        element('Sunday', _, _)
    ],
    [1, 2, 3, 4, 5, 6, 7]).


/************************* check_day_of_week_numbers **************************/
check_day_of_week_numbers(Elements, RightDaysOfWeek):-
    day_of_week_numbers(Elements, [], DaysOfWeek),
    equal_lists(RightDaysOfWeek, DaysOfWeek),
    write('passed'), !.
check_day_of_week_numbers(_, _):-write('failed').

/************************* test_join_shedule_loop *****************************/
test_join_shedule_loop(1,
    [
        sheduler_date(year(_), month(_), day(_), hour(_), minute(1), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(_), minute(2), sec(_))
    ],
    [
        sheduler_date(year(_), month(_), day(_), hour(3), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(_), hour(4), minute(_), sec(_))
    ],
    [
        sheduler_date(year(_), month(_), day(5), hour(_), minute(_), sec(_)),
        sheduler_date(year(_), month(_), day(6), hour(_), minute(_), sec(_))
    ],
    [
        sheduler_date(year(_), month(_), day(5), hour(3), minute(1), sec(_)),
        sheduler_date(year(_), month(_), day(6), hour(3), minute(1), sec(_)),
        sheduler_date(year(_), month(_), day(5), hour(4), minute(1), sec(_)),
        sheduler_date(year(_), month(_), day(6), hour(4), minute(1), sec(_)),
        sheduler_date(year(_), month(_), day(5), hour(3), minute(2), sec(_)),
        sheduler_date(year(_), month(_), day(6), hour(3), minute(2), sec(_)),
        sheduler_date(year(_), month(_), day(5), hour(4), minute(2), sec(_)),
        sheduler_date(year(_), month(_), day(6), hour(4), minute(2), sec(_))
    ]).

/************************* check_join_shedule_loop ****************************/

:-dynamic shedule_container/1.

check_join_shedule_loop(Mins, Hours, Days, Result):-
    retractall(shedule_container), assert(shedule_container([])),
    join_shedule_loop(Mins, Hours, Days, _),
    shedule_container(L), /*(print_sheduler_dates(L),*/
    equal_lists(L, Result), write('passed'), !.
check_join_shedule_loop(_, _, _, _):-write('failed').

/************************* make_all_tests_sheduler_settins ********************/
make_all_tests_sheduler_settins:-
    nl, write('every_nmin_loop tests'), nl,
    test_every_nmin_loop(N, Day, Hour, DatesIn, DatesOut, Start, Step, Result),
    write(N), write(' ? '),
    check_every_nmin_loop(Day, Hour, DatesIn, DatesOut, Start, Step, Result),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('search_minute_element tests'), nl,
    test_search_minute_element(N, Elements, RightDates),
    write(N), write(' ? '),
    check_search_minute_element(Elements, RightDates),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('every_nhour_loop tests'), nl,
    test_every_nhour_loop(N, DatesOut, Start, Step, Result),
    write(N), write(' ? '),
    check_every_nhour_loop(DatesOut, Start, Step, Result),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('search_hour_element tests'), nl,
    test_search_hour_element(N, Elements, RightDates),
    write(N), write(' ? '),
    check_search_hour_element(Elements, RightDates),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('every_nday_loop tests'), nl,
    test_every_nday_loop(N, DatesOut, Start, Step, Result),
    write(N), write(' ? '),
    check_every_nday_loop(DatesOut, Start, Step, Result),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('search_day_element tests'), nl,
    test_search_day_element(N, Elements, RightDates),
    write(N), write(' ? '),
    check_search_day_element(Elements, RightDates),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('day_of_week_numbers tests'), nl,
    test_day_of_week_numbers(N, Elements, RightDaysOfWeek),
    write(N), write(' ? '),
    check_day_of_week_numbers(Elements, RightDaysOfWeek),
    nl, fail.
make_all_tests_sheduler_settins:-
    nl, write('join_shedule_loop tests'), nl,
    test_join_shedule_loop(N, Mins, Hours, Days, Result),
    write(N), write(' ? '),
    check_join_shedule_loop(Mins, Hours, Days, Result),
    nl, fail.
/*The final predicate.*/
make_all_tests_sheduler_settins:-
    write('all tests of "sheduler settings" finished.'), nl.

