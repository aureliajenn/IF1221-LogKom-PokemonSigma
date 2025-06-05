:- include('facts.pl').
:- include('modules/state.pl').
:- include('modules/random.pl').
:- include('modules/startgame.pl').
:- include('modules/bag.pl').
:- include('modules/map.pl').
:- include('modules/move.pl').
:- include('modules/catchpokemon.pl').
:- include('modules/battle.pl').
:- include('modules/attack.pl').
:- include('modules/defend.pl').
:- include('modules/run.pl').
:- include('modules/skill.pl').
:- include('modules/setparty.pl').
:- include('modules/bonuslevelup.pl').
:- include('modules/superhyperpotion.pl').
:- include('modules/endgame.pl').

main :-
    startGame,
    help,
    game_loop.

game_loop :-
    repeat,
    write('> '),
    read(Command),
    write('Command dibaca: '), write(Command), nl,
    (Command == quit -> write('Keluar dari game.'), nl, halt ;
     (catch(call(Command), E, (write('Error: '), write(E), nl)), fail)),
    endGame,
    fail.

quit :- halt.

help :-
    nl, write('=== Daftar Command ==='), nl,
    write('--- Navigasi & Info ---'), nl,
    write('move(Direction).'), nl,
    write('showMap.'), nl,
    write('showBag.'), nl,
    write('showParty.'), nl,
    write('setParty(IdxParty,IdxBag).'), nl,
    
    nl,
    write('--- Encounter (saat bertemu pokemon liar) ---'), nl,
    write('battle.'), nl,
    write('catch.'), nl,
    write('run.'), nl,
    nl,
    write('--- Battle (saat bertarung) ---'), nl,
    write('attack.'), nl,
    write('defend.'), nl,
    write('skill(1). / skill(2).'), nl,
    write('run.'), nl,
    nl,
    write('--- Item ---'), nl,
    write('use_healing_item(Slot, Item).'), nl,
    nl,

    write('--- Ganti Current Pokemon ---'), nl,
    write('switch_active_pokemon(Index).'),
    nl,

    write('help.'), nl,
    write('quit.'), nl, nl.