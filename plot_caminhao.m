function plot_caminhao(x, y, phi, lc, cc)
    % Desenha caminhao na tela
    %  x = posicao do caminhao na garagem
    %  y = posicao do caminhao na garagem
    %  phi = angulo do caminhao
    %  Adriano Cruz
    %  UFRJ
    %  Copyright 1999

    x2 = x + 0.5 * lc * sind(phi);
    x3 = x - 0.5 * lc * sind(phi);
    x1 = x2 - cc * cosd(phi);
    x4 = x3 - cc * cosd(phi);

    y2 = y - 0.5 * lc * cosd(phi);
    y3 = y + 0.5 * lc * cosd(phi);
    y1 = y2 - cc * sind(phi);
    y4 = y3 - cc * sind(phi);

    plot([x3 x4 x1 x2], [y3 y4 y1 y2]);
    plot([x2 x3], [y2 y3], '*:');
end
