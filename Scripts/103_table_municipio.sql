DROP TABLE IF EXISTS municipio;
DROP SEQUENCE IF EXISTS municipio_seq;

CREATE SEQUENCE municipio_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE municipio (
     id             integer NOT NULL
    ,cod_ibge       integer NOT NULL
    ,macro_regiao   integer
    ,nome           varchar(100) NOT NULL
    ,cod_pais       integer
    ,uf             varchar(2) NOT NULL
);
    
ALTER TABLE municipio ADD CONSTRAINT pk_municipio PRIMARY KEY (id);
CREATE UNIQUE INDEX idx_municipio ON municipio (cod_ibge);

SELECT * FROM municipio WHERE UPPER(nome) = 'RIBEIRÃO PRETO' ORDER BY nome asc;
SELECT * FROM pais;