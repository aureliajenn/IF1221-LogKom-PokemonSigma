addItem(Item) :-
    bag(Bag),
    length(Bag, N),
    N < 40,
    append(Bag, [Item], NewBag),
    retract(bag(Bag)),
    assertz(bag(NewBag)),
    format("Item ~w berhasil ditambahkan ke dalam tas.\n", [Item]), !.

addItem(_) :-
    write("Tas sudah penuh! Tidak bisa menambahkan item baru.\n"), !.