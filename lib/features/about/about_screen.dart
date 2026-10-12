import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const description =
      'CalcNova is an all-in-one calculator application designed to make everyday calculations and unit conversions simple, quick, and convenient. It brings essential mathematical tools into one clean interface, including basic and scientific calculations and a range of common unit converters. The app is designed to work offline, with a focus on usability, accuracy, and a lightweight experience.';
  static const links = <(String, IconData, String)>[
    ('Portfolio', Icons.language_rounded, 'https://mahinexe.vercel.app/'),
    ('Email', Icons.email_outlined, 'mailto:almahincoc2@gmail.com'),
    ('GitHub', Icons.code_rounded, 'https://github.com/mahinexe'),
    (
      'LinkedIn',
      Icons.business_center_outlined,
      'https://www.linkedin.com/in/mahinexe334',
    ),
    (
      'Facebook',
      Icons.facebook_rounded,
      'https://www.facebook.com/myself.mahin',
    ),
    (
      'Instagram',
      Icons.camera_alt_outlined,
      'https://www.instagram.com/mahin.exe',
    ),
    ('X', Icons.alternate_email_rounded, 'https://x.com/myselfmahin'),
  ];
  Future<void> _open(BuildContext context, String value) async {
    final uri = Uri.parse(value);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open this link')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About CalcNova')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'app_icon.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'CalcNova',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Center(
          child: Text(
            'Version 1.0.0 • Built offline',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 24),
        Text(description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 28),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'dev_image.jpg',
                    width: 92,
                    height: 116,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mohammodullah Al Mahin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Computer Science and Engineering student with an interest in technology and cybersecurity.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Developed by Mohammodullah Al Mahin'),
        const SizedBox(height: 24),
        Text(
          'Connect',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...links.map(
          (link) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(link.$2),
            title: Text(link.$1),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _open(context, link.$3),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '© ${DateTime.now().year} Mohammodullah Al Mahin',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}
