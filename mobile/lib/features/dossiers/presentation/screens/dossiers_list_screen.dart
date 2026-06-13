import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/dossier_model.dart';
import '../providers/dossiers_provider.dart';

class DossiersListScreen extends ConsumerStatefulWidget {
  const DossiersListScreen({super.key});

  @override
  ConsumerState<DossiersListScreen> createState() => _DossiersListScreenState();
}

class _DossiersListScreenState extends ConsumerState<DossiersListScreen> {
  String _selectedFilter = 'Tous';
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;

  final List<String> _filters = ['Tous', 'En cours', 'Validés', 'Incomplets', 'Archivés'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isExpanded = _scrollController.position.pixels < 50;
      if (isExpanded != _isFabExtended) {
        setState(() => _isFabExtended = isExpanded);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dossiersAsync = ref.watch(dossiersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: _isFabExtended ? 180 : 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0B285D).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 24),
                if (_isFabExtended) ...[
                  const SizedBox(width: 8),
                  const Text('Nouveau Dossier', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600)),
                ]
              ],
            ),
          ),
        ),
      ),
      body: dossiersAsync.when(
        data: (dossiers) {
          final int total = dossiers.length;
          final int enCours = dossiers.where((d) => d.status != 'pret' && d.status != 'rejete' && d.status != 'valide').length;
          final int termines = dossiers.where((d) => d.status == 'pret' || d.status == 'valide').length;
          final int incomplets = dossiers.where((d) => d.status == 'rejete' || d.status == 'incomplet').length;

          // FILTER THE LIST
          List<DossierModel> filteredList = dossiers.where((d) {
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              if (!d.id.toLowerCase().contains(q) &&
                  !(d.type.toLowerCase().contains(q)) &&
                  !(d.beneficiaryNom?.toLowerCase().contains(q) ?? false)) {
                return false;
              }
            }
            if (_selectedFilter == 'En cours') return d.status != 'pret' && d.status != 'rejete' && d.status != 'valide';
            if (_selectedFilter == 'Validés') return d.status == 'pret' || d.status == 'valide';
            if (_selectedFilter == 'Incomplets') return d.status == 'rejete' || d.status == 'incomplet';
            if (_selectedFilter == 'Archivés') return false; 
            return true;
          }).toList();

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER BLEU
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
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mes dossiers',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Plus Jakarta Sans',
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Dernière mise à jour · aujourd\'hui 9h12',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildHdrBtn(Icons.tune),
                                  const SizedBox(width: 8),
                                  _buildHdrBtn(Icons.notifications_none),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // STATS GRID
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('Total', total.toString(), Colors.white.withValues(alpha: 0.1), Colors.white, Colors.white.withValues(alpha: 0.6))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatCard('Validés', termines.toString(), const Color(0x3310B981), const Color(0xFF6EE7B7), const Color(0x996EE7B7))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatCard('En cours', enCours.toString(), const Color(0x33F59E0B), const Color(0xFFFCD34D), const Color(0x99FCD34D))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatCard('Incomplet', incomplets.toString(), const Color(0x33EF4444), const Color(0xFFFCA5A5), const Color(0x99FCA5A5))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // SEARCH ROW
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontFamily: 'Inter'),
                              decoration: InputDecoration(
                                hintText: 'Rechercher un dossier...',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontFamily: 'Inter'),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.mic_none, color: Color(0xFF64748B), size: 16),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TABS
                    Container(
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      height: 66,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: isSelected ? const LinearGradient(
                                  colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ) : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // SORT ROW
                    Container(
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredList.length} dossiers · triés par date',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.swap_vert, size: 14, color: Color(0xFF0B285D)),
                                SizedBox(width: 4),
                                Text(
                                  'Récents',
                                  style: TextStyle(
                                    color: Color(0xFF0B285D),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Inter',
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

              // LIST
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text("Aucun dossier trouvé.", style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DossierDenseCard(dossier: filteredList[i]),
                        );
                      },
                      childCount: filteredList.length,
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0B285D))),
        error: (err, _) => const Center(child: Text('Erreur lors du chargement', style: TextStyle(fontSize: 16))),
      ),
    );
  }

  Widget _buildHdrBtn(IconData icon) {
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

  Widget _buildStatCard(String label, String count, Color bgColor, Color numColor, Color labelColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: numColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Plus Jakarta Sans',
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _DossierDenseCard extends StatelessWidget {
  final DossierModel dossier;
  const _DossierDenseCard({required this.dossier});

  @override
  Widget build(BuildContext context) {
    final status = dossier.status;
    final isDone = status == 'pret' || status == 'valide' || status == 'termine';
    final isIncomplete = status == 'rejete' || status == 'incomplet';
    final isEnCours = !isDone && !isIncomplete;

    Color borderColor = const Color(0xFFE2E8F0);
    Color badgeBg = const Color(0xFFD1FAE5);
    Color badgeText = const Color(0xFF065F46);
    String badgeLabel = 'VALIDÉ';
    
    Color iconBg = const Color(0xFFEFF6FF);
    Color iconColor = const Color(0xFF2563EB);
    IconData iconData = Icons.file_copy;

    if (isDone) {
      borderColor = const Color(0xFFBFDBFE);
      badgeBg = const Color(0xFFD1FAE5);
      badgeText = const Color(0xFF065F46);
      badgeLabel = 'VALIDÉ';
      iconBg = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF475569);
    } else if (isIncomplete) {
      borderColor = const Color(0xFFFECACA);
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFF991B1B);
      badgeLabel = 'INCOMPLET';
      iconBg = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFDC2626);
    } else {
      borderColor = const Color(0xFFFDE68A);
      badgeBg = const Color(0xFFFEF9C3);
      badgeText = const Color(0xFF92400E);
      badgeLabel = 'EN COURS';
      iconBg = const Color(0xFFFFF7ED);
      iconColor = const Color(0xFFEA580C);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isDone ? 1.0 : 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dc-top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.certTypeLabel(dossier.type),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#SN-${dossier.id.length > 8 ? dossier.id.substring(0,8) : dossier.id} · ${dossier.communeNom ?? 'Mairie'}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                      AppFormatters.dateShort(dossier.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // dc-prog
          if (!isDone)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: dossier.progress,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(isIncomplete ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isIncomplete ? 'Pièce manquante détectée' : 'Étape en cours — Vérification',
                        style: TextStyle(
                          color: isIncomplete ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '${(dossier.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: isIncomplete ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // dc-chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (isIncomplete)
                  _buildChip(Icons.warning_amber, 'Action requise', color: const Color(0xFFDC2626), bg: const Color(0xFFFEF2F2), border: const Color(0xFFFECACA))
                else
                  _buildChip(Icons.access_time, isDone ? 'Terminé' : '~2 j restants'),
                if (dossier.fraisFCFA == 0) _buildChip(Icons.paid_outlined, 'Gratuit'),
                if (dossier.beneficiaryNom != null) _buildChip(Icons.person_outline, dossier.beneficiaryNom!.split(' ').last),
              ],
            ),
          ),

          // dc-divider
          Container(
            height: 1.0,
            color: const Color(0xFFF1F5F9),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // dc-actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (isDone) ...[
                  Expanded(child: _buildActionBtn('Télécharger', Icons.download, Colors.transparent, Colors.white, useGradient: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildActionBtn('Archiver', Icons.archive, Colors.white, const Color(0xFF475569), border: const Color(0xFFE2E8F0))),
                ],
                if (isIncomplete) ...[
                  Expanded(child: _buildActionBtn('Supprimer', Icons.delete_outline, Colors.white, const Color(0xFF475569), border: const Color(0xFFE2E8F0))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildActionBtn('Corriger', Icons.refresh, const Color(0xFFDC2626), Colors.white)),
                ],
                if (isEnCours) ...[
                  Expanded(child: _buildActionBtn('Relancer', Icons.phone, const Color(0xFFFEF9C3), const Color(0xFF92400E))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildActionBtn('Contacter', Icons.message, Colors.white, const Color(0xFF475569), border: const Color(0xFFE2E8F0))),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.dossierDetailPath(dossier.id)),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_red_eye, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Détail', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
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

  Widget _buildChip(IconData icon, String label, {Color color = const Color(0xFF64748B), Color bg = const Color(0xFFF8FAFC), Color border = const Color(0xFFE2E8F0)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color bg, Color text, {Color? border, bool useGradient = false}) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: useGradient ? null : bg,
        gradient: useGradient ? const LinearGradient(
          colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ) : null,
        borderRadius: BorderRadius.circular(100),
        border: border != null ? Border.all(color: border, width: 1.0) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}
