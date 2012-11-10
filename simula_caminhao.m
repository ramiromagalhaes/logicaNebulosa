%
% [ee et] = caminhao_simula(fis, x, y, phi)
%
% Simula um caminh�o at� chegar na borda superior do espa�o
% (ou m�ximo de passos)
%
% Parametros: granularidade da amostragem para cada vari�vel
function [estacionou ee et] = simula_caminhao(fis, x_inicial, y_inicial, phi_inicial, desenha, cor) 

    %Definicao do caminhao
    comp_cam=18; % comprimento do caminhao
    larg_cam=8; % largura do caminhao   

    if nargin < 5
        desenha = 0;
    end

    if nargin < 6
        cor = 'b';
    end
    
    passos = 0;
    
    %desetino final do caminhao
    x_meta=50;
    y_meta=100;
    phi_meta=90;
    
    %tamanho do passo
    delta = 5;
    
    x = x_inicial;
    y = y_inicial;
    phi = phi_inicial;
    
 %   fprintf('***** Vers�o ');
 %   fprintf(fis.name);
 %   fprintf('\n');
    
    if desenha == 1             
        plot_caminhao(x, y, phi, larg_cam, comp_cam, cor);
    end
    
    while ((y < 100) && (passos < 50))
        
        if phi>=285
            phi = phi - 360;
        else
            if phi <= -105
                phi = phi + 360;
            end
        end
        
        alpha = evalfis([x phi], fis);
        
        phi = phi + alpha;
        
        phi_rad = phi * pi / 180;
        
        x = x + delta*cos(phi_rad);
        y = y + delta*sin(phi_rad);

        if desenha == 1
            plot_caminhao(x, y, phi, larg_cam, comp_cam, cor);
            pause (0.3);
        end
        
        passos = passos + 1;
    end
    
    if y>=100
        estacionou = 1;
    else
        estacionou = 0;
    end
    
    ee = mydist([x y phi], [x_meta y_meta phi_meta]);
    
    ct = passos * delta;
    cr = mydist([x_inicial y_inicial], [x_meta y_meta]);
    et = ct ./ cr;
end

function res = mydist(v1, v2)
    res0 = dist([v1' v2']);
    res = res0(1, 2);
end
