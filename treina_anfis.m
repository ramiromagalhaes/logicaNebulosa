function treina_anfis(treinamento)
    % Como o m�todo ANFIS j� est� implementado no Fuzzy Toolbox do Matlab,
    % resta-nos saber qual melhor combina��o de par�metros pode otimizar o
    % resultado do ANFIS.
    %
    % Essa fun��o gera um fis inicial utilizando as fun��es de gera��o
    % existentes no pr�prio Matlab: genfis1, genfis2 e genfis3 passando
    % diferentes par�metros para as mesmas. Cada novo par�metro que �
    % passado para uma dessas fun��es gera um novo arquivo fis, cada um
    % desses novos fis s�o passados ao ANFIS e, por fim, para a simula��o
    % do caminh�o, que gera as m�tricas de cada um dos percursos.
    
    roda_com_genfis1(treinamento); % Criando fis iniciais e rodando ANFIS com genfis1
    roda_com_genfis2(treinamento); % Criando fis iniciais e rodando ANFIS com genfis2
    roda_com_genfis3(treinamento); % Criando fis iniciais e rodando ANFIS com genfis3
   
end


function roda_com_genfis1 (treinamento)
    % Roda o ANFIS gerando os arquivos FIS iniciais com o genfis1.
    %
    % O nome dos arquivos gerados s�o FIS_ANFIS_genfis1_NumeroMFs_Epoca.fis
    %
    % Os arquivos ser�o gerados dentro da pasta %DIRETORIO_ATUAL%/fis/anfis
    % Para evitar problemas, certifique-se que esses diret�rios j� existam.
    %
    % Param:
    %   - treinamento: a matriz com as regras iniciais (antecedentes e 
    %                  consequentes).
    %
    arq_saida = 'fis/FIS_ANFIS_genfis1_';
    % Prefixo do nome do arquivo de sa�da    
    for numMFs = 2 : 20
    % numMFs � um dos par�metros que podem ser mudados no genfis1, estamos
    % variando esse n�mero de 2 a 20 para, posteriormente, testarmos qual
    % obteve melhot resultado
        sufixo = strcat(int2str(numMFs), '_');
        % A vari�vel sufixo ajuda a criar nome de arquivos dinamicamente
        for epoch_n = 1 : 10
            % A �poca � um par�metro que pode ser mudado no m�todo ANFIS
            sufixo_atual = strcat(sufixo, int2str(epoch_n));
            % Criando o sufixo do nome do arquivo
            in_fis = genfis1(treinamento,numMFs);
            % Gerando o fis inicial atrav�s da fun��o genfis1
            out_fis = anfis(treinamento,in_fis,epoch_n);
            % Passando o fis gerado para o m�todo ANFIS
                            
            nome_arq = strcat(arq_saida, sufixo_atual);
            % Gerando o nome do arquivo
            writefis(out_fis, nome_arq);
            % Gravando o arquivo FIS no disco
            disp (nome_arq);
            % Escrevendo na tela o nome do arquivo gerado. Dessa forma,
            % temos mais controle em que parte est� o algoritmo.
        end
    end
end

function roda_com_genfis2 (treinamento)
    % Roda o ANFIS gerando os arquivos FIS iniciais com o genfis2.
    %
    % O nome dos arquivos gerados s�o FIS_ANFIS_genfis2_Epoca_Radii.fis
    %    
    % Os arquivos ser�o gerados dentro da pasta %DIRETORIO_ATUAL%/fis/anfis
    % Para evitar problemas, certifique-se que esses diret�rios j� existam.
    %
    % Param:
    %   - treinamento: a matriz com as regras iniciais (antecedentes e 
    %                  consequentes).
    %
    
    arq_saida = 'fis/FIS_ANFIS_genfis2_';
    % Prefixo do nome do arquivo
    input_treinamento = treinamento(:,1:1:end-1);
    % Obtendo os antecedentes das regras
    output_treinamento = treinamento(:,end);
    % Obtendo os consequentes das regras
    
    for epoch_n = 2 : 20
    % A �poca � um par�metro que pode ser mudado no m�todo ANFIS, estamos
    % variando esse n�mero de 2 a 20 para, posteriormente, testarmos qual
    % obteve melhot resultado
        sufixo = strcat(int2str(epoch_n), '_');
        % A vari�vel sufixo ajuda a criar nome de arquivos dinamicamente
        for radii = 2 : 10
            sufixo_atual = strcat(sufixo, int2str(radii));        
            % Criando o sufixo atual do arquivo
            in_fis = genfis2(input_treinamento,output_treinamento, (radii / 10));
            % Chamando genfis2 para criarmos os fis iniciais. O genfis2
            % precisa que os antecedentes e consequentes sejam passados
            % separadamente (diferente do genfis1). 
            out_fis = anfis([input_treinamento output_treinamento], in_fis, epoch_n);
            % Gerando o novo fis atrav�s do anfis
                        
            nome_arq = strcat(arq_saida, sufixo_atual);
            % Gerando o nome do arquivo a ser salvo
            writefis(out_fis, nome_arq);
            % Gravando o fis em arquivo
            disp(nome_arq);
            % Escrevendo o nome do arquivo na tela para sabermos em que
            % passo estamos
        end
    end
end

function roda_com_genfis3 (treinamento)
% Roda o ANFIS gerando os arquivos FIS iniciais com o genfis3.
%
% O nome dos arquivos gerados s�o FIS_ANFIS_genfis3_Epoca_Radii.fis
%    
% Os arquivos ser�o gerados dentro da pasta %DIRETORIO_ATUAL%/fis/anfis
% Para evitar problemas, certifique-se que esses diret�rios j� existam.
%
% Param:
%   - treinamento: a matriz com as regras iniciais (antecedentes e 
%                  consequentes).
%
    arq_saida = 'fis/FIS_ANFIS_genfis3_';
    % Prefixo do nome do arquivo
    input_treinamento = treinamento(:,1:1:end-1);
    % Obtendo os antecedentes das regras
    output_treinamento = treinamento(:,end);
    % Obtendo os consequentes das regras
    
    for epoch_n = 2 : 20
    % A �poca � um par�metro que pode ser mudado no m�todo ANFIS, estamos
    % variando esse n�mero de 2 a 20 para, posteriormente, testarmos qual
    % obteve melhot resultado
        sufixo = strcat(int2str(epoch_n), '_');
        % A vari�vel sufixo ajuda a criar nome de arquivos dinamicamente
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
            disp(nome_arq);
            % Exibe o nome do arquivo
        end
    end
end
