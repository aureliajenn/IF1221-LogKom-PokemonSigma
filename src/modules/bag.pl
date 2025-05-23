:- module(bag, [setBag/0, showBag/0, is_slot_empty/1]).
:- dynamic bag/2.

setBag :-
    retractall(bag(_, _)),
    initBag(0, 19, pokeball(empty)),
    initBag(20, 39, empty).

initBag(Start, End, _) :- Start > End, !.
initBag(Start, End, Value) :-
    assertz(bag(Start, Value)),
    NewStart is Start + 1,
    initBag(NewStart, End, Value).

showBag :-
    write('=== Isi Tas ==='), nl,
    write('Slot 00-19: Pokeball'), nl,
    write('Slot 20-39: Kosong'), nl,
    write('Detail:'), nl,
    forall(between(0, 39, Index),
        (bag(Index, Item),
        format('Slot ~|~`0t~d~2+: ~w~n', [Index, Item]))).

is_slot_empty(Index) :-
    bag(Index, empty).