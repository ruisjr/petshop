DROP TABLE IF EXISTS usuario;
DROP SEQUENCE IF EXISTS usuario_seq;

CREATE SEQUENCE usuario_seq
	start 1 
	increment 1 
	NO MAXVALUE CACHE 1;

CREATE TABLE usuario(
	id                 integer       NOT NULL,
	nome               varchar(150)  NOT NULL,
	login              varchar(30)   NOT NULL,
	senha              varchar(8)    NOT NULL,
	data_cadastro      timestamp     NOT NULL DEFAULT CURRENT_DATE,
	data_ultimo_acesso timestamp,
	email              varchar(150),
	bloqueado          boolean		  NOT NULL 	DEFAULT TRUE,
	ativo              boolean		  NOT NULL	DEFAULT FALSE,
	primeiro_acesso    boolean		  NOT NULL  DEFAULT TRUE	
);
    
ALTER TABLE usuario ADD CONSTRAINT pk_usuario_id PRIMARY KEY(id);
CREATE UNIQUE INDEX idx_usuario ON usuario (id);

insert into usuario values (nextval('usuario_seq'), 'RUI', 'RUISJR', 'SENHA', current_date, current_date, 'ruisjr2005@gmail.com', false, true, false);

SELECT * FROM usuario;