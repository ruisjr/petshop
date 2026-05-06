DROP TABLE IF EXISTS pessoa_inf_adic;
DROP SEQUENCE IF EXISTS pessoa_inf_adic_seq;

CREATE SEQUENCE pessoa_inf_adic_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE pessoa_inf_adic(
    id              integer         NOT NULL,
    id_pessoa       integer         NOT NULL,
    endereco        varchar(100),
    numero          integer,
    bairro          varchar(50),
    cidade          varchar(100),
    uf              varchar(2),
    complemento     varchar(50),
    cep             integer,
    cod_ibge_cidade integer    
);

ALTER TABLE pessoa_inf_adic ADD CONSTRAINT pk_pessoa_inf_adic_id PRIMARY KEY (id);
ALTER TABLE pessoa_inf_adic ADD CONSTRAINT fk_pessoa_inf_adic FOREIGN KEY (id_pessoa) REFERENCES pessoa (id);

SELECT * FROM pessoa_inf_adic;