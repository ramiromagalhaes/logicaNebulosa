function resultado = simula_estacionamento(fis, iteracoes, varargin)
% Simula diversas iterações do estacionamento e escreve o resultado da
% simulação num arquivo ou na memória o resultado.
%   ENTRADAS
%    fis: o descritor do sistema nebuloso
%    iteracoes: a quantidade de iteracoes que faremos.
%    ----ARGUMENTOS OPCIONAIS
%        progress_bar: barra de progresso das simulacoes.
%
%   SAIDA: uma matriz com os resultados, onde cada linha 'i' (isto é,
%   resultado(i)) contém a saída da simulação i.
%   As colunas de resultado serão as seguintes:
%       resultado(i, 1):  valor inicial de x usado na simulação i
%       resultado(i, 2):  valor inicial de y usado na simulação i
%       resultado(i, 3):  valor inicial de phi usado na simulação i
%       resultado(i, 4):  delta usado ao longo da simulação
%       resultado(i, 5):  valor final de x na simulação i
%       resultado(i, 6):  valor final de y na simulação i
%       resultado(i, 7):  valor final de phi na simulação i
%       resultado(i, 8):  1 se o caminhao estacionou bem na simulação i; 0 caso contrário.
%       resultado(i, 9):  quantidade de passos tomada para estacionar na simulação i
%       resultado(i, 10): o erro de x na simulação i
%       resultado(i, 11): o erro de y na simulação i
%       resultado(i, 12): o erro de phi na simulação i
%       resultado(i, 13): o Erro do Estacionamento na simulação i
%       resultado(i, 14): o Erro de Trajetória na simulação i

    erro = 0.05;

    update_progress_bar = false;

    if (length(varargin) >= 1)
        progress_bar = varargin{1};
        update_progress_bar = true;
    end

    %matriz de resultados
    resultado = zeros(iteracoes, 14);



    %Quantidade de passos que o caminhao anda por iteracao. E a velocidade.
    delta = 5;

    %distancia contada a partir das paredes do estacionamento nas quais o
    %caminhao pode ser colocado aleatoriamente.
    padding = ceil(delta*(cosd(30) + cosd(60)));

    % xmeta: o valor ideal de x para onde o caminhão deve se deslocar.
    xmeta = 50;

    % ymeta: o valor ideal de y para onde o caminhão deve se deslocar.
    ymeta = 100;

    % phimeta: o valor ideal de phi que o caminhão deve ter final de seu deslocamento.
    phimeta = 90;

    %Universo de discurso do estacionamento descrito no formato
    %[x_inicial, x_final, y_inicial, y_final]
    estacionamento = [0, 100, 0, 100];

    %Universo de discurso do angulo do caminhao (phi)
    % o limite foi definido como [-105, 285] para cobrir eventuais valores fora
    % do limite mas os angulos variam de [-90,270]
    universo_phi = [-90 270];



    %laco principal
    for iteracao = 1:iteracoes
        x = rnd_position(estacionamento(1) + padding, estacionamento(2) - padding); %não colocaremos o caminhão colado na parede
        y = rnd_position(estacionamento(3) + padding, 50); %não colocaremos o caminhão colado na parede. O '50' vem das restrições do problema original
        phi = rnd_position(universo_phi(1), universo_phi(2));

        resultado(iteracao,:) = [x y phi delta estaciona(x, y, phi, delta, xmeta, ymeta, phimeta, erro, estacionamento, fis)];

        if (update_progress_bar) %atualiza contador de progresso, se conveniente
            waitbar(iteracao/iteracoes, progress_bar);
        end
    end

end



function rnd = rnd_position(minimo, maximo)
%Produz um valor aletorio entre os parametros 'minimo' e 'maximo'.
    rnd = rand() * (maximo - minimo) + minimo;
end
