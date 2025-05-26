
setParty(IdxParty, IdxBag) :-
    inBattle(_, _),
    write('Tidak bisa menukar pokemon saat dalam pertarungan!'), nl, !, fail.

setParty(IdxParty, IdxBag) :-
    integer(IdxParty), integer(IdxBag),
    IdxParty >= 0, IdxBag >= 0, IdxBag =< 39,
    party(PokemonList),
    length(PokemonList, PartySize),
    IdxParty < PartySize,
    bag(IdxBag, pokeball(filled(PokemonID))),
    nth0(IdxParty, PokemonList, CurrentPokemon),
    swap_pokemon(IdxParty, IdxBag, CurrentPokemon, PokemonID),
    showParty.

setParty(_, _) :-
    write('Indeks tidak valid atau slot tas tidak berisi pokemon!'), nl, fail.

swap_pokemon(IdxParty, IdxBag, PartyPokemon, BagPokemon) :-
    retract(party(PokemonList)),
    replace_in_list(IdxParty, BagPokemon, PokemonList, NewPartyList),
    assertz(party(NewPartyList)),
    retract(bag(IdxBag, pokeball(filled(BagPokemon)))),
    assertz(bag(IdxBag, pokeball(filled(PartyPokemon)))),
    format('Pemain menukar ~w di party dengan ~w di bag.~n', [PartyPokemon, BagPokemon]).

replace_in_list(0, New, [_|T], [New|T]) :- !.
replace_in_list(I, New, [H|T], [H|R]) :-
    I > 0,
    NI is I - 1,
    replace_in_list(NI, New, T, R).

showParty :-
    party(PokemonList),
    (PokemonList == [] ->
        write('Party Anda kosong!')
    ;
        write('=== Pokemon dalam Party ==='), nl,
        show_party_members(PokemonList, 0)
    ).

show_party_members([], _).
show_party_members([PokemonID|T], N) :-
    pokemonInstance(PokemonID, Species, Level, HP, ATK, DEF),
    pokemon(Species, _, _, BaseHP, _, _, _, _),
    MaxHP is BaseHP + (Level * 2),
    format('~d. ~w (Lv. ~w) HP: ~w/~w~n', [N, Species, Level, HP, MaxHP]),
    Next is N + 1,
    show_party_members(T, Next).