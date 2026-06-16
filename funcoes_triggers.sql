--trigger e função verificar conflito no momento de agendar consulta
CREATE OR REPLACE FUNCTION fn_verificar_conflito_consulta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'cancelada' THEN
        RETURN NEW;
    END IF;
	
    IF EXISTS (
        SELECT 1 
        FROM consulta 
        WHERE id_alocacao_medico = NEW.id_alocacao_medico 
          AND data_consulta = NEW.data_consulta 
          AND hora_consulta = NEW.hora_consulta
          AND status <> 'cancelada' -- Consultas canceladas não geram conflito
          AND id_consulta IS DISTINCT FROM NEW.id_consulta -- Ignora a si mesma em caso de UPDATE
    ) THEN
        RAISE EXCEPTION 'Conflito de Agenda Médica: Já existe uma consulta marcada para este médico no dia % às %.', 
            NEW.data_consulta, NEW.hora_consulta;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM consulta 
        WHERE cpf_paciente = NEW.cpf_paciente 
          AND data_consulta = NEW.data_consulta 
          AND hora_consulta = NEW.hora_consulta
          AND status <> 'cancelada'
          AND id_consulta IS DISTINCT FROM NEW.id_consulta
    ) THEN
        RAISE EXCEPTION 'Conflito de Paciente: O paciente (CPF: %) já possui outra consulta agendada exatamente para este mesmo dia e horário.', 
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
          AND horario = NEW.horario
          AND id_alocacao_medico IS DISTINCT FROM NEW.id_alocacao_medico
    ) THEN
        RAISE EXCEPTION 'Conflito de Consultório: A sala % já está reservada para este dia (%) e horário (%).', 
            NEW.id_consultorio, NEW.data_alocacao, NEW.horario;
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM alocacao_medico 
        WHERE crm = NEW.crm 
          AND data_alocacao = NEW.data_alocacao 
          AND horario = NEW.horario
          AND id_alocacao_medico IS DISTINCT FROM NEW.id_alocacao_medico
    ) THEN
        RAISE EXCEPTION 'Conflito de Médico: O médico (CRM: %) já possui alocação em outro consultório exatamente para este mesmo dia e horário.', 
            NEW.crm;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_conflito_alocacao
BEFORE INSERT OR UPDATE ON alocacao_medico
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_conflito_alocacao();


--trigger para verificar quem cancelou a consulta
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
            CURRENT_USER
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