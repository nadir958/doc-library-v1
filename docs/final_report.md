# RAPPORT FINAL : Stratégie de Développement "Document Library"

## 1. Résumé Exécutif
L'objectif est de bâtir une bibliothèque de documents personnelle, **privacy-first** et **local-first**, permettant de transformer des scans physiques en archives numériques intelligentes et synchronisées. Le développement est divisé en trois phases majeures pour maîtriser la complexité technique tout en offrant une valeur immédiate.

---

## 2. Vision du Produit
Transformer l'action de "scanner un PDF" en une expérience de "gestion de bibliothèque". 
- **Promesse** : Vos documents sont à vous, indexés localement, et accessibles partout sans compromis sur la vie privée.
- **Différenciateurs** : 
    - Organisation par métadonnées (tags, collections) et non simple arborescence de fichiers.
    - OCR local ultra-rapide.
    - Synchronisation optionnelle vers des services personnels (Drive, Nextcloud).

---

## 3. Phase 1 : Fondation Mobile (V1)
**Objectif** : Lancer la meilleure expérience de capture et d'organisation locale sur smartphone.

### Fonctionnalités Clés
- **Modes de Capture Hybrides** :
    - **Smart Scan** : Détection automatique des bords et correction de perspective.
    - **Photo Manuelle** : Capture brute pour les documents complexes.
- **OCR On-Device** : Extraction de texte en temps réel pour recherche plein texte.
- **Organisation** : Tags, Collections, Favoris et Archivage.
- **Sécurité** : Stockage chiffré local et verrouillage biométrique.

### Pile Technique Recommandée
- **Framework** : Flutter (Single codebase).
- **Moteur de Scan/OCR** : Google ML Kit (Performance & Offline).
- **Base de Données** : Isar ou ObjectBox (Rapidité & Sync-ready).
- **Traitement d'Image** : OpenCV (Cleanup & Filtres).

---

## 4. Phase 2 : Synchronisation Privacy-First (V2)
**Objectif** : Rendre la bibliothèque multi-appareils sans dépendre d'un serveur tiers propriétaire.

### Stratégie de Sync
- **Local-First Sync** : Les données sont sauvegardées localement d'abord, la synchro se fait en arrière-plan.
- **Cibles de Synchronisation** :
    - Google Drive (Grand public).
    - Nextcloud / WebDAV (Utilisateurs avancés / Privacy).
- **Gestion des Conflits** : Modèle "Keep Both" avec notification utilisateur pour éviter toute perte de données.

### Évolutions Techniques
- Introduction d'une couche d'abstraction `StorageProvider`.
- Gestion des checksums pour l'intégrité des fichiers.
- **Intégration Scanners Réseau** : Support expérimental des protocoles Mopria (Android) et AirPrint Scan (iOS) pour piloter des scanners Wi-Fi.

---

## 5. Phase 3 : Expansion Multi-Plateforme (V3)
**Objectif** : Accéder et gérer sa bibliothèque sur tous les écrans.

### Extensions
- **Web App** : Consultante et recherche via le cloud de l'utilisateur.
- **Desktop App** : 
    - Outils de gestion en masse et import par glisser-déposer.
    - **Support Natif des Scanners** : Intégration des protocoles TWAIN/WIA pour une numérisation directe depuis un scanner USB ou réseau sur ordinateur.
- **IA Avancée (Locale)** : Auto-tagging intelligent (détection de factures, dates d'échéance, montants).

---

## 6. Analyse des Risques & Succès
- **Risque d'OCR** : Atténué par l'utilisation de ML Kit au lieu de Tesseract.
- **Risque de Sync** : Atténué par une approche progressive et le support de WebDAV.
- **Critères de Succès** :
    - Temps entre capture et indexation < 2 secondes.
    - Taux de réussite de restauration sur un nouvel appareil : 100%.

---

## 7. Conclusion
Cette stratégie privilégie la **qualité du workflow initial** (V1) avant d'attaquer la complexité du réseau (V2). En utilisant Flutter et une architecture découplée, le projet est prêt pour une croissance vers le web et le desktop dès que la base mobile est stabilisée.

**Fin du Rapport.**
