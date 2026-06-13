import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dossiers/presentation/providers/dossiers_provider.dart';
import '../../../../core/providers/profile_state_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _greetingTimer;
  bool _isFrench = true;
  int _messageIndex = 0;

  final List<String> _civicMessages = [
    "Bienvenue sur votre espace personnel.",
    "L'état civil est le socle de vos droits citoyens.",
    "Déclarez vos naissances à temps pour l'avenir de vos enfants.",
    "Un citoyen à jour est un citoyen serein et protégé.",
    "La numérisation sécurise vos documents pour toute la vie.",
  ];

  @override
  void initState() {
    super.initState();
    _greetingTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _isFrench = !_isFrench;
          _messageIndex = (_messageIndex + 1) % _civicMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prenom = 'Pathé';
    final cniUploaded = ref.watch(cniUploadedProvider);

    final greetingText = _isFrench ? 'Bonjour $prenom,' : 'Dalal akk jamm $prenom,';
    final currentCivicMessage = _civicMessages[_messageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // TOP HEADER (Avatar, Greeting, Localisation, Icons)
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
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/photo_de_profile.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 28,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 600),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        greetingText,
                                        key: ValueKey<String>(greetingText),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Inter',
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, color: Color(0xFF93C5FD), size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Commune de Dakar',
                                      style: TextStyle(
                                        color: Color(0xFF93C5FD),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        height: 60,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            currentCivicMessage,
                            key: ValueKey<int>(_messageIndex),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Inter',
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!cniUploaded) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Ajoutez votre pièce d'identité pour des démarches plus rapides",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: const LinearProgressIndicator(
                                            value: 0.8,
                                            backgroundColor: Colors.white24,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push('/profile/completion');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0B285D),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Terminer la configuration',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 60), // Extra space for overlapping card
                  ],
                ),
              ),
            ),
            
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const _MainActionCard(),
                    const SizedBox(height: 32),
                    const _ProactiveAlertCard(),
                    const SizedBox(height: 32),
                    const _QuickActionsGrid(),
                    const SizedBox(height: 32),
                    const _TimelineSection(),
                    const SizedBox(height: 32),
                    const _AppointmentsSection(),
                    const SizedBox(height: 32),
                    const _CityHallLocationCard(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LA CARTE PRINCIPALE FLOTTANTE ───────────────────────────────────────
class _MainActionCard extends StatefulWidget {
  const _MainActionCard();

  @override
  State<_MainActionCard> createState() => _MainActionCardState();
}

class _MainActionCardState extends State<_MainActionCard> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _recommendations = [
    'Rechercher "Extrait de naissance"...',
    'Demander un "Certificat de mariage"...',
    'Suivre "Mon dossier en cours"...',
    'Rechercher "Certificat de résidence"...',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _recommendations.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12), // Ombre légèrement réduite
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding réduit (était 24)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17, // Police réduite (était 19)
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16), // Espace réduit (était 24)
            // Barre de recherche peaufinée et plus compacte
            Container(
              height: 50, // Hauteur réduite (était 56)
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2), // Léger glissement vers le haut
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_currentIndex),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _recommendations[_currentIndex],
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14, // Légèrement réduit (était 15)
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  // Petit bouton micro à l'intérieur de la recherche
                  Container(
                    width: 36, // Réduit (était 40)
                    height: 36,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_none_rounded, color: Color(0xFF3B82F6), size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LES DÉMARCHES RAPIDES ───────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  void _showCategorySheet(BuildContext context, String category, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Démarches : $category',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez le document que vous souhaitez obtenir.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop(); // Ferme le sheet via Navigator
                        if (item['route'] != null) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (item['doc'] != null) {
                              navigateToDocument(context, item['doc']);
                            } else {
                              router.push(item['route']);
                            }
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item['icon'], color: const Color(0xFF3B82F6), size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['title'],
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Démarches rapides',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSquareCard(
                context,
                'Naissance',
                Icons.person_add_alt_1_rounded,
                const Color(0xFFEFF6FF),
                const Color(0xFF2563EB),
                onTap: () => _showCategorySheet(context, 'Naissance', [
                  {
                    'title': 'Acte de naissance', 
                    'icon': Icons.edit_document, 
                    'route': AppRoutes.acteNaissanceForm,
                  },
                  {
                    'title': 'Extrait de naissance', 
                    'icon': Icons.file_copy_rounded, 
                    'route': '/document_detail',
                    'doc': {'id': 'extrait_naissance', 'name': 'Extrait de naissance', 'desc': 'Copie de l\'acte dans le registre', 'badges': [], 'price': 'Gratuit', 'delay': '48h', 'categoryName': 'État civil'}
                  },
                  {
                    'title': 'Copie littérale', 
                    'icon': Icons.file_present_rounded, 
                    'route': '/document_detail',
                    'doc': {'id': 'copie_litterale', 'name': 'Copie littérale', 'desc': 'Copie intégrale de l\'acte', 'badges': ['PAYANT'], 'price': '500 FCFA', 'delay': '48h', 'categoryName': 'État civil'}
                  },
                ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSquareCard(
                context,
                'Mariage',
                Icons.people_alt_rounded,
                const Color(0xFFFEF2F2),
                const Color(0xFFDC2626),
                onTap: () => _showCategorySheet(context, 'Mariage', [
                  {
                    'title': 'Certificat de mariage', 
                    'icon': Icons.favorite_border_rounded, 
                    'route': '/document_detail',
                    'doc': {'id': 'cert_mariage', 'name': 'Certificat de mariage', 'desc': 'Preuve officielle d\'union', 'badges': ['PAYANT'], 'price': '500 FCFA', 'delay': '48h', 'categoryName': 'Mariage'}
                  },
                  {
                    'title': 'Certificat de célibat', 
                    'icon': Icons.file_copy_rounded, 
                    'route': '/document_detail',
                    'doc': {'id': 'cert_celibat', 'name': 'Certificat de célibat', 'desc': 'Attestation de non-mariage', 'badges': ['PRÉSENTIEL'], 'price': 'Gratuit', 'delay': 'Sur place', 'categoryName': 'Mariage'}
                  },
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSquareCard(
                context,
                'Décès',
                Icons.folder_special_outlined,
                const Color(0xFFF8FAFC),
                const Color(0xFF475569),
                onTap: () => _showCategorySheet(context, 'Décès', [
                  {'title': 'Certificat de décès', 'icon': Icons.assignment_rounded, 'route': AppRoutes.decesForm},
                  {'title': 'Permis d\'inhumer', 'icon': Icons.health_and_safety_rounded, 'route': AppRoutes.decesForm},
                ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSquareCard(
                context,
                'Autres',
                Icons.widgets_outlined,
                const Color(0xFFFDF4FF),
                const Color(0xFFC026D3),
                onTap: () {
                  context.go('/documents');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSquareCard(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B285D).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── LA TIMELINE ──────────────────────────────────────────────────────────
class _TimelineSection extends ConsumerWidget {
  const _TimelineSection();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Aujourd\'hui';
    if (difference.inDays == 1) return 'Hier';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getDisplayType(String type) {
    switch (type.toUpperCase()) {
      case 'NAISSANCE': return 'Déclaration de naissance';
      case 'MARIAGE': return 'Certificat de mariage';
      case 'DECES': return 'Certificat de décès';
      default: return 'Demande administrative';
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'soumis': return 'Soumis';
      case 'en_traitement': return 'En cours de traitement';
      case 'valide': return 'Validé et disponible';
      case 'rejete': return 'Rejeté';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activité récente',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/documents'),
                  child: const Row(
                    children: [
                      Text(
                        'Tout voir',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Color(0xFF3B82F6), size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ref.watch(dossiersListProvider).when(
              data: (dossiers) {
                if (dossiers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Aucune activité récente.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  );
                }

                final sortedDossiers = List.of(dossiers)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final recentDossiers = sortedDossiers.take(3).toList();
                
                return Column(
                  children: List.generate(recentDossiers.length, (index) {
                    final dossier = recentDossiers[index];
                    final isLast = index == recentDossiers.length - 1;
                    return _buildTimelineItem(
                      title: _getDisplayType(dossier.type),
                      status: _getDisplayStatus(dossier.status),
                      time: _formatDate(dossier.createdAt),
                      statusType: dossier.status.toLowerCase() == 'valide' ? 'valide' : 'en_cours',
                      isLast: isLast,
                      context: context,
                    );
                  }),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                ),
              ),
              error: (err, stack) => Column(
                children: [
                  _buildTimelineItem(
                    title: 'Extrait de naissance',
                    status: 'Validé',
                    time: '08 juin',
                    subtitle: 'Dakar Plateau',
                    statusType: 'valide',
                    isLast: false,
                    context: context,
                  ),
                  _buildTimelineItem(
                    title: 'Certificat de mariage',
                    status: 'En cours',
                    subtitle: 'Agent affecté : Mme Ndiaye',
                    time: '07 juin',
                    statusType: 'en_cours',
                    isLast: false,
                    context: context,
                  ),
                  _buildTimelineItem(
                    title: 'Nouveau document disponible',
                    status: 'Nouveau',
                    time: 'Aujourd\'hui',
                    subtitle: 'Certificat de résidence',
                    statusType: 'nouveau',
                    isLast: true,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String status,
    required String time,
    required String statusType,
    required bool isLast,
    required BuildContext context,
    String? subtitle,
  }) {
    Color iconBgColor;
    Color iconColor;
    IconData icon;
    Color badgeBgColor;
    Color badgeTextColor;

    if (statusType == 'valide') {
      iconBgColor = const Color(0xFFD1FAE5);
      iconColor = const Color(0xFF059669);
      icon = Icons.check_circle_outline_rounded;
      badgeBgColor = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF065F46);
    } else if (statusType == 'nouveau') {
      iconBgColor = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF2563EB);
      icon = Icons.file_present_rounded;
      badgeBgColor = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF1D4ED8);
    } else {
      iconBgColor = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
      icon = Icons.hourglass_bottom_rounded;
      badgeBgColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFF92400E);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône harmonisée avec le reste de l'app
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          // Textes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (statusType != 'en_cours') ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ouverture...'), backgroundColor: Color(0xFF3B82F6)),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── NDIOGOYE PROACTIF ────────────────────────────────────────────────────
class _ProactiveAlertCard extends StatefulWidget {
  const _ProactiveAlertCard();

  @override
  State<_ProactiveAlertCard> createState() => _ProactiveAlertCardState();
}

class _ProactiveAlertCardState extends State<_ProactiveAlertCard> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _suggestions = [
    {
      'title': 'Acte disponible',
      'icon': Icons.check_circle_outline_rounded,
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFECFDF5),
      'text': 'Votre acte de naissance est déjà disponible. Souhaitez-vous le télécharger ?',
      'actionText': 'Télécharger',
      'actionIcon': Icons.download_rounded,
    },
    {
      'title': 'Dossier incomplet',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFF59E0B),
      'bgColor': const Color(0xFFFFFBEB),
      'text': 'Pièce manquante : Certificat d\'accouchement.',
      'actionText': 'Ajouter maintenant',
      'actionIcon': Icons.upload_file_rounded,
    },
    {
      'title': 'Nouvelle démarche',
      'icon': Icons.lightbulb_outline_rounded,
      'color': const Color(0xFF3B82F6),
      'bgColor': const Color(0xFFEFF6FF),
      'text': 'Vous pouvez désormais demander votre certificat de résidence.',
      'actionText': 'Demander',
      'actionIcon': Icons.arrow_forward_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _suggestions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ajouter un document',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez uploader le document requis.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Action effectuée avec succès.'), backgroundColor: Color(0xFF10B981)),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Prendre une photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B285D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSuggestion = _suggestions[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cercles décoratifs en fond
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFFFCD34D), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Ndiogoye Proactif',
                          style: TextStyle(
                            color: Color(0xFFFCD34D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(_suggestions.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(left: 4),
                          width: _currentIndex == index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 125, // Fixe la hauteur pour éviter les sauts du carrousel
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(_currentIndex),
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: currentSuggestion['bgColor'],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            currentSuggestion['icon'],
                            color: currentSuggestion['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSuggestion['text'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  if (_currentIndex == 1) {
                                    _showUploadSheet(context);
                                  } else {
                                    context.go('/dossiers');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currentSuggestion['actionText'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        currentSuggestion['actionIcon'],
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Flèche vers la droite pour rediriger vers les dossiers
                        GestureDetector(
                          onTap: () => context.go('/dossiers'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                          ),
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
}

// ── RENDEZ-VOUS & AGENDA ────────────────────────────────────────────────
class _AppointmentsSection extends StatelessWidget {
  const _AppointmentsSection();

  Widget _buildAppointmentCard(String day, String month, String title, String timeLocation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bloc Date façon "Boarding pass"
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                    height: 1.1,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Détails RDV
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: Color(0xFF94A3B8), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        timeLocation,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bouton QR
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.qr_code_rounded, color: Color(0xFF2563EB), size: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Vos rendez-vous',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Prendre RDV',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard('12', 'Juin', 'Dépôt dossier mariage', '09:00 - Guichet 3'),
        _buildAppointmentCard('28', 'Juin', 'Retrait passeport', '14:30 - Centre annexe'),
      ],
    );
  }
}

// ── MA MAIRIE LA PLUS PROCHE ────────────────────────────────────────────
class _CityHallLocationCard extends StatelessWidget {
  const _CityHallLocationCard();

  Widget _buildNewsItem({
    required String tag,
    required Color tagColor,
    required Color tagBg,
    required String title,
    required String commune,
    required String time,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$commune • $time',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Icon(icon, color: tagColor, size: 22),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ma mairie la plus proche',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B285D).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mairie de Dakar Plateau',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.directions_walk_rounded, color: Color(0xFF64748B), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'À 450m (6 min à pied)',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: Color(0xFF059669), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Ouvert - Ferme à 16h30',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: const Text('Itinéraire'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Appeler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 20),
              
              const Text(
                'Actualités civiques',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildNewsItem(
                tag: 'Alerte',
                tagColor: const Color(0xFFD97706),
                tagBg: const Color(0xFFFEF3C7),
                title: 'Fermeture exceptionnelle du guichet 3 ce vendredi matin.',
                commune: 'Dakar Plateau',
                time: 'Il y a 2h',
                icon: Icons.warning_amber_rounded,
              ),
              _buildNewsItem(
                tag: 'Info',
                tagColor: const Color(0xFF2563EB),
                tagBg: const Color(0xFFDBEAFE),
                title: 'Nouveaux tarifs applicables pour les copies littérales dès lundi.',
                commune: 'Dakar Plateau',
                time: 'Hier',
                icon: Icons.info_outline_rounded,
              ),
              _buildNewsItem(
                tag: 'Événement',
                tagColor: const Color(0xFF059669),
                tagBg: const Color(0xFFD1FAE5),
                title: 'Journée de sensibilisation à l\'état civil le 15 Juin.',
                commune: 'Dakar (Toutes)',
                time: '15 Juin',
                icon: Icons.event_available_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

