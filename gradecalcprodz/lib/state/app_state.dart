import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grade_models.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.semesters,
    required this.selectedTabIndex,
    required this.themeIndex,
    this.hasSeenOnboarding = false,
  });

  static const String prefsKey = 'gradecalc_state_v1';
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _themeIndexKey = 'theme_index_v1';

  List<Semester> semesters;
  int selectedTabIndex;
  int themeIndex;
  bool hasSeenOnboarding;
  Offset? themeRevealOrigin;
  int themeRevealSerial = 0;

  SharedPreferences? _prefs;
  Timer? _saveTimer;
  final ValueNotifier<int> _themeChangeTick = ValueNotifier<int>(0);

  ValueNotifier<int> get themeChanges => _themeChangeTick;

  factory AppState.seeded() {
    return AppState(
      semesters: [
        Semester(id: _newId(), name: 'S1', modules: []),
        Semester(id: _newId(), name: 'S2', modules: []),
      ],
      selectedTabIndex: 0,
      themeIndex: 0,
    );
  }

  Future<void> loadFromPrefs({int? maxThemes}) async {
    _prefs ??= await SharedPreferences.getInstance();
    hasSeenOnboarding = _prefs!.getBool(_onboardingKey) ?? false;

    final previousTheme = themeIndex;
    final storedTheme = _prefs!.getInt(_themeIndexKey);
    if (storedTheme != null) {
      themeIndex = _clampThemeIndex(storedTheme, maxThemes);
    }

    final raw = _prefs!.getString(prefsKey);
    if (raw == null || raw.isEmpty) {
      if (themeIndex != previousTheme) {
        _themeChangeTick.value += 1;
      }
      notifyListeners();
      return;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _applyFromJson(decoded, maxThemes: maxThemes);
    } catch (_) {
      // Ignore corrupted state while keeping recoverable values.
    }

    if (themeIndex != previousTheme) {
      _themeChangeTick.value += 1;
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_onboardingKey, true);
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index.clamp(0, semesters.length);
    _scheduleSave();
    notifyListeners();
  }

  void setThemeIndex(int index, int maxThemes) {
    setTheme(index, maxThemes: maxThemes);
  }

  void setTheme(int index, {required int maxThemes, Offset? revealOrigin}) {
    final next = _clampThemeIndex(index, maxThemes);
    if (themeIndex == next) {
      return;
    }
    themeIndex = next;
    themeRevealOrigin = revealOrigin;
    themeRevealSerial += 1;
    _themeChangeTick.value += 1;
    _scheduleSave();
    notifyListeners();
  }

  void addSemester() {
    final name = _nextSemesterName();
    semesters.add(Semester(id: _newId(), name: name, modules: []));
    selectedTabIndex = semesters.length - 1;
    _scheduleSave();
    notifyListeners();
  }

  void deleteSemester(String semesterId) {
    final index = semesters.indexWhere((s) => s.id == semesterId);
    if (index == -1) {
      return;
    }
    semesters.removeAt(index);
    if (selectedTabIndex > index) {
      selectedTabIndex -= 1;
    }
    _clampSelected();
    _scheduleSave();
    notifyListeners();
  }

  void renameSemester(String semesterId, String name) {
    final semester = semesters.firstWhere((s) => s.id == semesterId);
    semester.name = name.trim().isEmpty ? semester.name : name.trim();
    _scheduleSave();
    notifyListeners();
  }

  void addModule(String semesterId, {Module? module}) {
    final semester = semesters.firstWhere((s) => s.id == semesterId);
    if (module != null) {
      semester.modules.add(module);
    } else {
      final index = semester.modules.length + 1;
      semester.modules.add(
        Module(
          id: _newId(),
          name: 'Module $index',
          coeff: '1',
          td: '',
          tp: '',
          exam: '',
          examPercentage: 60,
          ccPercentage: 40,
          splitMode: '60_40',
        ),
      );
    }
    _scheduleSave();
    notifyListeners();
  }

  void deleteModule(String semesterId, String moduleId) {
    final semester = semesters.firstWhere((s) => s.id == semesterId);
    semester.modules.removeWhere((m) => m.id == moduleId);
    _scheduleSave();
    notifyListeners();
  }

  void reorderModules(String semesterId, int oldIndex, int newIndex) {
    final semester = semesters.firstWhere((s) => s.id == semesterId);
    final modules = semester.modules;
    if (oldIndex < 0 ||
        oldIndex >= modules.length ||
        newIndex < 0 ||
        newIndex > modules.length) {
      return;
    }

    var destination = newIndex;
    if (destination > oldIndex) {
      destination -= 1;
    }
    if (destination == oldIndex) {
      return;
    }

    final moved = modules.removeAt(oldIndex);
    modules.insert(destination, moved);
    _scheduleSave();
    notifyListeners();
  }

  void updateModule(
    String semesterId,
    String moduleId, {
    String? name,
    String? coeff,
    String? td,
    String? tp,
    String? exam,
    int? examPercentage,
    int? ccPercentage,
    String? splitMode,
    bool? isLocked,
    bool? isCollapsed,
  }) {
    final semester = semesters.firstWhere((s) => s.id == semesterId);
    final module = semester.modules.firstWhere((m) => m.id == moduleId);
    if (name != null) module.name = name;
    if (coeff != null) module.coeff = coeff;
    if (td != null) module.td = td;
    if (tp != null) module.tp = tp;
    if (exam != null) module.exam = exam;
    if (examPercentage != null) module.examPercentage = examPercentage;
    if (ccPercentage != null) module.ccPercentage = ccPercentage;
    if (splitMode != null) module.splitMode = splitMode;
    if (isLocked != null) module.isLocked = isLocked;
    if (isCollapsed != null) module.isCollapsed = isCollapsed;
    _scheduleSave();
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'themeIndex': themeIndex,
    'selectedTabIndex': selectedTabIndex,
    'semesters': semesters.map((s) => s.toJson()).toList(),
  };

  void _applyFromJson(Map<String, dynamic> json, {int? maxThemes}) {
    final themes = (json['themeIndex'] as int?) ?? themeIndex;
    final selected = (json['selectedTabIndex'] as int?) ?? 0;
    final semestersRaw = json['semesters'];
    final semestersJson = (semestersRaw as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Semester.fromJson)
        .toList();

    if (semestersRaw is List) {
      semesters = semestersJson;
    }
    themeIndex = _clampThemeIndex(themes, maxThemes);
    selectedTabIndex = selected;
    _clampSelected();
  }

  int _clampThemeIndex(int index, int? maxThemes) {
    if (maxThemes == null || maxThemes <= 0) {
      return index < 0 ? 0 : index;
    }
    return index.clamp(0, maxThemes - 1).toInt();
  }

  void _clampSelected() {
    final maxIndex = semesters.length;
    if (selectedTabIndex < 0) {
      selectedTabIndex = 0;
    } else if (selectedTabIndex > maxIndex) {
      selectedTabIndex = maxIndex;
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), _saveNow);
  }

  Future<void> _saveNow() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(prefsKey, jsonEncode(toJson()));
    await _prefs!.setInt(_themeIndexKey, themeIndex);
  }

  String _nextSemesterName() {
    final regex = RegExp(r'^s(\\d+)$', caseSensitive: false);
    var maxIndex = 0;
    for (final semester in semesters) {
      final match = regex.firstMatch(semester.name.trim());
      if (match != null) {
        final value = int.tryParse(match.group(1) ?? '');
        if (value != null && value > maxIndex) {
          maxIndex = value;
        }
      }
    }
    return 'S${maxIndex + 1}';
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void dispose() {
    _saveTimer?.cancel();
    _themeChangeTick.dispose();
    super.dispose();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required this.state, required super.child})
    : super(notifier: state);

  final AppState state;

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.state;
  }
}
