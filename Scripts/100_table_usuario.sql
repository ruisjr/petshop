drop table petshop.usuario;

create table petshop.usuario(
	id	  				integer       not null,
    nome  				varchar(150)  not null,
    senha 				varchar(8)    not null,
    data_ultimo_acesso  datetime,
    email				varchar(150),
    bloqueado			boolean		  not null 	default true,
    ativo				boolean		  not null	default false,
    primeiro_acesso		boolean		  not null  default true	
);
    
alter table petshop.usuario add constraint pk_usuario_id primary key(id);
select * from petshop.usuario;