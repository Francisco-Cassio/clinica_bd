CREATE ROLE atendente WITH LOGIN PASSWORD 'senhaAtendente2026';
GRANT SELECT ON paciente, medico, consultorio, alocacao_medico, consulta, especialidade TO atendente;

CREATE ROLE medico WITH LOGIN PASSWORD 'senhaMedico2026';
GRANT SELECT ON	paciente, consulta TO medico;

CREATE ROLE gerente WITH LOGIN PASSWORD 'senhaGerente2026';
GRANT SELECT ON atendente, medico, plano_saude, forma_pagamento, especialidade, consultorio to gerente;
GRANT SELECT (id_consulta, data_consulta, hora_consulta, status, cpf_paciente) ON consulta TO gerente;
GRANT SELECT (cpf, nome, data_nascimento) ON paciente TO gerente;


CREATE ROLE dba_clinica WITH LOGIN SUPERUSER PASSWORD 'senhaDBA2026';

REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;