%
% dados = geradados(fisCaminhaoMandani, intervaloX, intervaloPHI)
%
% Gera dados para o caminhao em formato de matriz
% a partir de um FIS Mamdani.
%
% Parametros: quantidade de intervalos para cada vari�vel fuzzy

function data = geradados(fisCaminhaoMandani, intervaloX, intervaloPHI)

if nargin < 3
    fisCaminhaoMandani = readfis('caminhao');
    intervaloX = 10;
    intervaloPHI = 10;
    
    fprintf('Parametros default: "caminhao.fis", 10, 10');
end

%gera valores, dada a quantidade de intervalos especificada
% vou dar espaco maior para o caminhao
%intervalosX = linspace(0 +1, 100 -1, intervaloX);
%intervalosPHI = linspace(-105 +1, 285 -1, intervaloPHI);
intervalosX = linspace(0 + intervaloX, 100 - intervaloX, intervaloX);
intervalosPHI = linspace(-105 + intervaloPHI, 285 - intervaloPHI, intervaloPHI);



%gera a lista de pares de entrada [X, PHI]
[X, PHI] = meshgrid(intervalosX, intervalosPHI);
entradas = [X(:) PHI(:)];

%gera matriz com dados de entrada e sa�da [X PHI Saida]
saidas = evalfis(entradas, fisCaminhaoMandani);
data = [entradas saidas];