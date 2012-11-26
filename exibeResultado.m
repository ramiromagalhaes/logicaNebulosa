function r = exibeResultado(filename)
%EXIBERESULTADO Summary of this function goes here
%   Detailed explanation goes here

    dataDir = 'data/';

    if (isempty(strfind(filename, 'estatisticas')))
        disp('Esta funcao le somente o arquivo de estatisticas.');
        r = -1;
        return;
    end

    data = csvread([dataDir filename]);

    if (~data)
        disp('Arquivo mencionado nao foi encontrado no diretorio de dados.');
        r = -2;
        return;
    end

    fprintf('                                   Media     Desv-Padrao\n');
    fprintf('Perc. de estacionamentos corretos: %5.2f      n/a\n', data(1, 8));
    fprintf('Erro de X                        : %5.2f     %5.2f\n', data(1, 10), data(2, 10));
    fprintf('Erro de Y                        : %5.2f     %5.2f\n', data(1, 11), data(2, 11));
    fprintf('Erro de PHI                      : %5.2f     %5.2f\n', data(1, 12), data(2, 12));
    fprintf('Erro de estacionamento           : %5.2f     %5.2f\n', data(1, 13), data(2, 13));
    fprintf('Erro de trajetória               : %5.2f     %5.2f\n', data(1, 14), data(2, 14));
    fprintf('\n');

    r = 0;
end

