# Guide de Dépannage du Build Android (CI/CD)

Ce document répertorie les problèmes complexes rencontrés lors de l'automatisation du build Android (APK) via GitHub Actions et leurs solutions.

## 1. Problème de Minification R8 avec Google ML Kit
**Erreur :** `ERROR: Missing classes detected while running R8` (Classes manquantes pour `ChineseTextRecognizerOptions`, etc.)

**Cause :** Lors d'un build `release`, l'outil de minification (R8/ProGuard) supprime le code inutilisé. Le package `google_mlkit_text_recognition` fait référence à des modèles de langues asiatiques que nous n'incluons pas (car nous n'utilisons que l'alphabet latin par défaut). R8 détecte ces références manquantes et fait crasher le build par sécurité.

**Solution :**
Nous avons créé un fichier de règles d'exclusion ProGuard (`android/app/proguard-rules.pro`) pour dire à R8 d'ignorer ces avertissements :
```text
-dontwarn com.google.mlkit.vision.text.**
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.**
```
Et nous avons lié ce fichier dans `android/app/build.gradle` :
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## 2. Incompatibilité de Version Dart (OpenCV)
**Erreur :** `Because doc_library depends on opencv_dart >=2.1.0 which requires SDK version >=3.10.0 <4.0.0, version solving failed.`

**Cause :** La version récente de `opencv_dart` (2.x) nécessite une version très récente du SDK Dart, non compatible avec la version stable de Flutter ciblée (3.22.0).

**Solution :**
Rétrogradation de `opencv_dart` à la version `^1.4.3` dans le fichier `pubspec.yaml`, qui est parfaitement compatible avec l'environnement actuel.

## 3. Configuration Minimale du SDK Android (minSdkVersion)
**Erreur :** `uses-sdk:minSdkVersion 21 cannot be smaller than version 24 declared in library [:opencv_dart]`

**Cause :** La librairie `opencv_dart` (v1.4.3) exige qu'Android 7.0 (API 24) soit la version minimale supportée, alors que le projet Flutter était configuré pour l'API 21.

**Solution :**
Modification de la valeur `minSdkVersion` de 21 à 24 dans `android/app/build.gradle`.

## 4. Conflit d'Espaces de Noms (Namespace) avec Isar et AGP 8+
**Erreur :** `Namespace not specified. Please specify a namespace in the module's build.gradle file` dans `isar_flutter_libs`.

**Cause :** L'Android Gradle Plugin (AGP) version 8 exige qu'un "namespace" soit explicitement défini pour chaque librairie. L'ancienne version d'Isar (3.x) ne déclare pas ce namespace.

**Solution :**
Plutôt que de rétrograder Gradle, un script a été ajouté à `android/build.gradle` pour injecter dynamiquement le namespace manquant dans toutes les sous-dépendances :
```gradle
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            if (project.android.hasProperty('namespace') && project.android.namespace == null) {
                project.android.namespace = project.group ?: "com.example.${project.name.replace('-', '_')}"
            }
        }
    }
}
```
