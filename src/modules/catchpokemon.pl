catch :-
    encountered(Species, _, _, _, _, _),
    write('Kamu memilih menangkap pokemon'), nl,
    (find_empty_pokeball_slot(Slot) ->
        rarityValue(common, Base),
        random_in_range(0, 36, Rand),
        CatchRate is Base + Rand,
        format('Hasil catch rate: ~w~n', [CatchRate]),
        (CatchRate > 50 ->
            writeln("Kamu berhasil menangkap pokemon!")
        ;
            writeln("Kamu gagal menangkap pokemon!"),
            write('Persiapkan dirimu! Pertarungan yang epik baru saja dimulai!'), nl
            start_battle
        )
    ;
        write('Tidak ada pokeball kosong!'), nl
    ).

store_encountered_pokemon :-
    encountered(Species, HP, ATK, DEF, Level, Exp),
    gensym(Species, ID),
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)),
    add_pokemon_to_party_or_bag(ID, Species),
    format("🔴 ~w masuk ke party atau Pokeball!~n", [Species]),
    retract(encountered(Species, HP, ATK, DEF, Level, Exp)),
    retract(pokemon_liar(_, _, Species, Level)).

add_pokemon_to_party_or_bag(ID, _) :-
    party(Party),
    length(Party, Len),
    (Len < 4 ->
        retract(party(Party)),
        append(Party, [ID], NewParty),
        assertz(party(NewParty))
    ;
        find_empty_pokeball_slot(Slot) ->
            retract(bag(Slot, pokeball(empty))),
            assertz(bag(Slot, pokeball(filled(ID))))
    ;
        write('Party dan Pokeball penuh! Pokemon masuk ke storage.'), nl,
        (storage(Storage) -> true ; Storage = []),
        retractall(storage(_)),
        append(Storage, [ID], NewStorage),
        assertz(storage(NewStorage))
    ).

find_empty_pokeball_slot(Slot) :-
    between(0, 19, Slot),
    bag(Slot, pokeball(empty)), !.