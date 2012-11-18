function mfParams = mfParamsMatrix(fis)
%Produz uma matriz de parametros das funcoes gaussianas usadas para
%parametrizar as funcoes de inclusao dos argumentos de entrada do sistema
%nebuloso 'fis'.

    nRegras = size(fis.rule, 2); %quantidade de regras do sistema = nMFs1 * nMFs2
    nEntradas = size(fis.input, 2); %quantidade de variáveis de entrada

    mfParams = zeros(nRegras, nEntradas, 2);

    for r = 1:nRegras
        for e = 1:nEntradas
            mfIndex = fis.rule(r).antecedent(e);
            mfParams(r, e, 1) = fis.input(e).mf(mfIndex).params(1); %sigma
            mfParams(r, e, 2) = fis.input(e).mf(mfIndex).params(2); %centro
        end
    end

end
