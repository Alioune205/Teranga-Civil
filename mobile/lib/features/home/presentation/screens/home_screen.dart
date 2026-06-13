import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dossiers/presentation/providers/dossiers_provider.dart';

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
    _greetingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    final user = ref.watch(authProvider).user;
    final prenom = user != null
        ? AppFormatters.titleCase(user.nom.split(' ').first)
        : 'Pape';

    final greetingText = _isFrench ? 'Bonjour $prenom,' : 'Nuyu na la $prenom,';
    final currentCivicMessage = _civicMessages[_messageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            // ── LE FOND BLEU AVEC BORDS ARRONDIS ──
            Container(
              height: 360, // Hauteur augmentée pour accommoder les nouveaux éléments
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),

            // ── LE CONTENU ──
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP HEADER (Avatar, Greeting, Localisation, Icons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Raccourci Profil
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                            ),
                            child: const Center(
                              child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Prénom animé et Localisation
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: Text(
                                  greetingText,
                                  key: ValueKey<String>(greetingText),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20, // Plus grand comme demandé
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                    letterSpacing: -0.5,
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
                        // Icônes de droite
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

                  // 2. MESSAGES CIVIQUES ROTATIFS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      height: 60, // Hauteur fixe pour éviter les sauts d'interface
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

                  // 3. BARRE DE PROFIL COMPLÉTÉ (Améliorée avec bouton)
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
                                      'Profil complété à 80%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
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
                                context.push('/profile');
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

                  const SizedBox(height: 24), // Espace avant de superposer la carte

                  // 4. LA CARTE FLOTTANTE CHEVAUCHANT LE BORD ARRONDIS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const _MainActionCard(),
                        const SizedBox(height: 32),

                        // LES DÉMARCHES RAPIDES (Grid)
                        // NDIOGOYE PROACTIF
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: _ProactiveAlertCard(),
                        ),
                        const SizedBox(height: 32),

                        // SERVICES RAPIDES
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildServicesRapides(context),
                        ),
                        const SizedBox(height: 32),

                        // TIMELINE
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: _TimelineSection(),
                        ),
                        const SizedBox(height: 32),

                        // COMMUNE CONNECTÉE
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildCommuneConnecteeSection(context),
                        ),
                        const SizedBox(height: 120), // Espace pour la bottom bar + sheet
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPER METHODS ────────────────────────────────────────────────────────

  void _showCategorySheet(BuildContext context, String category, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
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
                        context.pop(); // Ferme le sheet
                        if (item['route'] != null) {
                          context.push(item['route']);
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

  Widget _buildServicesRapides(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Services rapides',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildSmallServiceCard(
                context,
                'Naissance',
                Icons.child_care_rounded,
                const Color(0xFFEFF6FF),
                const Color(0xFF2563EB),
                onTap: () => _showCategorySheet(context, 'Naissance', [
                  {'title': 'Déclaration de naissance', 'icon': Icons.edit_document, 'route': AppRoutes.naissanceBeneficiary},
                  {'title': 'Extrait de naissance', 'icon': Icons.file_copy_rounded, 'route': null},
                  {'title': 'Copie littérale', 'icon': Icons.description_rounded, 'route': null},
                ]),
              ),
              const SizedBox(width: 12),
              _buildSmallServiceCard(
                context,
                'Mariage',
                Icons.people_alt_rounded,
                const Color(0xFFFEF2F2),
                const Color(0xFFDC2626),
                onTap: () => _showCategorySheet(context, 'Mariage', [
                  {'title': 'Certificat de mariage', 'icon': Icons.favorite_border_rounded, 'route': AppRoutes.mariageForm},
                  {'title': 'Extrait de mariage', 'icon': Icons.file_copy_rounded, 'route': null},
                ]),
              ),
              const SizedBox(width: 12),
              _buildSmallServiceCard(
                context,
                'Décès',
                Icons.folder_special_outlined,
                const Color(0xFFF8FAFC),
                const Color(0xFF475569),
                onTap: () => _showCategorySheet(context, 'Décès', [
                  {'title': 'Certificat de décès', 'icon': Icons.assignment_rounded, 'route': AppRoutes.decesForm},
                  {'title': 'Permis d\'inhumer', 'icon': Icons.health_and_safety_rounded, 'route': null},
                ]),
              ),
              const SizedBox(width: 12),
              _buildSmallServiceCard(
                context,
                'Autres',
                Icons.widgets_outlined,
                const Color(0xFFFDF4FF),
                const Color(0xFFC026D3),
                onTap: () {
                  context.go('/documents');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallServiceCard(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B285D).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommuneConnecteeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Commune connectée',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B285D).withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Mairie News 1
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1577493340887-b7bfff550145?auto=format&fit=crop&q=80&w=200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campagne d\'état civil',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gratuité pour les déclarations de naissance tardives jusqu\'au 30 Juin.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              height: 1.4,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: const Color(0xFFE2E8F0).withOpacity(0.5), height: 1),
              // Mairie News 2
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.construction_rounded, color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Réfection du marché central',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'EN COURS',
                                  style: TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '80% d\'avancement',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── LA CARTE PRINCIPALE FLOTTANTE ───────────────────────────────────────
class _MainActionCard extends StatelessWidget {
  const _MainActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 16), // Douce ombre portée pour le flottement
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Trouvez un document, une démarche ou posez une question.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            // Barre de recherche peaufinée
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Rechercher "Extrait de naissance"...',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Petit bouton micro à l'intérieur de la recherche
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mic_none_rounded, color: Color(0xFF3B82F6), size: 20),
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
      case 'NAISSANCE':
        return 'Déclaration de naissance';
      case 'MARIAGE':
        return 'Certificat de mariage';
      case 'DECES':
        return 'Certificat de décès';
      default:
        return 'Demande administrative';
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'soumis':
        return 'Soumis';
      case 'en_traitement':
        return 'En cours de traitement';
      case 'valide':
        return 'Validé et disponible';
      case 'rejete':
        return 'Rejeté';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B285D).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                  child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 20),
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
                      isCompleted: dossier.status.toLowerCase() == 'valide',
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
                    time: 'Il y a 2 jours',
                    isCompleted: true,
                    isLast: false,
                    context: context,
                  ),
                  _buildTimelineItem(
                    title: 'Certificat de mariage',
                    status: 'En cours',
                    subtitle: 'Agent affecté : Mme Ndiaye',
                    time: 'Hier',
                    isCompleted: false,
                    isLast: false,
                    context: context,
                  ),
                  _buildTimelineItem(
                    title: 'Nouveau document disponible',
                    status: 'Certificat de résidence',
                    time: 'Aujourd\'hui',
                    isCompleted: true,
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
    required bool isCompleted,
    required bool isLast,
    required BuildContext context,
    String? subtitle,
    String? buttonText,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne de l'indicateur
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF10B981) : Colors.white,
                  border: Border.all(
                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : const Icon(Icons.hourglass_empty_rounded, color: Color(0xFFF59E0B), size: 12),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Colonne du texte
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: isCompleted ? const Color(0xFF059669) : const Color(0xFFD97706),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Flèche à droite
          GestureDetector(
            onTap: () => context.go('/dossiers'),
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 14),
            ),
          ),
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
                AnimatedSwitcher(
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
                    height: 100, // Hauteur fixe pour éviter les sauts
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
