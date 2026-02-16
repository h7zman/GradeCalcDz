import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/grade_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'module_edit_sheet.dart';
import 'widgets/animations.dart';
import 'widgets/donut_chart.dart';
import 'widgets/modern_module_card.dart';
import 'widgets/result_page.dart';
import 'widgets/segmented_tab_control.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _tabsPageController;
  AppState? _observedState;

  @override
  void initState() {
    super.initState();
    _tabsPageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (_observedState == state) return;
    _observedState?.removeListener(_syncPageFromState);
    _observedState = state;
    _observedState!.addListener(_syncPageFromState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_tabsPageController.hasClients) return;
      _tabsPageController.jumpToPage(
        state.selectedTabIndex.clamp(0, _tabCount(state) - 1).toInt(),
      );
    });
  }

  @override
  void dispose() {
    _observedState?.removeListener(_syncPageFromState);
    _tabsPageController.dispose();
    super.dispose();
  }

  int _tabCount(AppState state) => state.semesters.length + 1;

  void _syncPageFromState() {
    final state = _observedState;
    if (state == null || !_tabsPageController.hasClients) return;

    final target = state.selectedTabIndex
        .clamp(0, _tabCount(state) - 1)
        .toInt();
    final current = (_tabsPageController.page ?? 0).round();
    if (target == current) return;

    _tabsPageController.animateToPage(
      target,
      duration: Motion.page,
      curve: Motion.curve,
    );
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    _observedState?.setSelectedTabIndex(index);
  }

  void _showThemePicker(BuildContext context) {
    final state = _observedState;
    if (state == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppThemes.choices.length,
            itemBuilder: (_, index) {
              final choice = AppThemes.choices[index];
              final selected = index == state.themeIndex;
              return Builder(
                builder: (tileContext) {
                  return ListTile(
                    onTap: () {
                      final box = tileContext.findRenderObject() as RenderBox?;
                      final origin = box?.localToGlobal(
                        box.size.center(Offset.zero),
                      );
                      Navigator.of(sheetContext).pop();
                      state.setTheme(
                        index,
                        maxThemes: AppThemes.choices.length,
                        revealOrigin: origin,
                      );
                    },
                    leading: CircleAvatar(backgroundColor: choice.preview),
                    title: Text(choice.name),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded)
                        : null,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showSemesterActions(
    BuildContext context,
    AppState state,
    Semester semester,
  ) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Rename semester'),
                onTap: () {
                  Navigator.of(sheetContext).pop(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Delete semester'),
                enabled: state.semesters.length > 1,
                onTap: state.semesters.length > 1
                    ? () => Navigator.of(sheetContext).pop(true)
                    : null,
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );

    if (!context.mounted) return;

    if (shouldDelete == null) {
      return;
    }

    if (shouldDelete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Delete semester?'),
            content: Text(
              '"${semester.name}" and all its modules will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        state.deleteSemester(semester.id);
      }
      return;
    }

    if (!context.mounted) return;

    final controller = TextEditingController(text: semester.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename semester'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Semester name'),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final trimmed = (newName ?? '').trim();
    if (trimmed.isEmpty || trimmed == semester.name) {
      return;
    }
    state.renameSemester(semester.id, trimmed);
  }

  Future<void> _openModuleEditor(
    BuildContext context,
    AppState state,
    Semester semester, {
    Module? module,
  }) async {
    if (module?.isLocked == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unlock this module before editing.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModuleEditSheet(
          module: module,
          onSave: (saved) {
            if (module == null) {
              state.addModule(semester.id, module: saved);
            } else {
              state.updateModule(
                semester.id,
                module.id,
                name: saved.name,
                coeff: saved.coeff,
                td: saved.td,
                tp: saved.tp,
                exam: saved.exam,
                examPercentage: saved.examPercentage,
                ccPercentage: saved.ccPercentage,
                splitMode: saved.splitMode,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppState state,
    Semester semester,
    Module module,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete module?'),
          content: Text('"${module.name}" will be removed permanently.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      state.deleteModule(semester.id, module.id);
    }
  }

  _DashboardStats _statsForSelection(AppState state) {
    if (state.selectedTabIndex < state.semesters.length) {
      final semester = state.semesters[state.selectedTabIndex];
      final calc = SemesterCalc.fromSemester(semester);
      return _DashboardStats(
        average: calc.average,
        totalModules: calc.totalModules,
        gradedModules: calc.gradedModules,
        passedModules: calc.passedModules,
      );
    }

    final overall = OverallCalc.fromSemesters(state.semesters);
    return _DashboardStats(
      average: overall.average,
      totalModules: overall.totalModules,
      gradedModules: overall.gradedModules,
      passedModules: overall.passedModules,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tokens = AppThemeTokens.of(context);
    final tabs = [...state.semesters.map((s) => s.name), 'Final Result'];
    final selectedIndex = state.selectedTabIndex
        .clamp(0, tabs.length - 1)
        .toInt();
    final selectedSemester = selectedIndex < state.semesters.length
        ? state.semesters[selectedIndex]
        : null;
    final stats = _statsForSelection(state);

    final showFab = selectedSemester != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tokens.bgTop, tokens.bgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TopNavigationBar(
                  tabs: tabs,
                  selectedIndex: selectedIndex,
                  onTabChanged: (index) {
                    HapticFeedback.selectionClick();
                    state.setSelectedTabIndex(index);
                  },
                  onSemesterLongPress: (index) {
                    if (index >= state.semesters.length) {
                      return;
                    }
                    HapticFeedback.selectionClick();
                    _showSemesterActions(context, state, state.semesters[index]);
                  },
                  onAddSemesterPressed: () {
                    HapticFeedback.mediumImpact();
                    state.addSemester();
                  },
                  onThemePressed: () => _showThemePicker(context),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OverallStatsCard(stats: stats),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _tabsPageController,
                  onPageChanged: _onPageChanged,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    if (index < state.semesters.length) {
                      final semester = state.semesters[index];
                      return _SemesterModulesView(
                        semester: semester,
                        onEdit: (module) => _openModuleEditor(
                          context,
                          state,
                          semester,
                          module: module,
                        ),
                        onDelete: (module) =>
                            _confirmDelete(context, state, semester, module),
                        onToggleLock: (module) {
                          state.updateModule(
                            semester.id,
                            module.id,
                            isLocked: !module.isLocked,
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          state.reorderModules(semester.id, oldIndex, newIndex);
                        },
                      );
                    }
                    return ResultPage(semesters: state.semesters);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimatedSlide(
        duration: Motion.item,
        curve: Curves.easeOutCubic,
        offset: showFab ? Offset.zero : const Offset(0, 1.6),
        child: AnimatedOpacity(
          duration: Motion.item,
          opacity: showFab ? 1 : 0,
          child: IgnorePointer(
            ignoring: !showFab,
            child: FloatingActionButton.extended(
              onPressed: selectedSemester == null
                  ? null
                  : () => _openModuleEditor(context, state, selectedSemester),
              icon: const Icon(FontAwesomeIcons.plus, size: 18),
              label: const Text('Add Module'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardStats {
  const _DashboardStats({
    required this.average,
    required this.totalModules,
    required this.gradedModules,
    required this.passedModules,
  });

  final double? average;
  final int totalModules;
  final int gradedModules;
  final int passedModules;
}

class _TopNavigationBar extends StatelessWidget {
  const _TopNavigationBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.onSemesterLongPress,
    required this.onAddSemesterPressed,
    required this.onThemePressed,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<int> onSemesterLongPress;
  final VoidCallback onAddSemesterPressed;
  final VoidCallback onThemePressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tokens.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.fieldBorder.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GradeCalcDZ',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By H7Z',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onThemePressed,
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Themes',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SegmentedTabControl(
                  tabs: tabs,
                  selectedIndex: selectedIndex,
                  onChanged: onTabChanged,
                  onLongPress: onSemesterLongPress,
                  scrollable: true,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAddSemesterPressed,
                tooltip: 'Add semester',
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverallStatsCard extends StatelessWidget {
  const _OverallStatsCard({required this.stats});

  final _DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: Motion.page,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Stats',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          DonutChart(
            score: stats.average ?? 0,
            maxScore: 20,
            size: 186,
            thickness: 20,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LegendItem(
                  label: 'Total',
                  value: stats.totalModules,
                  bulletColor: tokens.accent,
                  alignEnd: false,
                ),
              ),
              Expanded(
                child: _LegendItem(
                  label: 'Graded',
                  value: stats.gradedModules,
                  bulletColor: tokens.accent.withValues(alpha: 0.35),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.value,
    required this.bulletColor,
    required this.alignEnd,
  });

  final String label;
  final int value;
  final Color bulletColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: bulletColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: 'modules: ',
            style: theme.textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
            children: [
              TextSpan(
                text: '$value',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SemesterModulesView extends StatefulWidget {
  const _SemesterModulesView({
    required this.semester,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleLock,
    required this.onReorder,
  });

  final Semester semester;
  final ValueChanged<Module> onEdit;
  final ValueChanged<Module> onDelete;
  final ValueChanged<Module> onToggleLock;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<_SemesterModulesView> createState() => _SemesterModulesViewState();
}

class _SemesterModulesViewState extends State<_SemesterModulesView> {
  int? _heldIndex;

  void _onReorderStart(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _heldIndex = index);
  }

  void _onReorderEnd(int _) {
    if (!mounted) return;
    setState(() => _heldIndex = null);
  }

  void _onReorder(int oldIndex, int newIndex) {
    widget.onReorder(oldIndex, newIndex);

    var destination = newIndex;
    if (destination > oldIndex) {
      destination -= 1;
    }
    final maxIndex = widget.semester.modules.length - 1;
    if (maxIndex >= 0) {
      setState(() {
        _heldIndex = destination.clamp(0, maxIndex).toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    if (widget.semester.modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.boxOpen,
              color: tokens.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              'No modules yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap “Add Module” to start.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      itemCount: widget.semester.modules.length,
      buildDefaultDragHandles: false,
      onReorderStart: _onReorderStart,
      onReorderEnd: _onReorderEnd,
      onReorder: _onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Material(
              type: MaterialType.transparency,
              child: child,
            );
          },
        );
      },
      itemBuilder: (context, index) {
        final module = widget.semester.modules[index];
        return Padding(
          key: ValueKey(module.id),
          padding: EdgeInsets.only(
            bottom: index == widget.semester.modules.length - 1 ? 0 : 14,
          ),
          child: ReorderableDelayedDragStartListener(
            index: index,
            child: ModernModuleCard(
              module: module,
              moduleIndex: index + 1,
              isHeld: _heldIndex == index,
              onEdit: module.isLocked ? null : () => widget.onEdit(module),
              onDelete: () => widget.onDelete(module),
              onToggleLock: () => widget.onToggleLock(module),
            ),
          ),
        );
      },
    );
  }
}
