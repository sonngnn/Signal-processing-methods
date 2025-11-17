import tkinter as tk
from tkinter import filedialog, messagebox
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import scipy.io
import numpy as np
from scipy.signal import welch

class SignalApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Interface de Traitement du Signal")
        self.root.geometry("1200x800")  # Ajusté pour s'adapter à une seule fenêtre

        # Variables pour stocker les signaux
        self.original_signal = None
        self.noisy_signal = None
        self.profile = None  # Stocker le profil pour une utilisation future
        self.residuals = None  # Stocker les résidus du profil

        # Cadre pour les contrôles (boutons)
        control_frame = tk.Frame(root)
        control_frame.pack(side=tk.TOP, pady=10)

        # Bouton pour charger le fichier
        self.load_button = tk.Button(control_frame, text="Charger le Signal", command=self.load_signal)
        self.load_button.grid(row=0, column=0, padx=5)

        # Champ de saisie pour le RSB
        self.rsb_label = tk.Label(control_frame, text="RSB (dB) :")
        self.rsb_label.grid(row=0, column=1, padx=5)
        self.rsb_entry = tk.Entry(control_frame, width=10)
        self.rsb_entry.grid(row=0, column=2, padx=5)
        self.rsb_entry.insert(0, "10")  # Valeur par défaut

        # Bouton pour appliquer le bruit
        self.noise_button = tk.Button(control_frame, text="Bruitage du Signal", command=self.add_noise)
        self.noise_button.grid(row=0, column=3, padx=5)

        # Bouton pour recharger le signal initial
        self.reload_button = tk.Button(control_frame, text="Recharger le Signal", command=self.reload_signal)
        self.reload_button.grid(row=0, column=4, padx=5)

        # Bouton pour afficher le périodogramme
        self.periodogram_button = tk.Button(control_frame, text="Afficher le Périodogramme", command=self.display_periodogram)
        self.periodogram_button.grid(row=0, column=5, padx=5)

        # Bouton pour afficher le profil
        self.profile_button = tk.Button(control_frame, text="Afficher le Profil", command=self.display_profile)
        self.profile_button.grid(row=0, column=6, padx=5)

        # Champ de saisie pour la taille de segment N
        self.N_label = tk.Label(control_frame, text="Taille de Segment N :")
        self.N_label.grid(row=0, column=7, padx=5)
        self.N_entry = tk.Entry(control_frame, width=10)
        self.N_entry.grid(row=0, column=8, padx=5)
        self.N_entry.insert(0, "100")  # Valeur par défaut

        # Bouton pour afficher le découpage et les tendances
        self.segmentation_button = tk.Button(control_frame, text="Découpage & Tendances", command=self.display_segmentation)
        self.segmentation_button.grid(row=0, column=9, padx=5)

        # Bouton pour afficher le résidu du profil
        self.residual_button = tk.Button(control_frame, text="Résidu du Profil", command=self.display_residuals)
        self.residual_button.grid(row=0, column=10, padx=5)

        # Bouton pour afficher la courbe F2(N)
        self.F2_button = tk.Button(control_frame, text="Courbe F2(N)", command=self.display_F2_N)
        self.F2_button.grid(row=0, column=11, padx=5)

        # Cadre pour afficher les graphiques
        self.plot_frame = tk.Frame(root)
        self.plot_frame.pack(fill=tk.BOTH, expand=True)

        # Initialiser la figure matplotlib et le canvas
        self.fig, self.ax = plt.subplots(figsize=(12, 6))
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.plot_frame)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

    def load_signal(self):
        # Ouvrir une boîte de dialogue pour sélectionner un fichier .mat
        file_path = filedialog.askopenfilename(filetypes=[("Fichiers MATLAB", "*.mat")])
        if not file_path:
            return  # L'utilisateur a annulé la sélection

        try:
            # Charger le fichier .mat
            mat = scipy.io.loadmat(file_path)
            
            # Extraire le signal
            # Vous devrez adapter cette partie en fonction de la structure de vos fichiers .mat
            # Par exemple, supposons que le signal est stocké sous la clé 'signal'
            if 'signal' in mat:
                signal = mat['signal'].squeeze().astype(float)
            else:
                # Si la clé n'est pas 'signal', essayer de détecter automatiquement
                signal_keys = [key for key in mat.keys() if not key.startswith('__')]
                if not signal_keys:
                    messagebox.showerror("Erreur", "Aucun signal trouvé dans le fichier .mat.")
                    return
                signal = mat[signal_keys[0]].squeeze().astype(float)

            self.original_signal = signal  # Stocker le signal original
            self.noisy_signal = None  # Réinitialiser le signal bruité
            self.profile = None  # Réinitialiser le profil
            self.residuals = None  # Réinitialiser les résidus

            # Afficher le signal original
            self.plot_signal()

        except Exception as e:
            messagebox.showerror("Erreur", f"Impossible de charger le fichier : {e}")

    def add_noise(self):
        if self.original_signal is None:
            messagebox.showwarning("Attention", "Veuillez d'abord charger un signal.")
            return

        # Obtenir le RSB entré par l'utilisateur
        try:
            rsb_db = float(self.rsb_entry.get())
        except ValueError:
            messagebox.showerror("Erreur", "Veuillez entrer un RSB valide (nombre réel).")
            return

        if rsb_db <= 0 or rsb_db > 50:
            messagebox.showerror("Erreur", "Le RSB doit être compris entre 0 et 50 dB.")
            return

        # Calculer la puissance du signal
        signal_power = np.mean(self.original_signal ** 2)
        print(f"Puissance du signal : {signal_power:.4f}")

        # Calculer la puissance du bruit nécessaire
        rsb_linear = 10 ** (rsb_db / 10)
        noise_power = signal_power / rsb_linear
        print(f"RSB (dB) : {rsb_db}, RSB (linéaire) : {rsb_linear:.4f}, Puissance du bruit : {noise_power:.4f}")

        # Générer du bruit blanc gaussien
        noise = np.random.normal(0, np.sqrt(noise_power), self.original_signal.shape)
        print(f"Puissance du bruit généré : {np.mean(noise ** 2):.4f}")

        # Ajouter le bruit au signal original
        self.noisy_signal = self.original_signal + noise

        # Afficher le signal bruité
        self.plot_signal(noisy=True)

    def reload_signal(self):
        if self.original_signal is None:
            messagebox.showwarning("Attention", "Aucun signal chargé à recharger.")
            return

        self.noisy_signal = None  # Réinitialiser le signal bruité
        self.profile = None  # Réinitialiser le profil
        self.residuals = None  # Réinitialiser les résidus
        print("Signal initial rechargé.")
        self.plot_signal()

    def plot_signal(self, noisy=False):
        self.ax.clear()
        if noisy and self.noisy_signal is not None:
            self.ax.plot(self.original_signal, label='Signal Original', color='blue', alpha=0.7)
            self.ax.plot(self.noisy_signal, label='Signal Bruité', color='red', alpha=0.7)
            self.ax.legend()
        else:
            self.ax.plot(self.original_signal, label='Signal Original', color='blue', alpha=0.7)
            self.ax.legend()
        self.ax.set_title("Signal Chargé")
        self.ax.set_xlabel("Échantillons")
        self.ax.set_ylabel("Amplitude")
        self.ax.grid(True)
        self.canvas.draw()

    def display_periodogram(self):
        if self.original_signal is None:
            messagebox.showwarning("Attention", "Veuillez d'abord charger un signal.")
            return

        # Déterminer le signal actuel (noisy ou original)
        current_signal = self.noisy_signal if self.noisy_signal is not None else self.original_signal

        # Calculer le périodogramme en utilisant la méthode de Welch
        fs = 1.0  # Fréquence d'échantillonnage, ajustez si nécessaire
        f, Pxx = welch(current_signal, fs=fs, nperseg=1024)

        # Effacer l'axe actuel et tracer le périodogramme
        self.ax.clear()
        self.ax.semilogy(f, Pxx, color='green')
        self.ax.set_title("Périodogramme (Méthode de Welch)")
        self.ax.set_xlabel("Fréquence [Hz]")
        self.ax.set_ylabel("Densité Spectrale de Puissance")
        self.ax.grid(True)
        self.canvas.draw()

    def display_profile(self):
        if self.original_signal is None:
            messagebox.showwarning("Attention", "Veuillez d'abord charger un signal.")
            return

        # Déterminer le signal actuel (noisy ou original)
        current_signal = self.noisy_signal if self.noisy_signal is not None else self.original_signal

        # Centrer le signal (moyenne nulle) et intégrer
        centered_signal = current_signal - np.mean(current_signal)
        profile = np.cumsum(centered_signal)
        self.profile = profile  # Stocker le profil pour une utilisation future

        # Effacer l'axe actuel et tracer le profil
        self.ax.clear()
        self.ax.plot(profile, color='purple')
        self.ax.set_title("Profil du Signal")
        self.ax.set_xlabel("Échantillons")
        self.ax.set_ylabel("Amplitude (Profil)")
        self.ax.grid(True)
        self.canvas.draw()

    def display_segmentation(self):
        if self.profile is None:
            messagebox.showwarning("Attention", "Veuillez d'abord afficher le profil du signal.")
            return

        # Obtenir la taille de segment N entré par l'utilisateur
        try:
            N = int(self.N_entry.get())
        except ValueError:
            messagebox.showerror("Erreur", "Veuillez entrer une taille de segment N valide (entier positif).")
            return

        if N <= 0:
            messagebox.showerror("Erreur", "La taille de segment N doit être un entier positif.")
            return

        profile_length = len(self.profile)
        if N > profile_length:
            messagebox.showerror("Erreur", f"La taille de segment N doit être inférieure ou égale à la longueur du profil ({profile_length}).")
            return

        # Calculer le nombre de segments
        num_segments = profile_length // N
        if num_segments == 0:
            messagebox.showerror("Erreur", f"La taille de segment N est trop grande pour la longueur du profil ({profile_length}).")
            return

        # Initialiser les résidus avec des zéros
        self.residuals = np.zeros(profile_length)

        # Découper le profil en segments et ajuster les tendances
        segments = []
        trends = []
        for i in range(num_segments):
            start = i * N
            end = start + N
            segment = self.profile[start:end]
            segments.append(segment)

            # Ajuster une tendance locale (polynôme de degré 1, par exemple)
            x = np.arange(start, end)
            y = segment
            coeffs = np.polyfit(x, y, 1)  # Polynôme de degré 1
            trend = np.polyval(coeffs, x)
            trends.append(trend)

            # Calculer et stocker les résidus
            residual = y - trend
            self.residuals[start:end] = residual

        # Effacer l'axe actuel et tracer le profil avec les tendances
        self.ax.clear()
        self.ax.plot(self.profile, label='Profil du Signal', color='purple', alpha=0.7)

        # Tracer les tendances
        for i in range(num_segments):
            start = i * N
            end = start + N
            x = np.arange(start, end)
            trend = trends[i]
            self.ax.plot(x, trend, color='orange', linewidth=2)

        # Tracer les frontières des segments
        for i in range(1, num_segments):
            boundary = i * N
            self.ax.axvline(x=boundary, color='gray', linestyle='--', linewidth=1)

        self.ax.set_title("Profil du Signal avec Découpage et Tendances Locales")
        self.ax.set_xlabel("Échantillons")
        self.ax.set_ylabel("Amplitude (Profil)")
        self.ax.legend(['Profil du Signal', 'Tendances Locales', 'Frontières des Segments'])
        self.ax.grid(True)
        self.canvas.draw()

    def display_residuals(self):
        if self.residuals is None:
            messagebox.showwarning("Attention", "Veuillez d'abord effectuer le découpage et l'ajustement des tendances.")
            return

        # Effacer l'axe actuel et tracer les résidus
        self.ax.clear()
        self.ax.plot(self.residuals, label='Résidus du Profil', color='magenta')
        self.ax.set_title("Résidu du Profil du Signal")
        self.ax.set_xlabel("Échantillons")
        self.ax.set_ylabel("Résidu")
        self.ax.legend()
        self.ax.grid(True)
        self.canvas.draw()

    def display_F2_N(self):
        if self.profile is None:
            messagebox.showwarning("Attention", "Veuillez d'abord afficher le profil du signal.")
            return

        # Définir une plage de tailles de fenêtres N
        # Choisir des puissances de 2 pour N, par exemple de 16 à une fraction de la longueur du profil
        min_N = 16
        max_N = len(self.profile) // 4  # Ajustez selon vos besoins
        N_values = []
        power = 4  # 2^4 = 16
        while True:
            N = 2 ** power
            if N > max_N:
                break
            N_values.append(N)
            power += 1

        if not N_values:
            messagebox.showerror("Erreur", "La longueur du profil est trop courte pour les tailles de segment choisies.")
            return

        F_N = []

        for N in N_values:
            # Calculer le nombre de segments
            num_segments = len(self.profile) // N
            if num_segments == 0:
                continue

            # Découper le profil en segments de taille N
            residuals = []
            for i in range(num_segments):
                start = i * N
                end = start + N
                segment = self.profile[start:end]

                # Ajuster une tendance locale (polynôme de degré 1)
                x = np.arange(start, end)
                y = segment
                coeffs = np.polyfit(x, y, 1)  # Polynôme de degré 1
                trend = np.polyval(coeffs, x)

                # Calculer les résidus
                residual = y - trend
                residuals.extend(residual)

            # Calculer F(N) comme la racine carrée de la moyenne des résidus au carré
            residuals = np.array(residuals)
            F = np.sqrt(np.mean(residuals ** 2))
            F_N.append(F)

        if not F_N:
            messagebox.showerror("Erreur", "Aucun F(N) calculé. Vérifiez les tailles de segment N.")
            return

        # Convertir les listes en arrays pour le calcul logarithmique
        N_values = np.array(N_values[:len(F_N)])
        F_N = np.array(F_N)

        # Calculer les logarithmes
        log_N = np.log(N_values)
        log_F_N = np.log(F_N)

        # Ajuster une tendance linéaire sur log-log
        coeffs = np.polyfit(log_N, log_F_N, 1)
        slope = coeffs[0]  # Exposant de Hurst H
        intercept = coeffs[1]
        trend_line = slope * log_N + intercept
        H = slope  # L'exposant de Hurst

        # Effacer l'axe actuel et tracer F2(N) et la tendance
        self.ax.clear()
        self.ax.plot(N_values, F_N, 'o-', label='F2(N)', color='blue')
        self.ax.plot(N_values, np.exp(trend_line), 'r--', label=f'Tendance (H = {H:.4f})', linewidth=2)

        self.ax.set_xscale('log')
        self.ax.set_yscale('log')
        self.ax.set_title("Courbe F2(N) et Tendance Linéaire (Log-Log)")
        self.ax.set_xlabel("Taille de Fenêtre N")
        self.ax.set_ylabel("Fluctuation F2(N)")
        self.ax.legend()
        self.ax.grid(True, which="both", ls="--")
        self.canvas.draw()

        # Afficher le coefficient Hurst dans la fenêtre principale
        # Pour cela, nous allons ajouter un label en dessous du canvas
        # Vérifier si un label existe déjà, sinon le créer
        if hasattr(self, 'H_label'):
            self.H_label.config(text=f"Exposant de Hurst (H) : {H:.4f}")
        else:
            self.H_label = tk.Label(self.root, text=f"Exposant de Hurst (H) : {H:.4f}", font=("Helvetica", 14))
            self.H_label.pack(pady=10)

# Exécuter l'application
if __name__ == "__main__":
    root = tk.Tk()
    app = SignalApp(root)
    root.mainloop()
