function [fis erros] = gradient(dados, nMFs1, nMFs2, progress)
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
%   progress: referencia para uma barra de progresso, para medir o avanco
%             do algoritmo. Esse argumento e opcional. Note que esta funcao
%             apenas atualiza a posicao da barra. Cabe ao chamador
%             instancia-la e fecha-la.

show_progress = false;
if (nargin >= 4)
    show_progress = true;
end

nDados = size(dados, 1); %quantidade linhas do parametro dados
y = dados(:, size(dados, 2)); %coluna de saidas da massa de dados do caminhao = coluna 3

% geracao inicial do FIS treinado pelo metodo do gradiente
fis = genfis1(dados, [nMFs1 nMFs2], 'gaussmf');
nEntradas = size(fis.input, 2); %quantidade de variáveis de entrada = 2
nRegras = size(fis.rule, 2); %quantidade de regras do sistema = nMFs1 * nMFs2

%Os lambdas sao parametros que determinam o tamanho do passo que o
%algoritmo dara ao atualizar um valor.
lambdaB = .5;
lambdaC = .5;
lambdaSigma = .5;

%Vetor de erros a medida que as iteracoes progridem
erros = zeros(nDados, 1);

%Contera as saidas do sistema nebuloso para cada uma de suas regras. Essa
%matriz nao e realmente necessaria, visto que suas informacoes podem ser
%obtidas diretamente do FIS, mas ela e uma forma conveniente de fazermos
%alguns calculos. Se for necessario reduzir o uso de memoria, basta alterar
%o codigo para ler e usar os dados do FIS.
b = zeros(nRegras, 1);

%Este laco inicia a matriz b. Ela sera usada e atualizada no laco principal.
for r = 1:nRegras
    b(r) = fis.output.mf(r).params(3);
end



for m = 1:nDados
    if (show_progress) %Atualiza o contador de progresso.
        waitbar(m/nDados, progress);
    end

    %mv(i) contem o resultado da multiplicacao de todas as funcoes de
    %inclusao pertencentes a i-esima regra, usando como entrada os dados da
    %iteracao 'm'.
    mv = ones(nRegras, 1);

    %Esses lacos povoam mv. O calculo apresentado aqui corresponde a
    %equacao 7.14 do livro. Contudo, note que não precisamos calcular o
    %resultado de todas as regras com todas as tuplas de dados (conforme o
    %livro sugere), pois não usaremos isso para nada.
    for r = 1:nRegras
        %Esse e o laco da multiplicatoria das funcoes de inclusao presentes
        %na regra 'r', usando a tupla de dados 'm'.
        for e = 1:nEntradas
            %Preparando para chamar a funcao de inclusao
            mfIndex = fis.rule(r).antecedent(e);
            mf = fis.input(e).mf(mfIndex);

            %Chamando a funcao de inclusao e incluindo na multiplicatoria
            mv(r) = mv(r) * feval(mf.type, dados(m, e), mf.params);
        end
    end



    dividendo = sum(mv); %esse somatorio sera usado varias vezes

    %Contem os resultados do sistema nebuloso com a entrada m. Vide a
    %equacao 7.3 do livro.
    %Note que a reproducao da equacao 7.3 na pagina 224 esta incorreta,
    %pois a multiplicatoria do divisor vai de j = 1 a n, ao inves de R.
    defuzz = sum(mv .* b) / dividendo;



    %Calculo de ε (epsilon), conforme definido pela equacao 7.15 do livro
    epsilon = defuzz - y(m);

    %Registra o erro atual
    erros(m) = 0.5 * (epsilon)^2;



    %Este vetor sera utilizado multiplas vezes dentro do laco abaixo. Por
    %isso o deixamos precalculado.
    mvRegra = mv / dividendo;

    %Guardamos os novos parametros de cada funcao em uma variavel
    %temporaria para depois atualizar todos os parametros de todas as
    %funcoes de inclusao presentes em uma regra de uma vez so. Se não
    %fizermos vamos causar efeitos colaterais indesejados nos calculos dos
    %novos parametros. Aqui, a coluna 1 contera as variancias, enquanto a
    %coluna 2 contera os centros.
    novosParams = zeros(nEntradas, 2);

    %Atualizacao dos parametros de todas as funcoes de todas as regras
    for r = 1:nRegras
        %O livro sugere comecar pela atualizacao dos consequentes de cada
        %regra, mas essa ordem nao e importante pois seus novos valores nao
        %serao usados para o calculo dos antecedentes. Somente os valores
        %antigos do consequente sao relevantes.
        for e = 1:nEntradas
            %Isso permite identificar a MF de uma regra do sistema nebuloso
            %que desejamos atualizar.
            mfIndex = fis.rule(r).antecedent(e);

            %Calcula os novos parametros da funcao de inclusao antecedente
            %que acabamos de obter.
            sigmaAntigo = fis.input(e).mf(mfIndex).params(1);
            centroAntigo = fis.input(e).mf(mfIndex).params(2);

            entradaIteracao = dados(m, e); %a entrada que vou usar agora

            %Equacao 7.18 do livro
            novosParams(e, 1) = sigmaAntigo - lambdaSigma * epsilon * (b(r) - defuzz) * mvRegra(r) * ((entradaIteracao - centroAntigo)^2/(sigmaAntigo^3));

            %Equacao 7.17 do livro
            novosParams(e, 2) = centroAntigo - lambdaC * epsilon * (b(r) - defuzz) * mvRegra(r) * ((entradaIteracao - centroAntigo)/(sigmaAntigo^2));
        end

        %Atribuicao dos novos parametros das funcoes.
        for e = 1:nEntradas
            mfIndex = fis.rule(r).antecedent(e);
            fis.input(e).mf(mfIndex).params(1) = novosParams(e, 1);
            fis.input(e).mf(mfIndex).params(2) = novosParams(e, 2);
        end

        %Enfim, calculamos o parametro dos consequentes.
        b(r) = b(r) - lambdaB * epsilon * mvRegra(r);
        fis.output.mf(r).params(3) = b(r);
    end
end

end
