import 'package:flutter/material.dart';
import '../models/conjoined_event_detail.dart';
import '../models/transaction_item.dart';
import '../services/home_repository.dart';
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
  final String eventId;
  final String? eventTitle;
  final String backLabel;

  const ConjoinedEventDetailScreen({
    super.key,
    required this.repository,
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
  late Future<ConjoinedEventDetail> _futureDetail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    _futureDetail = widget.repository.getConjoinedEventDetail(widget.eventId);
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
      body: FutureBuilder<ConjoinedEventDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryFixed),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading event: ${snapshot.error}',
                style: const TextStyle(color: AppColors.dangerCoral),
              ),
            );
          }

          final detail = snapshot.data!;

          return Stack(
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
                    // Back link + Event Title + Share Icon Top Header Row
                    _buildSubHeader(context, detail),

                    const SizedBox(height: 16),

                    // 1. Hero Sunk Volume Card
                    EventHeroVolumeCard(detail: detail),

                    const SizedBox(height: 24),

                    // 2. Member Equity Split Section
                    MemberEquitySplitSection(
                      splits: detail.memberSplits,
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
                      records: detail.ledgerRecords,
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
                  onTap: () {
                    AddExpenseIncomeScreen.show(
                      context,
                      repository: widget.repository,
                      initialType: TransactionType.expense,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.35),
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
          );
        },
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

        // Centered Screen Title: Durga Puja 2026
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

        // Share / Export icon button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing event ledger report...'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
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
              Icons.ios_share_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
