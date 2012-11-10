%
%   Treina o RLS
%
function fisRLS = sugenobls(dados, nMFs1, nMFs2)

fisSaida = genfis1(dados, [nMFs1 nMFs2]);

y = dados(:, size(dados, 2));

nDados = size(dados, 1);
nRegras = size(fisSaida.rule, 2);
nEntradas = size(fisSaida.input, 2);

%calcular os mves intermediarios
mv = ones(nDados, nRegras);

for dado = 1:nDados 
    for regra = 1:nRegras
        %vamos calcular a aplicacao de uma amostra em uma regra
        for entrada = 1:nEntradas
            %obter a MF do conjunto associado a essa entradaiavel naquela regra
            index_mf = fisSaida.rule(regra).antecedent(entrada);
            mf = fisSaida.input(entrada).mf(index_mf);

            %aplicar a MF encontrada no ponto considerado
            mv(dado, regra) = mv(dado, regra) * feval(mf.type, dados(dado, entrada), mf.params);
        end
    end
end

%calcular phi
for dado = 1:nDados 
    for regra = 1:nRegras
        phi(dado, regra) = mv(dado, regra) / sum(mv(dado, :));
    end
end

%aplica fórmula do RLS
p = 2000 * eye(nRegras);

teta = zeros(nRegras, 1);

nSteps = 10 * nDados;
for step = 1:nSteps
    novoX = phi(1+ mod(step-1, nDados), :)';
    novoY = y(1+ mod(step-1, nDados), :);  

    novoP = (eye(nRegras) - p * novoX * inv(1 + novoX' * p * novoX) * novoX') * p;

    novoTeta = teta + novoP * novoX * (novoY - (novoX' * teta));

    p = novoP;
    teta = novoTeta;
end

%altera parametros b encontrados
fisRLS = fisSaida;
for regra = 1:nRegras
    fisRLS.output.mf(regra).params(3) = teta(regra);
end