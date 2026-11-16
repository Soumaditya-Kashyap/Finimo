import 'package:flutter/material.dart';
import '../models/conjoined_event_detail.dart';
import '../models/transaction_item.dart';
import '../services/category_repository.dart';
import '../services/event_repository.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/event_hero_volume_card.dart';
import '../widgets/event_ledger_records_section.dart';
import '../widgets/finimo_app_bar.dart';
import '../widgets/member_equity_split_section.dart';
import 'add_expense_income_screen.dart';
import 'user_profile_screen.dart';

class ConjoinedEventDetailScreen extends StatefulWidget {
  final HomeRepository repository;
  final EventRepository? eventRepository;
  final TransactionRepository? transactionRepository;
  final CategoryRepository? categoryRepository;
  final FamilyRepository? familyRepository;
  final String eventId;
  final String? eventTitle;
  final String backLabel;

  const ConjoinedEventDetailScreen({
    super.key,
    required this.repository,
    this.eventRepository,
    this.transactionRepository,
    this.categoryRepository,
    this.familyRepository,
    this.eventId = 'event_durga_puja_2026',
    this.eventTitle,
    this.backLabel = 'Activity',
  });

  @override
  State<ConjoinedEventDetailScreen> createState() =>
      _ConjoinedEventDetailScreenState();
}

class _ConjoinedEventDetailScreenState
    extends State<ConjoinedEventDetailScreen> {
  late final EventRepository _eventRepo;
  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;
  late final FamilyRepository _familyRepo;

  bool _isLoading = true;
  String? _errorMessage;
  ConjoinedEventDetail? _detail;

  @override
  void initState() {
    super.initState();
    _eventRepo = widget.eventRepository ?? HttpEventRepository();
    _transactionRepo =
        widget.transactionRepository ?? HttpTransactionRepository();
    _categoryRepo = widget.categoryRepository ?? HttpCategoryRepository();
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _eventRepo.getEventItems(widget.eventId);
      final detail = ConjoinedEventDetail.fromEventItemsResponse(data);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface02,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Event Pool?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${_detail?.eventTitle ?? "this event"}"? You can only delete events with no active receipts.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerCoral),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Pool'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _eventRepo.deleteEvent(widget.eventId);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "${_detail?.eventTitle}" deleted'),
            backgroundColor: AppColors.surface03,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot delete event: $e'),
            backgroundColor: AppColors.dangerCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: FinimoAppBar(
        onProfileTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  UserProfileScreen(repository: widget.repository),
            ),
          );
        },
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryFixed),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.dangerCoral, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading event:\n$_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.dangerCoral),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDetail,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    // Scrollable Event Body
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        MediaQuery.paddingOf(context).bottom + 90,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back link + Event Title + Share & Delete Icon Top Header Row
                          _buildSubHeader(context, _detail!),

                          const SizedBox(height: 16),

                          // 1. Hero Sunk Volume Card
                          EventHeroVolumeCard(detail: _detail!),

                          const SizedBox(height: 24),

                          // 2. Member Equity Split Section
                          MemberEquitySplitSection(
                            splits: _detail!.memberSplits,
                            onInfoTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Calculated live from member expenses in this event',
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // 3. Ledger Records Section
                          EventLedgerRecordsSection(
                            records: _detail!.ledgerRecords,
                            onSortTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sorted by Most Recent Date'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Bottom Sticky Floating CTA: "+ Add Expense to Event"
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.paddingOf(context).bottom + 12,
                      child: GestureDetector(
                        onTap: () async {
                          final recorded = await AddExpenseIncomeScreen.show(
                            context,
                            repository: widget.repository,
                            transactionRepository: _transactionRepo,
                            familyRepository: _familyRepo,
                            categoryRepository: _categoryRepo,
                            initialType: TransactionType.expense,
                            initialEventId: widget.eventId,
                          );
                          if (recorded == true) {
                            _loadDetail();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryFixed
                                    .withValues(alpha: 0.35),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Expense to Event',
                                style: AppTypography.headlineSm(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ).copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSubHeader(BuildContext context, ConjoinedEventDetail detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button with parent screen name (e.g. "← Activity" or "← Targets")
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.backLabel,
                style: AppTypography.bodySm(
                  color: AppColors.textMuted,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Centered Screen Title
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.eventTitle ?? detail.eventTitle,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSm(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ).copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Right Action: Delete / Share PopUp
        PopupMenuButton<String>(
          color: AppColors.surface02,
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
          onSelected: (val) {
            if (val == 'share') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing event ledger report...'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else if (val == 'delete') {
              _confirmDeleteEvent();
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.ios_share_rounded, size: 18, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text('Share Report', style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.dangerCoral),
                  SizedBox(width: 8),
                  Text('Delete Event', style: TextStyle(color: AppColors.dangerCoral)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
