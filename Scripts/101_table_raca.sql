DROP TABLE IF EXISTS especie;
DROP SEQUENCE IF EXISTS especie_seq;

CREATE SEQUENCE especie_seq
	start 1 
	increment 1 
	NO MAXVALUE CACHE 1;

create table especie(
	id			integer			not null,
    descricao	varchar(100)	not null
);
alter table especie add constraint pk_especie_id primary key (id);


DROP TABLE IF EXISTS raca;
DROP SEQUENCE IF EXISTS raca_seq;

CREATE SEQUENCE racao_seq
	start 1 
	increment 1 
	NO MAXVALUE CACHE 1;


create table raca(
	id			integer 		not null,
    id_especie  integer			not null,
    nome		integer 		not null,
    pelagem		varchar(100) 	not null,
    porte		varchar(2)		not null
);

alter table raca add CONSTRAINT CHK_Porte CHECK (Porte IN ('P', 'M', 'G'));
alter table raca add constraint pk_raca_id primary key (id);
alter table raca add constraint fk_raca_especie_id foreign key (id_especie) references especie(id);
alter table raca add index idx_raca(id, nome);