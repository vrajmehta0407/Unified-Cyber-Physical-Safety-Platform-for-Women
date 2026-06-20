import 'package:flutter/material.dart';

/// CyberShield 2.0 Premium Color System
/// Primary gradient: #6A5CFF -> #8B5CF6 -> #EC4899
/// Accents: Emerald, Sky Blue, Orange, Pink
class AppColors {
  // ─── Brand Primary ───
  static const primary = Color(0xFF8B5CF6);
  static const primaryLight = Color(0xFF6A5CFF);
  static const primaryDark = Color(0xFF7C3AED);
  static const secondary = Color(0xFFEC4899);

  // ─── Brand Gradient ───
  static const List<Color> primaryGradient = [Color(0xFF6A5CFF), Color(0xFF8B5CF6), Color(0xFFEC4899)];
  static const List<Color> primaryGradientShort = [Color(0xFF6A5CFF), Color(0xFF8B5CF6)];
  static const List<Color> secondaryGradient = [Color(0xFF8B5CF6), Color(0xFFEC4899)];
  static const List<Color> dangerGradient = [Color(0xFFEF4444), Color(0xFFF97316)];
  static const List<Color> successGradient = [Color(0xFF10B981), Color(0xFF34D399)];

  // ─── Accent Colors ───
  static const accentEmerald = Color(0xFF10B981);
  static const accentSky = Color(0xFF3B82F6);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPink = Color(0xFFEC4899);
  static const accentCyan = Color(0xFF06B6D4);

  // ─── Status / Semantic ───
  static const danger = Color(0xFFEF4444);
  static const dangerDark = Color(0xFFDC2626);
  static const success = Color(0xFF10B981);
  static const successDark = Color(0xFF059669);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // ─── Risk Levels ───
  static const riskHigh = Color(0xFFEF4444);
  static const riskMedium = Color(0xFFF59E0B);
  static const riskLow = Color(0xFF10B981);

  // ─── Light Theme Colors ───
  static const lightBackground = Color(0xFFF8F7FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1F0FB);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardAlt = Color(0xFFF5F3FF);
  static const lightTextPrimary = Color(0xFF1E1B4B);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightTextHint = Color(0xFF9CA3AF);
  static const lightBorder = Color(0xFFE5E7EB);
  static const lightBorderLight = Color(0xFFF3F4F6);
  static const lightDivider = Color(0xFFE5E7EB);

  // ─── Dark Theme Colors ───
  static const darkBackground = Color(0xFF0F0A1A);
  static const darkSurface = Color(0xFF1A1230);
  static const darkSurfaceAlt = Color(0xFF241B3A);
  static const darkCard = Color(0xFF221A3A);
  static const darkCardAlt = Color(0xFF1E1535);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextHint = Color(0xFF64748B);
  static const darkBorder = Color(0xFF2D2450);
  static const darkBorderLight = Color(0xFF3D3060);
  static const darkDivider = Color(0xFF2D2450);

  // ─── Legacy Aliases (dark mode defaults for backward compat) ───
  // These are used by existing screens. Migrate to theme-aware colors over time.
  static const background = darkBackground;
  static const surface = darkSurface;
  static const card = darkCard;
  static const cardAlt = darkCardAlt;
  static const textPrimary = darkTextPrimary;
  static const textSecondary = darkTextSecondary;
  static const textHint = darkTextHint;
  static const border = darkBorder;
  static const borderLight = darkBorderLight;

  // ─── Legacy Gradients ───
  static const List<Color> darkGradient = [Color(0xFF0F0A1A), Color(0xFF1A1230)];
  static const List<Color> cardGradient = [Color(0xFF221A3A), Color(0xFF1A1230)];

  // ─── Glassmorphism ───
  static const glassOverlayLight = Color(0xB3FFFFFF); // white 70%
  static const glassOverlayDark = Color(0x338B5CF6);  // purple 20%
  static const glassBorderLight = Color(0x4DFFFFFF);   // white 30%
  static const glassBorderDark = Color(0x33FFFFFF);     // white 20%
  // Legacy
  static const glassOverlay = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
}
