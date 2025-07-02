import 'package:flutter/material.dart';
import 'package:platia/presentation/admin/screens/users/user_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/data/models/user.dart';
import 'package:platia/data/models/user_role.dart';
import 'package:platia/domain/providers/user_provider.dart';
import 'package:platia/presentation/admin/screens/users/user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<UserProvider>().loadUsers();
  }

  List<User> _filterUsers(List<User> users, UserRole? role) {
    var filtered = users;

    if (role != null) {
      filtered = filtered.where((user) => user.role == role).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final query = _searchQuery.toLowerCase();
        return user.fullName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.phoneNumber.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final allUsers = userProvider.users;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.userManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tümü (${allUsers.length})'),
            Tab(
              text:
                  'Üyeler (${_filterUsers(allUsers, UserRole.member).length})',
            ),
            Tab(
              text:
                  'Eğitmenler (${_filterUsers(allUsers, UserRole.trainer).length})',
            ),
            Tab(
              text:
                  'Yöneticiler (${_filterUsers(allUsers, UserRole.admin).length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kullanıcı ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // User Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UserList(users: _filterUsers(allUsers, null)),
                _UserList(users: _filterUsers(allUsers, UserRole.member)),
                _UserList(users: _filterUsers(allUsers, UserRole.trainer)),
                _UserList(users: _filterUsers(allUsers, UserRole.admin)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(const UserEditScreen());
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<User> users;

  const _UserList({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'Kullanıcı bulunamadı',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<UserProvider>().loadUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(user.firstName[0].toUpperCase())
                  : null,
            ),
            title: Text(user.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: AppTextStyles.caption.copyWith(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              user.isActive ? Icons.check_circle : Icons.cancel,
              color: user.isActive ? AppColors.success : AppColors.error,
            ),
            onTap: () {
              context.push(UserDetailScreen(userId: user.id));
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.member:
        return AppColors.info;
      case UserRole.trainer:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.warning;
      case UserRole.superAdmin:
        return AppColors.error;
    }
  }
}
