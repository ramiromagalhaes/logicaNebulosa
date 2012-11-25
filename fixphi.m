function fixphi()
    outputDirName = 'data/';

    outputList = dir(outputDirName);
    outputSize = size(outputList, 1);

    xmeta = 50;
    ymeta = 100;
    phimeta = 90;
    erro = 0.05;

    for o = 1:outputSize
        if (outputList(o).isdir)
            continue;
        end

        if (~isempty(strfind(outputList(o).name, 'estatisticas')))
            continue;
        end

        filename = outputList(o).name;

        data = csvread([outputDirName filename]);

        for i = 1:size(data, 1)
            x = data(i, 5);
            y = data(i, 6);
            phi = data(i, 7);

            err_x = data(i, 10);
            err_y = data(i, 11);
            err_phi = eval_err(phi, phimeta);

            %Fixes

            sucesso = err_x < erro & ...
                err_y < erro & ...
                err_phi < erro;
            data(i, 8) = sucesso;

            data(i, 12) = err_phi;

            %Erro de estacionamento
            EE = sqrt((phi - phimeta)^2 + (x - xmeta)^2 + (y - ymeta)^2);
            data(i, 13) = EE;

            csvwrite([outputDirName filename], data);

            estatisticas = avalia_resultados(data);

            estatisticasFilename = filename(1:length(filename) - 4);
            csvwrite([outputDirName estatisticasFilename '-estatisticas.csv'], estatisticas);
        end
    end
end

function err = eval_err(val, expected)
    %Avalia qual o erro percentual entre val e expected.
    %O parâmetro val e o valor atual; expected e o valor esperado.
    err = abs((val - expected) / expected);
end

