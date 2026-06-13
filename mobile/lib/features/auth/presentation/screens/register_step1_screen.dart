import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/assets_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/auth_provider.dart';

class RegisterStep1Screen extends ConsumerStatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  ConsumerState<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends ConsumerState<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomCtr = TextEditingController();
  final _nomCtr = TextEditingController();
  final _identifierCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final _confirmCtr = TextEditingController();

  bool _usePhone = true;
  bool _acceptCgu = false;
  bool _acceptPolitique = false;

  @override
  void dispose() {
    _prenomCtr.dispose();
    _nomCtr.dispose();
    _identifierCtr.dispose();
    _passwordCtr.dispose();
    _confirmCtr.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _prenomCtr.text.trim().isNotEmpty &&
      _nomCtr.text.trim().isNotEmpty &&
      _identifierCtr.text.trim().isNotEmpty &&
      _passwordCtr.text.length >= 6 &&
      _confirmCtr.text == _passwordCtr.text &&
      _acceptCgu &&
      _acceptPolitique;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptCgu || !_acceptPolitique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions et la politique.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(registrationDataProvider.notifier).update((d) => d.copyWith(
          prenom: _prenomCtr.text.trim(),
          nom: _nomCtr.text.trim(),
          password: _passwordCtr.text,
          phone: _usePhone ? _identifierCtr.text.trim() : null,
          email: !_usePhone ? _identifierCtr.text.trim() : null,
          usePhone: _usePhone,
        ));

    try {
      await ref.read(authProvider.notifier).register(
            prenom: _prenomCtr.text.trim(),
            nom: _nomCtr.text.trim(),
            password: _passwordCtr.text,
            phone: _usePhone ? _identifierCtr.text.trim() : null,
            email: !_usePhone ? _identifierCtr.text.trim() : null,
          );
      if (!mounted) return;
      context.push(AppRoutes.registerStep3,
          extra: {'identifier': _identifierCtr.text.trim()});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Impossible d\'ouvrir : $url'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background abstrait premium
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header (Bouton retour)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primary),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),

                // Contenu scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Form(
                      key: _formKey,
                      onChanged: () => setState(() {}),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(Assets.logoTeranga, width: 120, height: 120, fit: BoxFit.contain),
                          const SizedBox(height: 16),

                          Text('Créer un compte', style: AppTextStyles.displayMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Remplissez le formulaire pour vous inscrire',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 28),

                          GlassCard(
                            child: Column(
                              children: [
                                _buildToggle(),
                                const SizedBox(height: 16),

                                if (_usePhone)
                                  AppTextField(
                                    label: 'Numéro de téléphone',
                                    hint: '77 123 45 67',
                                    controller: _identifierCtr,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    validator: Validators.phone,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                      child: Text('+221',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    ),
                                  )
                                else
                                  AppTextField(
                                    label: 'Adresse email',
                                    hint: 'nom@exemple.com',
                                    controller: _identifierCtr,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'L\'email est requis.';
                                      if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
                                        return 'Adresse email invalide.';
                                      }
                                      return null;
                                    },
                                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 22),
                                  ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Prénom',
                                        hint: 'Amadou',
                                        controller: _prenomCtr,
                                        validator: Validators.fullName,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Nom',
                                        hint: 'Diallo',
                                        controller: _nomCtr,
                                        validator: Validators.fullName,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                AppTextField(
                                  label: 'Mot de passe',
                                  hint: '••••••••',
                                  controller: _passwordCtr,
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.length < 6) return '6 caractères min.';
                                    return null;
                                  },
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(height: 16),

                                AppTextField(
                                  label: 'Confirmer le mot de passe',
                                  hint: '••••••••',
                                  controller: _confirmCtr,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) {
                                    if (v != _passwordCtr.text) return 'Les mots de passe ne correspondent pas.';
                                    return null;
                                  },
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(height: 24),

                                _CheckboxLink(
                                  value: _acceptCgu,
                                  onChanged: (v) => setState(() => _acceptCgu = v ?? false),
                                  prefix: 'J\'accepte les ',
                                  linkText: 'conditions générales d\'utilisation',
                                  onLinkTap: () => _openUrl('https://e-senegal.sn/#/conditions-generales-utilisation'),
                                ),
                                const SizedBox(height: 10),
                                _CheckboxLink(
                                  value: _acceptPolitique,
                                  onChanged: (v) => setState(() => _acceptPolitique = v ?? false),
                                  prefix: 'J\'accepte la ',
                                  linkText: 'politique de confidentialité',
                                  onLinkTap: () => _openUrl('https://e-senegal.sn/#/mentions-legales'),
                                ),
                                const SizedBox(height: 28),

                                PrimaryButton(
                                  label: 'Envoyer le code de vérification',
                                  onPressed: _submit,
                                  isLoading: isLoading,
                                  isEnabled: _isValid,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('Déjà un compte ? ', style: AppTextStyles.bodyMedium),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.login),
                                child: Text("Se connecter",
                                    style: AppTextStyles.link.copyWith(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _usePhone = true;
                _identifierCtr.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _usePhone ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _usePhone
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  'Téléphone',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: _usePhone ? Colors.white : AppColors.textSecondary,
                    fontWeight: _usePhone ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _usePhone = false;
                _identifierCtr.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_usePhone ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_usePhone
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  'Email',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: !_usePhone ? Colors.white : AppColors.textSecondary,
                    fontWeight: !_usePhone ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxLink extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;
  final String prefix;
  final String linkText;
  final VoidCallback onLinkTap;

  const _CheckboxLink({
    required this.value,
    required this.onChanged,
    required this.prefix,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall,
                children: [
                  TextSpan(text: prefix),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: onLinkTap,
                      child: Text(
                        linkText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
