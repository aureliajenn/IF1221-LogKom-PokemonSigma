useItem(Item) :-
    bag(Bag),
    select(Item, Bag, NewBag),  % hapus satu item yang cocok
    retract(bag(Bag)),
    assertz(bag(NewBag)),
    format("Item ~w telah digunakan dan dihapus dari tas.\n", [Item]), !.

useItem(Item) :-
    format("Item ~w tidak tersedia di tas.\n", [Item]), !.
