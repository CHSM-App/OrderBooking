import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addRegion.dart';
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kPrimaryLight  = Color(0xFFFFF3E8);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);
const _kRed           = Color(0xFFDC2626);
const _kRedLight      = Color(0xFFFEE2E2);
const _kGreen         = Color(0xFF16A34A);
const _kGreenLight    = Color(0xFFDCFCE7);

class RegionDetailsPage extends ConsumerStatefulWidget {
  const RegionDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegionDetailsPage> createState() =>
      _RegionDetailsPageState();
}

class _RegionDetailsPageState extends ConsumerState<RegionDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final companyId =
        ref.read(adminloginViewModelProvider).companyId;
    if (companyId != null && companyId.isNotEmpty) {
      await ref
          .read(regionofflineViewModelProvider.notifier)
          .fetchRegionList(companyId);
    }
  }

  bool _isNetworkError(String? message) {
    if (message == null) return false;
    final msg = message.toLowerCase();
    return [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host',
      'no address',
      'timeout',
      'unreachable',
    ].any(msg.contains);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Regions',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kDivider),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddRegionPage()),
        ).then((_) => _refresh()),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Add Region',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final state = ref.watch(regionofflineViewModelProvider);

    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: _kPrimary, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text('Loading regions…',
                style: TextStyle(
                    fontSize: 14,
                    color: _kTextSecondary.withOpacity(0.8))),
          ],
        ),
      );
    }

    if (state.error != null) {
      return _isNetworkError(state.error)
          ? _buildNoInternet()
          : _buildError();
    }

    return (state.regionList.when(
          data: (regions) => regions.isEmpty
              ? _buildEmpty()
              : _buildList(regions),
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: _kPrimary, strokeWidth: 2.5)),
          error: (e, _) =>
              _isNetworkError(e.toString()) ? _buildNoInternet() : _buildError(),
        )) ??
        _buildEmpty();
  }

  // ── Region list ────────────────────────────────────────────────────────────
  Widget _buildList(List<Region> regions) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: _kPrimary,
      backgroundColor: _kSurface,
      strokeWidth: 2.5,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: regions.length,
        itemBuilder: (_, i) => _RegionCard(
          region: regions[i],
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AddRegionPage(region: regions[i])),
          ).then((_) => _refresh()),
          onDelete: () => _confirmDelete(regions[i]),
        ),
      ),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: _kPrimaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.location_off_outlined,
                size: 34, color: _kPrimary),
          ),
          const SizedBox(height: 16),
          const Text('No Regions Found',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary)),
          const SizedBox(height: 6),
          const Text('Tap + Add Region to get started',
              style:
                  TextStyle(fontSize: 13, color: _kTextSecondary)),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildNoInternet() {
    return AdminNoInternetRetry(onRetry: _refresh);
  }

  Widget _buildError() {
    return AdminSomethingWentWrongRetry(onRetry: _refresh);
  }

  // ── Delete confirm dialog ──────────────────────────────────────────────────
  void _confirmDelete(Region region) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                  color: _kRedLight, shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded,
                  color: _kRed, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('Delete Region?',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this region? This action cannot be undone.',
          style: TextStyle(
              fontSize: 14, color: _kTextSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: _kTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;

      final companyId =
          ref.read(adminloginViewModelProvider).companyId;
      if (region.regionId == null ||
          companyId == null ||
          companyId.isEmpty) return;

      final result = await ref
          .read(regionofflineViewModelProvider.notifier)
          .deleteRegion(region.regionId!, companyId);

      if (!mounted) return;

      final ok = (result['status'] ?? 0) == 1;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(
              ok
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result['message'] ?? 'Something went wrong',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: ok ? _kGreen : _kRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));

      await ref
          .read(regionofflineViewModelProvider.notifier)
          .fetchRegionList(companyId);
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Region Card
// ══════════════════════════════════════════════════════════════════════════════
class _RegionCard extends StatelessWidget {
  final Region region;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RegionCard({
    required this.region,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final syncStatus = region.syncStatus?.toLowerCase();
    final isSynced   = syncStatus == 'synced';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kDivider),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: name + actions ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kPrimaryLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: _kPrimary),
                ),
                const SizedBox(width: 12),

                // Name + address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.regionName ?? 'Unknown Region',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${region.pincode ?? 'N/A'} • ${region.district ?? 'N/A'}, ${region.state ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kTextSecondary,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),

                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 16, color: _kPrimary),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kRedLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: _kRed),
                  ),
                ),
              ],
            ),

            // ── Sync badge ─────────────────────────────────────────
            if (region.syncStatus != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: _kDivider),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSynced
                        ? _kGreenLight
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSynced
                          ? _kGreen.withOpacity(0.4)
                          : _kPrimary.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSynced
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_sync_outlined,
                        size: 12,
                        color: isSynced ? _kGreen : _kPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSynced ? 'Synced' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSynced ? _kGreen : _kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
