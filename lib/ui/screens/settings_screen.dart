import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../../data/repositories/document_repository.dart';
import '../providers/document_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.general),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              settings.locale?.languageCode == 'fr' ? 'Français' : 
              settings.locale?.languageCode == 'en' ? 'English' :
              settings.locale?.languageCode == 'ar' ? 'العربية' : 'Système'
            ),
            onTap: () {
              _showLanguageDialog(context, settingsNotifier);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(l10n.theme),
            subtitle: Text(
              settings.themeMode == ThemeMode.system ? 'Système' :
              settings.themeMode == ThemeMode.dark ? 'Sombre' : 'Clair'
            ),
            onTap: () {
              _showThemeDialog(context, settingsNotifier);
            },
          ),
          const Divider(),
          _SectionHeader(title: l10n.security),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(l10n.biometricLock),
            subtitle: Text(l10n.disabledForNow),
            trailing: Switch(value: false, onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.comingSoon)),
              );
            }),
          ),
          const Divider(),
          _SectionHeader(title: l10n.data),
          ListTile(
            leading: const Icon(Icons.cloud_off, color: Colors.orangeAccent),
            title: const Text("Synchronisation Cloud"),
            subtitle: const Text("Non configurée (Phase 2)"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: Text(l10n.deleteAllData),
            onTap: () {
              _showDeleteAllDialog(context, ref);
            },
          ),
          const Divider(),
          _SectionHeader(title: l10n.about),
          ListTile(
            title: Text(l10n.version),
            trailing: const Text("1.0.0"),
          ),
          ListTile(
            title: Text(l10n.developedBy),
            subtitle: const Text("Privacy-First Document Library"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.system),
              onTap: () {
                notifier.setLocale(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Français"),
              onTap: () {
                notifier.setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("English"),
              onTap: () {
                notifier.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("العربية"),
              onTap: () {
                notifier.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.system),
              onTap: () {
                notifier.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.light),
              onTap: () {
                notifier.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.dark),
              onTap: () {
                notifier.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllData),
        content: const Text("Toutes vos données locales seront supprimées définitivement."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
               final repo = ref.read(documentRepositoryProvider);
               await repo.deleteAllData();
               ref.read(documentListProvider.notifier).loadDocuments();
               if (context.mounted) Navigator.pop(context);
            }, 
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.indigoAccent.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
