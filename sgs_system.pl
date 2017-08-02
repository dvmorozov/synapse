%% �����:
%% ����: 18.02.2011

read_delimiter('\\').

/*������ ������ ��������������� � ���������� ������,
����� ����� FIFO �����������*/
/*������������ ������ '\r', ��������� �� ��������*/
/*������ ����� �������� ������ (�������) ������*/
read_symbol(S):-get_char(S), get_char(_).

get_min_sec(Hour, Min, SecMSec):-get_time(S),
    stamp_date_time(S, date(_, _, _, Hour, Min, SecMSec, _, _, _), 'UTC').

/*�� ������ ������, ������, ���� ������������ ���� � ���� ������ ������� ���
������ ������. ������ ������ ����� ���� ��������. � ������� ��������� ������
�������� ���� ������������ ��������� �������� ������ (5-�), ���� ��� ����!*/
get_week_begin(Year, Month, 1, 1, WeekDay):-
    Year >= 1970, Month >= 1, Month =< 12,
    day_of_the_week(date(Year, Month, 1), WeekDay), !.
/*������ ��������� ������ - ������ �����������.*/
get_week_begin(Year, Month, WeekNum, Day, 1):-
    WeekNum =< 4, Month >= 1, Month =< 12,
    /*�� �������� ������������ ���� ������� ������������ ������...*/
    day_of_the_week(date(Year, Month, 1), DW),
    Day is WeekNum * 7 - 7 + 2 - DW, !.
get_week_begin(Year, Month, WeekNum, _, _):-
    write('Invalid parameters to get_week_begin: '),
    write('Year='), write(Year), write(', Month='), write(Month),
    write(', WeekNum='), write(WeekNum),
    nl, fail.

out_debug_message(Message):-
    print(Message), nl, flush_output.
