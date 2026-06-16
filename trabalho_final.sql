CREATE TABLE especialidade(
id_especialidade SERIAL NOT NULL PRIMARY KEY,
nome_especialidade VARCHAR NOT NULL,
valor_consulta NUMERIC NOT NULL
);

CREATE TABLE plano_saude(
id_plano_saude SERIAL NOT NULL PRIMARY KEY,
nome VARCHAR NOT NULL
);

CREATE TABLE consultorio(
id_consultorio SERIAL NOT NULL PRIMARY KEY,
num INTEGER,
andar INTEGER
);

CREATE TABLE endereco(
id_endereco SERIAL NOT NULL PRIMARY KEY,
num_casa INTEGER NOT NULL,
rua VARCHAR,
bairro VARCHAR NOT NULL,
cidade VARCHAR NOT NULL,
estado VARCHAR NOT NULL
);

CREATE TABLE atendente(
id_atendente SERIAL NOT NULL PRIMARY KEY,
nome VARCHAR NOT NULL,
expediente CHAR(1) NOT NULL CHECK(expediente='m' or expediente='v'),
salario NUMERIC NOT NULL
);

CREATE TABLE forma_pagamento(
id_forma_pagamento SERIAL NOT NULL PRIMARY KEY,
nome VARCHAR NOT NULL
);

CREATE TABLE medico(
crm VARCHAR NOT NULL PRIMARY KEY,
nome VARCHAR NOT NULL,
id_especialidade INTEGER NOT NULL REFERENCES especialidade(id_especialidade)
);

CREATE TABLE paciente(
cpf CHAR(11) NOT NULL PRIMARY KEY,
nome VARCHAR NOT NULL,
data_nascimento DATE NOT NULL,
telefone VARCHAR NOT NULL,
email VARCHAR,
id_endereco INTEGER NOT NULL REFERENCES endereco(id_endereco),
id_plano_saude INTEGER REFERENCES plano_saude(id_plano_saude)
);

CREATE TABLE medico_plano(
crm VARCHAR NOT NULL REFERENCES medico(crm),
id_plano_saude INTEGER NOT NULL REFERENCES plano_saude(id_plano_saude),
PRIMARY KEY (crm, id_plano_saude)
);

CREATE TABLE alocacao_medico(
id_alocacao_medico SERIAL NOT NULL PRIMARY KEY,
data_alocacao DATE NOT NULL,
horario_entrada TIME NOT NULL,
horario_saida TIME NOT NULL,
id_consultorio INTEGER NOT NULL REFERENCES consultorio(id_consultorio),
crm VARCHAR NOT NULL REFERENCES medico(crm)
);


CREATE TABLE consulta(
id_consulta SERIAL NOT NULL PRIMARY KEY,
cpf_paciente CHAR(11) NOT NULL REFERENCES paciente(cpf),
diagnostico VARCHAR,
status VARCHAR NOT NULL CHECK(status='agendada' OR status='acontecendo' OR status='realizada' or status='cancelada'),
id_atendente INTEGER NOT NULL REFERENCES atendente(id_atendente),
id_forma_pagamento INTEGER NOT NULL REFERENCES forma_pagamento(id_forma_pagamento),
id_alocacao_medico INTEGER NOT NULL REFERENCES alocacao_medico(id_alocacao_medico),
valor_pago NUMERIC(10,2) NOT NULL
);


CREATE TABLE auditoria_cancelamento (
id_auditoria SERIAL PRIMARY KEY,
id_consulta INTEGER NOT null REFERENCES consulta(id_consulta) ON DELETE CASCADE,
cpf_paciente CHAR(11) NOT NULL,
data_cancelamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
usuario_responsavel VARCHAR(50) NOT NULL
);


