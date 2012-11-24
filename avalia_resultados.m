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

    %{
    %Se algum dia alguém quiser escrever em arquivo as estatísticas, é só
    usar o seguinte código:

    for i = 1:length(estatisticas(:,1))
        fprintf(fd,'%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', ...
            estatisticas(i, 1), estatisticas(i, 2), estatisticas(i, 3), estatisticas(i, 4), ...
            estatisticas(i, 5), estatisticas(i, 6), estatisticas(i, 7), estatisticas(i, 8), ...
            estatisticas(i, 9), estatisticas(i, 10), estatisticas(i, 11), estatisticas(i, 12), ...
            estatisticas(i, 13), estatisticas(i, 14) );
    end
    %}

end
