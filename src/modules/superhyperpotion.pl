:- module(items, [
    use_super_potion/1,
    use_hyper_potion/1,
    get_healing_item/1,
    show_healing_item_info/1
]).

:- use_module(facts).

use_super_potion(Slot) :-
    use_healing_item(Slot, super_potion).

use_hyper_potion(Slot) :-
    use_healing_item(Slot, hyper_potion).

use_healing_item(Slot, Item) :-
    integer(Slot),
    between(20, 39, Slot),
    bag:bag(Slot, Item),
    item(Item, medicine, heal(Factor)),
    apply_healing_effect(Factor),
    bag:retract(bag(Slot, Item)),
    bag:assertz(bag(Slot, empty)),
    format('~w digunakan. Slot ~d kini kosong.~n', [Item, Slot]).

use_healing_item(_, _) :-
    write('Slot tidak valid atau bukan item healing yang valid.'), nl,
    fail.

apply_healing_effect(Factor) :-
    (battle:in_battle(ActivePokemon, _) ->
        heal_pokemon(ActivePokemon, Factor)
    ;
        write('Pilih Pokemon yang akan diheal:'), nl,
        party:showParty,
        read(PokemonIndex),
        party:party(Members),
        nth0(PokemonIndex, Members, PokemonID),
        heal_pokemon(PokemonID, Factor)
    ).

heal_pokemon(PokemonID, Factor) :-
    pokemonInstance(PokemonID, Species, Level, CurrentHP, ATK, DEF),
    pokemon(Species, _, _, BaseHP, _, _, _, _),
    MaxHP is BaseHP + (Level * 2),
    HealAmount is floor(MaxHP * Factor),
    NewHP is min(MaxHP, CurrentHP + HealAmount),
    retract(pokemonInstance(PokemonID, Species, Level, _, ATK, DEF)),
    assertz(pokemonInstance(PokemonID, Species, Level, NewHP, ATK, DEF)),
    format('~w dipulihkan ~d HP (~d/~d)~n', [Species, HealAmount, NewHP, MaxHP]).

get_healing_item(Item) :-
    random(0, 100, Chance),
    (Chance < 15 -> Item = super_potion
    ; Chance < 20 -> Item = hyper_potion
    ;               fail
    ).

show_healing_item_info(Item) :-
    member(Item, [super_potion, hyper_potion]),
    item(Item, Type, heal(Factor)),
    Percentage is Factor * 100,
    format('=== ~w ===~n', [Item]),
    format('Tipe: ~w~n', [Type]),
    format('Efek: Memulihkan ~d% HP Pokemon~n', [Percentage]),
    nl.