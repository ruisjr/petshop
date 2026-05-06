DROP TABLE IF EXISTS pessoa;
DROP SEQUENCE IF EXISTS pessoa_seq;

CREATE SEQUENCE pessoa_seq
    start 1 
    increment 1 
    NO MAXVALUE CACHE 1;

CREATE TABLE pessoa(
    id              integer         NOT NULL,
    nome            varchar(150)    NOT NULL,
    nome_reduzido   varchar(80),
    cpf_cnpj        varchar(14)     NOT NULL,
    data_nascimento date,
    data_cadastro   date            DEFAULT now(),
    tipo_pessoa     integer         NOT NULL,
    genero          varchar(1),
    estado_civil    varchar(1)
);

ALTER TABLE pessoa ADD CONSTRAINT pk_pessoa_id PRIMARY KEY (id);
ALTER TABLE pessoa ADD CONSTRAINT chk_pessoa_tipo_pessoa CHECK (tipo_pessoa IN (1, 4, 6, 5, 7, 10, 11)); -- 1-Cliente; 4-Fornecedor; 6-Funcionario (5-CLFO; 7-CLFU; 10-FOFU; 11-CLFOFU)
ALTER TABLE pessoa ADD CONSTRAINT chk_pessoa_genero CHECK (genero IN ('M', 'F'));
ALTER TABLE pessoa ADD CONSTRAINT chk_pessoa_estado_civil CHECK (estado_civil IN ('C', 'S', 'D', 'U', 'O')); --Casado, Solteiro, Divorciado, União Estável, Outros

SELECT * FROM pessoa;

