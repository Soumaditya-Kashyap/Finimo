import 'package:flutter/material.dart';
import '../models/conjoined_event_summary.dart';
import '../models/family_member.dart';
import '../models/transaction_category.dart';
import '../models/transaction_item.dart';
import '../services/category_repository.dart';
import '../services/dashboard_repository.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/amount_keypad_display.dart';
import '../widgets/beneficiary_chip_selector.dart';
import '../widgets/category_selector_grid.dart';
import '../widgets/conjoined_event_tag_card.dart';
import '../widgets/numeric_keypad_grid.dart';
import '../widgets/paid_by_payer_selector.dart';
import '../widgets/transaction_type_switch.dart';

class AddExpenseIncomeScreen extends StatefulWidget {
  final HomeRepository repository;
  final FamilyRepository? familyRepository;
  final CategoryRepository? categoryRepository;
  final TransactionRepository? transactionRepository;
  final DashboardRepository? dashboardRepository;
  final TransactionType initialType;
  final String? initialEventId;

  const AddExpenseIncomeScreen({
    super.key,
    required this.repository,
    this.familyRepository,
    this.categoryRepository,
    this.transactionRepository,
    this.dashboardRepository,
    this.initialType = TransactionType.expense,
    this.initialEventId,
  });

  /// Opens the screen as a full-height modal bottom sheet extending till top of screen
  static Future<bool?> show(
    BuildContext context, {
    required HomeRepository repository,
    FamilyRepository? familyRepository,
    CategoryRepository? categoryRepository,
    TransactionRepository? transactionRepository,
    DashboardRepository? dashboardRepository,
    TransactionType initialType = TransactionType.expense,
    String? initialEventId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseIncomeScreen(
        repository: repository,
        familyRepository: familyRepository,
        categoryRepository: categoryRepository,
        transactionRepository: transactionRepository,
        dashboardRepository: dashboardRepository,
        initialType: initialType,
        initialEventId: initialEventId,
      ),
    );
  }

  @override
  State<AddExpenseIncomeScreen> createState() => _AddExpenseIncomeScreenState();
}

class _AddExpenseIncomeScreenState extends State<AddExpenseIncomeScreen> {
  late final FamilyRepository _familyRepo;
  late final CategoryRepository _categoryRepo;
  late final TransactionRepository _transactionRepo;
  late final DashboardRepository _dashboardRepo;

  late TransactionType _selectedType;
  String _rawAmount = '0.00';
  String? _selectedPayerId;
  String? _selectedBeneficiaryMemberId; // null means 'Entire Family'
  String _selectedCategoryId = '';
  bool _isTaggedToEvent = false;
  bool _isSubmitting = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<FamilyMember> _members = [];
  ConjoinedEventSummary? _activeEvent;
  List<TransactionCategory> _allCategories = [];

  late Future<_AddScreenDependencies> _depsFuture;

  final ScrollController _scrollController = ScrollController();
  bool _showStickyAmount = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();
    _categoryRepo = widget.categoryRepository ?? HttpCategoryRepository();
    _transactionRepo =
        widget.transactionRepository ?? HttpTransactionRepository();
    _dashboardRepo =
        widget.dashboardRepository ?? HttpDashboardRepository();

    _scrollController.addListener(_onScroll);
    _depsFuture = _loadInitialDependencies();
  }

  Future<_AddScreenDependencies> _loadInitialDependencies() async {
    final results = await Future.wait([
      _familyRepo
          .getFamilyMembers()
          .catchError((_) => widget.repository.getFamilyMembers()),
      _dashboardRepo
          .getActiveConjoinedEvent()
          .catchError((_) => null),
      _categoryRepo
          .getCategories()
          .catchError((_) => TransactionCategory.defaultCategories),
    ]);

    final members = (results[0] as List<FamilyMember>?) ?? [];
    final activeEvent = results[1] as ConjoinedEventSummary?;
    final categories =
        (results[2] as List<TransactionCategory>?) ?? TransactionCategory.defaultCategories;

    _members = members;
    _activeEvent = activeEvent;
    _allCategories = categories;

    if (_selectedPayerId == null && members.isNotEmpty) {
      _selectedPayerId = members.first.id;
    }

    _syncSelectedCategoryForCurrentType();

    return _AddScreenDependencies(
      members: members,
      activeEvent: activeEvent,
      categories: categories,
    );
  }

  void _syncSelectedCategoryForCurrentType() {
    final targetTypeStr =
        _selectedType == TransactionType.expense ? 'EXPENSE' : 'INCOME';
    final matching = _allCategories
        .where((c) => c.type.toUpperCase() == targetTypeStr)
        .toList();

    if (matching.isEmpty) {
      final fallback = TransactionCategory.defaultCategories
          .where((c) => c.type.toUpperCase() == targetTypeStr)
          .toList();
      if (fallback.isNotEmpty) {
        _selectedCategoryId = fallback.first.id;
      }
      return;
    }

    final exists = matching.any((c) => c.id == _selectedCategoryId);
    if (!exists) {
      _selectedCategoryId = matching.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 170;
    if (shouldShow != _showStickyAmount) {
      setState(() => _showStickyAmount = shouldShow);
    }
  }

  void _handleKeyPress(String key) {
    setState(() {
      if (key == '.') {
        if (!_rawAmount.contains('.')) {
          _rawAmount += '.';
        }
      } else {
        if (_rawAmount == '0.00' || _rawAmount == '0') {
          _rawAmount = key;
        } else {
          if (_rawAmount.contains('.')) {
            final decimals = _rawAmount.split('.')[1];
            if (decimals.length >= 2) return;
          }
          if (_rawAmount.length < 9) {
            _rawAmount += key;
          }
        }
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_rawAmount.length > 1) {
        _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
      } else {
        _rawAmount = '0.00';
      }
    });
  }

  void _handleClear() {
    setState(() => _rawAmount = '0.00');
  }

  void _handlePresetAdd(double val) {
    final cur = double.tryParse(_rawAmount) ?? 0.0;
    setState(() {
      _rawAmount = (cur + val).toStringAsFixed(2);
    });
  }

  Future<void> _recordTransaction() async {
    final amount = double.tryParse(_rawAmount) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an amount greater than ₹0'),
          backgroundColor: AppColors.dangerCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: AppColors.dangerCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    String payerId = _selectedPayerId ?? '';
    if (payerId.isEmpty && _members.isNotEmpty) {
      payerId = _members.first.id;
    }
    if (payerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No member selected'),
          backgroundColor: AppColors.dangerCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Resolve transaction title
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      final selectedCat = _allCategories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => TransactionCategory(
          id: _selectedCategoryId,
          name: _selectedType == TransactionType.expense ? 'Expense' : 'Income',
          icon: Icons.receipt_long_outlined,
          iconColor: _selectedType == TransactionType.expense
              ? AppColors.primaryFixed
              : AppColors.tertiaryFixed,
        ),
      );
      title = selectedCat.name;
    }

    setState(() => _isSubmitting = true);

    try {
      final isExpense = _selectedType == TransactionType.expense;
      final typeStr = isExpense ? 'EXPENSE' : 'INCOME';
      final uuidRegex = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

      final beneficiaryId =
          (uuidRegex.hasMatch(_selectedBeneficiaryMemberId ?? ''))
              ? _selectedBeneficiaryMemberId
              : null;

      final eventId = isExpense
          ? (widget.initialEventId ??
              (_isTaggedToEvent &&
                      _activeEvent != null &&
                      uuidRegex.hasMatch(_activeEvent!.id)
                  ? _activeEvent!.id
                  : null))
          : null;

      await _transactionRepo.createTransaction(
        type: typeStr,
        amount: amount,
        title: title,
        categoryId: _selectedCategoryId,
        paidByMemberId: payerId,
        beneficiaryMemberId: beneficiaryId,
        eventId: eventId,
        transactionDate: DateTime.now(),
        paymentMode: 'UPI',
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!mounted) return;

      final accentColor =
          isExpense ? AppColors.primaryFixed : AppColors.tertiaryFixed;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.canvasBase, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (₹${amount.toStringAsFixed(2)}) recorded successfully!',
                  style: const TextStyle(
                      color: AppColors.canvasBase, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record transaction: $e'),
          backgroundColor: AppColors.dangerCoral,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final topOffset = topPadding + 36.0;

    final isExpense = _selectedType == TransactionType.expense;
    final accentColor =
        isExpense ? AppColors.primaryFixed : AppColors.tertiaryFixed;

    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.canvasBase,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle & Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  // Modal Drag Handle
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.surface03,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bar Row: Dot + Title + Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isExpense ? 'Add Expense' : 'Add Income',
                            style: AppTypography.headlineSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface02,
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Form Content with Floating Sticky Amount Bar
            Expanded(
              child: FutureBuilder<_AddScreenDependencies>(
                future: _depsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  }

                  final deps = snapshot.data ??
                      _AddScreenDependencies(
                        members: _members,
                        activeEvent: _activeEvent,
                        categories: _allCategories,
                      );

                  final targetTypeStr = isExpense ? 'EXPENSE' : 'INCOME';
                  final currentCategories = deps.categories
                      .where((c) => c.type.toUpperCase() == targetTypeStr)
                      .toList();

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        child: Column(
                          children: [
                            // 1. Segmented Expense / Income Switch
                            TransactionTypeSegmentedSwitch(
                              selectedType: _selectedType,
                              onTypeChanged: (type) {
                                setState(() {
                                  _selectedType = type;
                                  _syncSelectedCategoryForCurrentType();
                                });
                              },
                            ),

                            const SizedBox(height: 14),

                            // 2. Transaction Value Display & Quick Presets
                            AmountKeypadDisplay(
                              rawAmount: _rawAmount,
                              onPresetAdd: _handlePresetAdd,
                              onClear: _handleClear,
                            ),

                            const SizedBox(height: 14),

                            // Optional Title / Merchant note input
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface01,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.ghostBorder, width: 1),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 2),
                              child: TextField(
                                controller: _titleController,
                                style: AppTypography.labelMd(
                                    color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  hintText: isExpense
                                      ? 'Optional title / note (e.g. Swiggy, Fuel)'
                                      : 'Optional title / note (e.g. Salary, Client Payout, Bonus)',
                                  hintStyle: AppTypography.bodySm(
                                      color: AppColors.textMuted),
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 3. Paid By / Income By Selector (Dynamic members & contextual labels)
                            PaidByPayerSelector(
                              members: deps.members,
                              selectedMemberId: _selectedPayerId ??
                                  (deps.members.isNotEmpty
                                      ? deps.members.first.id
                                      : ''),
                              onSelected: (id) =>
                                  setState(() => _selectedPayerId = id),
                              title: isExpense ? 'Paid By' : 'Income By',
                              subtitle: isExpense
                                  ? 'Family Account'
                                  : 'Inflow Source',
                              activeColor: accentColor,
                            ),

                            const SizedBox(height: 16),

                            // 4. Spent For / Income For (Whom?) Chips (Dynamic members & contextual labels)
                            BeneficiaryChipSelector(
                              members: deps.members,
                              selectedBeneficiaryMemberId:
                                  _selectedBeneficiaryMemberId,
                              onSelected: (id) => setState(
                                  () => _selectedBeneficiaryMemberId = id),
                              title: isExpense
                                  ? 'Spent For (Whom?)'
                                  : 'Income For (Whom?)',
                              subtitle:
                                  isExpense ? 'Full Share' : 'Family Inflow',
                              activeColor: accentColor,
                            ),

                            const SizedBox(height: 16),

                            // 5. Category Selector Grid (Dynamic categories from API)
                            CategorySelectorGrid(
                              categories: currentCategories,
                              selectedCategoryId: _selectedCategoryId,
                              onSelected: (catId) =>
                                  setState(() => _selectedCategoryId = catId),
                              activeColor: accentColor,
                            ),

                            // 6. Conjoined Event Tag Card (Shared Pot) - shown ONLY for Expense if active event exists
                            if (isExpense && deps.activeEvent != null) ...[
                              const SizedBox(height: 16),
                              ConjoinedEventTagCard(
                                event: deps.activeEvent!,
                                isTagged: _isTaggedToEvent,
                                onToggle: (val) =>
                                    setState(() => _isTaggedToEvent = val),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // 7. Numeric Keypad
                            NumericKeypadGrid(
                              onKeyPress: _handleKeyPress,
                              onBackspace: _handleBackspace,
                            ),

                            const SizedBox(height: 20),

                            // 8. Record Transaction Primary Action Button
                            InkWell(
                              onTap: _isSubmitting ? null : _recordTransaction,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.28),
                                      blurRadius: 28,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: AppColors.canvasBase,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isExpense
                                                  ? 'Record Expense'
                                                  : 'Record Income',
                                              style: AppTypography.headlineSm(
                                                color: AppColors.canvasBase,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: AppColors.canvasBase,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Floating Sticky Amount Banner
                      Positioned(
                        top: 0,
                        left: 16,
                        right: 16,
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _showStickyAmount
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox(
                              width: double.infinity, height: 0),
                          secondChild: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface01,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isExpense
                                            ? AppColors.primaryFixed
                                                .withValues(alpha: 0.15)
                                            : AppColors.tertiaryFixed
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isExpense ? 'EXPENSE' : 'INCOME',
                                        style: AppTypography.labelSm(
                                          color: accentColor,
                                          fontWeight: FontWeight.w800,
                                        ).copyWith(fontSize: 9),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹$_rawAmount',
                                      style: AppTypography.headlineSm(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ).copyWith(fontSize: 18),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    _scrollController.animateTo(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                    );
                                  },
                                  child: Text(
                                    'Edit Value',
                                    style: AppTypography.labelSm(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddScreenDependencies {
  final List<FamilyMember> members;
  final ConjoinedEventSummary? activeEvent;
  final List<TransactionCategory> categories;

  _AddScreenDependencies({
    required this.members,
    required this.activeEvent,
    required this.categories,
  });
}
