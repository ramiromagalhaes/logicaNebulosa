%
%   Treina o BLS
%
function fisBLS = sugenobls(dados, nMFs1, nMFs2)

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

%aplica fórmula do BLS
teta = inv(phi' * phi) * phi' * y;

%altera parametros b encontrados
fisBLS = fisSaida;
for regra = 1:nRegras
    fisBLS.output.mf(regra).params(3) = teta(regra);
end