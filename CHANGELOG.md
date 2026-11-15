# Journal des modifications

## 2026-11-15 – Version 2.0
- Omada **6.3.0.45** par défaut (au lieu de 5.15.24.19).
- Prise en charge d'**Ubuntu 22.04 / 24.04** et de **Debian 11 / 12**. Ubuntu 16.04 et 18.04 ne sont plus supportés.
- **Java 17** (exigé depuis Omada 5.15.20) à la place de Java 8.
- **MongoDB 8.0** (7.0 sur Debian 11) à la place de 4.4, qui est en fin de vie.
- Clé du dépôt MongoDB en `signed-by`, sans `apt-key`, qui est obsolète.
- Vérifications au démarrage : root, x86_64, instructions **AVX**, espace disque.
- Détection d'une installation existante, avec mise à jour après confirmation.
- Variable `OMADA_URL` pour installer une autre version.
- README réécrit en français, avec une commande d'installation corrigée.

## 2025-10-04
- Omada 5.15.24.19.

## 2022-11-17
- Première version (Ubuntu 16.04 / 18.04 / 20.04, Omada 5.x, MongoDB 4.4, Java 8).
