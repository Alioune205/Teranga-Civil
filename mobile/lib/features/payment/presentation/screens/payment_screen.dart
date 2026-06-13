import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../dossiers/presentation/providers/dossiers_provider.dart';
import '../../../documents/presentation/providers/drafts_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String documentId;
  final String documentName;
  final Map<String, dynamic> formData;

  const PaymentScreen({
    super.key,
    required this.documentId,
    required this.documentName,
    required this.formData,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'wave', 'name': 'Wave', 'color': const Color(0xFF00C3F9), 'icon': Icons.waves},
    {'id': 'om', 'name': 'Orange Money', 'color': const Color(0xFFFF7900), 'icon': Icons.phone_android},
    {'id': 'wizzal', 'name': 'Wizzal', 'color': const Color(0xFF10B981), 'icon': Icons.account_balance_wallet},
    {'id': 'mixx', 'name': 'Mixx by Yas', 'color': const Color(0xFF8B5CF6), 'icon': Icons.currency_exchange},
    {'id': 'touchpoint', 'name': 'My Touch Point', 'color': const Color(0xFFEC4899), 'icon': Icons.touch_app},
    {'id': 'paypal', 'name': 'PayPal', 'color': const Color(0xFF003087), 'icon': Icons.payment},
  ];

  void _processPayment() {
    // 1. Supprimer du brouillon si présent
    ref.read(draftsProvider.notifier).removeDraft(widget.documentId);

    // 2. Invalider la liste des dossiers pour forcer un rechargement
    ref.invalidate(dossiersListProvider);

    // 3. Afficher la modale de succès
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SuccessModal(documentName: widget.documentName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Paiement',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        ),
        backgroundColor: const Color(0xFF0B285D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisissez votre moyen de paiement',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paiement sécurisé de 500 FCFA',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 24),
                  ..._paymentMethods.map((method) {
                    final isSelected = _selectedMethod == method['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = method['id']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? (method['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? (method['color'] as Color) : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (method['color'] as Color).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(method['icon'] as IconData, color: method['color'] as Color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                method['name'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: method['color'] as Color, size: 24),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          // BOTTOM CTA BAR
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _selectedMethod != null ? _processPayment : null,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _selectedMethod != null
                          ? const LinearGradient(
                              colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: _selectedMethod == null ? const Color(0xFFE2E8F0) : null,
                    ),
                    child: Text(
                      'Payer',
                      style: TextStyle(
                        color: _selectedMethod != null ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
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

class _SuccessModal extends StatelessWidget {
  final String documentName;

  const _SuccessModal({required this.documentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paiement Réussi !',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 12),
            const Text(
              "Votre document a bien été soumis. Le délai d'attente est de 48h maximum. Merci de patienter.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Inter', height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  context.pop(); // close modal
                  context.go('/dossiers'); // Aller vers la page des dossiers
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Text('Voir le document', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  context.pop(); // close modal
                  context.go('/documents'); // Retourner aux documents
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color(0xFFF1F5F9),
                  ),
                  child: const Text('Faire une autre demande', style: TextStyle(color: Color(0xFF475569), fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
