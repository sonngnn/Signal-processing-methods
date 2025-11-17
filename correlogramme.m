function [y, f] = correlogramme(x, Nfft, Fe)
    % Fonction pour calculer le corrélogramme d'un signal
    % Entrées :
    %   - x : Signal d'entrée
    %   - Nfft : Taille de la FFT
    %   - Fe : Fréquence d'échantillonnage
    % Sorties :
    %   - y : Densité spectrale de puissance calculée via le corrélogramme
    %   - f : Vecteur des fréquences

    % Longueur du signal
    N = length(x);

    % Calcul de la fonction d'autocorrélation
    rxx = xcorr(x, 'biased');

    % On garde uniquement les valeurs positives de l'autocorrélation
    rxx_positive = rxx(N:end);

    % Calcul de la FFT pour obtenir la densité spectrale de puissance
    y = abs(fft(rxx_positive, Nfft)) / Fe;

    % Génération du vecteur des fréquences
    f = (0:(Nfft-1)) * (Fe / Nfft);
    f = f - Fe / 2; % Décalage pour centrer autour de 0 Hz

    % Centrage du spectre
    y = fftshift(y);
end
