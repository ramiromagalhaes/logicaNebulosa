fisMandani = readfis('caminhao');
fisMandani.name = 'Mandani';
writefis(fisMandani, 'caminhaoMandani');

intervaloX = 10;
intervaloPHI = 10;
    
%gera dados do caminhao a partir do Mandani, com parametro default
dados = geradados(fisMandani, intervaloX, intervaloPHI);

intervaloX = 10;
intervaloY = 10;
intervaloPHI = 10;

nMFs = zeros(3,2);

nMFs(1,:) = [3,3];
nMFs(2,:) = [5,5];
nMFs(3,:) = [7,7];

for indiceNMF = 1:size(nMFs, 1)
    %Treina diversos FIS
    fprintf('Executando treinamentos ....\n');
    [fisANFIS, fisBLS, fisRLS, fisGradient] = executaTreinamentos(dados, nMFs(indiceNMF, 1), nMFs(indiceNMF, 2));

    fprintf('Simulando Mandani.....\n');
    [acMandani eeMandani etMandani] = simula_varios(fisMandani, intervaloX, intervaloY, intervaloPHI);

    fprintf('Simulando ANFIS.....\n');
    [acANFIS eeANFIS etANFIS] = simula_varios(fisANFIS, intervaloX, intervaloY, intervaloPHI);

    fprintf('Simulando BLS.....\n');
    [acBLS eeBLS etBLS] = simula_varios(fisBLS, intervaloX, intervaloY, intervaloPHI);

    fprintf('Simulando RLS.....\n');
    [acRLS eeRLS etRLS] = simula_varios(fisRLS, intervaloX, intervaloY, intervaloPHI);

    fprintf('Simulando Gradiente.....\n');
    [acGradient eeGradient etGradient] = simula_varios(fisGradient, intervaloX, intervaloY, intervaloPHI);

    %figuraEE = figure;
    %bar([eeMandani, etMandani ; eeANFIS, etANFIS ; eeBLS, etBLS ; eeRLS, etRLS ; eeGradient, etGradient],'grouped')
    %titulo = ['EE | ET [',num2str(intervaloX),', ',num2str(intervaloY),', ',num2str(intervaloPHI),'] - (Mandani - ANFIS - BLS - RLS - Gradient) ',num2str(nMFs(indiceNMF,1)),' x ',num2str(nMFs(indiceNMF,2))];
    %title(titulo);
    %imgEE = getframe(figuraEE);
    %imwrite(imgEE.cdata,[titulo,'.png']);
end