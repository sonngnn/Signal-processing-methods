function x_bruite = Bruitage_Signal(x, RSB_dB)
    % Fonction pour bruiter un signal avec un bruit blanc gaussien pour un RSB donné
    % Entrées :
    %   - x : Signal d'entrée (vecteur)
    %   - RSB_dB : Rapport Signal-Bruit en décibels
    % Sortie :
    %   - x_bruite : Signal bruité
    
    % Calcul de la puissance du signal
    P_signal = mean(x.^2);
    
    % Calcul de la puissance du bruit
    RSB = 10^(RSB_dB / 10); % Conversion en échelle linéaire
    P_bruit = P_signal / RSB;
    
    % Génération du bruit blanc gaussien
    bruit = sqrt(P_bruit) * randn(size(x));
    
    % Ajout du bruit au signal
    x_bruite = x + bruit;
end
