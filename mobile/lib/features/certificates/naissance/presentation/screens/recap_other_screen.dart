import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class RecapOtherScreen extends ConsumerWidget {
  final Map<String, dynamic> data;

  const RecapOtherScreen({super.key, required this.data});

  void _submitForm(BuildContext context) {
    // Send to payment
    context.push('/payment', extra: {
      'documentId': data['docId'] ?? 'extrait_naissance',
      'documentName': data['docName'] ?? 'Extrait de naissance',
      'formData': data,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forSelf = data['forSelf'] == true;
    final title = forSelf ? 'Récapitulatif (Pour moi)' : 'Récapitulatif (Proche)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vérifiez vos informations', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Assurez-vous que les informations saisies sont exactes avant de procéder au paiement.',
                style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDataRow('N° de Registre', data['registre']?.toString() ?? ''),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    _buildDataRow('Année de déclaration', data['annee']?.toString() ?? ''),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    _buildDataRow('Prénom et nom', data['nom']?.toString() ?? ''),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    _buildDataRow('Région de naissance', data['region']?.toString() ?? ''),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    _buildDataRow('Commune de naissance', data['commune']?.toString() ?? ''),
                    if (!forSelf && data['lienParente'] != null) ...[
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _buildDataRow('Lien de parenté', data['lienParente']?.toString() ?? ''),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Note d'alerte
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Toute fausse déclaration est passible de poursuites pénales selon la législation en vigueur.',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
                          height: 1.4,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF0B285D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Modifier',
                        style: TextStyle(color: Color(0xFF0B285D), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _submitForm(context),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Text(
                          'Payer et soumettre',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
