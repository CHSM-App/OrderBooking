import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/addRegion_viewmodel.dart';
import 'admin_addRegion.dart';
import 'package:order_booking_app/domain/models/region.dart';


class RegionListPage extends ConsumerStatefulWidget {
  const RegionListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends ConsumerState<RegionListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    /// Call API after first frame
    Future.microtask(() {
      ref.read(regionViewModelProvider.notifier).getRegionList();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(regionViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Regions",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRegionPage()),
            );

            /// Refresh list after adding region
            ref.read(regionViewModelProvider.notifier).getRegionList();
          },
          child: const Icon(Icons.add),
        ),
      ),

      body: _buildBody(state),
    );
  }

  Widget _buildBody(RegionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return state.regionList!.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (regions) {
        if (regions.isEmpty) {
          return const Center(child: Text("No regions found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: regions.length,
          itemBuilder: (context, index) {
            final Region region = regions[index];

            final animation = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * 0.1,
                  1,
                  curve: Curves.easeOut,
                ),
              ),
            );

            return FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: animation,
                child: _RegionCard(region: region),
              ),
            );
          },
        );
      },
    );
  }
}


class _RegionCard extends StatelessWidget {
  final Region region;

  const _RegionCard({required this.region});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.regionName??'',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${region.district}, ${region.state}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pincode: ${region.pincode}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
