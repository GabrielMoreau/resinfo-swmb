# SWMB in a nutshell

## Les bases

Le [dépôt git du projet](https://gitlab.in2p3.fr/resinfo-gt/swmb) SWMB
(Secure Windows Mode Batch).

### Je récupère l'ensemble des scripts et la documentation d'une des façons suivantes :

 * Clonage du dépôt Git
    * **ssh**
      ```
      git clone git@gitlab.in2p3.fr:resinfo-gt/swmb/resinfo-swmb.git
      ```
    * **https**
      ```
      git clone https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb.git
      ```
 * En téléchargeant l'archive au format Zip : [resinfo-swmb-master.zip](https://gitlab.in2p3.fr/resinfo-gt/swmb/resinfo-swmb/-/archive/master/resinfo-swmb-master.zip)

### Sur ma machine de test, je lance le script «de base» qui fixe les paramètres de configuration

Par défaut, SWMB essaye d'être conforme avec les [recommandations de l'ANSSI](https://www.ssi.gouv.fr/uploads/2017/01/np_securisation_windows10_collecte_de_donnees_v1.2.pdf).

Supposons que les différents scripts aient été téléchargés dans le dossier `C:\SWMB`

Je lance powershell avec un compte administrateur et privilèges élevés et je diminue temporairement la sécurité

```ps
powershell.exe

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

Je me positionne sur le bon répertoire et je lance les commandes

```ps
C:
cd \
cd SWMB

.\swmb.ps1 -preset "Presets\LocalMachine-Default.preset"
```

Évidement, si je ne veux pas appliquer tous les presets, il suffit que je ne sélectionne que ceux qui me plaisent...

**... et voilà !**

## Pour aller un peu plus loin

### Je crée une tâche planifée qui va lancer ce script et s'exécuter au démarrage du PC

 * Je lance le planificateur de tâche et crée une tâche de base avec les paramètres suivants :
    * nom : SWMB
    * déclencheur : au démarrage de l'ordinateur
    * action : démarrer un programme
    * programme et arguments du programme :
        * programme : `powershell.exe` (ou `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`)
        * argument : `-ExecutionPolicy RemoteSigned -file "C:\SWMB\swmb.ps1" -preset "Presets\LocalMachine-Default.preset"`
 * Une fois la tâche créee, vérifier que :
    * La tâche s'exécute avec le compte `Autorite NT\Système`
    * Exécuter avec les autorisations maximales
    * Exécuter même si l'utilisateur n'est pas connecté. Ne pas enregistrer le mot de passe
    * Configurer pour Windows 10
    * je redémarre mon pc et je vérifie que la tâche s'est exécutée correctement (cf. colonne résultat de la dernière exécution dans le planificateur de tâche)

### En savoir encore plus

 * Je lis le [README](https://gitlab.in2p3.fr/resinfo-gt/swmb/-/blob/master/README.md) du projet
 * Je lis les documentations sur les exemples de déploiement dans le répertoire «[dists](https://gitlab.in2p3.fr/resinfo-gt/swmb/-/tree/master/dists)» du projet
