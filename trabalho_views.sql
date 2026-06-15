CREATE OR REPLACE VIEW vw_historico_paciente AS
SELECT 
    p.cpf AS cpf_paciente,
    p.nome AS nome_paciente,
    EXTRACT(YEAR FROM age(CURRENT_DATE, p.data_nascimento)) AS idade,
    c.data_consulta,
    m.nome AS medico_responsavel,
    e.nome_especialidade AS especialidade,
    c.diagnostico
FROM 
    paciente p
INNER JOIN 
    consulta c ON p.cpf = c.cpf_paciente
INNER JOIN 
    alocacao_medico am ON c.id_alocacao_medico = am.id_alocacao_medico
INNER JOIN 
    medico m ON am.crm = m.crm
INNER JOIN 
    especialidade e ON m.id_especialidade = e.id_especialidade
WHERE 
    c.status = 'realizada'
ORDER BY 
    c.data_consulta DESC;

	
CREATE OR REPLACE VIEW vw_agenda_diaria AS
SELECT 
    c.id_consulta,
    c.data_consulta,
    c.hora_consulta,
    p.nome AS nome_paciente,
    p.telefone AS telefone_paciente,
    m.nome AS nome_medico,
    e.nome_especialidade,
    con.num AS numero_sala,
    con.andar,
    c.status
FROM consulta c
INNER JOIN paciente p ON c.cpf_paciente = p.cpf
INNER JOIN alocacao_medico am ON c.id_alocacao_medico = am.id_alocacao_medico
INNER JOIN medico m ON am.crm = m.crm
INNER JOIN especialidade e ON m.id_especialidade = e.id_especialidade
INNER JOIN consultorio con ON am.id_consultorio = con.id_consultorio
ORDER BY c.data_consulta ASC, c.hora_consulta ASC;


CREATE MATERIALIZED VIEW mvw_faturamento_gerencial AS
SELECT 
    EXTRACT(YEAR FROM c.data_consulta) AS ano,
    EXTRACT(MONTH FROM c.data_consulta) AS mes,
    e.nome_especialidade,
    COUNT(c.id_consulta) AS total_consultas_realizadas,
    SUM(e.valor_consulta) AS faturamento_total
FROM consulta c
INNER JOIN alocacao_medico am ON c.id_alocacao_medico = am.id_alocacao_medico
INNER JOIN medico m ON am.crm = m.crm
INNER JOIN especialidade e ON m.id_especialidade = e.id_especialidade
WHERE c.status = 'realizada'
GROUP BY EXTRACT(YEAR FROM c.data_consulta), EXTRACT(MONTH FROM c.data_consulta), e.nome_especialidade
ORDER BY ano DESC, mes DESC, faturamento_total DESC;

REFRESH MATERIALIZED VIEW mvw_faturamento_gerencial;


CREATE OR REPLACE VIEW vw_relatorio_evasao AS
SELECT 
    ac.id_auditoria,
    ac.id_consulta,
    p.nome AS nome_paciente,
    ac.data_cancelamento,
    ac.usuario_responsavel AS usuario_banco_cancelou,
    ate.nome AS atendente_original_agendamento
FROM auditoria_cancelamento ac
INNER JOIN paciente p ON ac.cpf_paciente = p.cpf
INNER JOIN consulta c ON ac.id_consulta = c.id_consulta
INNER JOIN atendente ate ON c.id_atendente = ate.id_atendente
ORDER BY ac.data_cancelamento DESC;


CREATE OR REPLACE VIEW vw_ocupacao_consultorios AS
SELECT 
    con.id_consultorio,
    con.num AS numero_sala,
    con.andar,
    COUNT(am.id_alocacao_medico) AS total_alocacoes_medicas
FROM consultorio con
LEFT JOIN alocacao_medico am ON con.id_consultorio = am.id_consultorio
GROUP BY con.id_consultorio, con.num, con.andar
ORDER BY total_alocacoes_medicas DESC, con.num ASC;
