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
y = dados(:, 3); %coluna de saidas da massa de dados

% geracao inicial do FIS treinado pelo metodo do gradiente
fisSaida = genfis1(dados, [nMFs1 nMFs2], 'gaussmf');
nEntradas = size(fisSaida.input, 2); %quantidade de variáveis de entrada
nRegras = size(fisSaida.rule, 2); %quantidade de regras do sistema


for m = 1:nDados

    %calcula os valores de inclusao
    mv = ones(nRegras, nDados);
    for dado = 1:nDados
        for regra = 1:nRegras      
            for entrada = 1:nEntradas
                %pega MF da vari�vel de entrada
                indiceMF = fisSaida.rule(regra).antecedent(entrada);
                mf = fisSaida.input(entrada).mf(indiceMF);

                %adicionar ao multiplicatorio do valor de inclusao
                valor = feval(mf.type, dados(dado, entrada), mf.params);
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
            %pega MF da vari�vel de entrada
            indiceMF = fisSaida.rule(r).antecedent(entrada);
            mf = fisSaida.input(entrada).mf(indiceMF);

            %calcula novo centro de input (parametro c)
            sigmaAntigo = fisSaida.input(entrada).mf(indiceMF).params(1);
            centroAntigo = fisSaida.input(entrada).mf(indiceMF).params(2);
            xAntigo = dados(m, entrada);

            novoCentro = centroAntigo - (erroM * (bRegra(r) - fXm)* mvRegra(r) * ((xAntigo - centroAntigo)/(sigmaAntigo^2)));            
            fisSaida.input(entrada).mf(indiceMF).params(2) = novoCentro;

            %calcula novo sigma
            novoSigma = sigmaAntigo - (erroM * (bRegra(r) - fXm)* mvRegra(r) * ((xAntigo - centroAntigo)/(sigmaAntigo^3)));            
            fisSaida.input(entrada).mf(indiceMF).params(1) = novoSigma;
        end
    end
end
