function treina_bls_rls_grad(dados, nMFs1, nMFs2)
% Executa os 4 treinamentos: ANFIS, BLS, RLS e Gradiente. Os FIS
% resultantes serao salvos na subpasta 'fis'. Retorna um vetor com os
% tempos tomados em cada treinamento.

    fisFolder = 'fis/';
    fisSufixo = ['-' num2str(nMFs1) '-' num2str(nMFs2)];

    %treina BLS
    disp('Iniciando treinamento com o BLS');
    fisBLS = bls(dados, nMFs1, nMFs2);
    fisBLS.name = 'BLS';
    writefis(fisBLS, [fisFolder 'caminhaoBLS' fisSufixo]);

    %treina RLS
    disp('Iniciando treinamento com o RLS');
    fisRLS = rls(dados, nMFs1, nMFs2);
    fisRLS.name = 'RLS';
    writefis(fisRLS, [fisFolder 'caminhaoRLS' fisSufixo]);

    %treina Gradiente
    disp('Iniciando treinamento com o Gradiente');
    fisGrad = gradient(dados, nMFs1, nMFs2);
    fisGrad.name = 'Gradient';
    writefis(fisGrad, [fisFolder 'caminhaoGradient' fisSufixo]);

    %treina Gradiente com MFs independentes das regras
    disp('Iniciando treinamento com o Gradiente com MFs independentes');
    fisGradIndepMFs = gradient(dados, nMFs1, nMFs2);
    fisGradIndepMFs.name = 'Gradient Independent MFs';
    writefis(fisGradIndepMFs, [fisFolder 'caminhaoGradientIndependentMFs' fisSufixo]);
end

