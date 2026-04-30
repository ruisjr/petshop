create table petshop.especie(
	id			integer			not null,
    descricao	varchar(100)	not null
);
alter table petshop.especie add constraint pk_especie_id primary key (id);


create table petshop.raca(
	id			integer 		not null,
    id_especie  integer			not null,
    nome		integer 		not null,
    pelagem		varchar(100) 	not null,
    porte		varchar(2)		not null
);

alter table petshop.raca add CONSTRAINT CHK_Porte CHECK (Porte IN ('P', 'M', 'G'));
alter table petshop.raca add constraint pk_raca_id primary key (id);
alter table petshop.raca add constraint fk_raca_especie_id foreign key (id_especie) references petshop.especie(id);
alter table petshop.raca add index idx_raca(id, nome);