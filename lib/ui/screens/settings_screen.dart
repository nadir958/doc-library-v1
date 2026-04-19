import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: "Général"),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Langue"),
            subtitle: const Text("Français"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Thème"),
            subtitle: const Text("Sombre (Système)"),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          const _SectionHeader(title: "Sécurité"),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Verrouillage Biométrique"),
            subtitle: const Text("Désactivé pour le moment"),
            trailing: Switch(value: false, onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bientôt disponible dans les réglages")),
              );
            }),
          ),
          const Divider(),
          const _SectionHeader(title: "Données"),
          ListTile(
            leading: const Icon(Icons.cloud_off, color: Colors.orangeAccent),
            title: const Text("Synchronisation Cloud"),
            subtitle: const Text("Non configurée (Phase 2)"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text("Effacer toutes les données"),
            onTap: () {
              _showDeleteAllDialog(context);
            },
          ),
          const Divider(),
          const _SectionHeader(title: "À propos"),
          const ListTile(
            title: Text("Version"),
            trailing: Text("1.0.0"),
          ),
          ListTile(
            title: const Text("Développé par Antigravity"),
            subtitle: const Text("Privacy-First Document Library"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tout effacer ?"),
        content: const Text("Toutes vos données locales seront supprimées définitivement."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Tout supprimer", style: TextStyle(color: Colors.red))
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
