clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%

mu = 0;
sigma = 5;
N = 1000;

bbgc = randn(N, 1) * sigma + mu;


%%%%%%%%%%%%%%%%%%%%%%%%%%% Traitement du signal %%%%%%%%%%%%%%%%%%%%%%%%%%%

[ac_biased, lags_biased] = xcorr(bbgc, 'biased');
[ac_unbiased, lags_unbiased] = xcorr(bbgc, 'unbiased');

DSP_theorique = sigma^2;

freq = (0:N-1)*(1/(N));
spectre_puissance = abs(fft(bbgc)).^2 / N;

%%%%%%%%%%%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plots des autocorrélations
figure;

subplot(3, 1, 1);
plot(bbgc);
title('Bruit blanc gaussien');
xlabel('Échantillons');
ylabel('Amplitude');
grid on;

subplot(3, 1, 2);
plot(lags_biased, ac_biased);
title('Autocorrélation biaisée');
xlabel('Décalage tau');
ylabel('Amplitude');
grid on;

subplot(3, 1, 3);
plot(lags_unbiased, ac_unbiased);
title('Autocorrélation non biaisée');
xlabel('Décalage tau');
ylabel('Amplitude');
grid on;


% Plots du spectre de puissance & DSP
figure;

plot(freq, spectre_puissance, 'DisplayName', 'Spectre de puissance');
hold on;
yline(DSP_theorique, 'LineWidth', 4, 'DisplayName', 'DSP théorique (\sigma^2)');
title('Spectre de puissance vs DSP théorique');
xlabel('Fréquence (Hz)');
ylabel('Amplitude');
legend;
grid on;

%% 
% Génération d'un signal de Weierstrass
Fs = 1000; % Fréquence d'échantillonnage
t = 0:1/Fs:1-1/Fs; % Durée de 1 seconde
x_weierstrass = zeros(size(t));

a = 0.5; % Paramètre du signal de Weierstrass
b = 3; % Facteur multiplicatif des fréquences

% Construction du signal
for k = 0:50
    x_weierstrass = x_weierstrass + a^k * cos(2*pi*b^k*t);
end

% Bruitage du signal avec un RSB de 10 dB
RSB_dB = 10;
x_bruite_weierstrass = Bruitage_Signal(x_weierstrass, RSB_dB);

% Tracé
figure;
subplot(2, 1, 1);
plot(t, x_weierstrass);
title('Signal de Weierstrass (Original)');
xlabel('Temps (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(t, x_bruite_weierstrass);
title(['Signal de Weierstrass Bruité (RSB = ', num2str(RSB_dB), ' dB)']);
xlabel('Temps (s)');
ylabel('Amplitude');

%%
% Charger un signal de parole depuis un fichier audio
[x_parole, Fs_parole] = audioread('nom_du_fichier_audio.wav'); % Remplacez par le fichier réel

% Bruitage du signal avec un RSB de 5 dB
RSB_dB = 5;
x_bruite_parole = Bruitage_Signal(x_parole, RSB_dB);

% Écoute des signaux
sound(x_parole, Fs_parole); % Signal original
pause(2); % Pause avant de jouer le signal bruité
sound(x_bruite_parole, Fs_parole); % Signal bruité

% Tracé
t_parole = (0:length(x_parole)-1) / Fs_parole; % Axe temporel
figure;
subplot(2, 1, 1);
plot(t_parole, x_parole);
title('Signal de Parole (Original)');
xlabel('Temps (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(t_parole, x_bruite_parole);
title(['Signal de Parole Bruité (RSB = ', num2str(RSB_dB), ' dB)']);
xlabel('Temps (s)');
ylabel('Amplitude');
 %%
 % Signal sinusoïdal
Fs = 1000; % Fréquence d'échantillonnage
t = 0:1/Fs:1-1/Fs; % Durée de 1 seconde
x = sin(2*pi*50*t); % Signal sinusoïdal à 50 Hz

% Tester les RSB de 5, 10 et 15 dB
RSB_dB = [5, 10, 15];
x_bruite = Bruitage_RSB(x, RSB_dB);

% Tracer les signaux
figure;
for i = 1:length(RSB_dB)
    subplot(length(RSB_dB), 1, i);
    plot(t, x_bruite{i});
    title(['Signal Bruité (RSB = ', num2str(RSB_dB(i)), ' dB)']);
    xlabel('Temps (s)');
    ylabel('Amplitude');
end
%%
% Charger un fichier audio
[x_audio, Fs_audio] = audioread('nom_du_fichier_audio.wav'); % Remplacez par votre fichier

% Tester les RSB de 5, 10 et 15 dB
RSB_dB = [5, 10, 15];
x_bruite_audio = Bruitage_RSB(x_audio, RSB_dB);

% Écouter les signaux bruités
for i = 1:length(RSB_dB)
    disp(['Lecture du signal bruité avec RSB = ', num2str(RSB_dB(i)), ' dB']);
    sound(x_bruite_audio{i}, Fs_audio);
    pause(5); % Pause entre les lectures
end
%%
% Paramètres du signal
Fs = 1000; % Fréquence d'échantillonnage (Hz)
t = 0:1/Fs:1-1/Fs; % Axe temporel sur 1 seconde
x = sin(2*pi*100*t); % Signal sinusoïdal à 100 Hz

% Ajouter du bruit au signal
RSB_dB = 10; % Rapport Signal-Bruit en dB
x_bruite = Bruitage_RSB(x, RSB_dB);

% Tracé
plot_signal_and_spectrogram(x, x_bruite{1}, Fs);
%%
