import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/addRegion_viewmodel.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'admin_addRegion.dart';

class RegionListPage extends ConsumerStatefulWidget {
  const RegionListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends ConsumerState<RegionListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = "";
  bool _showFab = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Listen to scroll for FAB animation
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _showFab) {
        setState(() => _showFab = false);
      } else if (_scrollController.offset <= 100 && !_showFab) {
        setState(() => _showFab = true);
      }
    });

    Future.microtask(() {
      ref.read(regionofflineViewModelProvider.notifier).fetchRegions();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(regionofflineViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: const Color(0xFFFF6F00),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Regions",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFFF6F00),
            foregroundColor: Colors.white,
            elevation: 8,
            child: const Icon(Icons.add_rounded, size: 22),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddRegionPage()),
              );
              ref.read(regionofflineViewModelProvider.notifier).fetchRegions();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          /// 🔍 ANIMATED SEARCH BAR
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: "Search region, district, state or pincode",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          /// 📦 REGION LIST
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }Widget _buildBody(AsyncValue<List<Region>> state) {
  return state.when(
    loading: () => const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
      ),
    ),
    error: (e, st) => Center(child: Text(e.toString())),
    data: (regions) {
      final filteredRegions = regions.where((region) {
        return (region.regionName ?? "").toLowerCase().contains(_searchQuery) ||
               (region.district ?? "").toLowerCase().contains(_searchQuery) ||
               (region.state ?? "").toLowerCase().contains(_searchQuery) ||
               (region.pincode ?? "").toString().contains(_searchQuery);
      }).toList();

      if (filteredRegions.isEmpty) {
        return const Center(
          child: Text(
            "No matching regions found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: filteredRegions.length,
        itemBuilder: (context, index) {
          final region = filteredRegions[index];
          return _AnimatedRegionCard(
            region: region,
            index: index,
            controller: _controller,
          );
        },
      );
    },
  );
}
    }
class _AnimatedRegionCard extends StatefulWidget {
  final Region region;
  final int index;
  final AnimationController controller;

  const _AnimatedRegionCard({
    required this.region,
    required this.index,
    required this.controller,
  });

  @override
  State<_AnimatedRegionCard> createState() => _AnimatedRegionCardState();
}

class _AnimatedRegionCardState extends State<_AnimatedRegionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(
          widget.index * 0.05,
          1,
          curve: Curves.easeOut,
        ),
      ),
    );

    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeInOut,
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: FadeTransition(
        opacity: widget.controller,
        child: SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) {
                _hoverController.forward();
                setState(() => _isHovered = true);
              },
              onTapUp: (_) {
                _hoverController.reverse();
                setState(() => _isHovered = false);
              },
              onTapCancel: () {
                _hoverController.reverse();
                setState(() => _isHovered = false);
              },
              child: _RegionCard(
                region: widget.region,
                isHovered: _isHovered,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  final Region region;
  final bool isHovered;

  const _RegionCard({
    required this.region,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10), // Reduced from 16 to 10
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHovered
              ? const Color(0xFFFF6F00).withOpacity(0.5)
              : const Color(0xFFFF6F00).withOpacity(0.2),
          width: isHovered ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6F00).withOpacity(isHovered ? 0.25 : 0.15),
            blurRadius: isHovered ? 16 : 12,
            offset: Offset(0, isHovered ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isHovered
                      ? [const Color(0xFFFF8F00), const Color(0xFFFF6F00)]
                      : [const Color(0xFFFF6F00), const Color(0xFFFF8F00)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6F00).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.regionName ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${region.district}, ${region.state}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "PIN: ${region.pincode}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFF6F00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isHovered)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFFF6F00),
                      size: 20,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}