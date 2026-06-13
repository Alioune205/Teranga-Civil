import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/dossiers_provider.dart';

class DossierDetailScreen extends ConsumerStatefulWidget {
  final String dossierId; 
  const DossierDetailScreen({super.key, required this.dossierId});

  @override
  ConsumerState<DossierDetailScreen> createState() => _DossierDetailScreenState();
}

class _DossierDetailScreenState extends ConsumerState<DossierDetailScreen> {
  bool _isDownloading = false;

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir', style: TextStyle(fontFamily: 'Inter')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showContactModal(String agentName, String agentRole) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    agentName.split(' ').map((e) => e[0]).join().toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Plus Jakarta Sans')),
                      const SizedBox(height: 4),
                      Text(agentRole, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Inter')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                      _showComingSoon();
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, color: Color(0xFF1D4ED8), size: 20),
                          SizedBox(width: 10),
                          Text('Message', style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                      _showComingSoon();
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Color(0xFF16A34A), size: 20),
                          SizedBox(width: 10),
                          Text('Appeler', style: TextStyle(color: Color(0xFF16A34A), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, String id) async {
    setState(() => _isDownloading = true);
    try {
      final path = await ref.read(downloadCertificateProvider(id).future);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Certificat sauvegardé :\n$path', style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e', style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dossierAsync = ref.watch(dossierDetailProvider(widget.dossierId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: dossierAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0B285D))),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Dossier introuvable', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextButton(onPressed: () => context.pop(), child: const Text('Retour', style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
        data: (dossier) {
          final status = dossier.status;
          final isDone = status == 'pret' || status == 'valide' || status == 'termine';
          final isIncomplete = status == 'rejete' || status == 'incomplet';

          Color badgeBg = const Color(0xFFD1FAE5);
          Color badgeText = const Color(0xFF065F46);
          String badgeLabel = 'VALIDÉ';

          if (isDone) {
            badgeBg = const Color(0x4010B981);
            badgeText = const Color(0xFF6EE7B7);
            badgeLabel = 'VALIDÉ';
          } else if (isIncomplete) {
            badgeBg = const Color(0x40EF4444);
            badgeText = const Color(0xFFFCA5A5);
            badgeLabel = 'INCOMPLET';
          } else {
            badgeBg = const Color(0x40F59E0B);
            badgeText = const Color(0xFFFCD34D);
            badgeLabel = 'EN COURS';
          }

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // DET-HDR (BLUE)
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                      child: Column(
                        children: [
                          // Nav
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.8), size: 18),
                                    const SizedBox(width: 6),
                                    Text('Mes dossiers', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildNavBtn(Icons.share),
                                  const SizedBox(width: 8),
                                  _buildNavBtn(Icons.more_vert),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Doc info
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.file_copy, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        badgeLabel,
                                        style: TextStyle(
                                          color: badgeText,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      AppFormatters.certTypeLabel(dossier.type),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Plus Jakarta Sans',
                                        letterSpacing: -0.3,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '#SN-${dossier.id} · ${dossier.communeNom ?? 'Mairie'}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Det-meta
                          Row(
                            children: [
                              Expanded(child: _buildMetaCard('72h', 'Durée totale')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildMetaCard(dossier.fraisFCFA == 0 ? 'Gratuit' : '${dossier.fraisFCFA} F', 'Coût')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildMetaCard(isDone ? '4/4' : '3/4', 'Étapes')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // BODY
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
                      child: Column(
                        children: [
                          // SECTION: Informations
                          _buildSectionCard(
                            icon: Icons.info_outline,
                            title: 'Informations du dossier',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildInfoCell('Référence', '#SN-${dossier.id}', hasBorder: true)),
                                    Expanded(child: _buildInfoCell('Type', AppFormatters.certTypeLabel(dossier.type))),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: _buildInfoCell('Soumis le', AppFormatters.dateShort(dossier.createdAt), hasBorder: true)),
                                    Expanded(child: _buildInfoCell('Validé le', isDone ? 'Aujourd\'hui' : '-')),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: _buildInfoCell('Mairie', dossier.communeNom ?? 'N/A', hasBorder: true)),
                                    Expanded(child: _buildInfoCell('Service', 'État civil')),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: _buildInfoCell('Validité doc.', '3 mois', hasBorder: true, isLastRow: true)),
                                    Expanded(child: _buildInfoCell('Canal', 'Teranga Civil', isLastRow: true)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // SECTION: Agent assigné
                          _buildSectionCard(
                            icon: Icons.support_agent,
                            title: 'Agent assigné',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('FS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Fatou Sall', style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                        SizedBox(height: 2),
                                        Text('Officier d\'état civil · Dakar', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontFamily: 'Inter')),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showContactModal('Fatou Sall', 'Officier d\'état civil · Dakar'),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                                          child: const Icon(Icons.message, size: 16, color: Color(0xFF2563EB)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showContactModal('Fatou Sall', 'Officier d\'état civil · Dakar'),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                                          child: const Icon(Icons.phone, size: 16, color: Color(0xFF16A34A)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // SECTION: Timeline
                          _buildSectionCard(
                            icon: Icons.timeline,
                            title: 'Suivi de la demande',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 6),
                              child: Column(
                                children: [
                                  _buildTimelineItem(
                                    step: 'Dossier soumis',
                                    agent: 'Via Teranga Civil · Système',
                                    time: '${AppFormatters.dateShort(dossier.createdAt)} · 14h32',
                                    note: 'Dossier enregistré. Confirmation envoyée par SMS.',
                                    isOk: true,
                                    isLast: false,
                                  ),
                                  _buildTimelineItem(
                                    step: 'Vérification des pièces',
                                    agent: 'Agent : Fatou Sall',
                                    time: dossier.progress >= 0.2 ? 'Aujourd\'hui · 09h15' : '-',
                                    note: dossier.progress >= 0.2 ? 'Pièces vérifiées et validées.' : 'En attente de vérification.',
                                    isOk: dossier.progress >= 0.2,
                                    isLast: false,
                                    isErr: isIncomplete,
                                  ),
                                  _buildTimelineItem(
                                    step: 'Paiement des frais',
                                    agent: 'Wave Mobile Money',
                                    time: dossier.progress >= 0.6 ? 'Aujourd\'hui · 10h04' : '-',
                                    note: dossier.progress >= 0.6 ? 'Transaction confirmée.' : 'En attente de paiement.',
                                    isOk: dossier.progress >= 0.6,
                                    isLast: false,
                                  ),
                                  _buildTimelineItem(
                                    step: 'Acte signé et disponible',
                                    agent: 'Mairie',
                                    time: dossier.progress == 1.0 ? 'Aujourd\'hui · 16h48' : '-',
                                    note: dossier.progress == 1.0 ? 'Document officiel prêt au téléchargement.' : 'En attente de signature.',
                                    isOk: dossier.progress == 1.0,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // SECTION: Pièces fournies
                          _buildSectionCard(
                            icon: Icons.attach_file,
                            title: 'Pièces fournies',
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                              child: Column(
                                children: [
                                  _buildPieceItem('1', 'Certificat d\'accouchement', true),
                                  _buildPieceItem('2', 'CNI du père', !isIncomplete),
                                  _buildPieceItem('3', 'CNI de la mère', true),
                                ],
                              ),
                            ),
                          ),

                          // ACT-BAR
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                if (isDone)
                                  GestureDetector(
                                    onTap: () => _download(context, dossier.id),
                                    child: Container(
                                      width: double.infinity,
                                      height: 48,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.download, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text('Télécharger l\'acte officiel', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                        ],
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showContactModal('Fatou Sall', 'Officier d\'état civil'),
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                                          alignment: Alignment.center,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.message, color: Color(0xFF1D4ED8), size: 18),
                                              SizedBox(width: 6),
                                              Text('Contacter l\'agent', style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _showComingSoon,
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0), borderRadius: BorderRadius.circular(12)),
                                          alignment: Alignment.center,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.share, color: Color(0xFF475569), size: 18),
                                              SizedBox(width: 6),
                                              Text('Partager', style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (isDone)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _showComingSoon,
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0), borderRadius: BorderRadius.circular(12)),
                                            alignment: Alignment.center,
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.archive, color: Color(0xFF475569), size: 18),
                                                SizedBox(width: 6),
                                                Text('Archiver', style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _showComingSoon,
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                                            alignment: Alignment.center,
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete, color: Color(0xFF991B1B), size: 18),
                                                SizedBox(width: 6),
                                                Text('Supprimer', style: TextStyle(color: Color(0xFF991B1B), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else 
                                  GestureDetector(
                                    onTap: _showComingSoon,
                                    child: Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                                      alignment: Alignment.center,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.delete, color: Color(0xFF991B1B), size: 18),
                                          SizedBox(width: 8),
                                          Text('Supprimer le dossier', style: TextStyle(color: Color(0xFF991B1B), fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isDownloading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF0B285D)),
                            SizedBox(height: 16),
                            Text('Téléchargement...', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavBtn(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildMetaCard(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans', height: 1)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF64748B), size: 18),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5, fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoCell(String label, String val, {bool hasBorder = false, bool isLastRow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: hasBorder ? const BorderSide(color: Color(0xFFF8FAFC), width: 1.0) : BorderSide.none,
          bottom: isLastRow ? BorderSide.none : const BorderSide(color: Color(0xFFF8FAFC), width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({required String step, required String agent, required String time, required String note, required bool isOk, required bool isLast, bool isErr = false}) {
    Color dotColor = const Color(0xFFE2E8F0);
    IconData? dotIcon;
    if (isErr) {
      dotColor = const Color(0xFFEF4444);
      dotIcon = Icons.close;
    } else if (isOk) {
      dotColor = const Color(0xFF10B981);
      dotIcon = Icons.check;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 2),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                child: dotIcon != null ? Icon(dotIcon, size: 12, color: Colors.white) : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80, // Approximate height to reach next dot
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: const Color(0xFFE2E8F0),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter', height: 1.3)),
                  const SizedBox(height: 4),
                  Text(agent, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontFamily: 'Inter')),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'Inter')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    ),
                    child: Text(note, style: const TextStyle(color: Color(0xFF475569), fontSize: 12, height: 1.5, fontFamily: 'Inter')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieceItem(String numStr, String name, bool isOk) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC), width: 1.0)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(numStr, style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter', height: 1.3))),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isOk ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(isOk ? Icons.check : Icons.close, size: 14, color: isOk ? const Color(0xFF059669) : const Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}
