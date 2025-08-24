import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workshop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/workshop.dart';
import 'workshop_detail_screen.dart';
import 'workshop_filter_screen.dart';

/// Workshop list screen with search and filtering capabilities
/// 
/// Displays a list of workshops with infinite scroll, search functionality,
/// and filtering options. Supports both mobile and desktop layouts.
class WorkshopListScreen extends StatefulWidget {
  final bool showSearchBar;
  
  const WorkshopListScreen({
    super.key,
    this.showSearchBar = false,
  });

  @override
  State<WorkshopListScreen> createState() => _WorkshopListScreenState();
}

class _WorkshopListScreenState extends State<WorkshopListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _showSearch = widget.showSearchBar;
    _setupScrollListener();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Setup scroll listener for infinite scroll
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        // Load more when near bottom
        context.read<WorkshopProvider>().loadMoreWorkshops();
      }
    });
  }

  /// Load initial workshop data
  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkshopProvider>().loadWorkshops(refresh: true);
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
          _buildFilterChips(),
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
          onPressed: _showFilterDialog,
        ),
        Consumer<WorkshopProvider>(
          builder: (context, provider, child) {
            if (provider.currentFilter.hasFilters) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  provider.clearFilters();
                },
                tooltip: '필터 초기화',
              );
            }
            return const SizedBox.shrink();
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
                    context.read<WorkshopProvider>().searchWorkshops('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (query) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == query) {
              context.read<WorkshopProvider>().searchWorkshops(query);
            }
          });
        },
        onSubmitted: (query) {
          context.read<WorkshopProvider>().searchWorkshops(query);
        },
      ),
    );
  }

  /// Build filter chips for mobile
  Widget _buildFilterChips() {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        final filter = provider.currentFilter;
        final chips = <Widget>[];

        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          chips.add(_buildFilterChip(
            label: '검색: ${filter.searchQuery}',
            onDeleted: () {
              _searchController.clear();
              provider.searchWorkshops('');
            },
          ));
        }

        if (filter.minPrice != null || filter.maxPrice != null) {
          final priceText = _getPriceRangeText(filter.minPrice, filter.maxPrice);
          chips.add(_buildFilterChip(
            label: '가격: $priceText',
            onDeleted: () {
              final newFilter = filter.copyWith(
                minPrice: null,
                maxPrice: null,
              );
              provider.applyFilter(newFilter);
            },
          ));
        }

        if (filter.tags != null && filter.tags!.isNotEmpty) {
          for (final tag in filter.tags!) {
            chips.add(_buildFilterChip(
              label: '#$tag',
              onDeleted: () {
                final newTags = List<String>.from(filter.tags!)..remove(tag);
                final newFilter = filter.copyWith(tags: newTags.isEmpty ? null : newTags);
                provider.applyFilter(newFilter);
              },
            ));
          }
        }

        if (chips.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Wrap(
            spacing: AppTheme.spacingSm,
            children: chips,
          ),
        );
      },
    );
  }

  /// Build filter chip
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  /// Build filter panel for tablet/desktop
  Widget _buildFilterPanel() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Consumer<WorkshopProvider>(
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
                  _buildPriceRangeFilter(priceRange.min, priceRange.max),
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
                  _buildTagsFilter(availableTags),
                  const SizedBox(height: AppTheme.spacingLg),
                ],
                
                // Clear filters button
                if (provider.currentFilter.hasFilters)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        provider.clearFilters();
                        _searchController.clear();
                      },
                      child: const Text('모든 필터 초기화'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build price range filter
  Widget _buildPriceRangeFilter(double minPrice, double maxPrice) {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        final filter = provider.currentFilter;
        final currentMin = filter.minPrice ?? minPrice;
        final currentMax = filter.maxPrice ?? maxPrice;
        
        return Column(
          children: [
            RangeSlider(
              values: RangeValues(currentMin, currentMax),
              min: minPrice,
              max: maxPrice,
              divisions: 20,
              labels: RangeLabels(
                '${currentMin.toInt()}원',
                '${currentMax.toInt()}원',
              ),
              onChanged: (values) {
                final newFilter = filter.copyWith(
                  minPrice: values.start,
                  maxPrice: values.end,
                );
                provider.applyFilter(newFilter);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${currentMin.toInt()}원'),
                Text('${currentMax.toInt()}원'),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Build tags filter
  Widget _buildTagsFilter(List<String> availableTags) {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        final selectedTags = provider.currentFilter.tags ?? [];
        
        return Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                final newTags = List<String>.from(selectedTags);
                if (selected) {
                  newTags.add(tag);
                } else {
                  newTags.remove(tag);
                }
                
                final newFilter = provider.currentFilter.copyWith(
                  tags: newTags.isEmpty ? null : newTags,
                );
                provider.applyFilter(newFilter);
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// Build workshop list
  Widget _buildWorkshopList() {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.workshops.isEmpty) {
          return const Center(child: LoadingWidget());
        }

        if (provider.errorMessage != null && provider.workshops.isEmpty) {
          return Center(
            child: AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.loadWorkshops(refresh: true),
            ),
          );
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

        return RefreshIndicator(
          onRefresh: () => provider.refreshWorkshops(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: provider.workshops.length + (provider.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.workshops.length) {
                // Loading indicator for pagination
                return const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingMd),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final workshop = provider.workshops[index];
              return _buildWorkshopCard(workshop);
            },
          ),
        );
      },
    );
  }

  /// Build workshop card
  Widget _buildWorkshopCard(Workshop workshop) {
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
                child: workshop.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          workshop.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
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

  /// Build image placeholder
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.business_center,
        size: 48,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  /// Build floating action button for admin users
  Widget? _buildFloatingActionButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAdmin) return null;
        
        return FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create workshop screen
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

  /// Show filter dialog for mobile
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const WorkshopFilterScreen(),
    );
  }

  /// Navigate to workshop detail
  void _navigateToWorkshopDetail(Workshop workshop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkshopDetailScreen(workshop: workshop),
      ),
    );
  }

  /// Get price range text
  String _getPriceRangeText(double? minPrice, double? maxPrice) {
    if (minPrice != null && maxPrice != null) {
      return '${minPrice.toInt()}원 - ${maxPrice.toInt()}원';
    } else if (minPrice != null) {
      return '${minPrice.toInt()}원 이상';
    } else if (maxPrice != null) {
      return '${maxPrice.toInt()}원 이하';
    }
    return '';
  }
}