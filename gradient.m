function fis = gradient(dados, nMFs1, nMFs2)
% Treinamento do sistema nebuloso do caminhão pelo método do gradiente. Ao
% longo dessa funcao, referenciaremos equacoes da 3a. edicao do livro Fuzzy
% Logic with Engineering Applications.
%   Os parametros dessa funcao sao os seguintes:
%   dados: matriz com a massa de dados que será usada para o treinamento.
%          A primeira coluna deve conter as entradas referentes à posição;
%          a segunda coluna deve conter as entradas referentes à direção;
%          a terceira coluna deve conter as saídas do ângulo de giro do volante.
%   nMFs1: numero de funcoes de inclusao para o parametro x.
%   nMFs2: numero de funcoes de inclusao para o parametro direção.

nDados = size(dados, 1); %quantidade linhas do parametro dados
y = dados(:, size(dados, 2)); %coluna de saidas da massa de dados do caminhao = coluna 3

% geracao inicial do FIS treinado pelo metodo do gradiente
fis = genfis1(dados, [nMFs1 nMFs2], 'gaussmf');
nEntradas = size(fis.input, 2); %quantidade de variáveis de entrada = 2
nRegras = size(fis.rule, 2); %quantidade de regras do sistema = nMFs1 * nMFs2

%Os lambdas sao parametros que determinam o tamanho do passo que o
%algoritmo dara ao atualizar um valor.
lambdaB = 1;
lambdaC = 1;
lambdaSigma = 1;

%Contera as saidas do sistema nebuloso para cada uma de suas regras. Essa
%matriz nao e realmente necessaria, visto que suas informacoes podem ser
%obtidas diretamente do FIS, mas ela e uma forma conveniente de fazermos
%alguns calculos. Se for necessario reduzir o uso de memoria, basta alterar
%o codigo para ler e usar os dados do FIS.
b = zeros(nRegras, 1);

%Este laco inicia a matriz b. Ela sera usada e atualizada no laco principal.
for r = 1:nRegras
    b(r) = getConsequentValueFromRules(fis, r);
end



for m = 1:nDados
    %A célula (i) desse vetor contem o resultado da multiplicacao de todas
    %as funcoes de inclusao pertencentes a i-esima regra.
    mv = ones(nRegras, 1);

    %Esses lacos povoam mv. O calculo apresentado aqui corresponde a
    %equacao 7.14 do livro. Contudo, note que não precisamos calcular o
    %resultado de todas as regras com todas as tuplas de dados (conforme o
    %livro sugere), pois não usaremos isso para nada.
    for r = 1:nRegras
        %Esse e o laco da multiplicatoria das funcoes de inclusao presentes
        %na regra 'r', usando a tupla de dados 'm'.
        for e = 1:nEntradas
            mv(r) = mv(r) * evalAntecedentMFFromRules(fis, r, e, dados(m, e));
        end
    end


    dividendo = sum(mv); %esse somatorio sera usado varias vezes

    %Vetor que contem os resultados das multiplicacoes das funcoes de
    %inclusao existentes em uma regra usando como entrada a tupla de dados
    %sobre a qual estamos iterando agora.
    mvRegra = mv / dividendo;

    %Contem os resultados do sistema nebuloso com a entrada m. Vide a
    %equacao 7.3 do livro.
    %Note que a reproducao da equacao 7.3 na pagina 224 esta incorreta,
    %pois a multiplicatoria do divisor vai de j = 1 a n, ao inves de R.
    fXm = sum(mv .* b) / dividendo;

    %Calculo de ε (epsilon), conforme definido pela equacao 7.15 do livro
    epsilon = fXm - y(m);

    %erro = 0.5 * (epsilon)^2; %isso nao e usado...

    %Atualizacao dos parametros de todas as funcoes de todas as regras
    for r = 1:nRegras
        %O livro sugere comecar pela atualizacao dos consequentes de cada
        %regra, mas essa ordem nao e importante pois seus novos valores nao
        %serao usados para o calculo dos antecedentes. Somente os valores
        %antigos do consequente sao relevantes.
        for e = 1:nEntradas
            %Obtem da regra 'r' a funcao de inclusao pertencente aos
            %antecedentes de indice 'e'.
            mf = getAntecedentMFFromRules(fis, r, e);

            %Calcula os novos parametros da funcao de inclusao antecedente
            %que acabamos de obter.
            centroAntigo = getMFMean(mf);
            sigmaAntigo = getMFStdDeviation(mf);

            entradaIteracao = dados(m, e); %a entrada que vou usar agora

            %Equacao 7.17 do livro
            novoCentro = centroAntigo - lambdaC * epsilon * (b(r) - fXm) * mvRegra(r) * ((entradaIteracao - centroAntigo)/(sigmaAntigo^2));

            %Equacao 7.18 do livro
            %Aqui estava faltando elevar (entradaIteracao - centroAntigo) ao quadrado
            novoSigma = sigmaAntigo - lambdaSigma * epsilon * (b(r) - fXm) * mvRegra(r) * ((entradaIteracao - centroAntigo)^2/(sigmaAntigo^3));

            %Atribuicao dos novos parametros das funcoes.
            setMFMean(mf, novoCentro);
            setMFStdDeviation(mf, novoSigma);
        end

        %Enfim, calculamos o parametro dos consequentes.
        b(r) = b(r) - lambdaB * epsilon * mvRegra(r);
        setConsequentParameterFromRules(fis, r, b(r));
    end
end

end



%-------------------------
% Funções auxiliares
%-------------------------



function mf = getAntecedentMFFromRules(fis, ruleIndex, inputIndex)
    mfIndex = fis.rule(ruleIndex).antecedent(inputIndex);
    mf = getAntecedentMF(fis, inputIndex, mfIndex);
end

function mf = getAntecedentMF(fis, inputIndex, mfIndex)
    mf = fis.input(inputIndex).mf(mfIndex);
end

function b = getConsequentValueFromRules(fis, ruleIndex)
    b = fis.output.mf(ruleIndex).params(3);
end

function output = evalAntecedentMFFromRules(fis, ruleIndex, inputIndex, input)
    mf = getAntecedentMFFromRules(fis, ruleIndex, inputIndex);
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

function setMFStdDeviation(mf, value)
   mf.params(1) = value;
end

function setConsequentParameterFromRules(fis, ruleIndex, param)
    fis.output.mf(ruleIndex).params(3) = param;
end
