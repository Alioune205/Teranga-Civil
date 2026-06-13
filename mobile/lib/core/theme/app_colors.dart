import 'package:flutter/material.dart';

/// Palette de couleurs officielle TERANGA CIVIL (Refonte Professionnelle).
abstract class AppColors {
  AppColors._();

  // ── Couleurs principales ─────────────────────────────────────────────────
  static const Color primary      = Color(0xFF0B285D); // Bleu profond professionnel
  static const Color primaryLight = Color(0xFF153B80); // Bleu clair pour interactions
  static const Color primaryDark  = Color(0xFF061533); // Bleu très sombre

  // ── Statuts & Alertes ────────────────────────────────────────────────────
  static const Color success      = Color(0xFF10B981); // Vert - OK, Succès, Validé
  static const Color warning      = Color(0xFFF59E0B); // Ambre - Attente, Alertes
  static const Color error        = Color(0xFFEF4444); // Rouge - Erreurs, Rejets
  static const Color info         = Color(0xFF3B82F6); // Bleu - Info neutre

  // ── Backgrounds & Surfaces ───────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Blanc ardoise (léger et pro)
  static const Color surface    = Color(0xFFFFFFFF); // Blanc pur pour les cartes
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Gris ardoise très clair

  // ── Textes ───────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1E293B); // Gris très foncé (presque noir)
  static const Color textSecondary = Color(0xFF64748B); // Gris neutre (sous-titres)
  static const Color textHint      = Color(0xFF94A3B8); // Gris clair (placeholders)
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanc sur fond Primary

  // ── Bordures & Séparateurs ───────────────────────────────────────────────
  static const Color border      = Color(0xFFE2E8F0); // Bordure subtile
  static const Color borderFocus = Color(0xFF0B285D); // Bordure au focus (Primary)
  static const Color divider     = Color(0xFFF1F5F9); // Séparateur très léger

  // ── Backgrounds statuts (version claire) ─────────────────────────────────
  static const Color statusGreenLight = Color(0xFFD1FAE5);
  static const Color statusAmberLight = Color(0xFFFEF3C7);
  static const Color statusRedLight   = Color(0xFFFEE2E2);
  static const Color statusBlueLight  = Color(0xFFDBEAFE);

  // ── États boutons ────────────────────────────────────────────────────────
  static const Color buttonDisabledBg   = Color(0xFFCBD5E1);
  static const Color buttonDisabledText = Color(0xFF94A3B8);

  // ── Overlay & ombres ─────────────────────────────────────────────────────
  static const Color overlay = Color(0x800F172A); // Overlay modal
  static const Color shadow  = Color(0x0A0F172A); // Ombre très très légère
  static const Color shadowStrong = Color(0x140F172A); // Ombre accentuée

  // ── Transparent ──────────────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;

  // ── Dégradés ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0B285D), Color(0xFF153B80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
