function [y, f] = welch(x, Nfft, Fe)

    % Paramètres
    overlap = 0.5;               % 50% de recouvrement
    step = Nfft * (1 - overlap); 
    N = length(x);
    n = floor((N - Nfft) / step) + 1;  % Nombre de segments
    f = linspace(-Fe/2, Fe/2, Nfft);   % Axe fréquentiel
    
    % Allocation
    y = zeros(1, Nfft);
    window = hamming(Nfft);
    U = sum(window.^2);  % Énergie de la fenêtre, pour la normalisation
    
    for i = 0:n-1
        start_idx = i * step + 1;
        end_idx = start_idx + Nfft - 1;
        
        % Si le dernier segment est plus court, on zero-pad
        if end_idx > N
            X = [x(start_idx:end); zeros(end_idx - N, 1)];
        else
            X = x(start_idx:end_idx);
        end
        
        % Application de la fenêtre
        X = X(:) .* window(:);
        
        % Calcul de la FFT et recentrage
        Xf = fftshift(fft(X, Nfft));
        
        % Accumulation du spectre de puissance
        y = y + abs(Xf).^2;
    end
    
    % Normalisation
    % Division par n pour la moyenne, par Fe pour la densité par Hz, et par U pour
    % tenir compte de l'énergie de la fenêtre.
    y = y / (n * U * Fe);
end
