function [ac ee et] = simula_varios(fis, x_precision, y_precision, phi_precision)

x_range = linspace(25, 75, x_precision);
y_range = linspace(0, 50, y_precision);
phi_range = linspace(-90, 270, phi_precision);

total_ac = [];
total_ee = [];
total_et = [];

for xp = 1:x_precision
    for yp = 1:y_precision
        for phip = 1:phi_precision
            [local_ac local_ee local_et] = simula_caminhao(fis, x_range(xp), y_range(yp), phi_range(phip), 0, '');

            total_ac = [total_ac local_ac];
            total_ee = [total_ee local_ee];
            total_et = [total_et local_et];
        end
    end
end

ac = size(total_ac);
ee = mean(total_ee);
et = mean(total_et);