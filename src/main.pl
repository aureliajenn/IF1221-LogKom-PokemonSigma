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
    write('> '), read(Command),
    (Command == quit ; Command == exit), !, write('Keluar dari game.'), nl;
    (catch(call(Command), E, (write('Error: '), write(E), nl)), fail),
    endGame,
    fail.

help :-
    nl, write('=== Daftar Command ==='), nl,
    write('move(Direction).   % up/down/left/right'), nl,
    write('showMap.'), nl,
    write('showBag.'), nl,
    write('showParty.'), nl,
    write('attack.'), nl,
    write('defend.'), nl,
    write('run.'), nl,
    write('use_super_potion(Slot).'), nl,
    write('use_hyper_potion(Slot).'), nl,
    write('setParty(IdxParty, IdxBag).'), nl,
    write('help.'), nl,
    write('quit. / exit.'), nl, nl.