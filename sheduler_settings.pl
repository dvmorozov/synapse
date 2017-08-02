%% јвтор:
%% ƒата: 02.04.2011

global_protocol_62056_mode(a).
global_device_62056_address(['1']).

/*—труктура
    device(
        user_id(_),
        group_id(_),
        device_id(_),
        ip(_),
        port(_),
        device_address(_),
        status(_),
        prot(_)).
    user_id - идент. пользовател€, которому принадлежит группа устройств;
    group_id - уникальный идентификатор группы устройств данного пользовател€;
    device_id - уникальный дл€ данного пользовател€ идентификатор устройства;
    device_address - адрес устройства (если имеет смысл дл€ данного протокола);
    status - список флагов состо€ни€ устройства из числа: not_available;
    prot - тип протокола, который используетс€ дл€ обмена с устройством.
*/
:-dynamic device/8.
/*
   sheduler_date(year(_), month(_), day(_), hour(_), minute(_), sec(_)).
*/
:-dynamic sheduler_date/6 .

/*—писок всех устройств, которые нужно опросить в данный момент времени.
ƒолжен быть сгенерирован при старте по данным конфигурации. ƒолжен ускорить
работу, поскольку дл€ нахождени€ устройств, которые нужно опрашивать в данное
врем€ достаточно одного поиска (список меток д.б. значительно короче списка
устройств).
shedule_step(sheduler_date(year(_), month(_), day(_),
    hour(_), minute(_), sec(_)),
    [device_62056(UserID, GroupID, IP, Port, DeviceAddress, Shedule,
    Status)]).
*/
:-dynamic shedule_step/2.

/********************* read_sheduler_date *************************************/
/*«агружает файл, по которому генерируетс€ расписание. L - список XML-элементов,
описывающих настройки.*/
read_sheduler_date(L):-
    load_xml_file('e:\\temp\\ShedulerDate.xml',
        [element('ShedulerDate', _, L)]).
        
/********************* elements_to_sheduler_date ******************************/
/*The predicate converts list of XML-elements to list of sheduler_date.*/
/*elements_to_sheduler_dates(Elements, Dates):-*/

/********************* search_minute_element **********************************/
/*The predicate searches any of elements related to minutes.*/
/*The termination condition.*/
search_minute_element([], []).
/*For every one minute.*/
search_minute_element([element('EveryNMin', _, [Value])|_],
    [sheduler_date(year(_), month(_), day(_), hour(_), minute(_), sec(_))]):-
    atom_to_term(Value, Min, _), Min == 1, !.
search_minute_element([element('EveryNMin', _, [Value])|_], DatesOut):-
    atom_to_term(Value, Min, _),
    every_nmin_loop(_, _, [], DatesOut, 0, Min), !.
search_minute_element([element('AtGivenMin', _, [Value])|_],
    [sheduler_date(year(_), month(_), day(_), hour(_), minute(Min), sec(_))]):-
    atom_to_term(Value, Min, _),
    Min >= 0, Min =< 59, !.
/*The predicate goes through the element list.*/
search_minute_element([_|T], DatesOut):-
    search_minute_element(T, DatesOut).

/********************* every_nmin_loop ****************************************/
/*Parameters checking.*/
every_nmin_loop(_, _, DatesIn, DatesIn, _, 0):-!, fail.
every_nmin_loop(_, _, DatesIn, DatesIn, Start, 0):-Start < 0, !, fail.
every_nmin_loop(_, _, DatesIn, DatesIn, _, Step):-Step < 0, !, fail.
/*The termination condition.*/
every_nmin_loop(_, _, DatesIn, DatesIn, Start, _):-Start >= 60, !.
every_nmin_loop(Day, Hour, DatesIn, DatesOut, Start, Step):-
    append(DatesIn, [sheduler_date(year(_), month(_), day(Day), hour(Hour),
        minute(Start), sec(_))], DatesOut1),
    StartNext is Start + Step,
    every_nmin_loop(Day, Hour, DatesOut1, DatesOut, StartNext, Step).

/********************* search_hour_element ************************************/
/*The predicate searches any of elements related to hours.*/
/*The termination condition.*/
search_hour_element([], []).
/*For every one hour.*/
search_hour_element([element('EveryNHour', _, [Value])|_],
    [sheduler_date(year(_), month(_), day(_), hour(_), minute(_), sec(_))]):-
    atom_to_term(Value, Hour, _), Hour == 1, !.
search_hour_element([element('EveryNHour', _, [Value])|_], DatesOut):-
    atom_to_term(Value, Hour, _),
    every_nhour_loop([], DatesOut, 0, Hour), !.
search_hour_element([element('AtGivenHour', _, [Value])|_],
    [sheduler_date(year(_), month(_), day(_), hour(Hour), minute(_), sec(_))]):-
    atom_to_term(Value, Hour, _),
    Hour >= 0, Hour =< 23, !.
/*The predicate goes through the element list.*/
search_hour_element([_|T], DatesOut):-
    search_hour_element(T, DatesOut).

/********************* every_nhour_loop ***************************************/
/*Parameters checking.*/
every_nhour_loop(DatesIn, DatesIn, _, 0):-!, fail.
every_nhour_loop(DatesIn, DatesIn, Start, 0):-Start < 0, !, fail.
every_nhour_loop(DatesIn, DatesIn, _, Step):-Step < 0, !, fail.
/*The termination condition.*/
every_nhour_loop(DatesIn, DatesIn, Start, _):-Start >= 24, !.
every_nhour_loop(DatesIn, DatesOut, Start, Step):-
    append(DatesIn, [sheduler_date(year(_), month(_), day(_), hour(Start),
        minute(_), sec(_))], DatesOut1),
    StartNext is Start + Step,
    every_nhour_loop(DatesOut1, DatesOut, StartNext, Step).

/********************* search_day_element *************************************/
/*The predicate searches any of elements related to days.*/
/*The termination condition.*/
search_day_element([], []).
/*For every one day.*/
search_day_element([element('EveryNDay', _, [Value])|_],
    [sheduler_date(year(_), month(_), day(_), hour(_), minute(_), sec(_))]):-
    atom_to_term(Value, Day, _), Day == 1, !.
search_day_element([element('EveryNDay', _, [Value])|_], DatesOut):-
    atom_to_term(Value, Day, _),
    every_nday_loop([], DatesOut, 0, Day), !.
search_day_element([element('AtGivenDay', _, [Value])|_],
    [sheduler_date(year(_), month(_), day(Day), hour(_), minute(_), sec(_))]):-
    atom_to_term(Value, Day, _),
    Day >=1, Day =< 31, !.
/*The predicate goes through the element list.*/
search_day_element([_|T], DatesOut):-
    search_day_element(T, DatesOut).

/********************* every_nday_loop ****************************************/
/*Parameters checking.*/
every_nday_loop(DatesIn, DatesIn, _, 0):-!, fail.
every_nday_loop(DatesIn, DatesIn, Start, 0):-Start =< 0, !, fail.
every_nday_loop(DatesIn, DatesIn, _, Step):-Step < 0, !, fail.
/*The termination condition.*/
every_nday_loop(DatesIn, DatesIn, Start, _):-Start >= 32, !.
every_nday_loop(DatesIn, DatesOut, Start, Step):-
    append(DatesIn, [sheduler_date(year(_), month(_), day(Start), hour(_),
        minute(_), sec(_))], DatesOut1),
    StartNext is Start + Step,
    every_nday_loop(DatesOut1, DatesOut, StartNext, Step).

/********************* search_day_of_week *************************************/
/*The predicate searches any of elements related to "day of week" shedule.*/
/*The termination condition.*/
search_day_of_week([], []).
search_day_of_week([element('AtGivenDoW', _, L)|_],
    DoWNumbers):-day_of_week_numbers(L, DoWNumbers), !.
/*The predicate goes through the element list.*/
search_day_of_week([_|T], DoWNumbers):-
    search_day_of_week(T, DoWNumbers).

/********************* day_of_week_numbers ************************************/
/*The predicate extracts "day of week" numbers from elements.*/
/*The termination condition.*/
day_of_week_numbers([], DoWNumberIn, DoWNumberIn).
day_of_week_numbers([element('Monday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [1], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).
day_of_week_numbers([element('Tuesday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [2], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).
day_of_week_numbers([element('Wednesday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [3], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).
day_of_week_numbers([element('Thursday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [4], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).
day_of_week_numbers([element('Friday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [5], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).
day_of_week_numbers([element('Saturday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [6], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).
day_of_week_numbers([element('Sunday', _, _)|T], DoWNumberIn, DoWNumberOut):-
    append_new(DoWNumberIn, [7], DoWNumberOut1),
    day_of_week_numbers(T, DoWNumberOut1, DoWNumberOut).

/********************* create_shedule *****************************************/

:-dynamic shedule_container/1.

create_shedule:-
    read_sheduler_date(Elements),
    search_minute_element(Elements, Minutes),
    search_hour_element(Elements, Hours),
    search_day_element(Elements, Days),
    join_shedule_lists(Minutes, Hours, Days, []),
    shedule_container(Shedule), print_sheduler_dates(Shedule).
    
/********************* join_shedule_lists *************************************/

join_shedule_lists(Minutes, Hours, Days, _/*DaysOfWeek*/):-
    retractall(shedule_container(_)), assert(shedule_container([])),
    join_shedule_loop(Minutes, Hours, Days, _/*DaysOfWeek*/).
    
/********************* join_shedule_loop **************************************/
join_shedule_loop(Minutes, Hours, Days, _/*DaysOfWeek*/):-
    sgs_member(sheduler_date(year(_), month(_), day(_),
       hour(_), minute(Min), sec(_)), Minutes),
    sgs_member(sheduler_date(year(_), month(_), day(_),
       hour(Hour), minute(_), sec(_)), Hours),
    sgs_member(sheduler_date(year(_), month(_), day(Day),
       hour(_), minute(_), sec(_)), Days),
    append_shedule_container(Min, Hour, Day),
    /*write(Min), write(' '), write(Hour), write(' '), write(Day), nl,*/
    fail.
/*The final predicate.*/
join_shedule_loop(_, _, _, _).

/********************* append_shedule_container *******************************/
append_shedule_container(Min, Hour, Day):-
    shedule_container(L),
    append(L, [sheduler_date(year(_), month(_), day(Day),
       hour(Hour), minute(Min), sec(_))], L1),
    retractall(shedule_container(_)), assert(shedule_container(L1)).
    
/********************* print_sheduler_dates ***********************************/
/*The termination condition.*/
print_sheduler_dates([]).
print_sheduler_dates([ShedulerDate|T]):-
    write(ShedulerDate), nl, print_sheduler_dates(T).

/********************* read_sheduler_settings *********************************/
read_sheduler_settings:-
    retractall(device(_, _, _, _, _, _, _, _)),
    retractall(shedule_step(_, _)),
    assert(
        device(
            user_id(1), group_id(1), device_id(0),
            ip('127.0.0.1'), port(1234), device_address([]),
            status([]), prot(iec62056))
        ),
    assert(
        shedule_step(
            sheduler_date(
                year(_), month(_), day(_), hour(_), minute(_), sec(10)),
            [
                device(
                    user_id(1), group_id(1), device_id(0),
                    ip('127.0.0.1'), port(1234), device_address([]),
                    status([]),
                    prot(iec62056)
                    )
            ])),
    assert(
        shedule_step(
            sheduler_date(
                year(_), month(_), day(_), hour(_), minute(_), sec(20)),
            [
                device(
                    user_id(1), group_id(1), device_id(0),
                    ip('127.0.0.1'), port(1234), device_address([]),
                    status([]),
                    prot(iec62056)
                    )
            ])),
    assert(
        shedule_step(
            sheduler_date(
                year(_), month(_), day(_), hour(_), minute(_), sec(30)),
            [
                device(
                    user_id(1), group_id(1), device_id(0),
                    ip('127.0.0.1'), port(1234), device_address([]),
                    status([]),
                    prot(iec62056)
                    )
            ])),
    assert(
        shedule_step(
            sheduler_date(
                year(_), month(_), day(_), hour(_), minute(_), sec(40)),
            [
                device(
                    user_id(1), group_id(1), device_id(0),
                    ip('127.0.0.1'), port(1234), device_address([]),
                    status([]),
                    prot(iec62056)
                    )
            ])),
    assert(
        shedule_step(
            sheduler_date(
                year(_), month(_), day(_), hour(_), minute(_), sec(50)),
            [
                device(
                    user_id(1), group_id(1), device_id(0),
                    ip('127.0.0.1'), port(1234), device_address([]),
                    status([]),
                    prot(iec62056)
                    )
            ])),
    assert(
        shedule_step(
            sheduler_date(
                year(_), month(_), day(_), hour(_), minute(_), sec(60)),
            [
                device(
                    user_id(1), group_id(1), device_id(0),
                    ip('127.0.0.1'), port(1234), device_address([]),
                    status([]),
                    prot(iec62056)
                    )
            ])
        ).

