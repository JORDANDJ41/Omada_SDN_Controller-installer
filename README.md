# Omada Controller – script d'installation pour Linux

Un script pour installer **ou mettre à jour** le contrôleur logiciel **TP-Link Omada** (Omada Network Application) sur Ubuntu ou Debian, en une commande.

Le script installe Java 17, JSVC et MongoDB depuis le dépôt officiel, puis télécharge et installe le paquet Omada.

![Version Omada](https://img.shields.io/badge/Omada-6.3.0.45-0b7fab)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?logo=ubuntu&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-11%20%7C%2012-A81D33?logo=debian&logoColor=white)

## Systèmes supportés

| Système | MongoDB installé | Java |
|---|---|---|
| Ubuntu 24.04 (recommandé) | 8.0 | OpenJDK 17 |
| Ubuntu 22.04 | 8.0 | OpenJDK 17 |
| Ubuntu 20.04 | 8.0 | OpenJDK 17 |
| Debian 12 | 8.0 | OpenJDK 17 |
| Debian 11 | 7.0 | OpenJDK 17 |

Seule l'architecture **x86_64** est supportée par TP-Link : pas de Raspberry Pi.

## Configuration conseillée

- 2 cœurs, **2 Go de RAM** minimum (4 Go conseillés)
- **10 Go** d'espace disque libre ou plus
- Un processeur avec les instructions **AVX**, exigées par MongoDB 5 et plus.
  > Sur une VM **Proxmox**, mettre le type de processeur sur `host` (Matériel → Processeurs → Type), sinon MongoDB ne démarre pas.

## Installation

En SSH ou en console, lancer :

```bash
curl -fsSL https://raw.githubusercontent.com/JORDANDJ41/Omada_SDN_Controller-installer/main/install-omada-controller.sh | sudo bash
```

À la fin, le script affiche l'adresse de l'interface : `https://<IP-du-serveur>:8043`.
Le premier démarrage prend 2 à 3 minutes.

### Installer une autre version

Récupérer le lien du `.deb` Linux sur la [page de téléchargement officielle](https://support.omadanetworks.com/download/software/omada-controller/), puis :

```bash
curl -fsSL https://raw.githubusercontent.com/JORDANDJ41/Omada_SDN_Controller-installer/main/install-omada-controller.sh | sudo OMADA_URL="https://static.tp-link.com/...linux_x64....deb" bash
```

## Mise à jour

1. **Faire une sauvegarde** dans le contrôleur : Paramètres → Maintenance → Sauvegarde.
2. Relancer la même commande d'installation. Le script détecte l'installation existante, demande confirmation, puis met Omada à jour en gardant la configuration.

> Depuis la version 5.14.32, on ne peut plus passer directement d'un contrôleur v4 à la dernière version : il faut d'abord monter en 5.x.

## Commandes utiles

```bash
sudo tpeap status   # état
sudo tpeap start    # démarrer
sudo tpeap stop     # arrêter
```

## Ports à ouvrir (pare-feu)

| Port | Usage |
|---|---|
| 8043/TCP | Interface web (HTTPS) |
| 8088/TCP | Interface web (HTTP) |
| 8843/TCP | Portail captif HTTPS |
| 27001/UDP, 29810/UDP | Découverte des équipements |
| 29811–29817/TCP | Adoption et gestion des équipements (29817 obligatoire depuis la v6) |

## Dépannage

- **MongoDB ne démarre pas / `Illegal instruction`** : le CPU n'a pas AVX (voir plus haut).
- **L'interface ne répond pas** : attendre quelques minutes, puis `sudo tpeap status`. Les journaux sont dans `/opt/tplink/EAPController/logs/`.
- **Équipements non découverts** : vérifier que le serveur est dans le même réseau/VLAN, ou utiliser l'adoption L3 (Omada Discovery Utility ou option DHCP 138).

## Retours

La version 2.0 vient d'être réécrite pour Omada 6.x. Si vous l'avez testée (réussite ou échec), merci de le signaler dans une [issue](https://github.com/JORDANDJ41/Omada_SDN_Controller-installer/issues) en précisant le système utilisé (`lsb_release -a`). En cas d'erreur, joignez la sortie du script.

## Liens

- [Guide officiel d'installation Linux](https://support.omadanetworks.com/document/13088/)
- [Guide officiel de mise à jour](https://support.omadanetworks.com/document/13222/)
- [Téléchargements Omada Controller](https://support.omadanetworks.com/download/software/omada-controller/)

Merci à [@willquill](https://github.com/willquill/omada-ubuntu) pour son guide d'origine.

## Licence

[MIT](LICENSE) : libre d'utilisation et de modification. Script fourni tel quel, sans garantie.

---

☕ Ce script vous a fait gagner du temps ? [Offrez-moi un café sur Ko-fi](https://ko-fi.com/jordandj41)
