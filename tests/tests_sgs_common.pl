%% Автор:
%% Дата: 27.04.2011

/********************* test_append_new ****************************************/
test_append_new(1, [1, 2, 3], [4, 2, 5], [1, 2, 3, 4, 5]).

/********************* check_test_append_new **********************************/
check_test_append_new(In1, In2, RightOut):-
    append_new(In1, In2, Out), equal_lists(Out, RightOut),
    write('passed'), nl, !.
check_test_append_new(_, _, _):-write('passed'), nl.

/********************* make_all_tests_sgs_common ******************************/
make_all_tests_sgs_common:-
    nl, write('append_new tests'), nl,
    test_append_new(N, In1, In2, RightOut),
    write(N), write(' ? '),
    check_test_append_new(In1, In2, RightOut),
    nl, fail.
/*The final predicate.*/
make_all_tests_sgs_common:-
    write('all tests of "sgs common" finished.'), nl.

