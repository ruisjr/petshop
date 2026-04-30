create table petshop.municipio(
	id			integer 		not null,
    cod_ibge	integer 		not null,
    nome		varchar(100) 	not null,
    uf			varchar(2)		not null
);

alter table petshop.municipio add constraint pk_municipio_id primary key (id);
alter table petshop.municipio add index idx_municipio(cod_ibge);