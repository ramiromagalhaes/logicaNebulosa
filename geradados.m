function data = geradados(fisFileName, saveToFile)
% Cria uma matriz cujas linhas contem a entrada que o sistema de controle
% do caminhao pode receber, associadas aos giro do volante resultante. O
% resultado dessa funcao e uma matriz cuja primeira coluna representa a
% posicao do caminhao, a segunda coluna o angulo do caminhao, e a terceira
% o giro do volante resultante.
% Os parâmetros de entrada da funcao são:
%   fisFileName - nome do FIS a usar para construir a matriz de dados.
%   saveToFile - um valor booleano (cujo default é true) que, se for
%                verdadeiro, exportara a matriz como um arquivo CSV dentro
%                da pasta 'data'.

    if nargin < 1
        fis = readfis('fis/caminhao-default.fis');
    else
        fis = readfis(fisFileName);
    end

    if nargin < 2
        saveToFile = true;
    end

    %gera a lista de pares de entrada [X, PHI]
    [X, PHI] = meshgrid( ...
        linspace(0, 100), ...
        linspace(-90, 270, 360) ...
    );
    entradas = [X(:) PHI(:)];

    %gera matriz com dados de entrada e sa�da [X PHI Saida]
    saidas = evalfis(entradas, fis);
    data = [entradas saidas];

    %guarda os dados num arquivo, para que todos possam usá-lo.
    if (saveToFile)
        filename = get_output_file_name();
        csvwrite(filename, data);
    end
end



function name = get_output_file_name()
%Função utilitária que cria um nome de arquivo para as saídas produzidas.
    the_time = clock();
    username = getenv('USERNAME');
    name = ['data/' username '-' ...
                num2str(the_time(1)) '-' num2str(the_time(2)) '-' ...
                num2str(the_time(3)) '-' num2str(the_time(4)) '-' ...
                num2str(the_time(5)) '-' num2str(the_time(6)) '.csv'];
end
