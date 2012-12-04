%
%   Treinamento do RLS
%
function fisRLS = rls(dados, nMFs1, nMFs2)

fisSaida = genfis1(dados, [nMFs1 nMFs2]);

% y é o vetor (coluna) de saída
y = dados(:, size(dados, 2));

nRegras = size(fisSaida.rule, 2);

% nDados = M (quantidade de linhas da matriz de dados)
nDados = size(dados, 1);

% nEntradas = N
nEntradas = size(fisSaida.input, 2);

%Cálculo dos graus de pertinência
mv = ones(nDados, nRegras);
for dado = 1:nDados 
    for regra = 1:nRegras
        %vamos calcular a aplicacao de uma amostra em uma regra
        for entrada = 1:nEntradas
            %obter a MF do conjunto associado a essa entrada naquela regra
            index_mf = fisSaida.rule(regra).antecedent(entrada);
            mf = fisSaida.input(entrada).mf(index_mf);

            %aplicar a MF encontrada no ponto considerado
            mv(dado, regra) = mv(dado, regra) * feval(mf.type, dados(dado, entrada), mf.params);
        end
    end
end

% Cálculo do phi (slide 36)
for dado = 1:nDados 
    for regra = 1:nRegras
        % sum(mv(dado, :)) = Soma dos valores da linha 'dado' da matriz mv
        phi(dado, regra) = mv(dado, regra) / sum(mv(dado, :));
    end
end

% Aplicação da fórmula do RLS (slides 57, 63 e 64)
% P(0); alfa = 2000; eye: matriz identidade
p = 2000 * eye(nRegras);

%theta = vetor coluna de zeros
theta = zeros(nRegras, 1);

nSteps = 10 * nDados;
for step = 1:nSteps
    % Cada linha de PHI e Y é usada 10 vezes; é isso que faz o
    % "1 + mod(step-1, nDados)"
    novoX = phi(1+ mod(step-1, nDados), :)';
    novoY = y(1+ mod(step-1, nDados), :);  

    novoP = (eye(nRegras) - p * novoX * inv(1 + novoX' * p * novoX) * novoX') * p;

    novoTheta = theta + novoP * novoX * (novoY - (novoX' * theta));

    p = novoP;
    theta = novoTheta;
end

%altera parametros b encontrados
fisRLS = fisSaida;
for regra = 1:nRegras
    fisRLS.output.mf(regra).params(3) = theta(regra);
end

