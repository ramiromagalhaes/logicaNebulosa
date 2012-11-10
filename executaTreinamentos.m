%
%   Executa os 4 treinamentos: ANFIS, BLS, RLS e Gradient
%
function [fisANFIS, fisBLS, fisRLS, fisGradient] = executaTreinamentos(dados, nMFs1, nMFs2)

%gera FIS para treinamento
novoFIS = genfis1(dados, [nMFs1 nMFs2]);

fisM = readfis('caminhao');

%treina ANFIS
fisANFIS = anfis(dados, novoFIS);
fisANFIS.name = 'ANFIS';
writefis(fisANFIS, 'caminhaoANFIS');

%treina BLS
fisBLS = bls(dados, nMFs1, nMFs2);
fisBLS.name = 'BLS';
writefis(fisBLS, 'caminhaoBLS');

%treina RLS
fisRLS = rls(dados, nMFs1, nMFs2);
fisRLS.name = 'RLS';
writefis(fisRLS, 'caminhaoRLS');

%treina Gradient
fisGradient = gradient(dados, fisBLS, nMFs1, nMFs2);
fisGradient.name = 'Gradient';
writefis(fisGradient, 'caminhaoGradient');