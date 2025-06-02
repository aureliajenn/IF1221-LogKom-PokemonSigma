:- dynamic(party/1).
:- dynamic(bag/2).
:- dynamic(inBattle/2).
:- dynamic(pokemonInstance/6).

% Menampilkan isi party
show_party :- showParty.

% Menukar Pokémon antara party dan tas (selama tidak dalam pertarungan)
% Menukar Pokémon antara party dan tas (selama tidak dalam pertarungan)
setParty(_, _) :-
    inBattle(_, _),
    write('Tidak bisa menukar Pokémon saat dalam pertarungan!'), nl, !, fail.

setParty(IdxParty, IdxBag) :-
    integer(IdxParty), integer(IdxBag),
    IdxParty >= 0, IdxBag >= 0, IdxBag =< 39,
    party(PokemonList),
    length(PokemonList, PartySize),
    IdxParty < PartySize,
    bag(IdxBag, pokeball(filled(PokemonID))),
    nth0(IdxParty, PokemonList, CurrentPokemon),
    swap_pokemon(IdxParty, IdxBag, CurrentPokemon, PokemonID),
    showParty, !.

setParty(_, _) :-
    write('Indeks tidak valid atau slot tas tidak berisi Pokémon!'), nl, fail.

% Menukar posisi Pokémon antara party dan tas
swap_pokemon(IdxParty, IdxBag, PartyPokemon, BagPokemon) :-
    retract(party(PokemonList)),
    replace_in_list(IdxParty, BagPokemon, PokemonList, NewPartyList),
    assertz(party(NewPartyList)),
    retract(bag(IdxBag, pokeball(filled(BagPokemon)))),
    assertz(bag(IdxBag, pokeball(filled(PartyPokemon)))).

% Replace elemen di indeks I dalam list
replace_in_list(0, New, [_|T], [New|T]) :- !.
replace_in_list(I, New, [H|T], [H|R]) :-
    I1 is I - 1,
    replace_in_list(I1, New, T, R).

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
