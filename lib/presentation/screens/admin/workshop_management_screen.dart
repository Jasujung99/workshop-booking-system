import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workshop_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/workshop.dart';
import '../../../core/utils/date_formatter.dart';
import 'workshop_form_screen.dart';

/// Workshop management screen for admin
/// 
/// Allows admin to view, create, edit, and delete workshops
class WorkshopManagementScreen extends StatefulWidget {
  const WorkshopManagementScreen({super.key});

  @override
  State<WorkshopManagementScreen> createState() => _WorkshopManagementScreenState();
}

class _WorkshopManagementScreenState extends State<WorkshopManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkshopProvider>().loadWorkshops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('워크샵 관리'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WorkshopProvider>().refreshWorkshops();
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToWorkshopForm(context),
        icon: const Icon(Icons.add),
        label: const Text('워크샵 추가'),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildWorkshopList()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildWorkshopGrid(crossAxisCount: 2)),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildWorkshopGrid(crossAxisCount: 3)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '워크샵 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    context.read<WorkshopProvider>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          context.read<WorkshopProvider>().searchWorkshops(value);
        },
      ),
    );
  }

  Widget _buildWorkshopList() {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.workshops.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.errorMessage != null) {
          return AppErrorWidget(
            message: provider.errorMessage!,
            onRetry: () => provider.refreshWorkshops(),
          );
        }

        if (provider.workshops.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshWorkshops(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.workshops.length,
            itemBuilder: (context, index) {
              final workshop = provider.workshops[index];
              return _buildWorkshopCard(workshop);
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkshopGrid({required int crossAxisCount}) {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.workshops.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.errorMessage != null) {
          return AppErrorWidget(
            message: provider.errorMessage!,
            onRetry: () => provider.refreshWorkshops(),
          );
        }

        if (provider.workshops.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshWorkshops(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: provider.workshops.length,
            itemBuilder: (context, index) {
              final workshop = provider.workshops[index];
              return _buildWorkshopGridCard(workshop);
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkshopCard(Workshop workshop) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToWorkshopForm(context, workshop: workshop),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Workshop image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: workshop.imageUrl != null
                    ? Image.network(
                        workshop.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder(80);
                        },
                      )
                    : _buildImagePlaceholder(80),
              ),
              const SizedBox(width: 16),
              // Workshop info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workshop.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        Text(
                          DateFormatter.formatCurrency(workshop.price),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workshop.capacity}명',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, workshop),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopGridCard(Workshop workshop) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: () => _navigateToWorkshopForm(context, workshop: workshop),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: workshop.imageUrl != null
                      ? Image.network(
                          workshop.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(double.infinity);
                          },
                        )
                      : _buildImagePlaceholder(double.infinity),
                ),
              ),
            ),
            // Workshop info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workshop.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormatter.formatCurrency(workshop.price),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleMenuAction(value, workshop),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('수정'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('삭제', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size == double.infinity ? null : size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? '검색 결과가 없습니다' : '등록된 워크샵이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? '다른 검색어를 시도해보세요'
                : '새로운 워크샵을 추가해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToWorkshopForm(context),
              icon: const Icon(Icons.add),
              label: const Text('워크샵 추가'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Workshop workshop) {
    switch (action) {
      case 'edit':
        _navigateToWorkshopForm(context, workshop: workshop);
        break;
      case 'delete':
        _showDeleteConfirmation(workshop);
        break;
    }
  }

  void _navigateToWorkshopForm(BuildContext context, {Workshop? workshop}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkshopFormScreen(workshop: workshop),
      ),
    );
  }

  void _showDeleteConfirmation(Workshop workshop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('워크샵 삭제'),
        content: Text('${workshop.title} 워크샵을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWorkshop(workshop);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _deleteWorkshop(Workshop workshop) async {
    final provider = context.read<WorkshopProvider>();
    final success = await provider.deleteWorkshop(workshop.id);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('워크샵이 삭제되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '워크샵 삭제에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}