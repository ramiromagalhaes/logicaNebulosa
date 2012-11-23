function fis = fisFromMatrix( sigmaC, b )
%FISFROMMATRIX Produz um fis a partir dos parametros sigmaC e b.

    fis = newfis('gradientFis', 'sugeno', 'prod', 'max', 'prod', 'max', 'wtaver');

    %entradas do sistema do caminhao
    fis = addvar(fis, 'input', 'x', [0 100]);
    fis = addvar(fis, 'input', 'direcao', [-90 270]);

    %saida do sistema do caminhao
    fis = addvar(fis, 'output', 'volante', [-30 30]);

    %adicao de funcoes de inclusao as variaveis
    for r = 1:size(sigmaC, 1)
        %entradas
        fis = addmf(fis, 'input',  1, ['inputmf'  num2str(r)], 'gaussmf', sigmaC(r, 1, :));
        fis = addmf(fis, 'input',  2, ['inputmf'  num2str(r)], 'gaussmf', sigmaC(r, 2, :));

        fis = addmf(fis, 'output', 1, ['outputmf' num2str(r)], 'linear', [0 0 b(r)]);
    end

    for r = 1:size(sigmaC, 1)
        fis = addrule(fis, [r r r 1 1]); %vide http://www.mathworks.com/help/fuzzy/addrule.html
    end
    
end
