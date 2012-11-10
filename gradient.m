%
%   Treina o Gradient
%
function fisGradient = gradient(dados, fisBLS, nMFs1, nMFs2)

fisSaida = genfis1(dados, [nMFs1 nMFs2], 'gaussmf');

%ajusta parametro iniciais do centro dos outputs para saida do BLS (parametro b)
nMF = size(fisSaida.output.mf, 2);
for indiceMF = 1:nMF
    fisSaida.output.mf(indiceMF).params(3) = fisBLS.output.mf(indiceMF).params(3);
end

nEntradas = size(fisSaida.input, 2);

%ajusta parametros iniciais sigma para 1
%for entrada = 1:nEntradas
    %pega MF da variável de entrada
%    vEntrada = fisSaida.input(entrada);
%    nMF = size(vEntrada.mf, 2);

    %Ajusta sigma para 1
%    for indiceMF = 1:nMF
%        fisSaida.input(entrada).mf(indiceMF).params(1) = 1;
%    end
%end

nDados = size(dados, 1);
nRegras = size(fisSaida.rule, 2);

%pega outputs
y = dados(:, size(dados, 2));

m = 1;
erroAntigo = 0;

while m <= nDados
    
    %calcula os valores de inclusão
    mv = ones(nRegras, nDados);
    for dado = 1:nDados
        for regra = 1:nRegras      
            for entrada = 1:nEntradas
                %pega MF da variável de entrada
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
            %pega MF da variável de entrada
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
    
    m = m + 1;
end

fisGradient = fisSaida;