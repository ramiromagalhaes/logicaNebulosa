%
%   Treina o BLS
%Recebe como par�metro os dados e o n�mero de fun��es de pertin�ncia
%Alterado nome da fun��o pois estava como 'sugenobls'
function fisBLS = bls(dados, nMFs1, nMFs2)

%gera o novo fis
fisSaida = genfis1(dados, [nMFs1 nMFs2]);

%separa os b da tabela de dados
y = dados(:, size(dados, 2));

%define o n�mero de entradas
nDados = size(dados, 1);

%define o n�mero de regras
nRegras = size(fisSaida.rule, 2);

%define o n�mero de inputs (no caso do problema do caminh�o 2, o par x e phi)
nEntradas = size(fisSaida.input, 2);

%calcular os mves intermediarios
%inicializa inicialmente com tudo um
mv = ones(nDados, nRegras);
%itera��o para calcular os resultados com o produto com os graus de
%pertin�ncia dada por uma fun��o de pertin�ncia.
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
%Acrescentado a cria��o da matriz phi com valores zero
phi = zeros(nDados,nRegras);
%calcular phi
for dado = 1:nDados 
    for regra = 1:nRegras
        phi(dado, regra) = mv(dado, regra) / sum(mv(dado, :));
    end
end

%ajuste do fis

%aplica f�rmula do BLS
teta = inv(phi' * phi) * phi' * y;

%altera parametros b encontrados
fisBLS = fisSaida;
for regra = 1:nRegras
    fisBLS.output.mf(regra).params(3) = teta(regra);
end
