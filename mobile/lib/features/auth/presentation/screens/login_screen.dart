import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/assets_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/auth_provider.dart';

/// S02 — Connexion (Refonte Premium)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _usePhone = true;
  bool _formValid = false;

  @override
  void dispose() {
    _identifierCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  void _checkValidity() {
    setState(() {
      _formValid = _identifierCtr.text.trim().isNotEmpty &&
          _passwordCtr.text.length >= 6;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // MOCK LOGIN POUR LE PROTOTYPE
    await Future.delayed(const Duration(milliseconds: 800)); // Faux chargement
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _showError(Object e) {
    String msg = 'Une erreur est survenue.';
    if (e is InvalidCredentialsFailure) {
      msg = e.message;
    } else if (e is NetworkFailure) {
      msg = e.message;
    } else if (e is TooManyAttemptsFailure) {
      msg = e.message;
    } else if (e is ApiFailure) {
      msg = e.message;
    } else if (e is ServerFailure) {
      msg = e.message;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final size = MediaQuery.of(context).size;

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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Devise (conservée et épurée)
                    _buildDevise(),
                    const SizedBox(height: 24),

                    // Logo officiel conservé
                    Image.asset(Assets.logoTeranga, width: 140, height: 140, fit: BoxFit.contain),
                    const SizedBox(height: 32),

                    // Titre
                    Text('Bienvenue', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous pour accéder à vos services',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Carte Formulaire Glassmorphism
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        onChanged: _checkValidity,
                        child: Column(
                          children: [
                            // Toggle Téléphone/Email style iOS
                            _buildToggle(),
                            const SizedBox(height: 24),

                            // Champs de saisie
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

                            AppTextField(
                              label: 'Mot de passe',
                              hint: '••••••••',
                              controller: _passwordCtr,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _formValid ? _submit() : null,
                              validator: (v) {
                                if (v == null || v.length < 6) return 'Minimum 6 caractères.';
                                return null;
                              },
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(height: 8),

                            // Mot de passe oublié
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text('Mot de passe oublié ?',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight)),
                              ),
                            ),
                            const SizedBox(height: 24),

                            PrimaryButton(
                              label: 'Se connecter',
                              onPressed: _submit,
                              isLoading: isLoading,
                              isEnabled: _formValid,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Connecter avec Google
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Ou continuer avec', style: AppTextStyles.bodySmall),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google Button
                    OutlinedButton(
                      onPressed: () {
                        // Action Google
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppColors.border),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Google',
                            style: AppTextStyles.buttonPrimary.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Inscription (Correction Overflow)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Pas encore de compte ? ', style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.registerStep1),
                          child: Text("Créer un compte",
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
    );
  }

  Widget _buildDevise() {
    return Column(
      children: [
        const Text(
          'REPUBLIQUE DU SENEGAL',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Un peuple - un but - une foi',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 8,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 25, height: 3, color: const Color(0xFF10B981)), // Vert adapté
            Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 25, height: 3, color: const Color(0xFFF59E0B)), // Jaune adapté
                const Icon(Icons.star, color: Color(0xFF10B981), size: 8),
              ],
            ),
            Container(width: 25, height: 3, color: const Color(0xFFEF4444)), // Rouge adapté
          ],
        ),
      ],
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
                _formValid = false;
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
                _formValid = false;
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
