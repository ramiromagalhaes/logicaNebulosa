function testa_anfis()
    % Como o método ANFIS já está implementado no Fuzzy Toolbox do Matlab,
    % resta-nos saber qual melhor combinação de parâmetros pode otimizar o
    % resultado do ANFIS.
    %
    % Essa função gera um fis inicial utilizando as funções de geração
    % existentes no próprio Matlab: genfis1, genfis2 e genfis3 passando
    % diferentes parâmetros para as mesmas. Cada novo parâmetro que é
    % passado para uma dessas funções gera um novo arquivo fis, cada um
    % desses novos fis são passados ao ANFIS e, por fim, para a simulação
    % do caminhão, que gera as métricas de cada um dos percursos.
    %
    % ATENÇÃO: Antes de roda essa função, certifique-se de que o arquivo
    % testing_data.csv existe dentro da pasta data. Caso contrário, um erro
    % será gerado.
     
    if exist('data/testing_data.csv', 'file') == 0
        fprintf(2, 'O Arquivo testing_data.csv não existe dentro da pasta data. Testa ANFIS não pode continuar.\n');
        return;
    end
    
    if exist('data/ramiro-2012-11-10-21-38-56.9535.csv', 'file') == 0
        fprintf(2, 'O Arquivo ramiro-2012-11-10-21-38-56.9535.csv não existe dentro da pasta data. Testa ANFIS não pode continuar.\n');
        return;
    end
    
    cria_pastas();
    % Criando estrutura de pastas necessárias para execução do script.
    
    dados = csvread('data/ramiro-2012-11-10-21-38-56.9535.csv');
    % Lendo o arquivo CSV que contém os dados
    treinamento = dados(1:2:end,:);
    % Utilizaremos apenas os índices ímpares para treinamento
    
    %roda_com_genfis1(treinamento);
    % Criando fis iniciais e rodando ANFIS com genfis1
    %roda_com_genfis2(treinamento);
    % Criando fis iniciais e rodando ANFIS com genfis2
    %roda_com_genfis3(treinamento);
    % Criando fis iniciais e rodando ANFIS com genfis3
    
    clear treinamento;
    % Liberando memória
    clear dados;
    % Liberando memória
    
    testa_anfis_gerados();
    % Testando os ANFIS gerados acima
    compara_csv_gerados();
    % Comparando os resultados obtidos
    
    fprintf(1, '\n\nTesta ANFIS terminou \n\n');
end

function cria_pastas()
% O algoritmo de teste do ANFIS geral milhares de arquivos (centenas de
% .fis e centenas de .csv). Para melhor organizá-los, esse algoritmo grava
% (e futuramente lê esses arquivos) em pastas para que haja uma melhor
% organização.
    if exist('fis/anfis', 'dir') == 7
        fprintf(1, 'Pasta ANFIS já existe \n');
    else
        mkdir('fis/anfis');
        fprintf(1, 'Pasta ANFIS inexistente.. pasta criada \n');
    end
    
    if exist('fis/anfis/res', 'dir') == 7
        fprintf(1, 'Pasta RES já existe \n');
    else
        mkdir('fis/anfis/res');
        fprintf(1, 'Pasta RES inexistente.. pasta criada \n');
    end

end

function roda_com_genfis1 (treinamento)
    % Roda o ANFIS gerando os arquivos FIS iniciais com o genfis1.
    %
    % O nome dos arquivos gerados são FIS_ANFIS_genfis1_NumeroMFs_Epoca.fis
    %
    % Os arquivos serão gerados dentro da pasta %DIRETORIO_ATUAL%/fis/anfis
    % Para evitar problemas, certifique-se que esses diretórios já existam.
    %
    % Param:
    %   - treinamento: a matriz com as regras iniciais (antecedentes e 
    %                  consequentes).
    %
    arq_saida = 'fis/anfis/FIS_ANFIS_genfis1_';
    % Prefixo do nome do arquivo de saída    
    for numMFs = 2 : 20
    % numMFs é um dos parâmetros que podem ser mudados no genfis1, estamos
    % variando esse número de 2 a 20 para, posteriormente, testarmos qual
    % obteve melhot resultado
        sufixo = strcat(int2str(numMFs), '_');
        % A variável sufixo ajuda a criar nome de arquivos dinamicamente
        for epoch_n = 1 : 10
            % A época é um parâmetro que pode ser mudado no método ANFIS
            sufixo_atual = strcat(sufixo, int2str(epoch_n));
            % Criando o sufixo do nome do arquivo
            in_fis = genfis1(treinamento,numMFs);
            % Gerando o fis inicial através da função genfis1
            out_fis = anfis(treinamento,in_fis,epoch_n);
            % Passando o fis gerado para o método ANFIS
                            
            nome_arq = strcat(arq_saida, sufixo_atual);
            % Gerando o nome do arquivo
            writefis(out_fis, nome_arq);
            % Gravando o arquivo FIS no disco
            nome_arq
            % Escrevendo na tela o nome do arquivo gerado. Dessa forma,
            % temos mais controle em que parte está o algoritmo.
        end
    end
end

function roda_com_genfis2 (treinamento)
    % Roda o ANFIS gerando os arquivos FIS iniciais com o genfis2.
    %
    % O nome dos arquivos gerados são FIS_ANFIS_genfis2_Epoca_Radii.fis
    %    
    % Os arquivos serão gerados dentro da pasta %DIRETORIO_ATUAL%/fis/anfis
    % Para evitar problemas, certifique-se que esses diretórios já existam.
    %
    % Param:
    %   - treinamento: a matriz com as regras iniciais (antecedentes e 
    %                  consequentes).
    %
    
    arq_saida = 'fis/anfis/FIS_ANFIS_genfis2_';
    % Prefixo do nome do arquivo
    input_treinamento = treinamento(:,1:1:end-1);
    % Obtendo os antecedentes das regras
    output_treinamento = treinamento(:,end);
    % Obtendo os consequentes das regras
    
    for epoch_n = 2 : 20
    % A época é um parâmetro que pode ser mudado no método ANFIS, estamos
    % variando esse número de 2 a 20 para, posteriormente, testarmos qual
    % obteve melhot resultado
        sufixo = strcat(int2str(epoch_n), '_');
        % A variável sufixo ajuda a criar nome de arquivos dinamicamente
        for radii = 2 : 10
            sufixo_atual = strcat(sufixo, int2str(radii));        
            % Criando o sufixo atual do arquivo
            in_fis = genfis2(input_treinamento,output_treinamento, (radii / 10));
            % Chamando genfis2 para criarmos os fis iniciais. O genfis2
            % precisa que os antecedentes e consequentes sejam passados
            % separadamente (diferente do genfis1). 
            out_fis = anfis([input_treinamento output_treinamento], in_fis, epoch_n);
            % Gerando o novo fis através do anfis
                        
            nome_arq = strcat(arq_saida, sufixo_atual);
            % Gerando o nome do arquivo a ser salvo
            writefis(out_fis, nome_arq);
            % Gravando o fis em arquivo
            nome_arq
            % Escrevendo o nome do arquivo na tela para sabermos em que
            % passo estamos
        end
    end
end

function roda_com_genfis3 (treinamento)
% Roda o ANFIS gerando os arquivos FIS iniciais com o genfis3.
%
% O nome dos arquivos gerados são FIS_ANFIS_genfis3_Epoca_Radii.fis
%    
% Os arquivos serão gerados dentro da pasta %DIRETORIO_ATUAL%/fis/anfis
% Para evitar problemas, certifique-se que esses diretórios já existam.
%
% Param:
%   - treinamento: a matriz com as regras iniciais (antecedentes e 
%                  consequentes).
%
    arq_saida = 'fis/anfis/FIS_ANFIS_genfis3_';
    % Prefixo do nome do arquivo
    input_treinamento = treinamento(:,1:1:end-1);
    % Obtendo os antecedentes das regras
    output_treinamento = treinamento(:,end);
    % Obtendo os consequentes das regras
    
    for epoch_n = 2 : 20
    % A época é um parâmetro que pode ser mudado no método ANFIS, estamos
    % variando esse número de 2 a 20 para, posteriormente, testarmos qual
    % obteve melhot resultado
        sufixo = strcat(int2str(epoch_n), '_');
        % A variável sufixo ajuda a criar nome de arquivos dinamicamente
        for radii = 2 : 10
            sufixo_atual = strcat(sufixo, int2str(radii));
            % Cria o sufixo do arquivo dinamicamente
            in_fis = genfis3(input_treinamento,output_treinamento, 'sugeno', radii);
            % Cria o arquivo fis inicial
            out_fis = anfis([input_treinamento output_treinamento], in_fis, epoch_n);
            % Passa o arquivo inicial para o ANFIS

            nome_arq = strcat(arq_saida, sufixo_atual);
            % Cria o nome do arquivo a ser salvo
            writefis(out_fis, nome_arq);
            % Escreve arquivo no disco
            nome_arq
            % Exibe o nome do arquivo
        end
    end
end

function testa_anfis_gerados()
% Depois de gerar os arquivos fis através das funções de genfis1, genfis2 e
% genfis3 e passá-los para o ANFIS, é hora de submetermos os fis gerados
% para uma bateria de testes, a fim de verificarmos qual tem melhor
% desempenho.
%
% Logo depois que cada fis é testado, um arquivo csv é gerado dentro do
% diretório %DIRETORIO_ATUAL%/fis/anfis/res/res seguindo o nome res(TIPO DE
% FIS)(NUMERO INTERNO)(NUMERO EXTERNO), sendo que (TIPO DE FIS) representa
% a utilização de genfis1, genfis2 ou genfis3 e (NUMERO INTERNO) e (NUMERO
% EXTERNO) representam número de membership functions, épocas ou radii,
% dependendo do tipo de genfis utilizado. Cada linha desse CSV representa
% os resultados de um dos dos testes. A primeira coluna do arquivo
% representa se o caminhão estacionou ou não, a segunda coluna representa o
% erro de estacionamento e a terceira coluna o erro de trajetória.

    dados = csvread('data/testing_data.csv');
    % Como utilizamos os índices ímpares para os treinamentos, os índices
    % pares foram obtidos e criou-se um novo arquivo CSV com eles, mais um
    % número aleatório, entre 0 e 25, que representa a coordenada Y para
    % que os testes pudessem ser feitos.
    nome_prefixo = 'fis/anfis/FIS_ANFIS_genfis';
    % Prefixo dos nomes dos fis que serão lidos

    for tipo_fis = 1 : 3
    % Como os arquivos fis tem a estrutura FIS_ANFIS_genfis(tipo do
    % fis)_(alguma informação numérica)_(outra informação numérica).fis,
    % esses loops são responsáveis por gerar os nomes dos arquivos.
        nome_tipo_prefiro = strcat(nome_prefixo, int2str(tipo_fis), '_');
        % Concatenando o tipo de fis ao nome (genfis1, genfis2 ou genfis3)
        % do arquivo a ser lido
        for i = 1 : 20
            nome_num_interno = strcat(nome_tipo_prefiro, int2str(i), '_');            
            for x = 2 : 10
                nome_num_externo = strcat(nome_num_interno, int2str(x));
                % Gerando o nome do fis por completo
                todos_e = zeros(length(dados), 1);
                % Cada fis é testado 18 mil vezes com os dados que estão na
                % variável "dados". O vetor todos_e conterá 18 mil linhas,
                % uma para cada simulação, com os valores 1 (não estacionou
                % corretamente) ou 0 (estacionou corretamente).
                todos_ee = zeros(length(dados), 1);
                % Cada fis é testado 18 mil vezes com os dados que estão na
                % variável "dados". O vetor todos_ee conterá 18 mil linhas,
                % uma para cada simulação, com os valores de erro de
                % estacionamento (o quão distante do ponto esperado para
                % estacionar o caminhão parou).
                todos_et = zeros(length(dados), 1);
                % Cada fis é testado 18 mil vezes com os dados que estão na
                % variável "dados". O vetor todos_ee conterá 18 mil linhas,
                % uma para cada simulação, com os valores de erro de
                % estacionamento (o quão distante do ponto esperado para
                % estacionar o caminhão parou).
                if exist(strcat(nome_num_externo, '.fis'), 'file') ~= 0
                % Testa se o arquivo realmente existe na pasta. Esse teste
                % é importante porque, embora na teoria todos os arquivos
                % existam, se algum arquivo não existir o script será
                % abortado.
                    fis = readfis(nome_num_externo);
                    % Lê o arquivo cujo nome foi criado
                    for linha_atual = 1 : length(dados)
                    % Enquanto houver linhas no arquivo de testes
                        [e, ee, et] = simula_caminhao(fis, dados(linha_atual, 1), dados(linha_atual, 2), dados(linha_atual, 3));
                        % Chama o simula_caminhao passando o fis lido e os
                        % dados do arquivo de testes
                        todos_e(linha_atual, 1) = e;
                        % Armazena a informação se o caminhão estacionou
                        % com sucesso ou não no teste realizado
                        todos_ee(linha_atual) = ee;
                        % Armazena a informação do erro de estacionamento
                        % do caminhão
                        todos_et(linha_atual) = et;
                        % Armazena a informação do erro de trajetória do
                        % caminhão
                    end
                    nome_saida = strcat('fis/anfis/res/res', int2str(tipo_fis), int2str(i), int2str(x), '.csv');
                    % Cria o nome do arquivo a ser gerado com o resultado
                    % da bateria de testes executada
                    csvwrite(nome_saida, [todos_e, todos_ee, todos_et]);
                    % Depois que os 18 mil testes forem executados, seus
                    % dados são gravados em um arquivo .csv dentro do
                    % diretório fis/anfis/res/res seguindo o nome res(TIPO
                    % DE FIS)(NUMERO INTERNO)(NUMERO EXTERNO), sendo que
                    % (TIPO DE FIS) representa a utilização de genfis1,
                    % genfis2 ou genfis3 e (NUMERO INTERNO) e (NUMERO
                    % EXTERNO) representam número de membership functions,
                    % épocas ou radii, dependendo do tipo de genfis
                    % utilizado.                    
                    nome_saida
                    % Escreve o nome do arquivo gerado, para acompanharmos
                    % em qual estado está o algoritmo.
                end
            end
        end
    end
end

function compara_csv_gerados()
% Depois de que cada fis foi exposto a uma bateria de testes pela função
% testa_anfis_gerados, é necessário obter o resultado desses testes e
% consolidá-los em uma matriz. Esse método gera um arquivo na raiz do
% projeto chamado resultado_anfis.csv onde cada linha representa o
% resultado dos testes consolidados. A primeira coluna contém o nome do
% arquivo com resultados consolidados, a segunda coluna a porcentagem de
% caminhões que estacionaram no arquivo citado, a terceira coluna a média
% de erro de estacionamento, a quarta coluna o desvio padrão de erro de
% estacionamento, a quinta coluna, a média de erro de trajetória e,
% finalmente, a sexta coluna o desvio padrão de erro de trajetória.
    inicio_dir = 'fis\anfis\res\';
    % Local onde os CSVs foram salvos
    arquivos_csv_inicial = dir(fullfile(strcat(inicio_dir, '*.csv')));
    % Lista o nome de todos os arquivos CSVs presentes no diretório

    parq = fopen('resultado_anfis.csv', 'w');
    % Cria o arquivo com o resultado da comparação. Esse arquivo será
    % gerado na raiz do projeto.
    for i = 1 : length(arquivos_csv_inicial)
    % Enquanto ainda houver arquivos CSVs a serem lidos
        nome_arquivo_curto = arquivos_csv_inicial(i, 1).name;
        % Obtém o nome do arquivo cujos dados vamos ler
        nome_arquivo = strcat(inicio_dir, nome_arquivo_curto);
        % Concatena o nome do arquivo ao diretório onde ele está localizado
        dados_arquivo = csvread(nome_arquivo);
        % Lê as informações do arquivo

        porcentagem =length(find(dados_arquivo(:,1)==0)) / ... 
            length(dados_arquivo(:,1)) * 100;
        % Calcula a porcentagem dos caminhões que estacionaram. A primeira
        % coluna de dados_arquivos contém os números 0 (estacionou) e 1
        % (não estaciou) (veja simula_caminhão.m linha 79). No numerador
        % contamos quantos números zeros existem nesse vetor-coluna e no
        % denominador contamos quantos elementos (sem distinção de valor)
        % existem no vetor-coluna. No final, multiplicamos por 100.
        media_estac = sum(abs(dados_arquivo(:,2))) / ...
            length(dados_arquivo(:,2));
        % Calculamos a média do erro de estacionamento em todos os testes.
        dev_pad_estac = std(dados_arquivo(:,2));
        % Calculamos o desvio padrão do erro de estacionamento em todos os
        % testes. 
        med_erro_trajetoria = sum(abs(dados_arquivo(:,3))) / ...
            length(dados_arquivo(:,3));
        % Calcula a média de erros de trajetória nos testes
        dev_erro_trajetoria = std(dados_arquivo(:,3));
        % Calcula o desvio padrão de erros de trajetória nos testes

        fprintf(parq, '%s,%f,%f,%f,%f,%f\n', nome_arquivo_curto, ...
            porcentagem, media_estac, dev_pad_estac, med_erro_trajetoria, ...
            dev_erro_trajetoria);
        % Escreve a informação obtida em arquivo

    end
    fclose(parq);
end