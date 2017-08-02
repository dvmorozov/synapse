%% Автор:
%% Дата: 24.03.2011

/*Наборы данных д.б. разделяемыми, поэтому не используется thread_local.*/
/*Структура data_item(DeviceAddress, ItemAddress, Value, Unit).*/
:-dynamic data_item_62056/4.
:-dynamic data_list_62056/2.

/*Включает демонстрационное изменение данных.*/
demo_data.

data_list_62056([], [
    data_item_62056([], ['1'], ['1'], ['A']),
    data_item_62056([], ['2'], ['2'], ['A']),
    data_item_62056([], ['3'], ['3'], ['A']),
    data_item_62056([], ['4'], ['4'], ['A']),
    data_item_62056([], ['5'], ['5'], ['A']),
    data_item_62056([], ['6'], ['6'], ['A']),
    data_item_62056([], ['7'], ['7'], ['A']),
    data_item_62056([], ['8'], ['8'], ['A']),
    data_item_62056([], ['9'], ['9'], ['A']),
    data_item_62056([], ['1','0'], ['1','0'], ['A']),
    data_item_62056([], ['1','1'], ['1','1'], ['A']),
    data_item_62056([], ['1','2'], ['1','2'], ['A']),
    data_item_62056([], ['1','3'], ['1','3'], ['A']),
    data_item_62056([], ['1','4'], ['1','4'], ['A']),
    data_item_62056([], ['1','5'], ['1','5'], ['A']),
    data_item_62056([], ['1','6'], ['1','6'], ['A']),
    data_item_62056([], ['1','7'], ['1','7'], ['A']),
    data_item_62056([], ['1','8'], ['1','8'], ['A']),
    data_item_62056([], ['1','9'], ['1','9'], ['A']),
    data_item_62056([], ['2','0'], ['2','0'], ['A']),
    data_item_62056([], ['2','1'], ['2','1'], ['A']),
    data_item_62056([], ['2','2'], ['2','2'], ['A']),
    data_item_62056([], ['2','3'], ['2','3'], ['A']),
    data_item_62056([], ['2','4'], ['2','4'], ['A']),
    data_item_62056([], ['2','5'], ['2','5'], ['A']),
    data_item_62056([], ['2','6'], ['2','6'], ['A']),
    data_item_62056([], ['2','7'], ['2','7'], ['A']),
    data_item_62056([], ['2','8'], ['2','8'], ['A']),
    data_item_62056([], ['2','9'], ['2','9'], ['A']),
    data_item_62056([], ['3','0'], ['3','0'], ['A']),
    data_item_62056([], ['3','1'], ['3','1'], ['A']),
    data_item_62056([], ['3','2'], ['3','2'], ['A']),
    data_item_62056([], ['3','3'], ['3','3'], ['A']),
    data_item_62056([], ['3','4'], ['3','4'], ['A']),
    data_item_62056([], ['3','5'], ['3','5'], ['A']),
    data_item_62056([], ['3','6'], ['3','6'], ['A']),
    data_item_62056([], ['3','7'], ['3','7'], ['A']),
    data_item_62056([], ['3','8'], ['3','8'], ['A']),
    data_item_62056([], ['3','9'], ['3','9'], ['A']),
    data_item_62056([], ['4','0'], ['4','0'], ['A'])
    ]).

/*Тестовая БД устройства с адресом 123.*/
data_list_62056(['1', '2', '3'], [
    /*Формат элементов данных описан на стр. 77 стандарта.*/
    data_item_62056('123', 'Linear'/*Identification.*/, 0/*Value.*/, 'kW'/*Units.*/),
    data_item_62056('123', 'Periodic'/*Identification.*/, 0/*Value.*/, 'kBar'/*Units.*/)
]).

modify_demo_data([], []):-
    demo_data,
    out_debug_message('Demo database modified successfully.').
modify_demo_data([data_item_62056(Address, Identification, Value, Unit)|T], Out):-
    demo_data,
    get_new_value(Identification, Value, NewValue),
    append([data_item_62056(Address, Identification, NewValue, Unit)], Out1, Out), modify_demo_data(T, Out1).
modify_demo_data(In, In):-
    not(demo_data),
    out_debug_message('Demo database modification is disabled.').

:-dynamic angle/1.
angle(0.0).

get_new_value(Identification, _, NewValue):-
    Identification == 'Periodic',  
    angle(Angle), 
    NewValue is 100 * sin(Angle),
    NewAngle is Angle + (pi / 180),
    string_concat('New angle: ', NewAngle, Msg), out_debug_message(Msg),
    retractall(angle(_)), assert(angle(NewAngle)).
get_new_value(_, Value, NewValue):-
    %%Identification == 'Linear',  
    NewValue is Value + 1.
