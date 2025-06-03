:- dynamic(party/1).
:- dynamic(bag/2).
:- dynamic(storage/1).

/* Inisialisasi tas */
setBag :-
    retractall(bag(_, _)),
    initBag(0, 19, pokeball(empty)),
    initBag(20, 39, empty).

initBag(I, End, _) :- I > End, !.
initBag(I, End, Value) :-
    assertz(bag(I, Value)),
    I1 is I + 1,
    initBag(I1, End, Value).

/* Menampilkan isi tas */
showBag :-
    write('=== Isi Tas ==='), nl,
    write('Slot 00-19: Pokeball'), nl,
    write('Slot 20-39: Item/Kosong'), nl, nl,
    show_bag_slots(0, 39).

show_bag_slots(I, Max) :- I > Max, !.
show_bag_slots(I, Max) :-
    (bag(I, Item) -> true ; Item = kosong),
    format_item(I, Item),
    I1 is I + 1,
    show_bag_slots(I1, Max).

pad_index(Index, Padded) :-
    (Index < 10 ->
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
format_item(Index, pokeball(filled(ID))) :-
    pad_index(Index, Padded),
    (pokemonInstance(ID, Species, _, _, _, _) ->
        format('Slot ~w: Pokeball (Terisi oleh ~w)~n', [Padded, Species])
    ;
        format('Slot ~w: Pokeball (Terisi oleh ID ~w)~n', [Padded, ID])
    ).
format_item(Index, Item) :-
    pad_index(Index, Padded),
    format('Slot ~w: ~w~n', [Padded, Item]).

/* Menambahkan item ke slot item (20–39) */
find_empty_item_slot(Index) :-
    between(20, 39, Index),
    bag(Index, empty), !.

add_item_to_bag(Item) :-
    find_empty_item_slot(Index),
    retract(bag(Index, empty)),
    assertz(bag(Index, Item)),
    format('Item ~w berhasil ditambahkan ke slot ~d.~n', [Item, Index]), !.
add_item_to_bag(_) :-
    write('Tas sudah penuh! Tidak bisa menambahkan item baru.'), nl.

/* Menemukan slot pokeball kosong (slot 0–19) */
find_empty_pokeball_slot(Slot) :-
    between(0, 19, Slot),
    bag(Slot, pokeball(empty)), !.

/* Memindahkan Pokémon yang dikalahkan ke tempat sesuai prioritas */
move_defeated_to_party_or_bag(PokemonID) :-
    pokemonInstance(PokemonID, Species, _, _, _, _),
    % Hapus dari party jika masih ada
    (party(Party) ->
        delete(Party, PokemonID, NewParty),
        retract(party(Party)),
        assertz(party(NewParty))
    ; true),

    % Coba kembalikan ke party jika masih bisa
    (party(Current), length(Current, Len), Len < 4 ->
        append(Current, [PokemonID], NewParty),
        retract(party(Current)),
        assertz(party(NewParty)),
        format('~w dimasukkan kembali ke party.~n', [Species])
    ;
        % Masukkan ke pokeball kosong jika tersedia
        (find_empty_pokeball_slot(Slot) ->
            retract(bag(Slot, pokeball(empty))),
            assertz(bag(Slot, pokeball(filled(PokemonID)))),
            format('~w dimasukkan ke pokeball slot ~d.~n', [Species, Slot])
        ;
            % Simpan ke storage
            (storage(S) -> true ; S = []),
            retractall(storage(_)),
            append(S, [PokemonID], NewStorage),
            assertz(storage(NewStorage)),
            format('~w dimasukkan ke storage karena party dan pokeball penuh.~n', [Species])
        )
    ).

/* Menambahkan Pokémon hasil tangkapan ke tempat yang sesuai */
add_pokemon_to_party_or_bag(ID, Species) :-
    (party(Party) ->
        length(Party, Len),
        (Len < 4 ->
            retract(party(Party)),
            append(Party, [ID], NewParty),
            assertz(party(NewParty)),
            format('~w dimasukkan ke dalam party.~n', [Species])
        ;
            (find_empty_pokeball_slot(Slot) ->
                retract(bag(Slot, pokeball(empty))),
                assertz(bag(Slot, pokeball(filled(ID)))),
                format('~w dimasukkan ke pokeball slot ~d.~n', [Species, Slot])
            ;
                (storage(S) -> true ; S = []),
                retractall(storage(_)),
                append(S, [ID], NewStorage),
                assertz(storage(NewStorage)),
                format('~w dimasukkan ke storage karena party dan pokeball penuh.~n', [Species])
            )
        )
    ;
        assertz(party([ID])),
        format('~w dimasukkan ke dalam party baru.~n', [Species])
    ).
