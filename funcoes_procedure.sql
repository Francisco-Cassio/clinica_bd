-- procedures para inserir/atualizar/deletar paciente
CREATE OR REPLACE PROCEDURE prcd_inserir_paciente(
    p_cpf CHAR(11), 
	p_nome VARCHAR, 
	p_data_nascimento DATE, 
	p_telefone VARCHAR, 
	p_email VARCHAR, 
	p_id_plano_saude INTEGER,
    p_num_casa INTEGER, 
	p_rua VARCHAR, 
	p_bairro VARCHAR, 
	p_cidade VARCHAR, 
	p_estado VARCHAR
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
DECLARE
    v_id_endereco INTEGER;
BEGIN
    IF trim(p_nome) = '' OR p_nome IS NULL THEN 
			RAISE EXCEPTION 'O nome do paciente é obrigatório.'; 
	END IF;
	
    IF trim(p_telefone) = '' OR p_telefone IS NULL THEN 
		RAISE EXCEPTION 'O telefone de contato é obrigatório.'; 
	END IF;
    IF trim(p_bairro) = '' OR p_bairro IS NULL OR trim(p_cidade) = '' OR p_cidade IS NULL OR trim(p_estado) = '' 
	OR p_estado IS NULL THEN
        RAISE EXCEPTION 'Bairro, cidade e estado do endereço são de preenchimento obrigatório.';
    END IF;

    IF length(p_cpf) <> 11 	OR p_cpf IS NULL THEN
		RAISE EXCEPTION 'CPF inválido. O documento deve ter exatamente 11 dígitos.'; 
	END IF;
    IF p_data_nascimento > CURRENT_DATE THEN 
		RAISE EXCEPTION 'A data de nascimento não pode estar no futuro.'; 
	END IF;

    INSERT INTO endereco(num_casa, rua, bairro, cidade, estado)
    VALUES(p_num_casa, p_rua, p_bairro, p_cidade, p_estado)
    RETURNING id_endereco INTO v_id_endereco;
    
    INSERT INTO paciente (cpf, nome, data_nascimento, telefone, email, id_endereco, id_plano_saude)
    VALUES (p_cpf, p_nome, p_data_nascimento, p_telefone, p_email, v_id_endereco, coalesce(p_id_plano_saude, 1));
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_atualizar_paciente(
    p_cpf CHAR(11), 
	p_nome VARCHAR, 
	p_data_nascimento DATE, 
	p_telefone VARCHAR, 
	p_email VARCHAR, 
	p_id_plano_saude INTEGER,
    p_num_casa INTEGER, 
	p_rua VARCHAR, 
	p_bairro VARCHAR, 
	p_cidade VARCHAR, 
	p_estado VARCHAR
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
DECLARE
    v_id_endereco_atual INTEGER;
    v_total_usuarios_endereco INTEGER;
    v_id_novo_endereco INTEGER;
BEGIN
	IF length(p_cpf) <> 11  OR p_cpf IS NULL THEN
		RAISE EXCEPTION	'Informe o CPF do paciente';
	END IF;
    IF trim(p_nome) = '' OR p_nome IS NULL THEN 
		RAISE EXCEPTION 'O nome do paciente é obrigatório.'; 
	END IF;
	
    IF trim(p_telefone) = '' OR p_telefone IS NULL THEN 
		RAISE EXCEPTION 'O telefone de contato é obrigatório.'; 
	END IF;
	
    IF trim(p_bairro) = '' OR p_bairro IS NULL OR trim(p_cidade) = '' OR p_cidade IS NULL OR trim(p_estado) = '' 
	OR p_estado IS NULL THEN
        RAISE EXCEPTION 'Bairro, cidade e estado do endereço são de preenchimento obrigatório.';
    END IF;
	
    IF p_data_nascimento > CURRENT_DATE THEN 
		RAISE EXCEPTION 'A data de nascimento não pode estar no futuro.'; 
	END IF;

    SELECT id_endereco INTO v_id_endereco_atual FROM paciente WHERE cpf = p_cpf;
    IF v_id_endereco_atual IS NULL THEN 
		RAISE EXCEPTION 'Paciente com CPF % não encontrado.', p_cpf; 
	END IF;

    SELECT COUNT(*) INTO v_total_usuarios_endereco FROM paciente WHERE id_endereco = v_id_endereco_atual;

    IF v_total_usuarios_endereco > 1 THEN
        INSERT INTO endereco(num_casa, rua, bairro, cidade, estado)
        VALUES(p_num_casa, p_rua, p_bairro, p_cidade, p_estado)
        RETURNING id_endereco INTO v_id_novo_endereco;
        
        UPDATE paciente 
        SET nome = p_nome, 
            data_nascimento = p_data_nascimento, 
            telefone = p_telefone, 
            email = p_email, 
            id_plano_saude = p_id_plano_saude,
            id_endereco = v_id_novo_endereco
        WHERE cpf = p_cpf;
    ELSE
        UPDATE endereco 
        SET num_casa = p_num_casa, 
            rua = p_rua, 
            bairro = p_bairro, 
            cidade = p_cidade, 
            estado = p_estado 
		WHERE id_endereco = v_id_endereco_atual;

        UPDATE paciente 
        SET nome = p_nome, 
            data_nascimento = p_data_nascimento, 
            telefone = p_telefone, 
            email = p_email, 
            id_plano_saude = p_id_plano_saude 
		WHERE cpf = p_cpf;
    END IF;
END;
$$;



-- Procedures para inserir/atualizar/deletar médico
CREATE OR REPLACE PROCEDURE prcd_inserir_medico(
	p_crm VARCHAR, 
	p_nome VARCHAR, 
	p_id_especialidade INTEGER
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
    IF trim(p_nome) = '' OR p_nome IS NULL THEN 
		RAISE EXCEPTION 'O nome do médico não pode estar vazio.'; 
	END IF;
    IF trim(p_crm) = '' OR p_crm IS NULL THEN 
		RAISE EXCEPTION 'O CRM é de preenchimento obrigatório.'; 
	END IF;

    INSERT INTO medico (crm, nome, id_especialidade) VALUES (p_crm, p_nome, p_id_especialidade);
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_atualizar_medico(
	p_crm VARCHAR, 
	p_nome VARCHAR, 
	p_id_especialidade INTEGER
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
    IF trim(p_nome) = '' OR p_nome IS NULL THEN 
		RAISE EXCEPTION 'O nome do médico não pode estar vazio.'; 
	END IF;
	
    UPDATE medico SET nome = p_nome, id_especialidade = p_id_especialidade WHERE crm = p_crm;
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_deletar_medico(p_crm VARCHAR)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
	IF trim(p_crm) = '' OR p_crm IS NULL THEN
		RAISE EXCEPTION 'Por favor, preencha os campos necessários';
	END IF;
	
    DELETE FROM medico WHERE crm = p_crm;
END;
$$;


-- Procedures para inserir/atualizar/deletar atendente
CREATE OR REPLACE PROCEDURE prcd_inserir_atendente(
	p_nome VARCHAR, 
	p_expediente CHAR(1), 
	p_salario NUMERIC
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
    IF trim(p_nome) = '' OR p_nome IS NULL THEN 
		RAISE EXCEPTION 'O nome do atendente é obrigatório.'; 
	END IF;
	
    IF lower(p_expediente) NOT IN ('m', 'v') OR p_expediente IS NULL THEN
		RAISE EXCEPTION 'Expediente inválido. Use m (manhã) ou v (vespertino).'; 
	END IF;
	
    IF p_salario <= 0 OR p_salario IS NULL THEN 
		RAISE EXCEPTION 'O salário deve ser maior que zero.'; 
	END IF;

    INSERT INTO atendente (nome, expediente, salario) VALUES (p_nome, lower(p_expediente), p_salario);
END;
$$;

CREATE OR REPLACE PROCEDURE prcd_reajustar_salario_atendente(
    p_id_atendente INTEGER,
    p_novo_salario FLOAT	
)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
	IF p_novo_salario <= 0 THEN
		RAISE EXCEPTION 'Insira um salário válido';
	END IF;
	
    UPDATE atendente 
    SET salario = p_novo_salario
    WHERE id_atendente = p_id_atendente;
end;
$$;


CREATE OR REPLACE PROCEDURE prcd_reajustar_expediente_atendente(
	p_id_atendente INTEGER,
	p_novo_expediente CHAR(1)
)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
	IF p_novo_expediente NOT IN ('m', 'v') OR p_novo_expediente IS NULL THEN
		RAISE EXCEPTION 'Informe um expediente válido';
	END IF;

	UPDATE atendente
	SET expediente = p_novo_expediente
	WHERE id_atendente = p_id_atendente;
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_deletar_atendente(p_id_atendente INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
	IF p_id_atendente IS NULL OR p_id_atendente <= 0 THEN
		RAISE EXCEPTION 'Informe um id válido';
	END IF;

	DELETE FROM atendente WHERE id_atendente = p_id_atendente;
END;
$$;


-- Procedures para agendar/encerrar/cancelar consulta
CREATE OR REPLACE PROCEDURE prcd_agendar_consulta(
    p_cpf_paciente CHAR(11),
    p_id_alocacao_medico INTEGER,
    p_id_forma_pagamento INTEGER,
    p_id_atendente INTEGER
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
DECLARE
    v_data_alocacao DATE;
    v_valor_atual NUMERIC;
BEGIN
    IF p_cpf_paciente IS NULL OR length(p_cpf_paciente) <> 11 THEN
        RAISE EXCEPTION 'O CPF do paciente é obrigatório e deve conter 11 dígitos.';
    END IF;

    IF p_id_alocacao_medico IS NULL OR p_id_alocacao_medico <= 0 OR
       p_id_forma_pagamento IS NULL OR p_id_forma_pagamento <= 0 OR
       p_id_atendente IS NULL OR p_id_atendente <= 0 THEN
	   		RAISE EXCEPTION 'Os IDs de alocação, forma de pagamento e atendente devem ser informados e válidos.';
    END IF;

    SELECT am.data_alocacao, e.valor_consulta 
    INTO v_data_alocacao, v_valor_atual
    FROM alocacao_medico am
    INNER JOIN medico m ON am.crm = m.crm
    INNER JOIN especialidade e ON m.id_especialidade = e.id_especialidade
    WHERE am.id_alocacao_medico = p_id_alocacao_medico;

    IF v_data_alocacao IS NULL THEN
        RAISE EXCEPTION 'A alocação médica informada (ID %) não existe no sistema.', p_id_alocacao_medico;
    END IF;

    IF v_data_alocacao < CURRENT_DATE THEN
        RAISE EXCEPTION 'Não é possível agendar consultas para alocações em datas que já passaram.';
    END IF;

    INSERT INTO consulta (
        status, diagnostico, 
        cpf_paciente, id_alocacao_medico, id_forma_pagamento, id_atendente, valor_pago
    )
    VALUES (
        'agendada', NULL, 
        p_cpf_paciente, p_id_alocacao_medico, p_id_forma_pagamento, p_id_atendente, v_valor_atual
    );
END;
$$;

CREATE OR REPLACE PROCEDURE prcd_encerrar_consulta(
    p_id_consulta INTEGER,
    p_diagnostico VARCHAR
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
    IF p_id_consulta IS NULL OR p_id_consulta <= 0 THEN
        RAISE EXCEPTION 'Informe um ID de consulta válido.';
    END IF;

    IF trim(p_diagnostico) = '' OR p_diagnostico IS NULL THEN
        RAISE EXCEPTION 'A consulta não pode ser encerrada sem um diagnóstico válido preenchido.';
    END IF;

    UPDATE consulta 
    SET status = 'realizada',
        diagnostico = p_diagnostico
    WHERE id_consulta = p_id_consulta;
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_cancelar_consulta(
    p_id_consulta INTEGER
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
    IF p_id_consulta IS NULL OR p_id_consulta <= 0 THEN
        RAISE EXCEPTION 'Informe um ID de consulta válido.';
    END IF;

    UPDATE consulta 
    SET status = 'cancelada', diagnostico = 'Consulta cancelada.'
    WHERE id_consulta = p_id_consulta;
END;
$$;


--Procedure para inserir/deletar plano de saúde
CREATE OR REPLACE PROCEDURE prcd_inserir_plano_saude(p_nome varchar(25))
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
	IF trim(p_nome) = '' OR p_nome IS NULL THEN
		RAISE EXCEPTION 'Informe o nome do plano de saúde';
	END IF;
	
    INSERT INTO plano_saude (nome) VALUES (p_nome);
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_deletar_plano_saude(p_id_plano_saude INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
	IF p_id_plano_saude <= 0 OR p_id_plano_saude IS NULL THEN
		RAISE EXCEPTION 'Informe um plano de saude válido!';
	END IF;

	DELETE FROM plano_saude WHERE id_plano_saude = p_id_plano_saude;
END;
$$;


-- Procedure para alocar médicos
CREATE OR REPLACE PROCEDURE prcd_inserir_alocacao_medico(
    p_data_alocacao DATE,
    p_horario_entrada TIME,
    p_horario_saida TIME,
    p_id_consultorio INTEGER,
    p_crm VARCHAR
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
    IF trim(p_crm) = '' OR p_crm IS NULL THEN
        RAISE EXCEPTION 'Informe um CRM válido.';
    END IF;

    IF p_id_consultorio <= 0 OR p_id_consultorio IS NULL THEN
        RAISE EXCEPTION 'Informe um ID de consultório válido.';
    END IF;

    IF p_data_alocacao IS NULL OR p_horario_entrada IS NULL OR p_horario_saida IS NULL THEN
    	RAISE EXCEPTION 'A data e os horários da alocação são obrigatórios.';
	END IF;

	IF p_horario_saida <= p_horario_entrada THEN
		RAISE EXCEPTION 'O horário de saída não pode ser menor ou igual ou horário de entrada!';
	END IF;

    IF p_data_alocacao < CURRENT_DATE THEN
        RAISE EXCEPTION 'Não é possível alocar um médico para uma data no passado.';
    END IF;
    
    INSERT INTO alocacao_medico (data_alocacao, horario_entrada, horario_saida, id_consultorio, crm) 
    VALUES (p_data_alocacao, p_horario_entrada, p_horario_saida, p_id_consultorio, p_crm);
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_deletar_alocacao_medico(p_id_alocacao_medico INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
    IF p_id_alocacao_medico <= 0 OR p_id_alocacao_medico IS NULL THEN
        RAISE EXCEPTION 'Informe os dados corretamente para realizar a exclusão!';
    END IF;
    
    DELETE FROM alocacao_medico WHERE id_alocacao_medico = p_id_alocacao_medico;
END;
$$;


-- Procedure para ligar médicos aos planos de saúde
CREATE OR REPLACE PROCEDURE prcd_inserir_medico_plano(
    p_crm varchar(10),
    p_id_plano_saude integer
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
	IF trim(p_crm) = '' OR p_crm IS NULL THEN
		RAISE EXCEPTION 'Informe um CRM válido!';
	END IF;

	IF p_id_plano_saude <= 0 OR p_id_plano_saude IS NULL THEN
		RAISE EXCEPTION 'Informe um plano de saúde válido!';
	END IF;
	
    INSERT INTO medico_plano (crm, id_plano_saude) VALUES (p_crm, p_id_plano_saude);
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_deletar_medico_plano(
    p_crm varchar(10),
    p_id_plano_saude integer
)
LANGUAGE plpgsql 
SECURITY DEFINER AS $$
BEGIN
	IF trim(p_crm) = '' OR p_crm IS NULL THEN
		RAISE EXCEPTION 'Informe um CRM válido!';
	END IF;

	IF p_id_plano_saude <= 0 OR p_id_plano_saude IS NULL THEN
		RAISE EXCEPTION 'Informe um plano de saúde válido!';
	END IF;
	
    DELETE FROM medico_plano WHERE crm = p_crm and id_plano_saude = p_id_plano_saude;
END;
$$;


--Procedures para a tabela especialidade
CREATE OR REPLACE PROCEDURE prcd_inserir_especialidade(
	p_nome VARCHAR,
	p_valor NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
	IF trim(p_nome) = '' OR p_nome IS NULL THEN
        RAISE EXCEPTION 'O nome da especialidade é obrigatório.';
    END IF;
    IF p_valor IS NULL OR p_valor <= 0 THEN
        RAISE EXCEPTION 'O valor da consulta deve ser maior que zero.';
    END IF;

    INSERT INTO especialidade (nome_especialidade, valor_consulta) VALUES (p_nome, p_valor);
END;
$$;


CREATE OR REPLACE PROCEDURE prcd_atualizar_valor_especialidade(
	p_id_especialidade INTEGER, 
	p_novo_valor NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
    IF p_id_especialidade IS NULL OR p_id_especialidade <= 0 THEN
        RAISE EXCEPTION 'Informe um ID de especialidade válido.';
    END IF;
    IF p_novo_valor IS NULL OR p_novo_valor <= 0 THEN
        RAISE EXCEPTION 'O novo valor deve ser maior que zero.';
    END IF;

    UPDATE especialidade SET valor_consulta = p_novo_valor WHERE id_especialidade = p_id_especialidade;
END;
$$;


--Procedure para a tabela consultorio
CREATE OR REPLACE PROCEDURE prcd_inserir_consultorio(
	p_num INTEGER, 
	p_andar INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
    IF p_num IS NULL OR p_num <= 0 THEN
        RAISE EXCEPTION 'O número da sala deve ser maior que zero.';
    END IF;
    IF p_andar IS NULL OR p_andar < 0 THEN
        RAISE EXCEPTION 'O andar não pode ser negativo.';
    END IF;

    INSERT INTO consultorio (num, andar) VALUES (p_num, p_andar);
END;
$$;


--Procedure para a tabela forma de pagamento
CREATE OR REPLACE PROCEDURE prcd_inserir_forma_pagamento(p_nome VARCHAR)
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
    IF trim(p_nome) = '' OR p_nome IS NULL THEN
        RAISE EXCEPTION 'O nome da forma de pagamento é obrigatório.';
    END IF;

    INSERT INTO forma_pagamento (nome) VALUES (p_nome);
END;
$$;








