import 'package:flutter/material.dart';
import '../services/event_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CreateEventSheet extends StatefulWidget {
  final EventRepository eventRepository;
  final VoidCallback onEventCreated;

  const CreateEventSheet({
    super.key,
    required this.eventRepository,
    required this.onEventCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required EventRepository eventRepository,
    required VoidCallback onEventCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateEventSheet(
        eventRepository: eventRepository,
        onEventCreated: onEventCreated,
      ),
    );
  }

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet> {
  final _titleController = TextEditingController();
  final _capController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _capController.dispose();
    super.dispose();
  }

  Future<void> _submitEvent() async {
    final title = _titleController.text.trim();
    final capText = _capController.text.trim();
    final cap = double.tryParse(capText);

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Please enter an event or pool title');
      return;
    }
    if (cap == null || cap <= 0) {
      setState(() => _errorMessage = 'Please enter a valid budget cap');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.eventRepository.createEvent(
        title: title,
        budgetCap: cap,
        startDate: _startDate,
        endDate: _endDate,
        status: 'ACTIVE',
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onEventCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "$title" created successfully!'),
            backgroundColor: AppColors.secondary,
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

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.secondary,
            surface: AppColors.surface02,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 14)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.secondary,
            surface: AppColors.surface02,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startStr = '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}';
    final endStr = _endDate != null
        ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
        : 'Select end date (optional)';

    final systemBottom = MediaQuery.viewPaddingOf(context).bottom > 0
        ? MediaQuery.viewPaddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final effectiveBottom =
        bottomInset > 0 ? bottomInset + 16 : systemBottom + 24;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset : 0,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, effectiveBottom),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.celebration_outlined, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'New Sinking Fund / Event',
                        style: AppTypography.headlineSm(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 18),
                      ),
                    ],
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

              // Event Title
              Text('EVENT / SINKING FUND TITLE', style: AppTypography.labelSm(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface01,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ghostBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Durga Puja 2026, Goa Family Trip',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget Cap
              Text('TOTAL BUDGET CAP (₹)', style: AppTypography.labelSm(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface01,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ghostBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _capController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(color: AppColors.secondary, fontSize: 20),
                    hintText: '10000',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 18),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dates Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('START DATE', style: AppTypography.labelSm(color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickStartDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface01,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.ghostBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.secondary),
                                const SizedBox(width: 8),
                                Text(startStr, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('END DATE', style: AppTypography.labelSm(color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickEndDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface01,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.ghostBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available_outlined, size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    endStr,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _endDate != null ? AppColors.textPrimary : AppColors.textMuted,
                                      fontSize: 13,
                                    ),
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
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
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
                          'Launch Shared Pool',
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
