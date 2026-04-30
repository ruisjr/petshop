create table petshop.cliente(
	id				integer 		not null,
    nome			varchar(100) 	not null,
    cpf_cnpj		varchar(14)		not null,
    data_nascimento	datetime		null,
    data_cadastro	datetime 		not null 	default now(),
    tipo_pessoa		integer			not null	default 0    
);

alter table petshop.cliente add CONSTRAINT chk_tipo_pessoa CHECK (tipo_pessoa IN (0, 1));
alter table petshop.cliente add constraint pk_cliente_id primary key (id);
alter table petshop.cliente add index idx_cliente(id, nome);