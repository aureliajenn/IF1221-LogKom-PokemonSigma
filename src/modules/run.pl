:- module(run, [run/0]).
:- dynamic(pending_encounter/2).
:- dynamic(encountered/6).
:- dynamic(temp_enemy_id/1).
:- dynamic(pokemon_liar/4).
:- dynamic(inBattle/2).

run :-
    inBattle(_, _),
    write('Command run tidak dapat dilakukan saat pertarungan.'), nl, !, fail.


run :-
    pending_encounter(Species, Level), !,
    retract(pending_encounter(Species, Level)),
    write('Kamu kabur dari pertemuan dengan Pokemon liar.'), nl,
    write('Haha skill issue...'), nl.

run :-
    encountered(Species, Rarity, BaseHP, BaseATK, Level, _), !,
    retract(encountered(Species, Rarity, BaseHP, BaseATK, Level, _)),
    ( retract(temp_enemy_id(_)) ; true ),
    retractall(pokemon_liar(_, _, Species, Level)),
    write('Kamu kabur dari pertemuan dengan Pokemon liar.'), nl,
    write('Haha skill issue...'), nl.


run :-
    write('Kamu tidak sedang dalam pertempuran atau pertemuan apapun!'), nl.
