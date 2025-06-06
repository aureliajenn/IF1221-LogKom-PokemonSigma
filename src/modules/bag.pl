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
    write('Slot 00 - 19: Pokeball'), nl,
    write('Slot 20 - 39: Item/Kosong'), nl, nl,
    write('+------+------------------------------------------+'), nl,
    write('| Slot |                   Isi                    |'), nl,
    write('+------+------------------------------------------+'), nl,
    show_bag_slots_table(0, 39),
    write('+------+------------------------------------------+'), nl.

/* Tampilkan slot dari tas dalam bentuk tabel */
/* Tampilkan slot dari tas dalam bentuk tabel */
show_bag_slots_table(I, Max) :- I > Max, !.
show_bag_slots_table(I, Max) :-
    (bag(I, Item) -> true ; Item = empty),  % Pastikan Item selalu terikat
    pad_index(I, Padded),
    describe_item(Item, Desc),
    pad_right(Desc, 42, PaddedDesc),
    format('|  ~w  |~w|~n', [Padded, PaddedDesc]),
    I1 is I + 1,
    show_bag_slots_table(I1, Max).

/* Deskripsi item */
describe_item(empty, '[Kosong]') :- !.
describe_item(kosong, '[Kosong]') :- !.
describe_item(pokeball(empty), 'Pokeball (Kosong)') :- !.
describe_item(pokeball(filled(ID)), Desc) :-
    (pokemonInstance(ID, Species, _, _, _, _) ->
        atom_concat('Pokeball (Terisi oleh ', Species, Temp),
        atom_concat(Temp, ')', Desc)
    ;
        number_codes(ID, IDCodes),
        atom_codes(IDAtom, IDCodes),
        atom_concat('Pokeball (Terisi oleh ID ', IDAtom, Temp),
        atom_concat(Temp, ')', Desc)
    ), !.
describe_item(Item, Desc) :-
    (var(Item) -> Desc = '[Unknown]' ;  % Handle uninstantiated variables
    atom(Item) -> Desc = Item ;
    term_to_atom(Item, Desc)), !.

/* Format nomor slot menjadi dua digit */
pad_index(Index, Padded) :-
    (Index < 10 ->
        number_codes(Index, Codes),
        atom_codes(IndexAtom, Codes),
        atom_concat('0', IndexAtom, Padded)
    ;
        number_codes(Index, Codes),
        atom_codes(Padded, Codes)
    ).

/* Tambah padding spasi agar kolom sejajar */
pad_right(Atom, TargetLength, Padded) :-
    atom_chars(Atom, Chars),
    length(Chars, Len),
    Spaces is max(0, TargetLength - Len),
    make_spaces(Spaces, SpaceAtom),
    atom_chars(SpaceAtom, SpaceChars),
    append(Chars, SpaceChars, ResultChars),
    atom_chars(Padded, ResultChars).

make_spaces(N, SpaceAtom) :-
    (N =< 0 ->
        SpaceAtom = ''
    ;
        length(L, N),
        maplist(=(' '), L),
        atom_chars(SpaceAtom, L)
    ).

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
    (party(Party) ->
        delete(Party, PokemonID, NewParty),
        retract(party(Party)),
        assertz(party(NewParty))
    ; true),
    (party(Current), length(Current, Len), Len < 4 ->
        append(Current, [PokemonID], NewParty),
        retract(party(Current)),
        assertz(party(NewParty)),
        format('~w dimasukkan kembali ke party.~n', [Species])
    ;
        (find_empty_pokeball_slot(Slot) ->
            retract(bag(Slot, pokeball(empty))),
            assertz(bag(Slot, pokeball(filled(PokemonID)))),
            format('~w dimasukkan ke pokeball slot ~d.~n', [Species, Slot])
        ;
            (storage(S) -> true ; S = []),
            retractall(storage(_)),
            append(S, [PokemonID], NewStorage),
            assertz(storage(NewStorage)),
            format('~w dimasukkan ke storage karena party dan pokeball penuh.~n', [Species])
        )
    ).

/* Menambahkan Pokémon ke party atau tempat lain jika penuh */
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
