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
    ( bag(I, Item) -> true ; Item = kosong ),
    format_item(I, Item),
    I1 is I + 1,
    show_bag_slots(I1, Max).

% Hindari penggunaan ~| atau ~`0t (tidak didukung GNU Prolog). Gunakan format manual.
pad_index(Index, Padded) :-
    ( Index < 10 ->
        number_codes(Index, Codes),
        append("0", Codes, PaddedCodes)
    ;
        number_codes(Index, PaddedCodes)
    ),
    atom_codes(Padded, PaddedCodes).

format_item(Index, empty) :-
    pad_index(Index, Padded),
    format('Slot ~w: [Kosong]~n', [Padded]).
format_item(Index, pokeball(empty)) :-
    pad_index(Index, Padded),
    format('Slot ~w: Pokeball (Kosong)~n', [Padded]).
format_item(Index, pokeball(filled(PokemonID))) :-
    pad_index(Index, Padded),
    format('Slot ~w: Pokeball (Terisi oleh ', [Padded]),
    (pokemonInstance(PokemonID, Species, _, _, _, _) ->
        format('~w)~n', [Species])
    ;
        format('ID ~w)~n', [PokemonID])
    ).
format_item(Index, Item) :-
    pad_index(Index, Padded),
    format('Slot ~w: ~w~n', [Padded, Item]).

find_empty_slot(Index) :-
    between(20, 39, Index),
    bag(Index, empty), !.

add_item_to_bag(Item) :-
    find_empty_slot(Index),
    retract(bag(Index, empty)),
    assertz(bag(Index, Item)),
    format('Item ~w berhasil ditambahkan ke slot ~d.~n', [Item, Index]), !.
add_item_to_bag(_) :-
    write('Tas sudah penuh! Tidak bisa menambahkan item baru.'), nl, !.

move_defeated_to_bag(PokemonID) :-
    % Hapus dari party
    party(List),
    delete(List, PokemonID, NewList),
    retract(party(List)),
    assertz(party(NewList)),

    % Cari slot kosong di pokeball (0–19)
    find_empty_pokeball_slot(0, Slot),
    assertz(bag(Slot, pokeball(filled(PokemonID)))),
    format('~w telah dipindahkan ke tas (slot ~d).~n', [PokemonID, Slot]).

find_empty_pokeball_slot(I, I) :-
    I =< 19,
    ( \+ bag(I, _) ; bag(I, pokeball(empty)) ), !.

find_empty_pokeball_slot(I, Slot) :-
    I1 is I + 1,
    find_empty_pokeball_slot(I1, Slot).
