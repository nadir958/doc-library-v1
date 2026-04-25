import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/document_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _SectionHeader(title: l10n.general),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.language_outlined,
                title: l10n.language,
                subtitle: settings.locale?.languageCode == 'fr' ? 'Français' : 
                          settings.locale?.languageCode == 'en' ? 'English' :
                          settings.locale?.languageCode == 'ar' ? 'العربية' : l10n.system,
                onTap: () => _showLanguageDialog(context, settingsNotifier),
              ),
              const Divider(height: 1, indent: 56, color: Colors.transparent),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.theme,
                subtitle: settings.themeMode == ThemeMode.system ? l10n.system :
                          settings.themeMode == ThemeMode.dark ? l10n.dark : l10n.light,
                onTap: () => _showThemeDialog(context, settingsNotifier),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.security),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.fingerprint_outlined, color: Colors.indigoAccent),
                title: Text(l10n.biometricLock, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: settings.isBiometricEnabled 
                    ? Text(l10n.biometricEnabled, style: const TextStyle(fontSize: 12))
                    : null,
                trailing: Switch.adaptive(
                  value: settings.isBiometricEnabled, 
                  onChanged: (val) => settingsNotifier.setBiometricEnabled(val),
                  activeColor: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: l10n.data),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.cloud_off_outlined,
                title: l10n.cloudSync,
                subtitle: l10n.notConfigured,
                color: Colors.orangeAccent,
              ),
              const Divider(height: 1, indent: 56, color: Colors.transparent),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.deleteAllData,
                subtitle: l10n.irreversibleAction,
                color: Colors.redAccent,
                onTap: () => _showDeleteAllDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: l10n.about),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const Divider(height: 1, indent: 24, endIndent: 24, color: Colors.transparent),
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.version,
                subtitle: l10n.stableVersion,
              ),
              const Divider(height: 1, indent: 56, color: Colors.transparent),
              _SettingsTile(
                icon: Icons.verified_outlined,
                title: l10n.developedBy,
                subtitle: l10n.appDescription,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              l10n.protectedByEncryption,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ),
  );
}

  void _showLanguageDialog(BuildContext context, SettingsNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.selectLanguage, style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(label: l10n.system, onTap: () => notifier.setLocale(null)),
            _DialogOption(label: "Français", onTap: () => notifier.setLocale(const Locale('fr'))),
            _DialogOption(label: "English", onTap: () => notifier.setLocale(const Locale('en'))),
            _DialogOption(label: "العربية", onTap: () => notifier.setLocale(const Locale('ar'))),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsNotifier notifier) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.selectTheme, style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(label: l10n.system, onTap: () => notifier.setThemeMode(ThemeMode.system)),
            _DialogOption(label: l10n.light, onTap: () => notifier.setThemeMode(ThemeMode.light)),
            _DialogOption(label: l10n.dark, onTap: () => notifier.setThemeMode(ThemeMode.dark)),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deleteAllData, style: theme.textTheme.titleLarge),
        content: Text(l10n.deleteAllDataConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () async {
               final repo = ref.read(documentRepositoryProvider);
               await repo.deleteAllData();
               ref.read(documentListProvider.notifier).loadDocuments();
               if (context.mounted) Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.delete),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.indigoAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      onTap: onTap,
      trailing: onTap != null ? Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)) : null,
    );
  }
}

class _DialogOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DialogOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

