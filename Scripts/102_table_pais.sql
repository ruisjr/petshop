create table petshop.pais(
	id			integer 		not null,
    cod_ibge	integer 		not null,
    nome		varchar(100) 	not null
);

alter table petshop.pais add constraint pk_pais_id primary key (id);
alter table petshop.pais add index idx_pais (cod_ibge);    