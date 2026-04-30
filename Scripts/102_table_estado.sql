drop table petshop.estado;

create table petshop.estado(
	id			integer 		not null,
    cod_ibge	integer 		not null,
    sigla		varchar(2) 	    not null
);

alter table petshop.estado add constraint pk_estado_id primary key (id);
alter table petshop.estado add index idx_estado (cod_ibge, sigla);