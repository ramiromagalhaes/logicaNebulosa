function treina(dados)
    %treina ANFIS
    disp('Iniciando treinamento com o ANFIS');
    treina_anfis(dados);

    disp('==============================');
    disp('Treinamentos com 3 parametros.');
    disp('==============================');
    treina_bls_rls_grad(dados, 3, 3);

    disp('==============================');
    disp('Treinamentos com 5 parametros.');
    disp('==============================');
    treina_bls_rls_grad(dados, 5, 5);

    disp('==============================');
    disp('Treinamentos com 7 parametros.');
    disp('==============================');
    treina_bls_rls_grad(dados, 7, 7);

    disp('===============================');
    disp('Treinamentos com 10 parametros.');
    disp('===============================');
    treina_bls_rls_grad(dados, 10, 10);
end
