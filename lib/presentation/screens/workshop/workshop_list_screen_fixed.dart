import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/loading_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../../main_fixed.dart';

/// Workshop list screen with search and filtering capabilities
/// 
/// Displays a list of workshops with infinite scroll, search functionality,
/// and filtering options. Supports both mobile and desktop layouts.
class WorkshopListScreenFixed extends StatefulWidget {
  final bool showSearchBar;
  
  const WorkshopListScreenFixed({
    super.key,
    this.showSearchBar = false,
  });

  @override
  State<WorkshopListScreenFixed> createState() => _WorkshopListScreenFixedState();
}

class _WorkshopListScreenFixedState extends State<WorkshopListScreenFixed> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _showSearch = widget.showSearchBar;
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load initial workshop data
  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MockWorkshopProvider>().loadWorkshops(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(),
          Expanded(child: _buildWorkshopList()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Sidebar with filters
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                if (_showSearch) _buildSearchBar(),
                _buildFilterPanel(),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _buildWorkshopList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Sidebar with filters
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                if (_showSearch) _buildSearchBar(),
                _buildFilterPanel(),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _buildWorkshopList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('워크샵 목록'),
      actions: [
        if (!_showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = true;
              });
            },
          ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('필터 기능은 향후 구현 예정입니다')),
            );
          },
        ),
      ],
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '워크샵 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (query) {
          setState(() {});
        },
      ),
    );
  }

  /// Build filter panel for tablet/desktop
  Widget _buildFilterPanel() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Consumer<MockWorkshopProvider>(
          builder: (context, provider, child) {
            final availableTags = provider.getAvailableTags();
            final priceRange = provider.getPriceRange();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '필터',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                
                // Price range filter
                if (priceRange != null) ...[
                  Text(
                    '가격 범위',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text('₩${priceRange.min.toInt()} - ₩${priceRange.max.toInt()}'),
                  const SizedBox(height: AppTheme.spacingLg),
                ],
                
                // Tags filter
                if (availableTags.isNotEmpty) ...[
                  Text(
                    '태그',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Wrap(
                    spacing: AppTheme.spacingSm,
                    runSpacing: AppTheme.spacingSm,
                    children: availableTags.map((tag) => FilterChip(
                      label: Text(tag),
                      selected: false,
                      onSelected: (selected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$tag 필터 선택됨')),
                        );
                      },
                    )).toList(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build workshop list
  Widget _buildWorkshopList() {
    return Consumer<MockWorkshopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.workshops.isEmpty) {
          return const Center(child: LoadingWidget());
        }

        if (provider.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  '워크샵이 없습니다',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  '다른 검색어나 필터를 시도해보세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter workshops based on search
        final filteredWorkshops = provider.workshops.where((workshop) {
          if (_searchController.text.isEmpty) return true;
          final query = _searchController.text.toLowerCase();
          return workshop.title.toLowerCase().contains(query) ||
                 workshop.description.toLowerCase().contains(query);
        }).toList();

        return RefreshIndicator(
          onRefresh: () => provider.refreshWorkshops(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: filteredWorkshops.length,
            itemBuilder: (context, index) {
              final workshop = filteredWorkshops[index];
              return _buildWorkshopCard(workshop);
            },
          ),
        );
      },
    );
  }

  /// Build workshop card
  Widget _buildWorkshopCard(MockWorkshop workshop) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: InkWell(
        onTap: () => _navigateToWorkshopDetail(workshop),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workshop image placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.business_center,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              // Workshop title
              Text(
                workshop.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              
              // Workshop description
              Text(
                workshop.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              // Workshop details
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    workshop.formattedPrice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.people,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '최대 ${workshop.capacity}명',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              
              // Workshop tags
              if (workshop.tags.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Wrap(
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingSm,
                  children: workshop.tags.take(3).map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build floating action button for admin users
  Widget? _buildFloatingActionButton() {
    return Consumer<MockAuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAdmin) return const SizedBox.shrink();
        
        return FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('워크샵 생성 기능은 향후 구현 예정입니다'),
              ),
            );
          },
          child: const Icon(Icons.add),
        );
      },
    );
  }

  /// Navigate to workshop detail
  void _navigateToWorkshopDetail(MockWorkshop workshop) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${workshop.title} 상세 화면으로 이동'),
        action: SnackBarAction(
          label: '확인',
          onPressed: () {},
        ),
      ),
    );
  }
}