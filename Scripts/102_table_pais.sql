DROP TABLE IF EXISTS pais;
DROP SEQUENCE IF EXISTS pais_seq;

CREATE SEQUENCE pais_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE pais(
    id          integer         not null,
    cod_ibge    integer         not null,
    nome        varchar(100)    not null
);

ALTER TABLE pais add constraint pk_pais_id primary key (id);
CREATE UNIQUE INDEX idx_pais ON pais (cod_ibge);

SELECT * FROM pais;