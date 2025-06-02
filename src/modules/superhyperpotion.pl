use_super_potion(Slot) :-
    use_healing_item(Slot, super_potion).

use_hyper_potion(Slot) :-
    use_healing_item(Slot, hyper_potion).

use_healing_item(Slot, Item) :-
    integer(Slot),
    between(20, 39, Slot),
    bag(Slot, Item),
    item(Item, medicine, heal(Factor)),
    apply_healing_effect(Factor),
    retract(bag(Slot, Item)),
    assertz(bag(Slot, empty)),
    format('~w digunakan. Slot ~d kini kosong.~n', [Item, Slot]), !.

use_healing_item(Slot, _) :-
    (\+ integer(Slot) ; \+ between(20, 39, Slot)),
    write('Slot harus berupa angka antara 20 sampai 39.'), nl,
    fail.

use_healing_item(Slot, Item) :-
    \+ bag(Slot, Item),
    format('Slot ~d tidak berisi ~w atau kosong.~n', [Slot, Item]), nl,
    fail.

apply_healing_effect(Factor) :-
    party(PokemonList),
    heal_party_pokemon(PokemonList, Factor).

heal_party_pokemon([], _).
heal_party_pokemon([PokemonID|T], Factor) :-
    heal_pokemon(PokemonID, Factor),
    heal_party_pokemon(T, Factor).

heal_pokemon(PokemonID, Factor) :-
    pokemonInstance(PokemonID, Species, Level, CurrentHP, ATK, DEF),
    pokemon(Species, _, _, BaseHP, _, _, _, _),
    MaxHP is BaseHP + (Level * 2),
    HealAmount is round(MaxHP * Factor),
    NewHP is min(CurrentHP + HealAmount, MaxHP),
    retract(pokemonInstance(PokemonID, Species, Level, CurrentHP, ATK, DEF)),
    assertz(pokemonInstance(PokemonID, Species, Level, NewHP, ATK, DEF)),
    format('HP ~w (~w) bertambah menjadi ~d/~d~n', [PokemonID, Species, NewHP, MaxHP]).
