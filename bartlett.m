function [y, f] = bartlett(x, Nfft, Fe)
    % Vérification de la taille du signal
    N = length(x);
    if mod(N, Nfft) ~= 0
        warning('Le signal n’est pas un multiple exact de Nfft. Les échantillons en excédent seront ignorés.');
        x = x(1:(floor(N / Nfft) * Nfft));
    end

    n = floor(N / Nfft); 
    f = linspace(-Fe/2, Fe/2, Nfft); 
    y = zeros(1, Nfft);

    for i = 0:(n-1)
        start_idx = i * Nfft + 1;
        end_idx = start_idx + Nfft - 1;
        X = x(start_idx:end_idx);

        % Appliquer une fenêtre Hamming
        window = hamming(Nfft)';
        X = X .* window;

        % Calcul du périodogramme
        y = y + (abs(fft(X)).^2) / (n * Fe);
    end

end
