:- module(bag, [setBag/0, showBag/0, is_slot_empty/1, add_item_to_bag/1]).
:- use_module(items).

setBag :-
    retractall(bag(_, _)),
    initBag(0, 19, pokeball(empty)),
    initBag(20, 39, empty).

initBag(Start, End, _) :- Start > End, !.
initBag(Start, End, Value) :-
    assertz(bag(Start, Value)),
    Next is Start + 1,
    initBag(Next, End, Value).

showBag :-
    write('=== Isi Tas ==='), nl,
    write('Slot 00-19: Pokeball'), nl,
    write('Slot 20-39: Item/Kosong'), nl, nl,
    forall(between(0, 39, Index),
        (bag(Index, Item),
        format_item(Index, Item))).

format_item(Index, empty) :-
    format('Slot ~|~`0t~d~2+: [Kosong]~n', [Index]).
format_item(Index, pokeball(empty)) :-
    format('Slot ~|~`0t~d~2+: Pokeball (Kosong)~n', [Index]).
format_item(Index, pokeball(filled(_))) :-
    format('Slot ~|~`0t~d~2+: Pokeball (Terisi)~n', [Index]).
format_item(Index, Item) :-
    (current_predicate(item/3), item(Item, Type, _)) -> 
        format('Slot ~|~`0t~d~2+: ~w (~w)~n', [Index, Item, Type])
    ;
        format('Slot ~|~`0t~d~2+: ~w (Item)~n', [Index, Item]).

is_slot_empty(Index) :-
    between(0, 39, Index),
    bag(Index, empty).

add_item_to_bag(Item) :-
    find_empty_slot(Index),
    retract(bag(Index, empty)),
    assertz(bag(Index, Item)),
    format('Item ~w ditambahkan ke slot ~w~n', [Item, Index]).

find_empty_slot(Index) :-
    between(20, 39, Index),
    bag(Index, empty),
    !.
find_empty_slot(_) :-
    write('Tas penuh! Tidak ada slot kosong.'), nl,
    fail.