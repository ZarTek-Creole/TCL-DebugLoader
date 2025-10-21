# TCL-DebugLoader

## 📋 Description

TCL-DebugLoader est un script Tcl conçu pour être chargé en premier dans la configuration d'un bot Eggdrop. Il facilite le chargement d'autres scripts Tcl tout en fournissant une gestion robuste des erreurs et des fonctionnalités avancées de débogage inspirées de LiveBugTracer.

Ce script professionnel assure la stabilité du bot même en cas d'erreurs de syntaxe dans les scripts chargés, tout en offrant un suivi détaillé des erreurs pour les développeurs.

## ✨ Fonctionnalités principales

- **Redirection des erreurs** : Capture et enregistre automatiquement toutes les erreurs Tcl dans `logs_Error/${::botnet-nick}_Error.log` avec traces complètes de la pile d'exécution
- **Journalisation sur canal IRC** : Envoi des messages d'erreur vers un canal IRC configurable (`CONF(CHANNEL_LOG)`) pour un suivi en temps réel
- **Protection contre les plantages** : Garantit la stabilité de l'Eggdrop même si un script contient des erreurs de syntaxe, avec option d'arrêt du bot (`DIE_ON_ERROR`)
- **Traçage de variables** : Surveillance des opérations de lecture/écriture/suppression sur des variables spécifiées (ex: `CONF`) pour le débogage
- **Protection contre les boucles infinies** : Détection et interruption des boucles infinies dans les commandes `for` et `while` (configurable via `ANTI_INFINITE_LOOP`)
- **Rapport d'erreurs réseau** : Envoi des messages d'erreur aux autres bots via `putallbots` (configurable via `NETWORK_ERROR_REPORT`)
- **Interface développeur optimisée** : Centralisation des rapports d'erreur, suppression des erreurs en double et traces détaillées pour faciliter le débogage

## 📦 Prérequis

- **Eggdrop** : Version 1.6.20 ou supérieure
- **Tcl** : Version 8.6 ou supérieure (généralement incluse avec Eggdrop)
- **Permissions d'écriture** : Le bot doit avoir les permissions d'écriture dans le répertoire `logs_Error/` pour la création des fichiers de journalisation

## 🚀 Installation

### 1. Cloner ou télécharger le dépôt

```bash
git clone https://github.com/ZarTek-Creole/TCL-DebugLoader.git
```

Alternativement, téléchargez le fichier ZIP depuis le [dépôt GitHub](https://github.com/ZarTek-Creole/TCL-DebugLoader) et extrayez-le.

### 2. Déplacer le script

Copiez le fichier `DebugLoader.tcl` vers le répertoire `scripts` de votre bot Eggdrop :

```bash
cp TCL-DebugLoader/DebugLoader.tcl /chemin/vers/eggdrop/scripts/
```

### 3. Modifier la configuration Eggdrop

Ouvrez votre fichier de configuration Eggdrop (ex: `eggdrop.conf`) et ajoutez la ligne suivante **en haut** de la section de chargement des scripts :

```tcl
source scripts/DebugLoader.tcl
```

**Important** : Ce script doit être chargé avant tous les autres scripts pour intercepter correctement les erreurs.

### 4. Recharger ou redémarrer le bot

Dans la console Eggdrop ou sur IRC, exécutez :

```
.rehash
```

Alternativement, redémarrez le bot :

```bash
./eggdrop -m eggdrop.conf
```

## ⚙️ Configuration

### Définir le canal de débogage

Dans `DebugLoader.tcl`, configurez la variable `CONF(CHANNEL_LOG)` pour spécifier le canal IRC de rapport d'erreurs :

```tcl
set CONF(CHANNEL_LOG) "#debug"
```

### Options de configuration avancées

- **DIE_ON_ERROR** : Arrête le bot en cas d'erreur fatale (désactivé par défaut)
- **ANTI_INFINITE_LOOP** : Active la protection contre les boucles infinies
- **NETWORK_ERROR_REPORT** : Active l'envoi des erreurs aux autres bots du réseau
- **Variables à tracer** : Personnalisez les variables à surveiller pour le débogage

## 📖 Utilisation

Une fois installé et configuré, TCL-DebugLoader fonctionne automatiquement en arrière-plan. Toutes les erreurs Tcl sont :

1. Enregistrées dans `logs_Error/${::botnet-nick}_Error.log` avec horodatage et trace complète
2. Envoyées au canal IRC configuré (si défini)
3. Optionnellement diffusées aux autres bots du réseau

### Exemple de sortie d'erreur

```
[10:30:45] [ERROR] Script: test.tcl
[10:30:45] Message: invalid command name "commande_invalide"
[10:30:45] Stack trace:
    invoked from within "commande_invalide"
    (file "scripts/test.tcl" line 42)
```

## 🔍 Fonctionnalités de débogage avancées

### Traçage de variables

Le script peut surveiller l'accès aux variables critiques :

```tcl
# Trace automatique de la variable CONF
trace add variable CONF {read write unset} ::DebugLoader::traceVariable
```

### Détection de boucles infinies

Protection automatique contre les boucles infinies :

```tcl
# Configuration du timeout (en millisecondes)
set CONF(LOOP_TIMEOUT) 5000
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Forker le projet
2. Créer une branche pour votre fonctionnalité (`git checkout -b feature/amelioration`)
3. Commiter vos changements (`git commit -m 'Ajout d'une fonctionnalité'`)
4. Pousser vers la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est distribué sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👤 Auteur

**ZarTek-Creole**

- GitHub: [@ZarTek-Creole](https://github.com/ZarTek-Creole)
- Projet: [TCL-DebugLoader](https://github.com/ZarTek-Creole/TCL-DebugLoader)

## 🐛 Support et bugs

Pour signaler un bug ou demander une fonctionnalité, veuillez ouvrir une issue sur le [dépôt GitHub](https://github.com/ZarTek-Creole/TCL-DebugLoader/issues).

## ⭐ Remerciements

- Inspiré par LiveBugTracer pour ses fonctionnalités de débogage avancées
- Communauté Eggdrop pour le support et les retours
- Tous les contributeurs qui ont participé à l'amélioration de ce projet

## 📚 Documentation complémentaire

- [Documentation Eggdrop](https://www.eggheads.org/support/egghtml/)
- [Documentation Tcl](https://www.tcl.tk/man/)
- [Guide des meilleures pratiques Tcl](https://wiki.tcl-lang.org/page/Tcl+Style+Guide)

---

**Note** : Ce script est un outil de développement professionnel. Pour une utilisation en production, assurez-vous de tester toutes les configurations dans un environnement de test avant le déploiement.
