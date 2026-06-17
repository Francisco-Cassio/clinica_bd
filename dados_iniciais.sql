insert into forma_pagamento (nome) values 
('pix'),
('cartão de crédito'),
('cartão de débito'),
('dinheiro');

insert into consultorio (num, andar) values 
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(1, 2),
(2, 2),
(3, 2),
(4, 2);

insert into especialidade (nome_especialidade, valor_consulta) values 
('clínico geral', 150.00),
('cardiologia', 250.00),
('pediatria', 200.00),
('ortopedia', 220.00);

insert into endereco (num_casa, rua, bairro, cidade, estado) values
(123, 'rua das flores', 'centro', 'timon', 'MA'),
(456, 'avenida piauí', 'são benedito', 'timon', 'MA');

insert into plano_saude (nome) values ('particular');