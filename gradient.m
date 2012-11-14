function fisSaida = gradient(dados, nMFs1, nMFs2)
% Treinamento do sistema nebuloso do caminhão pelo método do gradiente. Ao
% longo dessa funcao, referenciaremos equacoes da 3a. edicao do livro Fuzzy
% Logic with Engineering Applications.
%   dados: matriz com a massa de dados que será usada para o treinamento.
%          A primeira coluna deve conter as entradas referentes à posição;
%          a segunda coluna deve conter as entradas referentes à direção;
%          a terceira coluna deve conter as saídas do ângulo de giro do volante.
%   fisBLS: descritor inicial do sistema nebuloso.
%   nMFs1: numero de funcoes de inclusao para o parametro x.
%   nMFs2: numero de funcoes de inclusao para o parametro direção.

nDados = size(dados, 1); %quantidade linhas do parametro dados
y = dados(:, size(dados, 2)); %coluna de saidas da massa de dados do caminhao = coluna 3

% geracao inicial do FIS treinado pelo metodo do gradiente
fisSaida = genfis1(dados, [nMFs1 nMFs2], 'gaussmf');
nEntradas = size(fisSaida.input, 2); %quantidade de variáveis de entrada = 2
nRegras = size(fisSaida.rule, 2); %quantidade de regras do sistema = nMFs1 * nMFs2



for m = 1:nDados
    %A célula (i, j) dessa matriz contem o resultado da multiplicacao de todas
    %as funcoes de inclusao pertencentes a i-esima regra usando a j-esima tupla
    %de dados.
    mv = ones(nRegras, nDados);

    %Contera as saidas do sistema nebuloso para cada uma de suas regras
    b = zeros(nRegras, 1);

    %Esses lacos povoam a matriz mv. O calculo apresentado aqui corresponde
    %a equacao 7.14 do livro.
    for d = 1:nDados
        for r = 1:nRegras
            b(r) = getOutputValueFromRules(r); %Oportunamente, preenchemos a matriz b.

            %Esse e o laco da multiplicatoria das funcoes pertinentes a uma
            %regra, com um conjunto de dados.
            for e = 1:nEntradas
                valor = evalInputMFFromRules(fis, r, e, dados(d, e));
                mv(r, d) = mv(r, d) * valor; %como iniciamos mv com 1, podemos iterar dessa forma desde o inicio.
            end
        end
    end



    dividendo = sum(mv(:,m)); %so para evitar calcular isso 2 vezes

    %??????????????
    mvRegra = mv(:, m) / dividendo;

    %Contem os resultados do sistema nebuloso com a entrada m. Vide a
    %equacao 7.3 do livro.
    %Note que a reproducao da equacao 7.3 na pagina 224 esta incorreta,
    %pois a multiplicatoria do divisor vai de j = 1 a n, ao inves de R.
    fXm = sum(mv(:, m) .* b) / dividendo;

    %Calculo de ε (epsilon), conforme definido pela equacao 7.15 do livro
    epsilon = fXm - y(m);
    erro = 0.5 * (epsilon)^2;

    %Atualizacao dos parametros de todas as funcoes de todas as regras
    for r = 1:nRegras
        %calcula novo centro de output (parametro b)
        novoB = b(r) - epsilon * mvRegra(r);
        fisSaida.output.mf(r).params(3) = novoB;

        %ajusta parametros dos inputs
        for e = 1:nEntradas
            %pega MF da variavel de entrada
            mf = getInputMFFromRules(fis, r, e); %indiceMF = fisSaida.rule(r).antecedent(entrada);
                                                       %mf = fisSaida.input(entrada).mf(indiceMF);

            %calcula novo centro de input (parametro c)
            sigmaAntigo = getMFStdDeviation(mf);
            centroAntigo = getMFMean(mf);

            xAntigo = dados(m, e);

            novoCentro = centroAntigo - (epsilon * (b(r) - fXm)* mvRegra(r) * ((xAntigo - centroAntigo)/(sigmaAntigo^2)));            
            setMFMean(mf, novoCentro);

            %calcula novo sigma
            novoSigma = sigmaAntigo - (epsilon * (b(r) - fXm)* mvRegra(r) * ((xAntigo - centroAntigo)/(sigmaAntigo^3)));            
            setInputMFStdDeviation(mf, novoSigma);
        end
    end
end

end



%-------------------------
% Funções auxiliares
%-------------------------



function mf = getInputMFFromRules(fis, ruleIndex, inputIndex)
    mfIndex = fisSaida.rule(ruleIndex).antecedent(inputIndex);
    mf = getInputMF(fis, inputIndex, mfIndex);
end

function mf = getInputMF(fis, inputIndex, mfIndex)
    mf = fis.input(inputIndex).mf(mfIndex);
end

function b = getOutputValueFromRules(fis, ruleIndex)
    b = fis.output.mf(ruleIndex).params(3);
end

function output = evalInputMFFromRules(fis, ruleIndex, inputIndex, input)
    mf = getInputMFFromRules(fis, ruleIndex, inputIndex);
    output = mfEval(mf, input);
end

function output = mfEval(mf, input)
    output = feval(mf.type, input, mf.params);
end

function mean = getMFMean(mf)
    mean = mf.params(2);
end

function std = getMFStdDeviation(mf)
    std = mf.params(1);
end

function setMFMean(mf, value)
   mf.params(2) = value;
end

function setInputMFStdDeviation(mf, value)
   mf.params(1) = value;
end
