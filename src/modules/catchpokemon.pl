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
    Instance = pokemonInstance(Species, HP, ATK, DEF, Level, Exp),
    Pokeball = pokeball(Instance),
    (
        bag(Pokeball, Count) ->
            NewCount is Count + 1,
            retract(bag(Pokeball, Count)),
            assertz(bag(Pokeball, NewCount))
        ;
            assertz(bag(Pokeball, 1))
    ),
    format("🔴 ~w masuk ke Pokeball dan tersimpan dalam tas!~n", [Species]),
    retract(encountered(Species, HP, ATK, DEF, Level, Exp)).  % clear setelah ditangkap
