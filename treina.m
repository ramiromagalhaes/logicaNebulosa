function [tempoANFIS, tempoBLS, tempoRLS, tempoGrad] = treina(dados, nMFs1, nMFs2)
% Executa os 4 treinamentos: ANFIS, BLS, RLS e Gradiente. Os FIS
% resultantes serao salvos na subpasta 'fis'. Retorna um vetor com os
% tempos tomados em cada treinamento.

    fisFolder = 'fis/';
    fisNomePosfixo = ['-' num2str(nMFs1) '-' num2str(nMFs2)];

    %treina ANFIS
    disp('Iniciando treinamento com o ANFIS');
    tInicial = cputime;
    novoFIS = genfis1(dados, [nMFs1 nMFs2]);
    fisANFIS = anfis(dados, novoFIS);
    fisANFIS.name = 'ANFIS';
    tempoANFIS = cputime - tInicial;
    writefis(fisANFIS, [fisFolder 'caminhaoANFIS' fisNomePosfixo]);

    %treina BLS
    disp('Iniciando treinamento com o BLS');
    tInicial = cputime;
    fisBLS = bls(dados, nMFs1, nMFs2);
    fisBLS.name = 'BLS';
    tempoBLS = cputime - tInicial;
    writefis(fisBLS, [fisFolder 'caminhaoBLS' fisNomePosfixo]);

    %treina RLS
    disp('Iniciando treinamento com o RLS');
    tInicial = cputime;
    fisRLS = rls(dados, nMFs1, nMFs2);
    fisRLS.name = 'RLS';
    tempoRLS = cputime - tInicial;
    writefis(fisRLS, [fisFolder 'caminhaoRLS' fisNomePosfixo]);

    
    tempoGrad = zeros(2, 1); %para os tempos do gradiente

    %treina Gradiente
    disp('Iniciando treinamento com o Gradiente');
    tInicial = cputime;
    fisGrad = gradient(dados, nMFs1, nMFs2);
    fisGrad.name = 'Gradient';
    tempoGrad(1) = cputime - tInicial;
    writefis(fisGrad, [fisFolder 'caminhaoGradient' fisNomePosfixo]);

    %treina Gradiente com MFs independentes das regras
    disp('Iniciando treinamento com o Gradiente com MFs independentes');
    tInicial = cputime;
    fisGradIndepMFs = gradient(dados, nMFs1, nMFs2);
    fisGradIndepMFs.name = 'Gradient Independent MFs';
    tempoGrad(2) = cputime - tInicial;
    writefis(fisGradIndepMFs, [fisFolder 'caminhaoGradientIndependentMFs' fisNomePosfixo]);
end

