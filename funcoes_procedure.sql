-- Paciente --
create or replace procedure inserir_paciente(
	p_cpf char(11),
    p_nome varchar,
    p_data_nascimento date,
    p_telefone varchar,
    p_email varchar,
    p_id_endereco integer,
    p_id_plano_saude integer
)
language plpgsql as $$
begin
	insert into paciente (cpf, nome, data_nascimento, telefone, email, id_endereco, id_plano_saude)
	values (p_cpf, p_nome, p_data_nascimento, p_telefone, p_email, p_id_endereco, p_id_plano_saude)
end;
$$;

create or replace procedure atualizar_paciente(
    p_cpf char(11),
    p_novo_nome varchar,
    p_novo_telefone varchar,
    p_novo_email varchar,
    p_novo_id_plano_saude integer
)
language plpgsql as $$
begin
    update paciente 
    set nome = p_novo_nome,
        telefone = p_novo_telefone,
        email = p_novo_email,
        id_plano_saude = p_novo_id_plano_saude
    where cpf = p_cpf;
end;
$$;

create or replace procedure deletar_paciente(p_cpf char(11))
language plpgsql as $$
begin
    delete from paciente where cpf = p_cpf;
end;
$$;


-- Médico --
create or replace procedure inserir_medico(
    p_crm varchar,
    p_nome varchar,
    p_id_especialidade integer
)
language plpgsql as $$
begin
    insert into medico (crm, nome, id_especialidade)
    values (p_crm, p_nome, p_id_especialidade);
end;
$$;

create or replace procedure atualizar_medico(
    p_crm varchar,
    p_novo_nome varchar,
    p_nova_especialidade integer
)
language plpgsql as $$
begin
    update medico 
    set nome = p_novo_nome,
        id_especialidade = p_nova_especialidade
    where crm = p_crm;
end;
$$;

create or replace procedure deletar_medico(p_crm VARCHAR)
language plpgsql as $$
begin
    delete from medico where crm = p_crm;
end;
$$;


-- Atendente --
create or replace procedure inserir_atendente(
    p_nome varchar(50),
    p_expediente varchar(25),
    p_salario float
)
language plpgsql as $$
begin
    insert into atendente (nome, expediente, salario)
    values (p_nome, p_expediente, p_salario);
end;
$$;

create or replace procedure reajustar_salario_atendente(
    p_id_atendente integer,
    p_novo_salario float
)
language plpgsql as $$
begin
    update atendente 
    set salario = p_novo_salario
    where id_atendente = p_id_atendente;
end;
$$;


-- Consulta --
create or replace procedure agendar_consulta(
    p_data date,
    p_hora time,
    p_status varchar,
    p_diagnostico varchar(100),
    p_cpf char(11),
    p_id_alocacao_medico integer,
    p_id_forma_pagamento integer,
    p_id_atendente integer,
    p_id_plano_saude integer
)
language plpgsql as $$
begin
    insert into consulta (data, hora, status, diagnostico, cpf, id_alocacao_medico, id_forma_pagamento, id_atendente, id_plano_saude)
    values (p_data, p_hora, p_status, p_diagnostico, p_cpf, p_id_alocacao_medico, p_id_forma_pagamento, p_id_atendente, p_id_plano_saude);
end;
$$;

create or replace procedure encerrar_consulta(
    p_id_consulta integer,
    p_diagnostico varchar(100)
)
language plpgsql as $$
begin
    update consulta 
    set status = 'realizada',
		diagnostico = p_diagnostico
    where id_consulta = p_id_consulta;
end;
$$;

create or replace procedure cancelar_consulta(
    p_id_consulta integer
)
language plpgsql as $$
begin
    update consulta 
    set status = 'cancelada',
        diagnostico = 'consulta cancelada'
    where id_consulta = p_id_consulta;
end;
$$;


-- Plano de Saúde --
create or replace procedure inserir_plano_saude(
    p_nome varchar(25)
)
language plpgsql as $$
begin
    insert into plano_saude (nome)
    values (p_nome);
end;
$$;


-- Alocação Médico --
create or replace procedure inserir_alocacao_medico(
    p_id_consultorio integer,
    p_crm varchar(10)
)
language plpgsql as $$
begin
    insert into alocacao_medico (id_consultorio, crm)
    values (p_id_consultorio, p_crm);
end;
$$;

create or replace procedure deletar_alocacao_medico(
    p_id_alocacao_medico integer
)
language plpgsql as $$
begin
    delete from alocacao_medico 
    where id_alocacao_medico = p_id_alocacao_medico;
end;
$$;


-- Médico Plano --
create or replace procedure inserir_medico_plano(
    p_crm varchar(10),
    p_id_plano_saude integer
)
language plpgsql as $$
begin
    insert into medico_plano (crm, id_plano_saude)
    values (p_crm, p_id_plano_saude);
end;
$$;

create or replace procedure deletar_medico_plano(
    p_crm varchar(10),
    p_id_plano_saude integer
)
language plpgsql as $$
begin
    delete from medico_plano 
    where crm = p_crm and id_plano_saude = p_id_plano_saude;
end;
$$;