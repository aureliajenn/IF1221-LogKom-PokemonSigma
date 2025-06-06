:- dynamic(encountered/6).
:- dynamic(pokemonInstance/6).
:- dynamic(pokemon_liar/4).
:- dynamic(party/1).
:- dynamic(bag/2).
:- dynamic(storage/1).

catch :-
    inBattle(_, _),
    write('Command catch tidak dapat dilakukan saat pertarungan.'), nl, !, fail.

% Command utama: mencoba menangkap Pokémon liar saat encounter berlangsung
catch :-
    ( \+ encountered(Species, Rarity, _, _, _, _) ->
        write('Tidak ada Pokemon liar yang bisa ditangkap!'), nl
    ;
        write('Kamu mencoba menangkap Pokemon...'), nl,
        ( find_empty_pokeball_slot(Slot) ->
            rarityValue(Rarity, Base),
            random_in_range(0, 36, Rand),
            CatchRate is Base + Rand,
            format('Catch rate: ~d~n', [CatchRate]),
            ( CatchRate > 50 ->
                write('Kamu berhasil menangkap Pokemon!'), nl,
                store_encountered_pokemon
            ;
                write('Pokemon berhasil menghindar! Memulai pertarungan!'), nl,
                start_battle_from_encounter
            )
        ;
            write('Tidak ada Pokeball kosong! Pokemon tidak bisa ditangkap.'), nl
        )
    ), !.

start_battle_from_encounter :-
    pending_encounter(Species, Level),
    retract(pending_encounter(Species, Level)),
    generate_pokemon_id(EnemyID),
    pokemon(Species, Rarity, _, BaseHP, BaseATK, BaseDEF, _, _),
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is BaseDEF + Level,
    assertz(pokemonInstance(EnemyID, Species, Level, HP, ATK, DEF)),

    ( active_pokemon(PlayerID) -> true ; (party([PlayerID|_]), assertz(active_pokemon(PlayerID)))),    
    assertz(inBattle(PlayerID, EnemyID)),

    pokemonInstance(PlayerID, PlayerSpecies, _, _, _, _),
    write('Pertarungan dimulai!'), nl,
    format('Pertarungan dimulai antara ~w dan ~w!~n~n', [PlayerSpecies, Species]),

    write('Command yang dapat digunakan selama pertarungan:'), nl,
    write('- attack.      : Serangan fisik standar'), nl,
    write('- defend.      : Bertahan, defense naik 30% selama 1 turn'), nl,
    write('- skill(N).    : Gunakan skill ke-N (1 atau 2 jika Lv >= 10)'), nl.

% Menyimpan Pokémon liar yang berhasil ditangkap ke party/bag/storage
store_encountered_pokemon :-
    encountered(Species, Rarity, BaseHP, BaseATK, Level, _),
    generate_pokemon_id(ID),
    HP is BaseHP + Level * 2,
    ATK is BaseATK + Level,
    DEF is Level + 5,
    assertz(pokemonInstance(ID, Species, Level, HP, ATK, DEF)),
    add_pokemon_to_party_or_bag(ID, Species),
    format('~w masuk ke party atau Pokeball!~n', [Species]),
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
                write('Party dan Pokeball penuh. Pokemon masuk ke storage.~n'),
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
% auto_catch_defeated(_EnemyID) :-
%     ( encountered(Species, Rarity, BaseHP, BaseATK, Level, _) ->
%         format('Kamu mencoba menangkap ~w setelah mengalahkannya...~n', [Species]),
%         ( find_empty_pokeball_slot(_) ->
%             rarityValue(Rarity, Base),
%             random_in_range(0, 36, Rand),
%             CatchRate is Base + Rand,
%             format('Catch rate: ~d~n', [CatchRate]),
%             ( CatchRate > 50 ->
%                 write('Berhasil menangkap Pokémon setelah mengalahkannya!~n'),
%                 store_encountered_pokemon
%             ;
%                 write('Pokemon kabur meski sudah dikalahkan...~n'),
%                 end_battle
%             )
%         ;
%             write('Tidak ada Pokeball kosong. Tidak bisa menangkap Pokemon!~n'),
%             end_battle
%         )
%     ;
%         write('Tidak ada Pokemon yang bisa ditangkap saat ini.'), nl
%     ).
auto_catch_defeated(_EnemyID) :-
    ( encountered(Species, Rarity, BaseHP, BaseATK, Level, _) ->
        format('~w telah dikalahkan dan berhasil ditangkap secara otomatis!~n', [Species]),
        store_encountered_pokemon
    ;
        write('Tidak ada Pokemon yang bisa ditangkap saat ini.'), nl
    ).
