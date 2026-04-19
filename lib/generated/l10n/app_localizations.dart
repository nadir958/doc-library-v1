import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Doc Library'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @folders.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers'**
  String get folders;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un document...'**
  String get searchHint;

  /// No description provided for @noDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document trouvé.'**
  String get noDocuments;

  /// No description provided for @addDocument.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un document'**
  String get addDocument;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la galerie'**
  String get fromGallery;

  /// No description provided for @general.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get general;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @security.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get security;

  /// No description provided for @biometricLock.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage Biométrique'**
  String get biometricLock;

  /// No description provided for @data.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get data;

  /// No description provided for @deleteAllData.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les données'**
  String get deleteAllData;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developedBy.
  ///
  /// In fr, this message translates to:
  /// **'Développé par Pick Wisely'**
  String get developedBy;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @tags.
  ///
  /// In fr, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTag.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un tag'**
  String get addTag;

  /// No description provided for @deleteDocument.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le document ?'**
  String get deleteDocument;

  /// No description provided for @deleteDocumentConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les pages seront supprimées.'**
  String get deleteDocumentConfirm;

  /// No description provided for @newFolder.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau dossier'**
  String get newFolder;

  /// No description provided for @folderName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du dossier'**
  String get folderName;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @selectFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier de destination'**
  String get selectFolder;

  /// No description provided for @rootFolder.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier (Racine)'**
  String get rootFolder;

  /// No description provided for @ocrInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Extraction du texte en cours...'**
  String get ocrInProgress;

  /// No description provided for @noPages.
  ///
  /// In fr, this message translates to:
  /// **'Aucune page dans ce document.'**
  String get noPages;

  /// No description provided for @capturePreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu des captures'**
  String get capturePreview;

  /// No description provided for @addPages.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des pages'**
  String get addPages;

  /// No description provided for @selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner la langue'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le thème'**
  String get selectTheme;

  /// No description provided for @viewDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Voir les documents'**
  String get viewDocuments;

  /// No description provided for @disabledForNow.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé pour le moment'**
  String get disabledForNow;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible dans les réglages'**
  String get comingSoon;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get addNote;

  /// No description provided for @smartScan.
  ///
  /// In fr, this message translates to:
  /// **'Smart Scan'**
  String get smartScan;

  /// No description provided for @smartScanDesc.
  ///
  /// In fr, this message translates to:
  /// **'Détection automatique et correction'**
  String get smartScanDesc;

  /// No description provided for @system.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get system;

  /// No description provided for @light.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get dark;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
