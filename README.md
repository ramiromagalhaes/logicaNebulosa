# 2º Trabalho de Lógica Nebulosa - PPGI - Universidade Federal do Rio de Janeiro
Este é o código-fonte e resultados das simulações e treinamentos do 2º trabalho de Lógica Nebulosa do 3º bloco de 2012 do Programa de Pós-Graduação de Informática da Universidade Federal do Rio de Janeiro.

Os autores deste trabalho são:

> Juan Marcelo Dell’Oso                		112094854
> Mariam dos Passos Afonso da Conceição		112169455
> Ramiro Pereira de Magalhães          		111510679
> Renato Moura Martins Medeiros        		112113797

# Dados de treinamento
Os dados utilizados para o treinamento de sistemas nebulosos com os diversos algoritmos que experimentamos (BLS, RLS, Gradiente e ANFIS) estão no arquivo 'treino/treinamento.csv' e podem ser facilmente carregados usando a função 'csvread' do Matlab.

# Treinamento
Use a função 'treina' para treinar sistemas nebulosos TSK usando os métodos BLS, RLS, Gradiente e ANFIS. O único parâmetro dessa função é a massa de dados com a qual o treinamento será executado. Ao total, são mais de 600 treinamentos diferentes que serão feitos, e podem demorar várias horas para serem concluídos.

Se precisar fazer treinamentos diferentes e com outros parâmetros, consulte as funções 'bls', 'rls', 'gradiente' que desenvolvemos, assim como a função ANFIS do Matlab. Para mais detalhes, veja nosso relatório em [https://docs.google.com/document/d/1UuyMFG5MQJrIryI72-0zRUgXDsCP97XGaSAwr1r_Vk0].

*Nota:* os descritores dos sistemas nebulosos são arquivos FIS que serão armazenados na pasta 'fis' durante a execução dos treinamento.

# Simulação
Use a função 'simula' para executar simulações com todos os sistemas nebulosos descritos em arquivos FIS presentes na pasta 'fis'. Note que são mais de 600 simulações que serão executadas. Na nossa experiência o tempo total dispendido na execução de todas as simulações supera 9 horas.

Se precisar fazer simulações específicas com outros parâmetros ou sistemas nebulosos, consulte a função 'simula_estacionamento'.


