Plumber - hosting API
================

Hosting
-------

API uruchamia sie na porcie 7494 (patrz plik *runAPI.R*). W celu trwałego uruchomienia API na serwerze należy wywołać skrypt *runAPI.R*. Nie zrobimy tego poprzez wywołanie odpowiedniej komendy w terminalu gdyż po jego zamknięciu proces zostaje skillowany i API przestaje działać. W związku z tym wykorzystamy program [screen](https://askubuntu.com/questions/389834/how-to-run-application-from-terminal-forever).

Uruchomienie API - instrukcja
-----------------------------

``` bash
screen 
cd ~/myProject
Rscript runAPI.R
```

Nastepnie należy skorzystać ze skrótów klawiszowych *Ctrl+A* i *Ctrl+D* by zamknąć screen-a ale pozostawiając jego sesję aktywną. Poleceniem:

``` bash
screen -ls 
```

zobaczymy wszystkie aktywne sesje screen-a. Aby spowrotem otworzyć daną sesję wpisujemy:

``` bash
screen -r processId
```

gdzie *processId* to numer procesu obługującego daną sesję wypisany na początku nazw wylistowanych aktywnych sesji screena. Aby skillować sesję wywołujemy:

``` bash
screen -XS processId quit
```

Uwierzytelnienie
----------------

W podanym przykładzie uwierzytelnienie jest zrobione po stronie API. Każda metoda zawiera parametr **userKey** będący kluczem uwierzytelniającym. Jeśli klucz pasuje do zapisanej w pliku *usersKey.txt* listy kluczy logujemy odpytanie i próbujemy je zrealizować, wpp zapytanie jest wstrzymane i zwracany jest error.
