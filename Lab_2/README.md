# Bazy Danych - Laboratorium 2

### Student:

    Bartłomiej Krawczyk

### Numer Albumu:

    310774

## Pytania

### 1. Wykonaj wszystkie polecenia z zajęć.

```sql
CREATE TABLE stanowiska
(
  id_stanowiska     NUMBER (4) CONSTRAINT stanowisko_pk PRIMARY KEY,
  nazwa             VARCHAR2 (60 CHAR) NOT NULL,
  min_placa         NUMBER (7,2),
  max_placa         NUMBER (7, 2)
);

CREATE TABLE pracownicy
(
  id_pracownika     NUMBER (4) CONSTRAINT pracownicy_pk PRIMARY KEY,
  imie              VARCHAR2 (40 CHAR) NOT NULL,
  nazwisko          VARCHAR2 (40 CHAR) NOT NULL,
  zarobki           NUMBER (7, 2),
  data_zatrudnienia DATE,
  id_zakladu        NUMBER (4) NOT NULL,
  id_kierownika     NUMBER (4) REFERENCES pracownicy(id_pracownika),
  kod_stanowiska    NUMBER (4) NOT NULL REFERENCES stanowiska(id_stanowiska)
);

CREATE TABLE regiony
(
  id_regionu        NUMBER (4) CONSTRAINT regiony_pk PRIMARY KEY,
  nazwa             VARCHAR2 (60 CHAR) NOT NULL
);

CREATE TABLE kraje
(
  id_kraju          NUMBER (4) CONSTRAINT kraje_pk PRIMARY KEY,
  nazwa             VARCHAR2 (60 CHAR) NOT NULL,
  id_regionu        NUMBER (4) NOT NULL REFERENCES regiony(id_regionu)
);


CREATE TABLE zaklady
(
  id_zakladu        NUMBER (4) CONSTRAINT zaklady_pk PRIMARY KEY,
  nazwa             VARCHAR2 (60 CHAR) NOT NULL,
  manager_id        NUMBER (4),
  id_lokalizacji    NUMBER (4)
);

ALTER TABLE zaklady
ADD CONSTRAINT zaklad_manager_fk FOREIGN KEY (manager_id)
REFERENCES pracownicy(id_pracownika);

ALTER TABLE stanowiska
ADD CONSTRAINT min_placa
CHECK (min_placa >= 1000);

```

### 2. Stwórz tabelę Szkolenia zawierającą kolumnę identyfikator i nazwa.

```sql
CREATE TABLE szkolenia
(
  id_szkolenia      NUMBER (4) CONSTRAINT szkolenia_pw PRIMARY KEY,
  nazwa             VARCHAR2 (60 CHAR) NOT NULL
);
```

### 3. Zmodyfikuj tabelę Pracownicy dodając kolumnę szkolenie_id będące kluczem obcym do tabeli Szkolenia.

```sql
ALTER TABLE pracownicy
ADD (
  id_szkolenia      NUMBER (4) REFERENCES szkolenia(id_szkolenia)
);
```

### 4. Zmodyfikuj tabelę Pracownicy usuwając kolumnę date_zatrudnienia.

```sql
ALTER TABLE pracownicy
DROP COLUMN data_zatrudnienia;
```

### 5. Usuń tabelę Zakłady. Co obserwujesz? Dlaczego? Jak wymusić usunięcie tabeli?

```sql
DROP TABLE zaklady;
```

Tabela, do której nie ma żadnych odnośników jest usuwana bez problemu.

```sql
ALTER TABLE pracownicy ADD CONSTRAINT zaklad_pracownika_fk FOREIGN KEY (id_zakladu)
REFERENCES zaklady (id_zakladu);

DROP TABLE zaklady;
```

Dopiero teraz otrzymujemy błąd:

```
DROP TABLE zaklady
Error report -
SQL Error: ORA-02449: tabela ma unikatowe/główne klucze, do których odwołują się obce klucze
02449. 00000 -  "unique/primary keys in table referenced by foreign keys"
*Cause:    An attempt was made to drop a table with unique or
           primary keys referenced by foreign keys in another table.
*Action:   Before performing the above operations the table, drop the
           foreign key constraints in other tables. You can see what
           constraints are referencing a table by issuing the following
           command:
           SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = "tabnam";
```

Aby móc usunąć zakłady wystarczy usunąć Constraint zaklad_pracownika_fk (lub zmienić metodę działania w przypadku usunięcia tabel).

```sql
ALTER TABLE pracownicy DROP CONSTRAINT zaklad_pracownika_fk;

DROP TABLE zaklady;
```

### 6. Przywróć tabelę Zakłady poleceniem FLASHBACK tablename TO BEFORE DROP.

```sql
FLASHBACK TABLE zaklady TO BEFORE DROP;
```

Tabela, po usunięciu jest przenoszona do RECYLCE BIN, z którego można ją przywrócić.

### 7. Co zmienia klauzula PURGE przy DROP table? Wypróbuj na tabeli Adresy. Jak wtedy odtworzyć dane?

```sql
CREATE TABLE adresy
(
  id_adresu         NUMBER (4) CONSTRAINT adresy_pk PRIMARY KEY,
  ulica             VARCHAR2 (255 BYTE) NOT NULL,
  kod_pocztowy      VARCHAR2 (6 CHAR) NOT NULL,
  miasto            VARCHAR2 (60 CHAR) NOT NULL,
  id_kraju          NUMBER (4) NOT NULL REFERENCES kraje(id_kraju)
);

DROP TABLE adresy PURGE;

FLASHBACK TABLE adresy TO BEFORE DROP;
```

Po dodaniu klauzuli PURGE przy wywołaniu DROP TABLE, tabela jest usuwana bez powrotnie i próba przywrócenia tabeli z RECYCLE BIN się nie powiedzie.

```
Error starting at line : 86 in command -
FLASHBACK TABLE adresy TO BEFORE DROP
Error report -
SQL Error: ORA-38305: obiekt nie znajduje się w RECYCLE BIN
38305. 00000 -  "object not in RECYCLE BIN"
*Cause:    Trying to Flashback Drop an object which is not in RecycleBin.
*Action:   Only the objects in RecycleBin can be Flashback Dropped.
```
