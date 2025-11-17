%% Première phase du projet : extraction d’une signature caractérisant la dépendance long terme 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Préambule %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Question 1: BBGC et spectre

clear;
clc;
close all;

% Génération du bruit blanc gaussien
N = 1000;        
mu = 0;          
sigma = 1;       
bbgc = mu + sigma * randn(1, N);  

% Fonction pour générer une impulsion de Dirac
function dirac_imp = my_dirac(N)
    dirac_imp = zeros(1, N);
    dirac_imp(floor(N/2)) = 1;  
end

% Calcul des fonctions d'autocorrélation
autocorr_theorique = sigma^2 * my_dirac(N);
[autocorr_biased, lags] = xcorr(bbgc, 'biased');
[autocorr_unbiased, ~] = xcorr(bbgc, 'unbiased');

% Affichage de la variance théorique
figure;
subplot(3,1,1);
plot(-N/2:N/2-1, autocorr_theorique);
title('Variance Théorique: \sigma^2 * Impulsion de Dirac');
xlabel('Lags (\tau)');
ylabel('Amplitude');
grid on;

% Affichage des autocorrélations biaisée et non biaisée
subplot(3,1,2);
plot(lags, autocorr_biased);
title('Autocorrélation Biaisée');
xlabel('Lags (\tau)');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot(lags, autocorr_unbiased);
title('Autocorrélation Non Biaisée');
xlabel('Lags (\tau)');
ylabel('Amplitude');
grid on;


%% Question 2: Périodogrammes

clear;
clc;
close all; 

% Génération du bruit blanc gaussien
N = 100000;        
mu = 0;          
sigma = 1;       
bbgc = mu + sigma * randn(1, N);  

Fe = 10^-6;
Nfft = 256; % Afin d'avoir une puissance de 2 pour la fft (Transformée de Fourier rapide)
f = (0:Nfft-1) * Fe / Nfft;

[DSP_Daniel, f_Daniel] = daniell(bbgc, Nfft, Fe);
[DSP_Bartlett, f_Bartlett] = bartlett(bbgc, Nfft, Fe);
[DSP_Welch, f_Welch] = welch(bbgc, Nfft, Fe);

figure;
subplot(4,1,1);
plot(f, abs(fft(bbgc, Nfft)).^2 / Nfft)
title("Spectre de puissance d'une réalisation de notre BBGC");
xlabel('Fréquence (Hz)');
ylabel('Puissance');

subplot(4,1,2);
plot(f_Daniel, DSP_Daniel);
title('DSP estimée avec le périodogramme de Daniel');
xlabel('Fréquence (Hz)');
ylabel('DSP');

subplot(4,1,3);
plot(f_Bartlett, DSP_Bartlett);
title('DSP estimée avec le périodogramme de Bartlett');
xlabel('Fréquence (Hz)');
ylabel('DSP');

subplot(4,1,4);
plot(f_Welch, DSP_Welch);
title('DSP estimée avec le périodogramme de Welch');
xlabel('Fréquence (Hz)');
ylabel('DSP');


%% Question 3: Corrélogramme

clear;
clc;
close all;

% Génération du bruit blanc gaussien centré (BBGC)
N = 10000;        
mu = 0;          
sigma = 1;       
bbgc = mu + sigma * randn(1, N);

% Fréquence d'échantillonnage (à adapter selon vos besoins)
Fe = 1;  % Par exemple Fe = 1 Hz, ou autre. L'important est de rester cohérent.
Nfft = 1024;

% Estimation de l'autocorrélation non biaisée (ou biaisée, selon le choix)
[autocorr_unbiased, lags] = xcorr(bbgc, 'unbiased');

% On va fenêtrer l'autocorrélation.  
% Par exemple, utilisation d'une fenêtre Hamming de même longueur que l'autocorrélation
L = length(autocorr_unbiased);
window = hamming(L)'; 
autocorr_windowed = autocorr_unbiased .* window;

% Calcul du corrélogramme : FFT de l'autocorrélation fenêtrée
% Note: on utilise fftshift pour centrer le spectre en fréquences négatives/positives
DSP_corr = fftshift(abs(fft(autocorr_windowed, Nfft)));

% Construction de l'axe fréquentiel
f_corr = linspace(-Fe/2, Fe/2, Nfft);

% Pour comparaison, calculons un périodogramme "naïf" du même signal
DSP_periodogram = abs(fftshift(fft(bbgc, Nfft))).^2 / (N * Fe);

[DSP_Bartlett, f_Bartlett] = bartlett(bbgc, Nfft, Fe);

% Affichage du corrélogramme et comparaison
figure;
subplot(4,1,1);
plot(f_corr, DSP_corr);
title('Corrélogramme (fenêtré)');
xlabel('Fréquence (Hz)');
ylabel('DSP');
grid on;

% Affichage du périodogramme brut
subplot(4,1,2);
plot(f_corr, DSP_periodogram);
title('Périodogramme brut');
xlabel('Fréquence (Hz)');
ylabel('Puissance');
grid on;

subplot(4,1,3);
plot(f_Bartlett, DSP_Bartlett);
title('DSP estimée par Bartlett');
xlabel('Fréquence (Hz)');
ylabel('DSP');
grid on;

subplot(4,1,4);
plot(f_corr, ones(size(f_corr))*sigma^2*Fe, 'r--', 'LineWidth',1.5);
title("DSP théorique d'un BBGC");
xlabel('Fréquence (Hz)');
ylabel('DSP');
grid on;


%% Question 4: Bruitage signal de Wierstrass

clear;
clc;
close all;

% Chargement des données
x_weierstrass = load('data_Weierstrass.mat');
x_weierstrass = x_weierstrass.data{1,1};

x_speech = load('fcno03fz.mat');
x_speech = x_speech.fcno03fz;

RSB_values = [5 10 15];  % Les trois RSB à tester

% Bruitage du signal de Weierstrass
figure;
for i = 1:length(RSB_values)
    RSB_dB = RSB_values(i);
    x_weier_bruite = Bruitage_RSB(x_weierstrass, RSB_dB);
    x_weier_bruite = x_weier_bruite{1,1};
    
    subplot(length(RSB_values),1,i);
    plot(x_weier_bruite);
    title(sprintf('Signal de Weierstrass bruité à un SNR de %d dB', RSB_dB));
    xlabel('Échantillons');
    ylabel('Amplitude');
    grid on;
end

% Bruitage du signal de parole
figure;
for i = 1:length(RSB_values)
    RSB_dB = RSB_values(i);
    x_speech_bruite = Bruitage_RSB(x_speech, RSB_dB);
    x_speech_bruite = x_speech_bruite{1,1};
    
    subplot(length(RSB_values),1,i);
    plot(x_speech_bruite);
    title(sprintf('Signal de parole bruité à un SNR de %d dB', RSB_dB));
    xlabel('Échantillons');
    ylabel('Amplitude');
    grid on;
end


% Question 4: Spectrogramme

RSB_dB = 15;

x_weier_bruite = Bruitage_RSB(x_weierstrass, RSB_dB);
x_weier_bruite = x_weier_bruite{1,1};


% Supposons que Fe soit connu, par exemple Fe = 16000 Hz (à adapter selon vos données)
Fe = 16000; 
t_weier = (0:length(x_weierstrass)-1)/Fe;  % Axe temporel du signal original
t_weier_bruite = (0:length(x_weier_bruite)-1)/Fe; % Axe temporel du signal bruité

% Figure pour le signal original
figure;
subplot(2,1,1);
plot(t_weier, x_weierstrass);
title('Signal de Weierstrass (sans bruit)');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Calcul du spectrogramme (choix de la fenêtre, du recouvrement, etc.)
% Par exemple :
window = 256;
noverlap = 128;
nfft = 512;
[S,F,T,P] = spectrogram(x_weierstrass, window, noverlap, nfft, Fe);

subplot(2,1,2);
% Normalisation des fréquences F (si souhaité) : F_norm = F/(Fe/2);
F_norm = F/(Fe/2); 
imagesc(T, F_norm, 10*log10(P));
axis xy;
colormap jet;
xlabel('Temps (s)');
ylabel('Fréquence Normalisée');
title('Spectrogramme du Signal de Weierstrass (sans bruit)');
colorbar;

xlim([0, max(t_weier)]);

% Figure pour le signal bruité
figure;
subplot(2,1,1);
plot(t_weier_bruite, x_weier_bruite);
title(sprintf('Signal de Weierstrass bruité à un SNR de %d dB', RSB_dB));
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

[S_b,F_b,T_b,P_b] = spectrogram(x_weier_bruite, window, noverlap, nfft, Fe);

subplot(2,1,2);
F_b_norm = F_b/(Fe/2);
imagesc(T_b, F_b_norm, 10*log10(P_b));
axis xy;
colormap jet;
xlabel('Temps (s)');
ylabel('Fréquence Normalisée');
title(sprintf('Spectrogramme du Signal bruité à un SNR de %d dB', RSB_dB));
colorbar;

xlim([0, max(t_weier_bruite)]);

