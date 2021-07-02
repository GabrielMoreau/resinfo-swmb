# SWMB - Secure Windows Mode Batch

 * [CONTRIBUTING](./CONTRIBUTING.md)
 * [FAQ](./FAQ.md)
 * [LICENSE](./LICENSE.md)
 * [NEWS](./NEWS.md)
 * [REFERENCES](./REFERENCES.md).
 * [USE CASE (distribution)](./dists/README.md)

## Préambule

SWMB est un projet issu du groupe de travail SWMB du réseau métier RESINFO du CNRS.
Il s'agit de gérer la sécurité, la confidentialité et la vie privée sous l'OS Windows 10 à l'aide de scripts.
L'objectif est de pouvoir déployer facilement sur un parc informatique des règles de sécurité (stratégie)
que les postes soient ou ne soient pas dans un Active Directory.
Dans un souci de traçage (qualité) et de partage des connaissances, toutes les actions possibles sont lisibles dans un format texte.
Le langage de programmation choisit est le Powershell de Microsoft.
L'ensemble du code et de la documentation est accessible sur une forge Git.

Le choix de réaliser un système de scripts est donc un choix complémentaire d'une solution avec GPO associée au clickodrome Active Directory.
La question de savoir comment SWMB est déployé sur les postes de travail n'est pas directement lié au projet SWMB lui-même.
C'est un logiciel comme les autres et peut donc être intégré dans tout système de gestion de configuration.

Le projet se veut modulaire.
Il doit être facile à maintenir, facile à comprendre, facile à étendre et facile à utiliser.
Le site https://www.ghacks.net/2015/08/14/comparison-of-windows-10-privacy-tools/ référence de nombreuses solutions possibles.
SWMB a fait le choix de prendre pour base le code de Disassembler0 :  `Win10-Initial-Setup-Script`,
car celui-ci répondait à tous nos critères ci-dessus.

En ce qui concerne les stratégies de sécurité applicables,
SWMB s'appuie principalement sur les règles édictées par l'Agence Nationale de la Sécurité des Systèmes d'Information ([ANSSI](https://www.ssi.gouv.fr/)).
Il y a ainsi dans SWMB trois niveaux de règles possibles :
 * `Modules\SWMB\Win10` - règles du projet amont non modifiées ;
 * `Modules\SWMB\Resinfo` - règles extraites de la documentation de l'ANSSI, ou de certaines consignes du RSSI du CNRS,
    applicable dans tout l'ESR (Enseignement Supérieur et Recherche) ;
 * `Modules\SWMB\Custom` - règles intéressantes que vous pouvez étendre pour votre site.

Chaque règle peut-être activée (`enable`) ou déactivé (`disable`) très facilement dans un fichier de configuration (`preset`).
Des fichiers types sont proposés.
À chaque règle est associée un commentaire en français faisant référence à son origine.
Le français a été choisi afin de suivre le vocable de l'ANSSI
et de part la version française de Windows 10 équipant la majorité de nos parcs informatiques.

Pour les règles `Custom`, il est possible de les paramétrer avec un fichier de variable afin de les adapter à votre parc.
Un jeu de paramètres par défaut est proposé.
Les autres règles ne sont pas paramétrables, car elles sont, dans un premier temps, à prendre ou à laisser !
Le projet amont sur lequel nous nous appuyons n'avait d'ailleurs pas prévu de pouvoir paramétrer des règles.

**Quelques références** :
 * Projet amont `Win10-Initial-Setup-Script` :
   https://github.com/Disassembler0/Win10-Initial-Setup-Script
 * Document de l'[ANSSI](https://fr.wikipedia.org/wiki/Agence_nationale_de_la_s%C3%A9curit%C3%A9_des_syst%C3%A8mes_d%27information)
   (Agence Nationale de la Sécurité des Systèmes d'Information - France) :
   [https://www.ssi.gouv.fr/administration/guide/restreindre-la-collecte-de-donnees-sous-windows-10/](https://www.ssi.gouv.fr/administration/guide/restreindre-la-collecte-de-donnees-sous-windows-10/)
 * Document de la [BSI](https://fr.wikipedia.org/wiki/Office_f%C3%A9d%C3%A9ral_de_la_s%C3%A9curit%C3%A9_des_technologies_de_l%27information)
   (Office fédéral de la sécurité des technologies de l’information - Allemagne) :
   [https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Cyber-Security/SiSyPHuS/AP11/Hardening_Guideline.pdf](https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Cyber-Security/SiSyPHuS/AP11/Hardening_Guideline.pdf)

Plus de références sur la page [REFERENCES](./REFERENCES.md).


## Scripts Powershell Disassembler0

Ce projet s'appuie sur le projet :
[https://github.com/Disassembler0/Win10-Initial-Setup-Script](https://github.com/Disassembler0/Win10-Initial-Setup-Script)
Ce projet est ajouté en tant que `subtree`.

```bash
git remote add -f Win10-Initial https://github.com/Disassembler0/Win10-Initial-Setup-Script.git
git subtree add --prefix Win10-Initial-Setup-Script/ Win10-Initial master --squash
```

Pour mettre à jour :

```bash
git subtree pull --prefix Win10-Initial-Setup-Script/ https://github.com/Disassembler0/Win10-Initial-Setup-Script.git master --squash
```

Voir [CONTRIBUTING](./CONTRIBUTING.md).

## Preset

Un preset par paragraphe de l'ANSSI
 * preset Télémétrie
 * preset Cortana et search
 * preset Paramètres de personnalisation de l'expérience utilisateur
 * preset Applications universelles
 * preset Cloud


## Usage

### Usage direct depuis PowerShell

```ps1
# Exécution d'une fonction seule
.\Win10.ps1 NomFonction

# Exécution d'un jeu de preset
.\Win10.ps1 -preset "Presets\UserExperience-Resinfo.preset"
```

### Usage intégré dans un script PowerShell

```ps1
# Load core SWMB engine
Import-Module Modules\SWMB.psd1

# Initialize
SWMB_Init

# Load a preset file (could be call multiple times)
SWMB_LoadTweakFile "Presets\UserExperience-Resinfo.preset"

# Load one preset (could be call multiple times)
SWMB_AddOrRemoveTweak "NomFonction"

# If you want to check consistency
SWMB_CheckTweaks

# Execute all presets
SWMB_RunTweaks
```

### Intégration dans un autre projet Git


### Définition de vos propres valeurs de variables

Si vous souhaitez définir vos propres valeurs de variables utilisées le module `Custom.psm1`, procédez de la façon suivante :
 * Créez un fichier nommé `Custom-VarOverload.psm1` dans le même répertoire que le module `Custom-VarDefault.psm1`,
   ou dans n'importe quel dossier parent `..` ou sous dossier `Modules` d'un dossier parent !
   Cela laisse pas mal de choix...
 * Définissez les valeurs du hash de vos variables globales
   (Ne modifiez pas toute la table de hashage comme dans le fichier `Custom-VarDefault.psm1`)
 * Exemple :
   ```ps
   $Global:SWMB_Custom.NTP_ManualPeerList = "0.fr.pool.ntp.org, 1.fr.pool.ntp.org"
   ```


## Exemples de déploiement et d'utilisation

Vous trouverez, dans le répertoire [dists](dists), des exemples de déploiement du script
(manuel, au démarrage de la machine, avec OCS Inventory, chiffrement des volumes...).

Le fichier [README](dists/manual-use/README.md) du répertoire «manual-use» rappelle quelques principes sur les politiques d'exécution de Powershell.
