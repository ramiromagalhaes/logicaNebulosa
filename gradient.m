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
lambdaB = 1;
lambdaC = 1;
lambdaSigma = 1;

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
    if (show_progress)
        waitbar(m/nDados, progress);
    end

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
            %Preparando para chamar a funcao de inclusao
            mfIndex = fis.rule(ruleIndex).antecedent(inputIndex);
            mf = fis.input(inputIndex).mf(mfIndex);

            %Chamando a funcao de inclusao e incluindo na multiplicatoria
            output = feval(mf.type, dados(m, e), mf.params);
            mv(r) = mv(r) * output;
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

    %Registra o erro atual
    erros(m) = 0.5 * (epsilon)^2;

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

            %Equacao 7.17 do livro
            novoCentro = centroAntigo - lambdaC * epsilon * (b(r) - fXm) * mvRegra(r) * ((entradaIteracao - centroAntigo)/(sigmaAntigo^2));

            %Equacao 7.18 do livro
            %Aqui estava faltando elevar (entradaIteracao - centroAntigo) ao quadrado
            novoSigma = sigmaAntigo - lambdaSigma * epsilon * (b(r) - fXm) * mvRegra(r) * ((entradaIteracao - centroAntigo)^2/(sigmaAntigo^3));

            %Atribuicao dos novos parametros das funcoes.
            fis.input(e).mf(mfIndex).params(1) = novoSigma;
            fis.input(e).mf(mfIndex).params(2) = novoCentro;
        end

        %Enfim, calculamos o parametro dos consequentes.
        b(r) = b(r) - lambdaB * epsilon * mvRegra(r);
        fis.output.mf(r).params(3) = b(r);
    end
end

end
