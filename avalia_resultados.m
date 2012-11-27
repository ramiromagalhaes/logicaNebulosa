function estatisticas = avalia_resultados( resultado )
    %a partir dos resultados de uma simulação, cria uma matriz com média,
    %desvio padrão e variância dos resultados
    %   ENTRADA: matriz de resultado conforme a produzida pela função
    %   simula_estacionamento
    %   SAIDA: matriz de estatísticas sobre cada parâmetro produzido pela
    %   função simula_estacionento. A primeira linha conterá a média, a segunda
    %   o desvio padrão e a terceira a variância.

    estatisticas = zeros(3, size(resultado,2));

    for i = 1:size(resultado,2)
        estatisticas(1, i) = mean( resultado(:,i) );
        estatisticas(2, i) = std ( resultado(:,i) );
        estatisticas(3, i) = var ( resultado(:,i) );
    end

end
