%% Автор:
%% Дата: 09.06.2011

:-consult('../lib/optparse.pl').
:-consult('sgs_common.pl').

optspec_server_launcher([[opt('groupid'), type(integer), default(0),
    shortflags([]), longflags(['groupid']),
    help(['device group id for test servers creation'])]]).

server_launcher:-optspec_server_launcher(OptSpec),
    opt_arguments(OptSpec, Opts, _),
    check_server_launcher_args(OptSpec, Opts).

check_server_launcher_args(_, Opts):-
    sgs_member(groupid(GroupID), Opts), not(GroupID == 0), !,
    server_launcher_main(GroupID).
check_server_launcher_args(OptSpec, _):-optspec_server_launcher(OptSpec),
    opt_help(OptSpec, HelpText), print(HelpText), nl.
    
launch_group_devices(Connection, GroupID):-
    odbc_prepare(Connection, 'select Port from TableDevice where GroupID=?',
                             [default], Statement, [fetch(fetch)]),
    odbc_execute(Statement, [GroupID]),
    launch_servers(Statement),
    odbc_free_statement(Statement).
    
launch_servers(Statement):-
    odbc_fetch(Statement, row(Port), next),
    (Port == end_of_file
    -> true
    ; writeln(Port),
    atom_chars('server62056.exe --ipport ', S1), atom_chars(Port, S2),
    append(S1, S2, S), atom_chars(Exe, S), win_exec(Exe, showdefault),
    launch_servers(Statement)
    ).

server_launcher_main(GroupID):-
    sg_odbc_connect(Connection),
    launch_group_devices(Connection, GroupID),
    sg_odbc_disconnect(Connection).

