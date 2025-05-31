catchPokemon(Rarity) :-
    rarityValue(Rarity, Base),
    random_in_range(0, 36, Rand),
    CatchRate is Base + Rand,
    format("CatchRate = ~w + ~w = ~w~n", [Base, Rand, CatchRate]),
    (CatchRate > 50 ->
        writeln("🎉 Pokémon berhasil ditangkap!"),
        store_encountered_pokemon;
        writeln("💥 Gagal menangkap! Lanjut ke battle.")
    ).

store_encountered_pokemon :-
    encountered(Species, HP, ATK, DEF, Level, Exp),
    gensym(Species, ID),
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)),
    add_pokemon_to_party_or_bag(ID, Species),
    format("🔴 ~w masuk ke party atau Pokeball!~n", [Species]),
    retract(encountered(Species, HP, ATK, DEF, Level, Exp)).

add_pokemon_to_party_or_bag(ID, _) :-
    party(Party),
    length(Party, Len),
    (Len < 6 ->
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