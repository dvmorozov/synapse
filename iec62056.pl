%% �����:
%% ����: 19.02.2011

:-thread_local baud_rate_62056/1.
:-thread_local protocol_62056_mode/1.

/*��������� ��������� ������ ���������� � ������, ����� ��������� ��������
������ ������� �����������, �� �� ��������� � ���!*/

/*����������� ������ ��� ��������������� ���������� ������
� ����������� ������ � ������ ���������� ��������*/
fifo_fill_symbol('?').

/*********** Request message **************************************************/
/*��������� ����������� �� ������ ������*/
request_head_62056(['/', '?']).

request_tail_62056(['!', 'q', 'w']):-manual_input, !.
request_tail_62056(['!', '\x0d', '\x0a']):-not(manual_input), !.

/*����������� ���������� ����� ������� 62056*/
max_request_len_62056(L):-max_address_len_62056(MaxAddrLen),
    request_head_62056(RequestHead), length(RequestHead, RequestHeadLen),
    request_tail_62056(RequestTail), length(RequestTail, RequestTailLen),
    L is MaxAddrLen + RequestHeadLen + RequestTailLen.

/*��� ���������� � ���� ������ 62056 �������*/
allowed_address_symbols_62056([
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ',
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'A', 'S', 'D',
    'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'X', 'C', 'V', 'B', 'N', 'M',
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd',
    'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm']).

/*����������� ���������� ����� ������*/
max_address_len_62056(32).

request_message_62056(S, Address):-request_head_62056(Start),
    append(Start, AddressPart, S), address_part_62056(AddressPart, Address).

/*�������� ���� �������� � ���� ����� (�������� ����� �� ����) �
����������� �������*/
address_part_62056(AP, Address):-
    append(Address, RT, AP), request_tail_62056(RT).

/*������ ����� ��������*/
check_address_symbols_62056([]).
/*��������� ������������ �������� ����� ��������� �������*/
check_address_symbols_62056([H|T]):-allowed_address_symbols_62056(AS),
    /*��������� member ������-�� ������ ����� � ������� ���� ���������,
    ���� �������� �������� ��������� �� ��� �� ������*/
    sgs_member(H, AS), check_address_symbols_62056(T).

/*������� �������� ��������, ����� Address - ������ ������*/
remove_leading_address_zeros_62056(Address, RealAddress):-
    append(_, RealAddress, Address),
    /*����������� ��������� ������������, ������� �������� � ��������
    ������ ReadAddress*/
    check_leading_address_zero_62056(RealAddress), !.

check_leading_address_zero_62056([]).
check_leading_address_zero_62056([H|_]):-not(H == '0').

/************ Identification message ******************************************/
:-thread_local minimum_reaction_time_62056/1.
/*Answer of a tariff device. Fields 23) and 24) are optional,
they are part of field 14).*/
/*���� �������� ����� �������������� ��� ��� �������, ��� � ��� ��������.*/
identification_message_62056(Message, ManufactIdent, Identification, BaudRate):-
    append(['/'|ManufactIdentPart], ['\x0d', '\x0a'], Message),
    append(ManufactIdent, [BaudRate|Identification], ManufactIdentPart),
    length(ManufactIdent, L), L == 3, !.
/*
a) Protocol mode A (without baud rate changeover)
Any desired printable characters except "/", "!" and as long as they are not
specified for protocol mode B or protocol mode C
b) Protocol mode B (with baud rate changeover, without acknowledgement/option
select message)
A - 600 Bd
B - 1 200 Bd
C - 2 400 Bd
D - 4 800 Bd
E - 9 600 Bd
F - 19200Bd
G, H, I - reserved for later extensions
c) Protocol mode C and protocol mode E (with baud rate changeover, with
acknowledgement/option select message or other protocols)
0 - 300 Bd
1 - 600 Bd
2 - 1 200 Bd
3 - 2 400 Bd
4 - 4 800 Bd
5 - 9 600 Bd
6 - 19200Bd
7, 8, 9 - reserved for later extensions.
d) Protocol mode D (data transmission at 2 400 Bd)
Baud rate character is always 3.
*/
/*��� �������������� ������� �����������*/
baud_rate_symbols_62056([
    'A', 'B', 'C', 'D', 'E', 'F', '0', '1', '2', '3', '4', '5', '6']).

protocol_62056_mode_b_baudrate('A', 600).
protocol_62056_mode_b_baudrate('B', 1200).
protocol_62056_mode_b_baudrate('C', 2400).
protocol_62056_mode_b_baudrate('D', 4800).
protocol_62056_mode_b_baudrate('E', 9600).
protocol_62056_mode_b_baudrate('F', 19200).

protocol_62056_mode_ce_baudrate('0', 300).
protocol_62056_mode_ce_baudrate('1', 600).
protocol_62056_mode_ce_baudrate('2', 1200).
protocol_62056_mode_ce_baudrate('3', 2400).
protocol_62056_mode_ce_baudrate('4', 4800).
protocol_62056_mode_ce_baudrate('5', 9600).
protocol_62056_mode_ce_baudrate('6', 19200).

/* Usage of escape character "W" in protocol mode E (item 24 in 6.3.2)
Enhanced baud rate and mode identification character (optional field,
defining protocol mode E):
0-1 - reserved for future applications.
2 - binary mode (HDLC) see Annex E.
3-9 - reserved for future applications.
Other printable characters with exception of /, \ and ! manufacturer-specific
use. */
allowed_W_62056(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']).

/*Sequence delimiter (backslash code 5CH), optional field. This character is
always followed by a one character field 24). This field is part of the maximum
16 character wide identification field 14). Multiple pairs 23)/24) are allowed.*/
ident_seq_62056(Backslash, W):-Backslash == '\\', allowed_W_62056(SW),
    sgs_member(W, SW).

/*Identification, manufacturer-specific, 16 printable characters maximum except
for "/" and "!". "\" is only allowed as an escape character, see 23) and 24).*/
ident_62056(Ident):-length(Ident, L), L =< 16, check_ident_62056(Ident).

check_ident_62056([]).
check_ident_62056([Backslash, W|Tail]):-ident_seq_62056(Backslash, W),
    check_ident_62056(Tail), !.
check_ident_62056([Symbol|Tail]):-printable(Symbol), not(Symbol=='/'),
    not(Symbol=='!'), check_ident_62056(Tail).
    
/*********** Acknowledgement/option select message ****************************/
/*Protocol control character:
0 - normal protocol procedure
1 - secondary protocol procedure
2 - HDLC protocol procedure, see Annex E
3-9 - reserved for future applications*/
pcc_62056(S):-sgs_member(S, ['0', '1', '2']).

/*Mode control character:
0 - normal protocol procedure
1 - secondary protocol procedure
2 - HDLC protocol procedure, see Annex E
3-9 - reserved for future applications
*/
mcc_62056(S):-sgs_member(S, ['0', '1', '2']).

ack_opt_62056(S):-protocol_62056_mode(c), ack_opt_62056_all(S).
ack_opt_62056(S):-protocol_62056_mode(e), ack_opt_62056_all(S).

ack_opt_62056_all(S):-append(['\x06', V, Z, Y, '\x0d', '\x0a'], _, S),
    pcc_62056(V), check_baud_ident_62056(Z), mcc_62056(Y).
    
check_baud_ident_62056(Symbol):-
    check_baud_ident_62056_1(Symbol), !,
    write('Baudrate='), write(Symbol), nl.
check_baud_ident_62056(Symbol):-
    /*��� ����� ��������, ��� ������ ������ ������� � ������� �� �����������.*/
    retractall(baud_rate_62056(_)),
    write('Invalid baud rate symbol '), write(Symbol),
    write(' for protocol mode '), protocol_62056_mode(Mode), write(Mode),
    nl, fail.

check_baud_ident_62056_1(Symbol):-protocol_62056_mode(a), printable(Symbol),
    not(Symbol=='/'), not(Symbol=='!'), baud_rate_symbols_62056(List),
    not(sgs_member(Symbol, List)), !,
    retractall(baud_rate_62056(_)), assert(baud_rate_62056(300)).
check_baud_ident_62056_1(Symbol):-protocol_62056_mode(b),
    protocol_62056_mode_b_baudrate(Symbol, Baudrate), !,
    retractall(baud_rate_62056(_)), assert(baud_rate_62056(Baudrate)).
check_baud_ident_62056_1(Symbol):-protocol_62056_mode(c),
    protocol_62056_mode_ce_baudrate(Symbol, Baudrate), !,
    retractall(baud_rate_62056(_)), assert(baud_rate_62056(Baudrate)).
check_baud_ident_62056_1(Symbol):-protocol_62056_mode(d), Symbol == '3', !,
    retractall(baud_rate_62056(_)), assert(baud_rate_62056(2400)).
check_baud_ident_62056_1(Symbol):-protocol_62056_mode(e),
    protocol_62056_mode_ce_baudrate(Symbol, Baudrate), !,
    retractall(baud_rate_62056(_)), assert(baud_rate_62056(Baudrate)).

/*********** Data message (except in programming mode) ************************/
/*Frame start character (STX, start of text code 02H) indicating where the
calculation of BCC shall start from This character is not required if there
is no data set to follow*/
stx_62056('\x02').
/*End character in the block (ETX, end of text, code 03H)*/
etx_62056('\x03').
/*The scope of the block check character BCC is as specified in ISO/IEC 1745:1975,
and is from the character immediately following the first SOH or STX character
detected up to and including the ETX character which terminates the message.
The calculated BCC is placed immediately following the ETX.*/

empty_data_message_62056(Message):-
    append(['\x02', '!', '\x0d', '\x0a', '\x03'], [Bcc], Message),
    init_bcc_62056('\x0'), bcc_62056(['!', '\x0d', '\x0a', '\x03'], Bcc).

/*�������� ��� ���������� ������ bcc �� ���������� ������ ������.*/
/*�������� ������ ����� ��������� �������� ��� ������� ������.*/
:-thread_local bcc_62056_init_val/1.

bcc_62056(CharSet, Bcc):-
    calc_bcc_62056(CharSet, Bcc),
    /*���������� ������������ ��������.*/
    init_bcc_62056(Bcc).

init_bcc_62056(Bcc):-
    retractall(bcc_62056_init_val(_)), assert(bcc_62056_init_val(Bcc)).

calc_bcc_62056(CharSet, Bcc):-
    calc_bcc_sum_loop(CharSet, BccSum), !,
    char_code(BccSum, Code), Code1 is Code /\ 127,
    char_code(Bcc, Code1).
/*������� ���, ������� � ���������� �������, ��� ��� ����������� ���������
�������!*/
calc_bcc_sum_loop([], V):-bcc_62056_init_val(V).
calc_bcc_sum_loop([H|T], Bcc):-
    calc_bcc_sum_loop(T, Bcc1),
    char_code(H, Code),
    char_code(Bcc1, Code1), Code2 is Code1 + Code,
    char_code(Bcc, Code2).

/*�������� ������������ ��������. ����� ��� CR, LF �� ������ ����!*/
check_data_line_62056(DataLine):-
    /*����� �������� �����*/
    all_printable(DataLine),
    all_allowed(['!', '/'], DataLine),
    length(DataLine, L), L =< 78.

/*������ ����������� ��������.*/
check_data_set_62056(Address, Value, Unit):-
    /*�������� ��� ����������� ��������.*/
    all_printable(Address), all_printable(Value), all_printable(Unit),
    length(Address, LA), LA=<16, all_allowed(['(', ')', '/', '!'], Address),
    length(Value, LV), LV=<32, all_allowed(['(', ')', '*', '/', '!'], Value),
    length(Unit, LU), LU=<16, all_allowed(['(', ')', '/', '!'], Unit).

/*��������� ��� ������� ������ �������� �� ������ ����������.*/
data_set_62056(DS, Address, Value, Unit):-
    append(Address, ['('|DS2], DS), append(Value, DS3, DS2),
    /*! ��������� ������������ �������� ��� ��������� ������� ��������.
    ����� - ������������ �����!*/
    append(UB, [')'|_], DS3), unit_62056(UB, Unit), !.
    
unit_62056([], []).
unit_62056(['*'|T], T).

/*********** Acknowledgement message ******************************************/

ack_62056(['\x06'|_]).
    
/*********** Repeat-request message (negative acknowledgement) ****************/

nack_62056(['\x15'|_]).

/*********** Programming command message **************************************/
/*Used for programming and block oriented data transfer, see also 6.5.        */
/*��� ������� ���� ������� � ������� ������ ���� ���� �������, ���������
������������ ������ ������ ��������� � ��������� �������������� ���������.
BCC ��������� �� ������� SOH!*/

/*��� ���������� ������� ������ ����������� "!", ����� �� ��������� � �������
��� ������������ ������.*/

/*********** Password command *************************************************/
password_62056(Message, Command, Password):-
    append(['\x01'|DataPart], [Bcc], Message),
    append(['P', Command, '\x02'|DataSet], ['\x03'], DataPart),
    /*����� data_set_62056 �� ����� BCC ��������� ������������ �������� ��
    ������ ��� �������, �� � ��� ��������� ���������.*/
    data_set_62056(DataSet, [], Password, []),
    init_bcc_62056('\x0'), bcc_62056(DataPart, Bcc), !.

/*********** Write command ****************************************************/
command_62056(Message, Command, SubCommand, Address, Value, Unit, OptId):-
    append(['\x01'|DataPart], [Bcc], Message),
    append([Command, SubCommand, '\x02'|DataSet], [OptId], DataPart),
    data_set_62056(DataSet, Address, Value, Unit),
    init_bcc_62056('\x0'), bcc_62056(DataPart, Bcc), !.
    
write_62056(Message, SubCommand, Address, Value, Unit):-
    command_62056(Message, 'W', SubCommand, Address, Value, Unit, '\x03').

/*������ ���� �������� ���������. ������ � ���� ����� �.�. �����!*/
write_first_62056(Message, SubCommand, Address, Value):-protocol_62056_mode(c),
    command_62056(Message, 'W', SubCommand, Address, Value, [], '\x04').

/*����������� ����� �������� ���������.*/
write_middle_62056(Message, SubCommand, Value):-protocol_62056_mode(c),
    command_62056(Message, 'W', SubCommand, [], Value, [], '\x04').

/*��������� ���� �������� ���������.*/
write_last_62056(Message, SubCommand, Value, Unit):-protocol_62056_mode(c),
    command_62056(Message, 'W', SubCommand, [], Value, Unit, '\x03').

/*********** Read command *****************************************************/
read_62056(Message, SubCommand, Address, Value, Unit):-
    command_62056(Message, 'R', SubCommand, Address, Value, Unit, '\x03').

/*********** Execute command **************************************************/
/*Formatted communication coding method execute (optional, see Annex C).*/
formatted_execution_62056(Message, Code, Data):-
    command_62056(Message, 'E', '2', Code, Data, [], '\x03').

/*********** Exit command (break) *********************************************/
exit_62056(Message, Command):-
    command_62056(Message, 'B', Command, [], [], [], '\x03').

/*********** Data message (programming mode) **********************************/
data_message_pro_62056(Message, Address, Value, Unit, OptId):-
    append(['\x02'|DataPart], [Bcc], Message),
    append(DataSet, [OptId], DataPart),
    data_set_62056(DataSet, Address, Value, Unit),
    init_bcc_62056('\x0'), bcc_62056(DataPart, Bcc), !.

/*������ ���� �������� ���������. ������ � ���� ����� �.�. �����!*/
data_message_pro_first_62056(Message, Address, Value):-protocol_62056_mode(c),
    data_message_pro_62056(Message, Address, Value, [], '\x04').

/*����������� ����� �������� ���������.*/
data_message_pro_middle_62056(Message, Value):-protocol_62056_mode(c),
    data_message_pro_62056(Message, [], Value, [], '\x04').

/*��������� ���� �������� ���������.*/
data_message_pro_last_62056(Message, Value, Unit):-protocol_62056_mode(c),
    data_message_pro_62056(Message, [], Value, Unit, '\x03').

/*********** Error message (programming mode) *********************************/
/*This consists of 32 printable characters maximum with exception of (, ), *, /
and !. It is bounded by front and rear boundary characters, as in the data set
structure. This is manufacturer-specific and should be chosen so that it cannot
be confused with data, for example starting all error messages with ER.*/
error_message_pro_62056(Message, ErrMsg):-
    append(['\x02', '(' |ErrMsg], [')', '\x03', Bcc], Message),
    append(['\x02', '(' |ErrMsg], [')', '\x03'], R),
    init_bcc_62056('\x0'), bcc_62056(R, Bcc).
    
check_error_message(ErrMsg):-length(ErrMsg, L), L=<32, all_printable(ErrMsg),
    /*�.�. ��������� ������ �����������!*/
    all_allowed(['(', ')', '*', '/', '!'], ErrMsg).

/*********** Parsing **********************************************************/

:-thread_local long_message_62056/0.
:-thread_local parsing_mode_62056/1.

parse_fifo_62056(FIFO, Out, NewFIFO):-handle_message_62056(FIFO, Out, NewFIFO).

/*���� ������ ������ ���������������, ����� �� ��������� �����.*/
handle_message_62056(FIFO, Out, NewFIFO):-
    server_62056_mode, /*������� �������� � ������ �������.*/
    scan_fifo_62056(FIFO, M, Garbage),
    handle_server_62056_message(M, Out),
    /*��������� ��� �� ������ ������ �� ����� ������������� ���������.*/
    delete_from_fifo_62056(FIFO, Garbage, M, NewFIFO),
    reset_long_message_62056, !,
    /*�������� ��������, ����� ���������� �������� ��������� �� fifo.*/
    server_62056_reply(Out).
handle_message_62056(FIFO, Out, NewFIFO):-
    client_62056_mode, /*������� �������� � ������ �������.*/
    scan_fifo_62056(FIFO, M, Garbage),
    handle_client_62056_message(M, Out),
    delete_from_fifo_62056(FIFO, Garbage, M, NewFIFO),
    reset_long_message_62056, !.
/*� ������, ����� ������ �� ����������.*/
handle_message_62056(FIFO, _, FIFO).

/*����� �������� ������ �������� ��������� ���� ��������� �����,
������� �� � ������ fifo...*/
reset_long_message_62056:-parsing_mode_62056(to_end),
    retract_long_message_62056, !.
/*...���������� � ������ ������.*/
reset_long_message_62056.

/*������� ��������� ������ ������ � ���������� ������� ������.*/
/*����� ������������� append ��������� ������������ ���������, �������
������������� �� � ������ ������, ��������� � ������ ����� ���� �����!*/
/*������� ����� ��������� ��� ������� �� ������, ����� ���������,
��� ������ �� ������������! ����� ����� ���� ������ �������������!*/
scan_fifo_62056(FIFO, [H|T], _):-append([H|T], _, FIFO),
    set_parsing_mode_62056(from_begin).
scan_fifo_62056(FIFO, [H|T], Garbage):-append(Garbage, [H|T], FIFO),
    not(equal_lists([H|T], FIFO)),
    set_parsing_mode_62056(to_end).

retract_parsing_mode_62056:-parsing_mode_62056(_),
    retractall(parsing_mode_62056(_)), !.
retract_parsing_mode_62056:-not(parsing_mode_62056(_)).

set_parsing_mode_62056(Mode):-parsing_mode_62056(Mode), !.
set_parsing_mode_62056(Mode):-retract_parsing_mode_62056,
    assert(parsing_mode_62056(Mode)).

/*������������ ����� ������ data message ����� 78, ������� � ������� ���
����������� ������ ����� ��������� �� ����������� ���������.*/
max_fifo_len_62056(100).

/*������ ������������� �������� ������, ����� ������� ����������� � ������.*/
init_fifo_62056([]).

/*������������ �������� ������ � �����.
������ ������ ���������������, ����� �� ��������� �����.*/
push_fifo_62056(FIFO, S, NewFIFO):-
    put_symbol_into_fifo_62056(S, FIFO, NewFIFO). /*, !,
    print_list(NewFIFO), nl.*/
    
put_symbol_into_fifo_62056(S, FIFO, NewFIFO):-
    max_fifo_len_62056(MaxFIFOLen), length(FIFO, L), L<MaxFIFOLen, !,
    append(FIFO, [S], NewFIFO).
put_symbol_into_fifo_62056(S, FIFO, NewFIFO):-
    /*� Remainder �������� ��� �������, ����� �������.*/
    stack(_, Remainder, FIFO),
    append(Remainder, [S], NewFIFO).

delete_from_fifo_62056(FIFO, Garbage, Message, Remainder):-
    append(Garbage, Message, M),
    append(M, Remainder, FIFO). /*, !,
    write('garbage :'), print_list(Garbage), nl,
    write('message :'), print_list(Message), nl,
    write('FIFO :'), print_list(FIFO), nl,
    write('remainder :'), print_list(Remainder), nl.*/
    
/*��������� ��������� ����� �������� �� ��������������� ����� �����, �.�.
����� �� ���������� ��������� � FIFO, �� ��������� ���� ������ ���������
�������*/
:-thread_local long_message_62056/0.
/*� ������ parsing_mode_62056(to_end) �������� ������ ���������, ����������
������������ � �����, ��������� ����� ������ ������� ��������� ����������.*/
:-thread_local parsing_mode_62056/1.

retract_long_message_62056:-long_message_62056, retractall(long_message_62056), !.
retract_long_message_62056:-not(long_message_62056).


