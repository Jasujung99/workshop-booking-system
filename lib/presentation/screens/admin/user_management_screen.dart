import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/payment_info.dart';
import '../../theme/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  UserRole? _roleFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadUsers(),
          );
        }

        return Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: _buildUserList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.error != null) {
          return AppErrorWidget(
            message: provider.error!,
            onRetry: () => provider.loadUsers(),
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(
                    child: _buildUserList(provider),
                  ),
                ],
              ),
            ),
            if (provider.selectedUser != null)
              Expanded(
                flex: 1,
                child: _buildUserDetail(provider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout(); // Same as tablet for now
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: '사용자 검색...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UserRole?>(
                  value: _roleFilter,
                  decoration: const InputDecoration(
                    labelText: '권한 필터',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<UserRole?>(
                      value: null,
                      child: Text('전체'),
                    ),
                    ...UserRole.values.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _roleFilter = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(UserManagementProvider provider) {
    final filteredUsers = _getFilteredUsers(provider.users);

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('사용자가 없습니다.'),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user, provider);
      },
    );
  }

  Widget _buildUserCard(User user, UserManagementProvider provider) {
    final isSelected = provider.selectedUser?.id == user.id;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U')
              : null,
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(user.role),
                const SizedBox(width: 8),
                Text(
                  '가입일: ${_formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user, provider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_bookings',
              child: Text('예약 내역 보기'),
            ),
            const PopupMenuItem(
              value: 'change_role',
              child: Text('권한 변경'),
            ),
          ],
        ),
        onTap: () {
          provider.selectUser(user);
          provider.loadUserBookings(user.id);
        },
      ),
    );
  }

  Widget _buildUserDetail(UserManagementProvider provider) {
    final user = provider.selectedUser!;
    final bookings = provider.getUserBookingsList(user.id);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사용자 상세 정보',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildUserInfo(user),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            '예약 내역',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Expanded(
            child: _buildBookingsList(bookings, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('이름', user.name),
            _buildInfoRow('이메일', user.email),
            _buildInfoRow('전화번호', user.phoneNumber ?? '미등록'),
            _buildInfoRow('권한', _getRoleDisplayName(user.role)),
            _buildInfoRow('가입일', _formatDate(user.createdAt)),
            if (user.updatedAt != null)
              _buildInfoRow('수정일', _formatDate(user.updatedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, UserManagementProvider provider) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text('예약 내역이 없습니다.'),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, provider);
      },
    );
  }

  Widget _buildBookingCard(Booking booking, UserManagementProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${booking.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text('예약 타입: ${_getBookingTypeDisplayName(booking.type)}'),
            Text('총 금액: ₩${booking.totalAmount.toStringAsFixed(0)}'),
            Text('예약일: ${_formatDate(booking.createdAt)}'),
            if (booking.paymentInfo != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text('결제 상태: ${_getPaymentStatusDisplayName(booking.paymentInfo!.status)}'),
            ],
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (booking.status == BookingStatus.confirmed)
                  TextButton(
                    onPressed: () => _showStatusChangeDialog(booking, provider),
                    child: const Text('상태 변경'),
                  ),
                if (booking.paymentInfo != null && 
                    booking.paymentInfo!.status == PaymentStatus.completed)
                  TextButton(
                    onPressed: () => _showRefundDialog(booking, provider),
                    child: const Text('환불 처리'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    return Chip(
      label: Text(_getRoleDisplayName(role)),
      backgroundColor: role == UserRole.admin
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color backgroundColor;
    switch (status) {
      case BookingStatus.pending:
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        break;
      case BookingStatus.confirmed:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        break;
      case BookingStatus.completed:
        backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
        break;
      case BookingStatus.cancelled:
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        break;
      case BookingStatus.noShow:
        backgroundColor = Theme.of(context).colorScheme.outline.withOpacity(0.2);
        break;
    }

    return Chip(
      label: Text(_getBookingStatusDisplayName(status)),
      backgroundColor: backgroundColor,
    );
  }

  List<User> _getFilteredUsers(List<User> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesRole = _roleFilter == null || user.role == _roleFilter;
      
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _handleUserAction(String action, User user, UserManagementProvider provider) {
    switch (action) {
      case 'view_bookings':
        provider.selectUser(user);
        provider.loadUserBookings(user.id);
        break;
      case 'change_role':
        _showRoleChangeDialog(user, provider);
        break;
    }
  }

  void _showRoleChangeDialog(User user, UserManagementProvider provider) {
    UserRole? selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.name}의 권한 변경'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) => RadioListTile<UserRole>(
              title: Text(_getRoleDisplayName(role)),
              value: role,
              groupValue: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: selectedRole != null && selectedRole != user.role
                ? () async {
                    Navigator.of(context).pop();
                    final success = await provider.updateUserRole(user.id, selectedRole!);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('권한이 변경되었습니다.')),
                      );
                    }
                  }
                : null,
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(Booking booking, UserManagementProvider provider) {
    BookingStatus? selectedStatus = booking.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 상태 변경'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: BookingStatus.values.map((status) => RadioListTile<BookingStatus>(
              title: Text(_getBookingStatusDisplayName(status)),
              value: status,
              groupValue: selectedStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: selectedStatus != null && selectedStatus != booking.status
                ? () async {
                    Navigator.of(context).pop();
                    final success = await provider.updateBookingStatus(booking.id, selectedStatus!);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('예약 상태가 변경되었습니다.')),
                      );
                    }
                  }
                : null,
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(Booking booking, UserManagementProvider provider) {
    final refundController = TextEditingController(
      text: booking.totalAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('환불 처리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('총 결제 금액: ₩${booking.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: refundController,
              decoration: const InputDecoration(
                labelText: '환불 금액',
                prefixText: '₩',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final refundAmount = double.tryParse(refundController.text);
              if (refundAmount != null && refundAmount > 0) {
                Navigator.of(context).pop();
                final success = await provider.processRefund(
                  booking.paymentInfo!.paymentId,
                  refundAmount,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('환불이 처리되었습니다.')),
                  );
                }
              }
            },
            child: const Text('환불'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.user:
        return '일반 사용자';
      case UserRole.admin:
        return '관리자';
    }
  }

  String _getBookingStatusDisplayName(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return '대기중';
      case BookingStatus.confirmed:
        return '확정';
      case BookingStatus.completed:
        return '완료';
      case BookingStatus.cancelled:
        return '취소';
      case BookingStatus.noShow:
        return '노쇼';
    }
  }

  String _getBookingTypeDisplayName(BookingType type) {
    switch (type) {
      case BookingType.workshop:
        return '워크샵';
      case BookingType.space:
        return '공간 대관';
    }
  }

  String _getPaymentStatusDisplayName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return '결제 대기';
      case PaymentStatus.processing:
        return '결제 처리중';
      case PaymentStatus.completed:
        return '결제 완료';
      case PaymentStatus.failed:
        return '결제 실패';
      case PaymentStatus.cancelled:
        return '결제 취소';
      case PaymentStatus.refunded:
        return '환불 완료';
      case PaymentStatus.partiallyRefunded:
        return '부분 환불';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}