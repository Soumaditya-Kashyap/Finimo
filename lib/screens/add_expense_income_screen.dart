import 'package:flutter/material.dart';
import '../models/conjoined_event_summary.dart';
import '../models/family_member.dart';
import '../models/transaction_category.dart';
import '../models/transaction_item.dart';
import '../services/home_repository.dart';
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
  final TransactionType initialType;

  const AddExpenseIncomeScreen({
    super.key,
    required this.repository,
    this.initialType = TransactionType.expense,
  });

  /// Opens the screen as a full-height modal bottom sheet extending till top of screen
  static Future<void> show(
    BuildContext context, {
    required HomeRepository repository,
    TransactionType initialType = TransactionType.expense,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseIncomeScreen(
        repository: repository,
        initialType: initialType,
      ),
    );
  }

  @override
  State<AddExpenseIncomeScreen> createState() => _AddExpenseIncomeScreenState();
}

class _AddExpenseIncomeScreenState extends State<AddExpenseIncomeScreen> {
  late TransactionType _selectedType;
  String _rawAmount = '0.00';
  String _selectedPayerId = 'm1_arpa';
  String _selectedBeneficiary = 'Entire Family';
  String _selectedCategoryId = 'groceries';
  bool _isTaggedToEvent = true;
  bool _isSubmitting = false;

  late Future<_AddScreenDependencies> _depsFuture;

  final ScrollController _scrollController = ScrollController();
  bool _showStickyAmount = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _scrollController.addListener(_onScroll);
    _depsFuture = Future.wait([
      widget.repository.getFamilyMembers(),
      widget.repository.getActiveConjoinedEvent(),
    ]).then((res) => _AddScreenDependencies(
          members: res[0] as List<FamilyMember>,
          activeEvent: res[1] as ConjoinedEventSummary,
        ));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show sticky pill only when the large amount card is fully scrolled under header (> 170px)
    final shouldShow = _scrollController.hasClients && _scrollController.offset > 170;
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
    setState(() => _isSubmitting = true);
    // Simulate ledger write & API sync
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    // Keep a generous safe gap from status bar so it never overlaps battery/time/status bar icons!
    final topOffset = topPadding + 36.0;

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
                              color: AppColors.primaryFixed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryFixed.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Transaction',
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
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryFixed),
                    );
                  }

                  final deps = snapshot.data!;

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
                        onTypeChanged: (type) => setState(() => _selectedType = type),
                      ),

                      const SizedBox(height: 14),

                      // 2. Transaction Value Display & Quick Presets
                      AmountKeypadDisplay(
                        rawAmount: _rawAmount,
                        onPresetAdd: _handlePresetAdd,
                        onClear: _handleClear,
                      ),

                      const SizedBox(height: 16),

                      // 3. Paid By Payer Row (Arpa vs Chandrani)
                      PaidByPayerSelector(
                        members: deps.members,
                        selectedMemberId: _selectedPayerId,
                        onSelected: (id) => setState(() => _selectedPayerId = id),
                      ),

                      const SizedBox(height: 16),

                      // 4. Beneficiary / Spent For Chips
                      BeneficiaryChipSelector(
                        selectedBeneficiary: _selectedBeneficiary,
                        onSelected: (b) => setState(() => _selectedBeneficiary = b),
                      ),

                      const SizedBox(height: 16),

                      // 5. Category 3x2 Grid
                      CategorySelectorGrid(
                        categories: TransactionCategory.defaultCategories,
                        selectedCategoryId: _selectedCategoryId,
                        onSelected: (catId) => setState(() => _selectedCategoryId = catId),
                      ),

                      const SizedBox(height: 16),

                      // 6. Conjoined Event Tag Card (Shared Pot)
                      ConjoinedEventTagCard(
                        event: deps.activeEvent,
                        isTagged: _isTaggedToEvent,
                        onToggle: (val) => setState(() => _isTaggedToEvent = val),
                      ),

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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryFixed.withValues(alpha: 0.28),
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
                                        'Record Transaction',
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
                // Floating Sticky Amount Banner (floats on top without altering layout height)
                Positioned(
                        top: 0,
                        left: 16,
                        right: 16,
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _showStickyAmount
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox(width: double.infinity, height: 0),
                          secondChild: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface01,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primaryFixed.withValues(alpha: 0.35),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _selectedType == TransactionType.expense
                                            ? AppColors.primaryFixed.withValues(alpha: 0.15)
                                            : AppColors.tertiaryFixed.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _selectedType == TransactionType.expense ? 'EXPENSE' : 'INCOME',
                                        style: AppTypography.labelSm(
                                          color: _selectedType == TransactionType.expense
                                              ? AppColors.primaryFixed
                                              : AppColors.tertiaryFixed,
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
                                      duration: const Duration(milliseconds: 300),
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
  final ConjoinedEventSummary activeEvent;

  _AddScreenDependencies({
    required this.members,
    required this.activeEvent,
  });
}
