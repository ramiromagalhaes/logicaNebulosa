function simula()
%SIMULA Executa simulacoes com todos os fis contidos no diretorio 'fis'

    fisDirName = 'fis/';
    outputDirName = 'data/';

    %'Velocidade' do caminhao.
    delta = 5;

    %distancia contada a partir das paredes do estacionamento nas quais o
    %caminhao pode ser colocado aleatoriamente.
    padding = ceil(delta*(cosd(30) + cosd(60)));

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
        resultado = simula_estacionamento(delta, 50, 100, 0, 0.05, 10000, [0 100 0 100], padding, [-90 270], fis, progressBarSimulacoes);
        estatisticas = avalia_resultados(resultado);
        disp(['Segundos tomados: ' num2str(cputime - tInicial)]);

        csvwrite([outputDirName filename '.csv'], resultado);
        csvwrite([outputDirName filename '-estatisticas.csv'], estatisticas);
    end

end

