function fisSaida = gradient(dados, nMFs1, nMFs2)
% Treinamento do sistema nebuloso do caminhão pelo método do gradiente.
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
    %primeiro, calculamos os graus de inclusao de cada funcao de inclusao
    %(mf - membership function) do sistema nebuloso, usando os dados que
    %temos de exemplo.
    mv = ones(nRegras, nDados);
    for dado = 1:nDados
        for regra = 1:nRegras      
            for entrada = 1:nEntradas
                mf = getInputMFFromRules(regra, entrada);

                %adicionar ao multiplicatorio do valor de inclusao
                valor = mfEval(mf, dados(dado, entrada));
                mv(regra, dado) = mv(regra, dado) * valor;
            end
        end
    end

    %calcula f(Xm)
    mvRegra = ones(nRegras, 1);
    bRegra = ones(nRegras, 1);
    fXm = 0;
    for r = 1:nRegras
        %pega parametro b
        bRegra(r) = fisSaida.output.mf(r).params(3);
        mvRegra(r) = mv(r, m) / sum(mv(:,m));
        fXm = fXm + mvRegra(r) * bRegra(r);
    end

    %calcula erro
    erroM = fXm - y(m);
    novoErro = (1/2) * (erroM)^2;

    %ajusta parametro
    for r = 1:nRegras
        %calcula novo centro de output (parametro b)
        novoB = bRegra(r) - erroM * mvRegra(r);
        fisSaida.output.mf(r).params(3) = novoB;

        %ajusta parametros dos inputs
        for entrada = 1:nEntradas
            %pega MF da variavel de entrada
            mf = getInputMFFromRules(fis, r, entrada); %indiceMF = fisSaida.rule(r).antecedent(entrada);
                                                       %mf = fisSaida.input(entrada).mf(indiceMF);

            %calcula novo centro de input (parametro c)
            sigmaAntigo = getMFStdDeviation(mf);
            centroAntigo = getMFMean(mf);

            xAntigo = dados(m, entrada);

            novoCentro = centroAntigo - (erroM * (bRegra(r) - fXm)* mvRegra(r) * ((xAntigo - centroAntigo)/(sigmaAntigo^2)));            
            setMFMean(mf, novoCentro);

            %calcula novo sigma
            novoSigma = sigmaAntigo - (erroM * (bRegra(r) - fXm)* mvRegra(r) * ((xAntigo - centroAntigo)/(sigmaAntigo^3)));            
            setMFStdDeviation(mf, novoSigma);
        end
    end
end

end



%-------------------------
% Funções auxiliares
%-------------------------



function mf = getInputMF(fis, inputIndex, mfIndex)
    mf = fis.input(inputIndex).mf(mfIndex);
end

function mf = getInputMFFromRules(fis, ruleIndex, inputIndex)
    %TODO what to do when there is no MF in the informed ruleIndex and inputIndex?
    mfIndex = fisSaida.rule(ruleIndex).antecedent(inputIndex);
    mf = getInputMF(fis, inputIndex, mfIndex);
end

% http://www.mathworks.com/help/fuzzy/gaussmf.html
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

function v = mfEval(mf, input)
    v = feval(mf.type, input, mf.params);
end
