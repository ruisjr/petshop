DROP TABLE IF EXISTS especie;
DROP SEQUENCE IF EXISTS especie_seq;

CREATE SEQUENCE especie_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE especie(
    id          integer         NOT NULL,
    descricao   varchar(100)    NOT NULL
);

ALTER TABLE especie ADD CONSTRAINT pk_especie_id PRIMARY KEY (id);

INSERT INTO especie VALUES (nextval('especie_seq'), 'CACHORRO');
INSERT INTO especie VALUES (nextval('especie_seq'), 'GATO');
INSERT INTO especie VALUES (nextval('especie_seq'), 'AVE');

SELECT * FROM especie;


SELECT id, nome, porte, pelagem, id_especie   FROM especie WHERE id = :PAR_id LIMIT 1

DROP TABLE IF EXISTS raca;
DROP SEQUENCE IF EXISTS raca_seq;

CREATE SEQUENCE raca_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE raca(
    id          integer         not null,
    id_especie  integer         not null,
    nome        varchar(50)     not null,
    pelagem     varchar(100)    not null,
    porte       varchar(1)      not null
);

ALTER TABLE raca ADD CONSTRAINT CHK_Porte CHECK (Porte IN ('P', 'M', 'G'));
ALTER TABLE raca ADD CONSTRAINT pk_raca_id PRIMARY KEY (id);
ALTER TABLE raca ADD CONSTRAINT fk_raca_especie_id FOREIGN KEY (id_especie) REFERENCES especie(id);
ALTER TABLE raca ADD CONSTRAINT chk_pelagem CHECK (pelagem IN ('CURTO', 'MEDIO', 'LONGO'));
CREATE UNIQUE INDEX idx_raca ON usuario (id, nome);

INSERT INTO raca VALUES (nextval('raca_seq'), 8, 'SHITZU', 'CURTO', 'P');

SELECT * FROM raca;

