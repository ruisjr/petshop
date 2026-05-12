DROP TABLE IF EXISTS estado;
DROP SEQUENCE IF EXISTS estado_seq;

CREATE SEQUENCE estado_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE estado(
    id          integer         NOT NULL,
    cod_ibge    integer         NOT NULL,
    sigla       varchar(2)      NOT NULL 
);

ALTER TABLE estado ADD CONSTRAINT pk_estado_id primary key (id);
CREATE UNIQUE INDEX idx_estado ON estado (cod_ibge, sigla);

SELECT * FROM estado;