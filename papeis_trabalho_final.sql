CREATE ROLE atendente WITH LOGIN PASSWORD 'senhaAtendente2026';
CREATE ROLE medico WITH LOGIN PASSWORD 'senhaMedico2026';
CREATE ROLE gerente WITH LOGIN PASSWORD 'senhaGerente2026';
CREATE ROLE dba_clinica WITH LOGIN SUPERUSER PASSWORD 'senhaDBA2026';

REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

GRANT SELECT ON paciente, medico, consultorio, alocacao_medico, consulta, especialidade, plano_saude, forma_pagamento, endereco TO atendente;
GRANT SELECT, INSERT ON auditoria_cancelamento TO atendente;

GRANT SELECT ON paciente, consulta, alocacao_medico, consultorio TO medico;

GRANT SELECT ON atendente, medico, plano_saude, forma_pagamento, especialidade, consultorio, endereco, auditoria_cancelamento, medico_plano TO gerente;
GRANT SELECT (id_consulta, data_consulta, hora_consulta, status, cpf_paciente) ON consulta TO gerente;
GRANT SELECT (cpf, nome, data_nascimento) ON paciente TO gerente;

GRANT EXECUTE ON PROCEDURE prcd_inserir_paciente, prcd_atualizar_paciente, prcd_deletar_paciente TO atendente;
GRANT EXECUTE ON PROCEDURE prcd_agendar_consulta, prcd_cancelar_consulta TO atendente;
GRANT EXECUTE ON PROCEDURE prcd_encerrar_consulta TO medico;
GRANT EXECUTE ON PROCEDURE prcd_inserir_medico, prcd_atualizar_medico, prcd_deletar_medico TO gerente;
GRANT EXECUTE ON PROCEDURE prcd_inserir_atendente, prcd_reajustar_salario_atendente, prcd_reajustar_expediente_atendente, prcd_deletar_atendente TO gerente;
GRANT EXECUTE ON PROCEDURE prcd_inserir_alocacao_medico, prcd_deletar_alocacao_medico TO gerente;
GRANT EXECUTE ON PROCEDURE prcd_inserir_medico_plano, prcd_deletar_medico_plano TO gerente;
GRANT EXECUTE ON PROCEDURE prcd_inserir_especialidade, prcd_atualizar_valor_especialidade TO gerente;
GRANT EXECUTE ON PROCEDURE prcd_inserir_consultorio, prcd_inserir_forma_pagamento, prcd_inserir_plano_saude, prcd_deletar_plano_saude TO gerente;

GRANT SELECT ON vw_agenda_diaria TO atendente, medico;
GRANT SELECT ON vw_historico_paciente TO medico;
GRANT SELECT ON mvw_faturamento_gerencial, vw_relatorio_evasao, vw_ocupacao_consultorios TO gerente;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO atendente, gerente;