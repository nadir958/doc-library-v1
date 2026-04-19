# Plan d'Implémentation - Phase 1 (V1) : Mobile-First Document Library

Ce plan détaille la mise en place technique de la première version de l'application, basée sur les objectifs du **Rapport Final**.

## Objectifs Mémorisés
- **Expérience Locale** : Rapidité et confidentialité (pas de cloud en V1).
- **Capture Hybride** : Support du Smart Scan et de la Photo Manuelle.
- **Organisation** : Recherche par OCR et gestion par Tags/Collections.

---

## Architecture Proposée
Utilisation d'une architecture en couches (Clean Architecture simplifiée) :
- **Data** : Modèles Isar, Repository de stockage local.
- **Domain** : Entités et services de traitement (OCR, Image Processing).
- **UI** : Widgets Flutter, gestion d'état (Provider ou Riverpod).

---

## Étape 1 : Modèle de Données (Isar DB)
Création des schémas pour stocker les documents et leurs métadonnées.

### [NEW] `document_model.dart`
- `id`: Id auto-incrémenté.
- `title`: Titre du document.
- `createdAt`: Date de création.
- `tags`: Liste de chaînes de caractères (indexée).
- `pages`: Liste de liens vers les objets `PageModel`.

### [NEW] `page_model.dart`
- `imagePath`: Chemin local vers l'image traitée.
- `originalPath`: Chemin vers la photo brute.
- `ocrText`: Texte extrait par ML Kit.
- `order`: Position dans le document.

---

## Étape 2 : Module de Capture & OCR
Intégration des services de vision.

### [NEW] `scan_service.dart`
- Méthode `startSmartScan()` : Utilise `google_mlkit_document_scanner`.
- Méthode `takeManualPhoto()` : Utilise le package `camera`.

### [NEW] `ocr_service.dart`
- Méthode `processImage(String path)` : Extrait le texte via `google_mlkit_text_recognition`.

---

## Étape 3 : Interface Utilisateur (V1)
Développement des écrans principaux avec un design "Premium".

### 1. Dashboard (Library View)
- Liste de cartes avec thumbnails.
- Barre de recherche filtrant sur le titre et le texte OCR.
- Bouton flottant (FAB) ouvrant le choix de capture.

### 2. Document Detail
- Visualiseur de pages.
- Édition des tags et du titre.
- Export en PDF simple.

---

## Plan de Vérification
- **Tests Unitaires** : Validation du schéma Isar et de l'indexation de recherche.
- **Tests Manuels** :
    - Vérifier que le texte d'un document scanné est immédiatement trouvable via la recherche.
    - Tester le basculement fluide entre Scan et Photo.

---

## Questions pour l'Utilisateur
> [!IMPORTANT]
> 1. Souhaitez-vous utiliser **Riverpod** ou **Provider** pour la gestion d'état ? (Je recommande Riverpod pour sa robustesse).
> 2. Préférez-vous un design **Dark Mode** par défaut ou un thème dynamique ?
> 3. Comme Flutter n'est pas pré-installé dans cet environnement, préférez-vous que je génère tout le code pour que vous puissiez le copier dans votre projet local ?
