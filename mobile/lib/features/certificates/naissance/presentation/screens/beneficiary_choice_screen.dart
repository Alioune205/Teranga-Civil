import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BeneficiaryChoiceScreen extends StatelessWidget {
  final String docId;
  final String docName;

  const BeneficiaryChoiceScreen({
    super.key,
    this.docId = 'extrait_naissance',
    this.docName = 'Extrait de naissance',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fond gris très clair pour faire ressortir les cartes
      appBar: AppBar(
        title: Text(
          docName,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        ),
        backgroundColor: const Color(0xFF0B285D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bleu courbé (nouveau design system)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0B285D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pour qui ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez le bénéficiaire pour adapter le formulaire à votre situation.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildPremiumCard(
                    context,
                    title: 'Pour moi-même',
                    subtitle: 'Utilisez vos données de profil pour pré-remplir le formulaire rapidement.',
                    icon: Icons.person_rounded,
                    color: const Color(0xFF2563EB), // Bleu vif
                    bgColor: const Color(0xFFEFF6FF),
                    onTap: () => context.push(AppRoutes.naissanceRecapSelf, extra: {'docId': docId, 'docName': docName}),
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumCard(
                    context,
                    title: 'Pour une autre personne',
                    subtitle: 'Renseignez les informations d\'un proche (enfant, conjoint, etc.).',
                    icon: Icons.family_restroom_rounded,
                    color: const Color(0xFF059669), // Vert vif
                    bgColor: const Color(0xFFECFDF5),
                    onTap: () => context.push(AppRoutes.naissanceOtherPerson, extra: {'docId': docId, 'docName': docName}),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Alert info premium
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_rounded, color: Color(0xFF64748B), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Toutes vos informations sont chiffrées de bout en bout et transmises de manière sécurisée à l\'officier d\'état civil.',
                            style: TextStyle(
                              color: const Color(0xFF475569),
                              fontSize: 13,
                              height: 1.4,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 24),
          ],
        ),
      ),
    );
  }
}
