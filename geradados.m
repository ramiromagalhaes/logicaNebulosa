% data = geradados(fisFilename)
%
% Gera dados para o caminhao em formato de matriz
% a partir de um FIS Mamdani.
%
% Parametros: quantidade de intervalos para cada vari�vel fuzzy
function geradados(fisFilename)
    if nargin < 3
        fisFilename = readfis('fis/caminhao-default.fis');
    end

    %gera a lista de pares de entrada [X, PHI]
    [X, PHI] = meshgrid( ...
        linspace(0, 100), ...
        linspace(-90, 270, 360) ...
    );
    entradas = [X(:) PHI(:)];

    %gera matriz com dados de entrada e sa�da [X PHI Saida]
    saidas = evalfis(entradas, fisFilename);
    data = [entradas saidas];

    %guarda os dados num arquivo, para que todos possam usá-lo.
    filename = get_output_file_name();
    csvwrite(filename, data);
end



function name = get_output_file_name()
%Função utilitária que cria um nome variável para as saídas produzidas.
    the_time = clock();
    username = getenv('USERNAME');
    name = ['data/' username '-' ...
                num2str(the_time(1)) '-' num2str(the_time(2)) '-' ...
                num2str(the_time(3)) '-' num2str(the_time(4)) '-' ...
                num2str(the_time(5)) '-' num2str(the_time(6)) '.csv'];
end
