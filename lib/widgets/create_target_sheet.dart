import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../services/category_repository.dart';
import '../services/target_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CreateTargetSheet extends StatefulWidget {
  final TargetRepository targetRepository;
  final CategoryRepository categoryRepository;
  final VoidCallback onTargetCreated;

  const CreateTargetSheet({
    super.key,
    required this.targetRepository,
    required this.categoryRepository,
    required this.onTargetCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required TargetRepository targetRepository,
    required CategoryRepository categoryRepository,
    required VoidCallback onTargetCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTargetSheet(
        targetRepository: targetRepository,
        categoryRepository: categoryRepository,
        onTargetCreated: onTargetCreated,
      ),
    );
  }

  @override
  State<CreateTargetSheet> createState() => _CreateTargetSheetState();
}

class _CreateTargetSheetState extends State<CreateTargetSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _timeFrame = 'MONTHLY';
  int _notifyThreshold = 80;
  String? _selectedCategoryId;

  List<TransactionCategory> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await widget.categoryRepository.getCategories(type: 'EXPENSE');
      if (mounted) {
        setState(() {
          _categories = list;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _submitTarget() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter a target name');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid limit amount');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.targetRepository.createTarget(
        targetName: name,
        limitAmount: amount,
        timeFrame: _timeFrame,
        categoryId: _selectedCategoryId,
        notifyThresholdPct: _notifyThreshold,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onTargetCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Target "$name" created successfully!'),
            backgroundColor: AppColors.surface03,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.canvasBase,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.ghostBorder, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surface03,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Spending Target',
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerCoral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.dangerCoral, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.dangerCoral, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Target Name Field
              Text('TARGET NAME', style: AppTypography.labelSm(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface01,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ghostBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Groceries & Household, Dining Out',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Limit Amount
              Text('LIMIT AMOUNT (₹)', style: AppTypography.labelSm(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface01,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ghostBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.primaryFixed,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(color: AppColors.primaryFixed, fontSize: 20),
                    hintText: '15000',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 18),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text('CATEGORY (OPTIONAL)', style: AppTypography.labelSm(color: AppColors.textMuted)),
              const SizedBox(height: 8),
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All Expenses (Family Cap)'),
                          selected: _selectedCategoryId == null,
                          selectedColor: AppColors.primaryFixed,
                          backgroundColor: AppColors.surface01,
                          labelStyle: TextStyle(
                            color: _selectedCategoryId == null ? AppColors.canvasBase : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedCategoryId = null);
                          },
                        ),
                      ),
                      ..._categories.map((cat) {
                        final isSel = _selectedCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 14, color: isSel ? AppColors.canvasBase : cat.iconColor),
                                const SizedBox(width: 4),
                                Text(cat.name),
                              ],
                            ),
                            selected: isSel,
                            selectedColor: AppColors.primaryFixed,
                            backgroundColor: AppColors.surface01,
                            labelStyle: TextStyle(
                              color: isSel ? AppColors.canvasBase : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedCategoryId = cat.id;
                                if (_nameController.text.trim().isEmpty) {
                                  _nameController.text = cat.name;
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Time Frame (Monthly / Weekly)
              Text('TIMEFRAME', style: AppTypography.labelSm(color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: ['MONTHLY', 'WEEKLY', 'DAILY'].map((tf) {
                  final isSel = _timeFrame == tf;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tf),
                      selected: isSel,
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.surface01,
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.canvasBase : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) => setState(() => _timeFrame = tf),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Notify Threshold (Slider or Pills)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NOTIFY THRESHOLD', style: AppTypography.labelSm(color: AppColors.textMuted)),
                  Text('$_notifyThreshold%', style: const TextStyle(color: AppColors.dangerCoral, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _notifyThreshold.toDouble(),
                min: 50,
                max: 100,
                divisions: 10,
                activeColor: AppColors.dangerCoral,
                inactiveColor: AppColors.surface03,
                onChanged: (val) => setState(() => _notifyThreshold = val.round()),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTarget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    foregroundColor: AppColors.canvasBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: AppColors.canvasBase, strokeWidth: 2),
                        )
                      : Text(
                          'Save Spending Limit',
                          style: AppTypography.headlineSm(
                            color: AppColors.canvasBase,
                            fontWeight: FontWeight.w700,
                          ).copyWith(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
