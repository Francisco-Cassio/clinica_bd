-- SCRIPT DE APRESENTAÇÃO - BANCO DE DADOS DE CLÍNICA

\echo ''
\echo '============================================================'
\echo '1) VISÃO GERAL DAS TABELAS BÁSICAS'
\echo '============================================================'

SELECT * FROM especialidade;
SELECT * FROM forma_pagamento;
SELECT * FROM consultorio;
SELECT * FROM plano_saude;
select * from atendente;
select * from medico;


\echo ''
\echo '============================================================'
\echo '2) CADASTRO DE FUNCIONÁRIOS E MÉDICOS VIA PROCEDURES'
\echo '============================================================'

-- Cadastro de atendente
CALL prcd_inserir_atendente('Ana Souza', 'm', 1800.00);
call prcd_deletar_atendente(2);

-- Cadastro de médicos
CALL prcd_inserir_medico('CRM001', 'Dr. Carlos Lima', 1);
CALL prcd_inserir_medico('CRM002', 'Dra. Marina Alves', 2); 

SELECT * FROM atendente;

SELECT 
    m.crm,
    m.nome AS medico,
    e.nome_especialidade,
    e.valor_consulta
FROM medico m
JOIN especialidade e ON e.id_especialidade = m.id_especialidade;


\echo ''
\echo '============================================================'
\echo '3) CADASTRO DE PACIENTES VIA PROCEDURE'
\echo '============================================================'

CALL prcd_inserir_paciente(
    '11122233344',
    'João Pereira',
    '1998-05-10',
    '(86) 99999-1111',
    'joao@email.com',
    1,
    100,
    'Rua A',
    'Centro',
    'Timon',
    'MA'
);

CALL prcd_inserir_paciente(
    '55566677788',
    'Maria Oliveira',
    '2001-09-20',
    '(86) 98888-2222',
    'maria@email.com',
    1,
    200,
    'Rua B',
    'Centro',
    'Timon',
    'MA'
);

SELECT 
    p.cpf,
    p.nome,
    p.telefone,
    ps.nome AS plano,
    e.rua,
    e.bairro,
    e.cidade,
    e.estado
FROM paciente p
JOIN plano_saude ps ON ps.id_plano_saude = p.id_plano_saude
JOIN endereco e ON e.id_endereco = p.id_endereco;


\echo ''
\echo '============================================================'
\echo '4) ALOCAÇÃO DE MÉDICOS EM CONSULTÓRIOS'
\echo '============================================================'

-- Alocação de horários futuros
CALL prcd_inserir_alocacao_medico(CURRENT_DATE + 1, '08:00', '09:00', 1, 'CRM001');
CALL prcd_inserir_alocacao_medico(CURRENT_DATE + 1, '09:00', '10:00', 1, 'CRM001');
CALL prcd_inserir_alocacao_medico(CURRENT_DATE + 1, '10:00', '11:00', 2, 'CRM002');

SELECT 
    am.id_alocacao_medico,
    am.data_alocacao,
    am.horario_entrada,
    am.horario_saida,
    c.num AS sala,
    c.andar,
    m.nome AS medico
FROM alocacao_medico am
JOIN consultorio c ON c.id_consultorio = am.id_consultorio
JOIN medico m ON m.crm = am.crm
ORDER BY am.data_alocacao, am.horario_entrada;


\echo ''
\echo '============================================================'
\echo '5) TESTE DE TRIGGER: CONFLITO DE ALOCAÇÃO'
\echo '============================================================'

-- Tentativa deve falha, pois a sala 1 já está ocupada amanhã das 08:00 às 09:00.
DO $$
BEGIN
    CALL prcd_inserir_alocacao_medico(CURRENT_DATE + 1, '08:30', '09:30', 1, 'CRM002');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ERRO ESPERADO: %', SQLERRM;
END $$;


\echo ''
\echo '============================================================'
\echo '6) VERIFICAÇÃO DE HORÁRIOS DISPONÍVEIS'
\echo '============================================================'

SELECT * FROM vw_verificar_disponiveis;


\echo ''
\echo '============================================================'
\echo '7) AGENDAMENTO DE CONSULTA'
\echo '============================================================'

CALL prcd_agendar_consulta('11122233344', 1, 1, 1);

CALL prcd_agendar_consulta('55566677788', 2, 2, 1);

SELECT * FROM vw_agenda_diaria;


\echo ''
\echo '============================================================'
\echo '8) TESTE DE TRIGGER: CONFLITO DE CONSULTA'
\echo '============================================================'

-- Tentativa falha, pois a alocação 1 já foi ocupada por João.
DO $$
BEGIN
    CALL prcd_agendar_consulta('55566677788', 1, 1, 1);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ERRO ESPERADO: %', SQLERRM;
END $$;


\echo ''
\echo '============================================================'
\echo '9) FLUXO DA CONSULTA: AGENDADA -> ACONTECENDO -> REALIZADA'
\echo '============================================================'

CALL prcd_iniciar_consulta(1);

SELECT 
    id_consulta,
    cpf_paciente,
    status,
    diagnostico
FROM consulta
WHERE id_consulta = 1;

CALL prcd_encerrar_consulta(1, 'Paciente com sintomas leves. Prescrito repouso e hidratação.');

SELECT 
    id_consulta,
    cpf_paciente,
    status,
    diagnostico,
    valor_pago
FROM consulta
WHERE id_consulta = 1;


\echo ''
\echo '============================================================'
\echo '10) HISTÓRICO DO PACIENTE'
\echo '============================================================'

SELECT * FROM vw_historico_paciente;


\echo ''
\echo '============================================================'
\echo '11) FATURAMENTO GERENCIAL'
\echo '============================================================'


SELECT * FROM mvw_faturamento_gerencial;


\echo ''
\echo '============================================================'
\echo '12) CANCELAMENTO DE CONSULTA E AUDITORIA'
\echo '============================================================'

-- Cancela a consulta 2, que ainda está agendada.
CALL prcd_cancelar_consulta(2);

SELECT 
    id_consulta,
    cpf_paciente,
    status,
    diagnostico
FROM consulta
ORDER BY id_consulta;

-- A trigger registra automaticamente quem cancelou.
SELECT * FROM auditoria_cancelamento;
SELECT * FROM vw_relatorio_evasao;


\echo ''
\echo '============================================================'
\echo '13) RELATÓRIO DE OCUPAÇÃO DOS CONSULTÓRIOS'
\echo '============================================================'

SELECT * FROM vw_ocupacao_consultorios;


\echo ''
\echo '============================================================'
\echo '14) EXEMPLO DE ATUALIZAÇÃO DE DADOS'
\echo '============================================================'

-- Atualiza dados de um paciente
CALL prcd_atualizar_paciente(
    '11122233344',
    'João Pereira Silva',
    '1998-05-10',
    '(86) 99999-3333',
    'joao.silva@email.com',
    1,
    101,
    'Rua Nova',
    'Centro',
    'Timon',
    'MA'
);

SELECT 
    p.cpf,
    p.nome,
    p.telefone,
    p.email,
    e.num_casa,
    e.rua,
    e.bairro,
    e.cidade,
    e.estado
FROM paciente p
JOIN endereco e ON e.id_endereco = p.id_endereco
WHERE p.cpf = '11122233344';


\echo ''
\echo '============================================================'
\echo '15) DEMONSTRAÇÃO DE PAPÉIS E SEGURANÇA (ROLES)'
\echo '============================================================'

\echo '-- A) SIMULANDO O ACESSO COMO ATENDENTE --'
-- Mudando a sessão para o papel de atendente, e o mesmo pode visualizar pacientes
SET ROLE atendente;
SELECT cpf, nome, telefone FROM paciente LIMIT 2;

-- ERRO: O atendente tentará cadastrar um médico (ação de gerente)
DO $$
BEGIN
    CALL prcd_inserir_medico('CRM999', 'Dr. Teste Invasor', 1);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'BLOQUEIO DE SEGURANÇA FUNCIONANDO (ATENDENTE): %', SQLERRM;
END $$;

-- Voltando a sessão para o administrador/dono do banco
RESET ROLE;

\echo '-- B) SIMULANDO O ACESSO COMO MÉDICO --'
-- Mudando a sessão para o papel de médico
SET ROLE medico;

-- ERRO ESPERADO: O médico tentará agendar uma consulta (ação de atendente)
DO $$
BEGIN
    CALL prcd_agendar_consulta('11122233344', 1, 1, 1);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'BLOQUEIO DE SEGURANÇA FUNCIONANDO (MÉDICO): %', SQLERRM;
END $$;

-- Voltando a sessão para o administrador
RESET ROLE;