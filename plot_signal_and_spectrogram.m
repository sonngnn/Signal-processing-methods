function plot_signal_and_spectrogram(x, x_bruite, Fs)
    % Fonction pour afficher la représentation temporelle et le spectrogramme
    % d'un signal original et bruité sur deux figures distinctes.
    % Entrées :
    %   - x : Signal original
    %   - x_bruite : Signal bruité
    %   - Fs : Fréquence d'échantillonnage
    
    % Durée totale du signal
    t = (0:length(x)-1) / Fs; % Axe temporel en secondes

    % Paramètres du spectrogramme
    window = hamming(256); % Fenêtre Hamming
    overlap = 128; % Recouvrement
    nfft = 512; % Taille de la FFT

    % Figure pour le signal original
    figure;
    
    % Représentation temporelle
    subplot(2, 1, 1);
    plot(t, x);
    title('Représentation temporelle du signal original');
    xlabel('Temps (s)');
    ylabel('Amplitude');
    
    % Spectrogramme
    subplot(2, 1, 2);
    spectrogram(x, window, overlap, nfft, Fs, 'yaxis');
    title('Spectrogramme du signal original');
    xlabel('Temps (s)');
    ylabel('Fréquence normalisée');
    colormap jet;

    % Figure pour le signal bruité
    figure;
    
    % Représentation temporelle
    subplot(2, 1, 1);
    plot(t, x_bruite);
    title('Représentation temporelle du signal bruité');
    xlabel('Temps (s)');
    ylabel('Amplitude');
    
    % Spectrogramme
    subplot(2, 1, 2);
    spectrogram(x_bruite, window, overlap, nfft, Fs, 'yaxis');
    title('Spectrogramme du signal bruité');
    xlabel('Temps (s)');
    ylabel('Fréquence normalisée');
    colormap jet;
end
