CREATE OR REPLACE FUNCTION fn_verificar_conflito_consulta()
RETURNS TRIGGER AS $$
DECLARE
    v_data_alocacao DATE;
    v_entrada TIME;
    v_saida TIME;
BEGIN
    IF NEW.status = 'cancelada' THEN
        RETURN NEW;
    END IF;

    SELECT data_alocacao, horario_entrada, horario_saida
    INTO v_data_alocacao, v_entrada, v_saida
    FROM alocacao_medico
    WHERE id_alocacao_medico = NEW.id_alocacao_medico;

    IF EXISTS (
        SELECT 1 
        FROM consulta 
        WHERE id_alocacao_medico = NEW.id_alocacao_medico 
          AND status <> 'cancelada' 
          AND id_consulta IS DISTINCT FROM NEW.id_consulta
    ) THEN
        RAISE EXCEPTION 'Conflito de Agenda: Este slot médico (Alocação %) já está ocupado por outro paciente.', 
            NEW.id_alocacao_medico;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM consulta c
        INNER JOIN alocacao_medico am ON c.id_alocacao_medico = am.id_alocacao_medico
        WHERE c.cpf_paciente = NEW.cpf_paciente 
          AND am.data_alocacao = v_data_alocacao 
          AND am.horario_entrada < v_saida
          AND am.horario_saida > v_entrada
          AND c.status <> 'cancelada'
          AND c.id_consulta IS DISTINCT FROM NEW.id_consulta
    ) THEN
        RAISE EXCEPTION 'Conflito de Paciente: O paciente (CPF: %) já tem outra consulta marcada que conflita com este horário.', 
            NEW.cpf_paciente;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_conflito_consulta
BEFORE INSERT OR UPDATE ON consulta
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_conflito_consulta();

--trigger e função para verificar conflito quanto a alocação do médico
CREATE OR REPLACE FUNCTION fn_verificar_conflito_alocacao()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM alocacao_medico 
        WHERE id_consultorio = NEW.id_consultorio 
          AND data_alocacao = NEW.data_alocacao 
          AND horario_entrada < NEW.horario_saida
          AND horario_saida > NEW.horario_entrada
          AND id_alocacao_medico IS DISTINCT FROM NEW.id_alocacao_medico
    ) THEN
        RAISE EXCEPTION 'Conflito de Consultório: A sala % já está reservada para este dia (%) neste intervalo de tempo.', 
            NEW.id_consultorio, NEW.data_alocacao;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM alocacao_medico 
        WHERE crm = NEW.crm 
          AND data_alocacao = NEW.data_alocacao 
          AND horario_entrada < NEW.horario_saida
          AND horario_saida > NEW.horario_entrada
          AND id_alocacao_medico IS DISTINCT FROM NEW.id_alocacao_medico
    ) THEN
        RAISE EXCEPTION 'Conflito de Médico: O médico (CRM: %) já possui alocação em outro consultório neste mesmo intervalo.', 
            NEW.crm;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_conflito_alocacao
BEFORE INSERT OR UPDATE ON alocacao_medico
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_conflito_alocacao();


-- trigger para verificar quem cancelou a consulta
CREATE OR REPLACE FUNCTION fn_auditar_cancelamento_consulta()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'cancelada' THEN
        INSERT INTO auditoria_cancelamento (
            id_consulta, 
            cpf_paciente, 
            data_cancelamento, 
            usuario_responsavel
        )
        VALUES (
            NEW.id_consulta, 
            NEW.cpf_paciente, 
            CURRENT_TIMESTAMP, 
            CONCAT(CURRENT_USER, ' via ', COALESCE(NULLIF(current_setting('application_name', true), ''), 'Terminal/Aplicação'))
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_auditar_cancelamento
AFTER UPDATE ON consulta
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cancelamento_consulta();

-- trigger para atualizar o faturamento gerencial automaticamente
CREATE OR REPLACE FUNCTION fn_atualizar_mvw_faturamento()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mvw_faturamento_gerencial;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_atualizar_faturamento
AFTER UPDATE ON consulta
FOR EACH ROW
WHEN (NEW.status = 'realizada')
EXECUTE FUNCTION fn_atualizar_mvw_faturamento();