DROP TABLE pracownicy;
DROP TABLE stanowiska;
--DROP TABLE adresy;
DROP TABLE kraje;
DROP TABLE regiony;
DROP TABLE szkolenia;
DROP TABLE zaklady;


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

CREATE TABLE szkolenia
(
  id_szkolenia      NUMBER (4) CONSTRAINT szkolenia_pw PRIMARY KEY,
  nazwa             VARCHAR2 (60 CHAR) NOT NULL
);

ALTER TABLE pracownicy
ADD (
  id_szkolenia      NUMBER (4) REFERENCES szkolenia(id_szkolenia)
);

ALTER TABLE pracownicy
DROP COLUMN data_zatrudnienia;


ALTER TABLE pracownicy ADD CONSTRAINT zaklad_pracownika_fk FOREIGN KEY (id_zakladu)
REFERENCES zaklady (id_zakladu);

DROP TABLE zaklady;

ALTER TABLE pracownicy DROP CONSTRAINT zaklad_pracownika_fk;

DROP TABLE zaklady;

FLASHBACK TABLE zaklady TO BEFORE DROP;

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