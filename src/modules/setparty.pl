:- dynamic(party/1).
:- dynamic(bag/2).
:- dynamic(inBattle/2).
:- dynamic(pokemonInstance/6).

% Menampilkan isi party
show_party :- showParty.

% Menukar Pokémon antara party dan tas (selama tidak dalam pertarungan)
setParty(IdxParty1Based, IdxBag) :-
    inBattle(_, _),
    write('Tidak bisa menukar Pokemon saat dalam pertarungan!'), nl, !, fail.

setParty(IdxParty1Based, IdxBag) :-
    integer(IdxParty1Based), integer(IdxBag),
    IdxParty1Based >= 1, IdxBag >= 0, IdxBag =< 39,
    party(PokemonList),
    length(PokemonList, PartySize),
    IdxParty1Based =< PartySize,  % validasi indeks langsung
    nth1(IdxParty1Based, PokemonList, CurrentPokemon),  % pakai nth1 (1-based)
    bag(IdxBag, pokeball(filled(PokemonID))),
    swap_pokemon_1based(IdxParty1Based, IdxBag, CurrentPokemon, PokemonID),
    showParty, !.

setParty(_, _) :-
    write('Indeks tidak valid atau slot tas tidak berisi Pokemon!'), nl, fail.

% Menukar posisi Pokémon antara party dan tas (versi 1-based)
swap_pokemon_1based(IdxParty1Based, IdxBag, PartyPokemon, BagPokemon) :-
    retract(party(PokemonList)),
    replace_in_list_1based(IdxParty1Based, BagPokemon, PokemonList, NewPartyList),
    assertz(party(NewPartyList)),
    retract(bag(IdxBag, pokeball(filled(BagPokemon)))),
    assertz(bag(IdxBag, pokeball(filled(PartyPokemon)))).

% Replace elemen di indeks I (1-based) dalam list
replace_in_list_1based(1, New, [_|T], [New|T]) :- !.
replace_in_list_1based(I, New, [H|T], [H|R]) :-
    I > 1,
    I1 is I - 1,
    replace_in_list_1based(I1, New, T, R).

% Tampilkan isi party
showParty :-
    party(PokemonList),
    write('=== Party ==='), nl,
    show_party_members(PokemonList, 1).

show_party_members([], _).
show_party_members([PokemonID|T], N) :-
    pokemonInstance(PokemonID, Species, Level, HP, ATK, DEF),
    pokemon(Species, Rarity, _, _, _, _, _, _),
    format('~d. ~w (Lv.~d) HP:~d ATK:~d DEF:~d Rarity:~w~n',
        [N, Species, Level, HP, ATK, DEF, Rarity]),
    N1 is N + 1,
    show_party_members(T, N1).
