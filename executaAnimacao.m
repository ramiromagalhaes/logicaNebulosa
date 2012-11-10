fisMandani = readfis('caminhao');
fisMandani.name = 'Mandani';
writefis(fisMandani, 'caminhaoMandani');

intervaloX = 10;
intervaloPHI = 10;
    
%gera dados do caminhao a partir do Mandani, com parametro default
dados = geradados(fisMandani, intervaloX, intervaloPHI);

nMFs1 = 3;
nMFs2 = 3;

[fisANFIS, fisBLS, fisRLS, fisGradient] = executaTreinamentos(dados, nMFs1, nMFs2);

figure;

%Universo de discurso da variavel de posicao x
xi=0; xf=100;    
%Universo de discurso da variavel de posicao y
yi=0; yf=100;
    
title('Caminhao');
%
%Definicao do parque de estacionamento
%
Axis = ([xi xf yi yf]);
%
plot([xi xf xf xi xi],[yi yi yf yf yi]);
hold on;

simula_caminhao(fisMandani, 55, 10, 10, 1, 'b');
simula_caminhao(fisANFIS, 55, 10, 10, 1, 'r');
simula_caminhao(fisBLS, 55, 10, 10, 1, 'g');
simula_caminhao(fisRLS, 55, 10, 10, 1, 'y');
simula_caminhao(fisGradient, 55, 10, 10, 1, 'k');