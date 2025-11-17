% Bruitage d'un signal avec un rapport signal à bruit donné

function x_bruite = Bruitage_RSB(x, RSB_dB)
    
    % Puissance moyenne du signal
    P_signal = mean(x.^2);
    
    x_bruite = cell(1, length(RSB_dB)); 
    
    for i = 1:length(RSB_dB)
        % Conversion du RSB en échelle linéaire
        RSB = 10^(RSB_dB(i) / 10);
        
        % Calcul de la puissance du bruit
        P_bruit = P_signal / RSB;
        
        % Génération du bruit gaussien et bruitage de notre signal
        bruit = sqrt(P_bruit) * randn(size(x));
        x_bruite{i} = x + bruit;
    end
end
