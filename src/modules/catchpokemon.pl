:- dynamic(encountered/6).
:- dynamic(pokemonInstance/6).
:- dynamic(pokemon_liar/4).
:- dynamic(party/1).
:- dynamic(bag/2).
:- dynamic(storage/1).

% Command utama: mencoba menangkap Pokémon liar saat encounter berlangsung
catch :-
    ( \+ encountered(Species, Rarity, _, _, _, _) ->
        write('Tidak ada Pokémon liar yang bisa ditangkap!'), nl
    ;
        write('Kamu mencoba menangkap Pokémon...'), nl,
        ( find_empty_pokeball_slot(Slot) ->
            rarityValue(Rarity, Base),
            random_in_range(0, 36, Rand),
            CatchRate is Base + Rand,
            format('Catch rate: ~d~n', [CatchRate]),
            ( CatchRate > 50 ->
                write('🎉 Kamu berhasil menangkap Pokémon!~n'),
                store_encountered_pokemon
            ;
                write('Pokémon berhasil menghindar! Pertarungan berlanjut...~n'),
                start_battle
            )
        ;
            write('⚠ Tidak ada Pokéball kosong! Pokémon tidak bisa ditangkap.'), nl
        )
    ), !.

% Menyimpan Pokémon liar yang berhasil ditangkap ke party/bag/storage
store_encountered_pokemon :-
    encountered(Species, Rarity, BaseHP, BaseATK, Level, _),
    generate_pokemon_id(ID),
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is Level + 5,
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)),
    add_pokemon_to_party_or_bag(ID, Species),
    format('🔴 ~w masuk ke party atau Pokéball!~n', [Species]),
    % Bersihkan encounter yang sudah ditangkap
    retract(encountered(Species, Rarity, BaseHP, BaseATK, Level, _)),
    retractall(temp_enemy_id(_)),
    retractall(pokemon_liar(_, _, Species, Level)),
    end_battle.

% Prioritas penyimpanan: Party → Pokeball → Storage
add_pokemon_to_party_or_bag(ID, Species) :-
    ( party(Party) ->
        length(Party, Len),
        ( Len < 4 ->
            retract(party(Party)),
            append(Party, [ID], NewParty),
            assertz(party(NewParty)),
            format('~w dimasukkan ke dalam party.~n', [Species])
        ;
            ( find_empty_pokeball_slot(Slot) ->
                retract(bag(Slot, pokeball(empty))),
                assertz(bag(Slot, pokeball(filled(ID)))),
                format('~w dimasukkan ke pokeball slot ~d.~n', [Species, Slot])
            ;
                write('⚠ Party dan Pokéball penuh. Pokémon masuk ke storage.~n'),
                ( storage(S) -> true ; S = [] ),
                retractall(storage(_)),
                append(S, [ID], NewStorage),
                assertz(storage(NewStorage)),
                format('~w dimasukkan ke storage.~n', [Species])
            )
        )
    ;
        assertz(party([ID])),
        format('~w dimasukkan ke dalam party baru.~n', [Species])
    ).

% Mencari slot pokéball kosong di tas (slot 0–19)
find_empty_pokeball_slot(Slot) :-
    between(0, 19, Slot),
    bag(Slot, pokeball(empty)), !.

% Menangkap otomatis jika Pokémon dikalahkan dalam pertarungan
auto_catch_defeated(_EnemyID) :-
    ( encountered(Species, Rarity, BaseHP, BaseATK, Level, _) ->
        format('Kamu mencoba menangkap ~w setelah mengalahkannya...~n', [Species]),
        ( find_empty_pokeball_slot(_) ->
            rarityValue(Rarity, Base),
            random_in_range(0, 36, Rand),
            CatchRate is Base + Rand,
            format('Catch rate: ~d~n', [CatchRate]),
            ( CatchRate > 50 ->
                write('🎉 Berhasil menangkap Pokémon setelah mengalahkannya!~n'),
                store_encountered_pokemon
            ;
                write('❌ Pokémon kabur meski sudah dikalahkan...~n'),
                end_battle
            )
        ;
            write('⚠ Tidak ada Pokéball kosong. Tidak bisa menangkap Pokémon!~n'),
            end_battle
        )
    ;
        write('Tidak ada Pokémon yang bisa ditangkap saat ini.'), nl
    ).
