catch :-
    ( encountered(Species, Rarity, _, _, _, _) ->
        write('Kamu memilih menangkap pokemon'), nl,
        ( find_empty_pokeball_slot(Slot) ->
            rarityValue(Rarity, Base),
            random_in_range(0, 36, Rand),
            CatchRate is Base + Rand,
            format('Hasil catch rate: ~d~n', [CatchRate]),
            ( CatchRate > 50 ->
                write('Kamu berhasil menangkap pokemon!'), nl,
                store_encountered_pokemon
            ;
                write('Kamu gagal menangkap pokemon!'), nl,
                write('Persiapkan dirimu! Pertarungan yang epik baru saja dimulai!'), nl,
                start_battle
            )
        ;
            write('Tidak ada pokeball kosong!'), nl
        )
    ;
        write('Tidak ada pokemon untuk ditangkap!'), nl
    ), !.

store_encountered_pokemon :-
    encountered(Species, Rarity, BaseHP, BaseATK, Level, _),
    generate_pokemon_id(ID),
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is Level + 5,  % Jika tidak punya BaseDEF, pakai aturan default
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)),
    add_pokemon_to_party_or_bag(ID, Species),
    format('🔴 ~w masuk ke party atau Pokeball!~n', [Species]),
    retract(encountered(Species, Rarity, BaseHP, BaseATK, Level, _)),
    retract(pokemon_liar(_, _, Species, Level)).

add_pokemon_to_party_or_bag(ID, _) :-
    ( party(Party) ->
        length(Party, Len),
        ( Len < 4 ->
            retract(party(Party)),
            append(Party, [ID], NewParty),
            assertz(party(NewParty))
        ;
            ( find_empty_pokeball_slot(Slot) ->
                retract(bag(Slot, pokeball(empty))),
                assertz(bag(Slot, pokeball(filled(ID))))
            ;
                write('Party dan Pokeball penuh! Pokemon masuk ke storage.'), nl,
                ( storage(Storage) -> true ; Storage = [] ),
                retractall(storage(_)),
                append(Storage, [ID], NewStorage),
                assertz(storage(NewStorage))
            )
        )
    ; % jika party belum ada, buat party
        assertz(party([ID]))
    ).

find_empty_pokeball_slot(Slot) :-
    between(0, 19, Slot),
    bag(Slot, pokeball(empty)), !.

auto_catch_defeated(_EnemyID) :-
    encountered(Species, Rarity, _, _, _, _),
    format('Kamu mencoba menangkap ~w...~n', [Species]),
    ( find_empty_pokeball_slot(Slot) ->
        rarityValue(Rarity, Base),
        random_in_range(0, 36, Rand),
        CatchRate is Base + Rand,
        format('Catch rate: ~d~n', [CatchRate]),
        ( CatchRate > 50 ->
            write('Berhasil menangkap Pokémon!~n'),
            store_encountered_pokemon
        ;
            write('Ternyata Pokémon kabur walau sudah dikalahkan...~n')
        )
    ;
        write('Tidak ada Pokeball kosong untuk menangkap Pokémon!~n')
    ).

