import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.bgTop,
    required this.bgBottom,
    required this.card,
    required this.cardAlt,
    required this.field,
    required this.fieldBorder,
    required this.textMuted,
    required this.accent,
    required this.accentAlt,
    required this.danger,
    required this.success,
    required this.chip,
    required this.chipSelected,
    required this.shadow,
    required this.glass,
    required this.glow,
    required this.cardRadius,
    required this.fieldRadius,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color card;
  final Color cardAlt;
  final Color field;
  final Color fieldBorder;
  final Color textMuted;
  final Color accent;
  final Color accentAlt;
  final Color danger;
  final Color success;
  final Color chip;
  final Color chipSelected;
  final Color shadow;
  final Color glass;
  final Color glow;
  final double cardRadius;
  final double fieldRadius;

  static AppThemeTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<AppThemeTokens>();
    assert(tokens != null, 'AppThemeTokens not found in Theme');
    return tokens!;
  }

  @override
  AppThemeTokens copyWith({
    Color? bgTop,
    Color? bgBottom,
    Color? card,
    Color? cardAlt,
    Color? field,
    Color? fieldBorder,
    Color? textMuted,
    Color? accent,
    Color? accentAlt,
    Color? danger,
    Color? success,
    Color? chip,
    Color? chipSelected,
    Color? shadow,
    Color? glass,
    Color? glow,
    double? cardRadius,
    double? fieldRadius,
  }) {
    return AppThemeTokens(
      bgTop: bgTop ?? this.bgTop,
      bgBottom: bgBottom ?? this.bgBottom,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      field: field ?? this.field,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentAlt: accentAlt ?? this.accentAlt,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      chip: chip ?? this.chip,
      chipSelected: chipSelected ?? this.chipSelected,
      shadow: shadow ?? this.shadow,
      glass: glass ?? this.glass,
      glow: glow ?? this.glow,
      cardRadius: cardRadius ?? this.cardRadius,
      fieldRadius: fieldRadius ?? this.fieldRadius,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      field: Color.lerp(field, other.field, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      fieldRadius: fieldRadius + (other.fieldRadius - fieldRadius) * t,
    );
  }
}

class ThemeChoice {
  const ThemeChoice({
    required this.name,
    required this.data,
    required this.tokens,
    required this.isDark,
    required this.preview,
  });

  final String name;
  final ThemeData data;
  final AppThemeTokens tokens;
  final bool isDark;
  final Color preview;
}

class AppThemes {
  static final List<ThemeChoice> choices = [
    _build(
      name: 'Light 1',
      isDark: false,
      preview: const Color(0xFF105C36),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFFF3F4F7),
        bgBottom: Color(0xFFEDEEF2),
        card: Color(0xFFFFFFFF),
        cardAlt: Color(0xFFF7F8FB),
        field: Color(0xFFF6F7FA),
        fieldBorder: Color(0xFFD4D8E1),
        textMuted: Color(0xFF6B7280),
        accent: Color(0xFF105C36),
        accentAlt: Color(0xFF13EC5B),
        danger: Color(0xFFDC4C4C),
        success: Color(0xFF0F7A46),
        chip: Color(0xFFDCDDE5),
        chipSelected: Color(0xFFC9CDD8),
        shadow: Color(0x220B1220),
        glass: Color(0xCCFFFFFF),
        glow: Color(0x33105C36),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Light 2',
      isDark: false,
      preview: const Color(0xFF1769FF),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFFF2F7FF),
        bgBottom: Color(0xFFEAF1FD),
        card: Color(0xFFFFFFFF),
        cardAlt: Color(0xFFF5F8FF),
        field: Color(0xFFF2F6FF),
        fieldBorder: Color(0xFFCBD7EE),
        textMuted: Color(0xFF5F6F8C),
        accent: Color(0xFF1769FF),
        accentAlt: Color(0xFF65B5FF),
        danger: Color(0xFFD84F6D),
        success: Color(0xFF1E8B63),
        chip: Color(0xFFDCE4F5),
        chipSelected: Color(0xFFCEDAF0),
        shadow: Color(0x22101D38),
        glass: Color(0xCCFFFFFF),
        glow: Color(0x331769FF),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Light 3',
      isDark: false,
      preview: const Color(0xFFC96A1A),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFFFFF6F0),
        bgBottom: Color(0xFFFDF0E8),
        card: Color(0xFFFFFFFF),
        cardAlt: Color(0xFFFFF8F4),
        field: Color(0xFFFFF5EE),
        fieldBorder: Color(0xFFF0D8C8),
        textMuted: Color(0xFF7A6556),
        accent: Color(0xFFC96A1A),
        accentAlt: Color(0xFFFF9F43),
        danger: Color(0xFFDC5B5B),
        success: Color(0xFF1C9668),
        chip: Color(0xFFF3DED2),
        chipSelected: Color(0xFFEBD1C1),
        shadow: Color(0x221D0E06),
        glass: Color(0xCCFFFFFF),
        glow: Color(0x33C96A1A),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Light 4',
      isDark: false,
      preview: const Color(0xFF6E56CF),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFFF6F4FF),
        bgBottom: Color(0xFFEFECFC),
        card: Color(0xFFFFFFFF),
        cardAlt: Color(0xFFF7F5FF),
        field: Color(0xFFF2EFFF),
        fieldBorder: Color(0xFFD7CFF2),
        textMuted: Color(0xFF6F6990),
        accent: Color(0xFF6E56CF),
        accentAlt: Color(0xFFB497FF),
        danger: Color(0xFFD85F9A),
        success: Color(0xFF2E9A73),
        chip: Color(0xFFE4DFF6),
        chipSelected: Color(0xFFD9D2F1),
        shadow: Color(0x22120B2A),
        glass: Color(0xCCFFFFFF),
        glow: Color(0x336E56CF),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Light 5',
      isDark: false,
      preview: const Color(0xFF0F8A67),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFFF0FAF7),
        bgBottom: Color(0xFFE7F3F0),
        card: Color(0xFFFFFFFF),
        cardAlt: Color(0xFFF3FBF8),
        field: Color(0xFFEAF5F1),
        fieldBorder: Color(0xFFC9E1D9),
        textMuted: Color(0xFF5D7470),
        accent: Color(0xFF0F8A67),
        accentAlt: Color(0xFF42D3A8),
        danger: Color(0xFFD55C74),
        success: Color(0xFF0F8A67),
        chip: Color(0xFFD8ECE6),
        chipSelected: Color(0xFFC7E2DA),
        shadow: Color(0x220B2119),
        glass: Color(0xCCFFFFFF),
        glow: Color(0x330F8A67),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Dark 1',
      isDark: true,
      preview: const Color(0xFF22D47A),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFF09110D),
        bgBottom: Color(0xFF0D1612),
        card: Color(0xFF18231D),
        cardAlt: Color(0xFF1D2A23),
        field: Color(0xFF212F28),
        fieldBorder: Color(0xFF2D4037),
        textMuted: Color(0xFF98A7A0),
        accent: Color(0xFF22D47A),
        accentAlt: Color(0xFF98F5C5),
        danger: Color(0xFFFF7B7B),
        success: Color(0xFF22D47A),
        chip: Color(0xFF27362E),
        chipSelected: Color(0xFF31443A),
        shadow: Color(0x70000000),
        glass: Color(0x14FFFFFF),
        glow: Color(0x5522D47A),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Dark 2',
      isDark: true,
      preview: const Color(0xFF5E8BFF),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFF0C1018),
        bgBottom: Color(0xFF111826),
        card: Color(0xFF1A2434),
        cardAlt: Color(0xFF1F2B3D),
        field: Color(0xFF243248),
        fieldBorder: Color(0xFF344760),
        textMuted: Color(0xFF9AA8BF),
        accent: Color(0xFF5E8BFF),
        accentAlt: Color(0xFF9DB6FF),
        danger: Color(0xFFFF7D8E),
        success: Color(0xFF53D39B),
        chip: Color(0xFF253347),
        chipSelected: Color(0xFF2F4158),
        shadow: Color(0x7A000000),
        glass: Color(0x18FFFFFF),
        glow: Color(0x665E8BFF),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Dark 3',
      isDark: true,
      preview: const Color(0xFFA56BFF),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFF110C1C),
        bgBottom: Color(0xFF171126),
        card: Color(0xFF201A33),
        cardAlt: Color(0xFF28203E),
        field: Color(0xFF2D2547),
        fieldBorder: Color(0xFF41345F),
        textMuted: Color(0xFFB0A1CA),
        accent: Color(0xFFA56BFF),
        accentAlt: Color(0xFFD1B3FF),
        danger: Color(0xFFFF8BA7),
        success: Color(0xFF6FE6B4),
        chip: Color(0xFF2F2648),
        chipSelected: Color(0xFF3B3060),
        shadow: Color(0x78000000),
        glass: Color(0x18FFFFFF),
        glow: Color(0x66A56BFF),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Dark 4',
      isDark: true,
      preview: const Color(0xFF2ED9C3),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFF061516),
        bgBottom: Color(0xFF0B1D1F),
        card: Color(0xFF13272A),
        cardAlt: Color(0xFF173034),
        field: Color(0xFF1B383D),
        fieldBorder: Color(0xFF2A4B52),
        textMuted: Color(0xFF93B4B8),
        accent: Color(0xFF2ED9C3),
        accentAlt: Color(0xFF8EF8E9),
        danger: Color(0xFFFF8C8C),
        success: Color(0xFF5DE9A9),
        chip: Color(0xFF1D3A3E),
        chipSelected: Color(0xFF295157),
        shadow: Color(0x76000000),
        glass: Color(0x14FFFFFF),
        glow: Color(0x662ED9C3),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
    _build(
      name: 'Dark 5',
      isDark: true,
      preview: const Color(0xFFF2A93B),
      tokens: const AppThemeTokens(
        bgTop: Color(0xFF18120A),
        bgBottom: Color(0xFF21190F),
        card: Color(0xFF2C2217),
        cardAlt: Color(0xFF35291B),
        field: Color(0xFF3D3020),
        fieldBorder: Color(0xFF56442C),
        textMuted: Color(0xFFC9B99E),
        accent: Color(0xFFF2A93B),
        accentAlt: Color(0xFFFFD37D),
        danger: Color(0xFFFF8577),
        success: Color(0xFF7BE2A2),
        chip: Color(0xFF3A2D1F),
        chipSelected: Color(0xFF4A3928),
        shadow: Color(0x76000000),
        glass: Color(0x14FFFFFF),
        glow: Color(0x66F2A93B),
        cardRadius: 28,
        fieldRadius: 14,
      ),
    ),
  ];

  static ThemeChoice _build({
    required String name,
    required bool isDark,
    required Color preview,
    required AppThemeTokens tokens,
  }) {
    final textColor = isDark
        ? const Color(0xFFF0F4FF)
        : const Color(0xFF111827);
    final onPrimary =
        ThemeData.estimateBrightnessForColor(tokens.accent) == Brightness.dark
        ? Colors.white
        : const Color(0xFF081122);
    final onSecondary =
        ThemeData.estimateBrightnessForColor(tokens.accentAlt) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF081122);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: tokens.accent,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: tokens.accent,
          secondary: tokens.accentAlt,
          surface: tokens.card,
          onSurface: textColor,
          error: tokens.danger,
          onPrimary: onPrimary,
          onSecondary: onSecondary,
        );

    final baseText = GoogleFonts.interTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    ).apply(bodyColor: textColor, displayColor: textColor);

    final textTheme = baseText.copyWith(
      headlineMedium: GoogleFonts.lexend(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.lexend(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      titleLarge: GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleSmall: GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bgBottom,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: tokens.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: tokens.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.cardRadius),
        ),
      ),
      dividerColor: tokens.fieldBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.field,
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.accent, width: 1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: tokens.fieldBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: tokens.glow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide(color: tokens.fieldBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.accent,
        foregroundColor: onPrimary,
        elevation: 8,
        extendedTextStyle: textTheme.labelLarge?.copyWith(color: onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.chip,
        selectedColor: tokens.accent,
        disabledColor: tokens.chip,
        side: BorderSide(color: tokens.fieldBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: textTheme.labelSmall ?? const TextStyle(),
        secondaryLabelStyle: textTheme.labelSmall ?? const TextStyle(),
      ),
      splashFactory: InkSparkle.splashFactory,
      fontFamily: GoogleFonts.inter().fontFamily,
      extensions: [tokens],
    );

    return ThemeChoice(
      name: name,
      data: base,
      tokens: tokens,
      isDark: isDark,
      preview: preview,
    );
  }
}
