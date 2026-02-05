import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addRegion.dart';

class RegionDetailsPage extends ConsumerStatefulWidget {
  const RegionDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegionDetailsPage> createState() => _RegionDetailsPageState();
}

class _RegionDetailsPageState extends ConsumerState<RegionDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch regions on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final companyId = ref.read(adminloginViewModelProvider).companyId;
      if (companyId != null && companyId.isNotEmpty) {
        ref.read(regionofflineViewModelProvider.notifier).fetchRegions(companyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final regionState = ref.watch(regionViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Regions',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
       
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add Region Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRegionPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4A5568),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Region',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final regionState = ref.watch(regionofflineViewModelProvider);
    final regionList = regionState.regionList;
    
    // Show loading indicator
    if (regionState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A5568),
        ),
      );
    }

    // Show error state
    if (regionState.error != null) {
      return _buildErrorState(regionState.error!);
    }

    // Handle AsyncValue states
    return regionList?.when(
      data: (regions) => regions.isEmpty
          ? _buildEmptyState()
          : _buildRegionList(regions),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A5568),
        ),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
    ) ?? _buildEmptyState();
  }

  Widget _buildRegionList(List<Region> regions) {
    return RefreshIndicator(
      onRefresh: () async {
        final companyId = ref.read(adminloginViewModelProvider).companyId;
        if (companyId != null && companyId.isNotEmpty) {
          await ref.read(regionofflineViewModelProvider.notifier).fetchRegions(companyId);
        }
      },
      color: const Color(0xFF4A5568),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          return _buildRegionCard(regions[index]);
        },
      ),
    );
  }

  Widget _buildRegionCard(Region region) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Region Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  region.regionName ?? 'Unknown Region',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6CF5), // Rich blue color like in image
                  ),
                ),
              ),
              if (region.syncStatus != null)
                _buildSyncStatusBadge(region.syncStatus!),
            ],
          ),
          const SizedBox(height: 6),
          
          // Pincode and Location in one line
          Text(
            '${region.pincode ?? 'N/A'} • ${region.district ?? 'N/A'}, ${region.state ?? 'N/A'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusBadge(String status) {
    final isSync = status.toLowerCase() == 'synced';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSync
              ? const Color(0xFF5B6CF5) // Blue like "Shipped"
              : const Color(0xFFFF8A65), // Orange like "Accepted"
          width: 1.5,
        ),
      ),
      child: Text(
        isSync ? 'Synced' : 'Pending',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSync
              ? const Color(0xFF5B6CF5)
              : const Color(0xFFFF8A65),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Regions Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first region to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final companyId = ref.read(adminloginViewModelProvider).companyId;
              if (companyId != null && companyId.isNotEmpty) {
                ref.read(regionofflineViewModelProvider.notifier).fetchRegions(companyId);
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5568),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}