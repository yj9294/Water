import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
import '../widgets/ios_nav_bar.dart';
import '../widgets/soft_card.dart';
import '../widgets/water_background.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalPage(
      title: 'Privacy Policy',
      eyebrow: 'Legal',
      subtitle:
          'HydraPal keeps tracking lightweight and local-first. This page explains what is stored and how it is used.',
      sections: const [
        _LegalSectionCard(
          title: 'What we collect',
          body:
              'Hydration records, target preferences, and app settings may be stored on your device so the app can remember your routine.',
        ),
        _LegalSectionCard(
          title: 'How we use data',
          body:
              'Local data is used to keep tracking, reminders, and preferences working as expected. If ads are enabled, the ad provider may process device and usage signals under its own policies.',
        ),
        _LegalSectionCard(
          title: 'Sharing',
          body:
              'We do not sell your personal data. Only limited information needed to run the app may be processed by service providers.',
        ),
        _LegalSectionCard(
          title: 'Children',
          body:
              'HydraPal is not intended for children under 13. If you believe a child has provided information, contact us for help.',
        ),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalPage(
      title: 'Terms of Service',
      eyebrow: 'Legal',
      subtitle:
          'These terms apply when you use HydraPal. The app is for personal tracking only, not medical advice.',
      sections: const [
        _LegalSectionCard(
          title: 'Use of the app',
          body:
              'HydraPal is a personal hydration tracker. Do not rely on it for diagnosis or treatment decisions.',
        ),
        _LegalSectionCard(
          title: 'Service availability',
          body:
              'We may change, suspend, or remove features at any time to keep the app stable or support future updates.',
        ),
        _LegalSectionCard(
          title: 'Third-party services',
          body:
              'Some builds may use third-party services such as advertising providers. Their own terms and policies may also apply.',
        ),
        _LegalSectionCard(
          title: 'Disclaimer',
          body:
              'Hydration targets and suggestions are informational only and are not medical advice. Please consult a qualified professional for health decisions.',
        ),
      ],
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalPage(
      title: 'Support',
      eyebrow: 'Help',
      subtitle:
          'Need help with the app, privacy, or feedback? Reach out and include a few details so we can help quickly.',
      sections: [
        _LegalActionCard(
          title: 'Email support',
          body: 'zhh520wje@163.com',
          actionLabel: 'Send email',
          onAction: () => _openEmail(context),
        ),
        const _LegalSectionCard(
          title: 'What to include',
          body:
              'Please include your iPhone model, iOS version, app version, and a short description of the issue if possible.',
        ),
        const _LegalSectionCard(
          title: 'Response time',
          body:
              'We aim to reply within a reasonable time, usually within a few business days.',
        ),
      ],
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri.parse('mailto:zhh520wje@163.com');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      AppToast.show(
        context,
        'Could not open Mail. Please email zhh520wje@163.com',
      );
    }
  }
}

class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.title,
    required this.eyebrow,
    required this.subtitle,
    required this.sections,
  });

  final String title;
  final String eyebrow;
  final String subtitle;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bg,
      child: WaterBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              58,
              AppSpacing.pageX,
              AppSpacing.pageBottomWithTab,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              IosNavBar(
                title: title,
                showBack: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 10),
              _HeroCard(eyebrow: eyebrow, subtitle: subtitle),
              const SizedBox(height: 14),
              ...sections.expand(
                (section) => [section, const SizedBox(height: 12)],
              ),
              const SizedBox(height: 4),
              const _FooterNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.eyebrow, required this.subtitle});

  final String eyebrow;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      height: 180,
      radius: 26,
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -14,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.aqua.withValues(alpha: .32),
                    AppColors.aqua.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.aqua,
                  letterSpacing: 0.14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              const Text(
                'HydraPal',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.body.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _LegalActionCard extends StatelessWidget {
  const _LegalActionCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.body.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onAction,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.aqua,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.bg,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'If you need anything else, email zhh520wje@163.com.',
        style: AppTextStyles.label.copyWith(fontSize: 11),
      ),
    );
  }
}
