:- dynamic(bag/2).

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
    show_bag_slots(0, 39).

show_bag_slots(I, Max) :- I > Max, !.
show_bag_slots(I, Max) :-
    bag(I, Item),
    format_item(I, Item),
    I1 is I + 1,
    show_bag_slots(I1, Max).

format_item(Index, empty) :-
    format('Slot ~|~`0t~d~2+: [Kosong]~n', [Index]).
format_item(Index, pokeball(empty)) :-
    format('Slot ~|~`0t~d~2+: Pokeball (Kosong)~n', [Index]).
format_item(Index, pokeball(filled(PokemonID))) :-
    format('Slot ~|~`0t~d~2+: Pokeball (Terisi oleh ~w)~n', [Index, PokemonID]).
format_item(Index, Item) :-
    Item \= empty, Item \= pokeball(_),
    format('Slot ~|~`0t~d~2+: ~w~n', [Index, Item]).

find_empty_slot(Index) :-
    between(20, 39, Index),
    bag(Index, empty), !.

add_item_to_bag(Item) :-
    find_empty_slot(Index),
    retract(bag(Index, empty)),
    assertz(bag(Index, Item)),
    format('Item ~w berhasil ditambahkan ke slot ~d.\n', [Item, Index]), !.
add_item_to_bag(_) :-
    write('Tas sudah penuh! Tidak bisa menambahkan item baru.\n'), !.