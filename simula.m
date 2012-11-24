function simula()
%SIMULA Executa simulacoes com todos os fis contidos no diretorio 'fis'

    fisDirName = 'fis/';
    outputDirName = 'data/';

    iteracoes = 1000;

    fisList = dir(fisDirName);
    fisListSize = size(fisList, 1);

    textoProgressBar = 'Simulando ';
    progressBarFis = waitbar(0, 'Simulando ');
    progressBarSimulacoes = waitbar(0, 'Progresso da simulacao atual');

    for f = 1:fisListSize
        if (fisList(f).isdir)
            continue;
        end

        filename = fisList(f).name;

        % Configuramos o gerador de numeros aleatorios para que ele produza
        % a mesma sequencia de valores para cada teste.
        rng(229862740);

        waitbar(f/fisListSize, progressBarFis, [textoProgressBar filename]);

        fis = readfis([fisDirName filename]);

        tInicial = cputime;
        resultado = simula_estacionamento(0.05, iteracoes, fis, progressBarSimulacoes);
        estatisticas = avalia_resultados(resultado);
        disp(['Segundos tomados: ' num2str(cputime - tInicial)]);

        csvwrite([outputDirName filename '.csv'], resultado);
        csvwrite([outputDirName filename '-estatisticas.csv'], estatisticas);
    end

end

