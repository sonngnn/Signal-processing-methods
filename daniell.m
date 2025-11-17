% Nous avons choisi d'implémenter cette fonction avec une boucle for mais nous
% pouvons également utiliser la convolution

function [Px_lisse, f] = daniell(x, Nfft, Fe)
    
    % Calcul du spectre de puissance (d'après le Th. de WK)
    X = fft(x, Nfft);
    Px = abs(X).^2 / Nfft;

    % Taille de la fenêtre glissante
    window_length = 5;
    
    % Spectre lissé
    Px_lisse = zeros(1, Nfft);
    
    % Boucle sur chaque point fréquentiel
    for i = 1:Nfft
        % Fenêtre centrée sur i
        indices = mod((i-floor(window_length/2):i+floor(window_length/2)) -1, Nfft) +1; 
        Px_lisse(i) = mean(Px(indices));
    end
    
    % Axe des fréquences
    f = (0:Nfft-1) * Fe / Nfft;
end
