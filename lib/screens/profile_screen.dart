import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 화면으로 이동 (나중에 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 기능은 아직 준비중입니다.')),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? _buildNotLoggedIn(context)
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 프로필 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            user.profileImage.isNotEmpty 
                                ? user.profileImage 
                                : 'https://via.placeholder.com/150',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatColumn('저장한 여행', user.savedTrips.length.toString()),
                            const SizedBox(width: 40),
                            _buildStatColumn('작성한 리뷰', user.reviewedTrips.length.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 섹션 목록
                  _buildSection(
                    context,
                    '저장한 여행',
                    Icons.favorite,
                    () {
                      // 저장한 여행 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('저장한 여행 기능은 아직 준비중입니다.')),
                      );
                    },
                  ),
                  _buildSection(
                    context,
                    '방문 기록',
                    Icons.history,
                    () {
                      // 방문 기록 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('방문 기록 기능은 아직 준비중입니다.')),
                      );
                    },
                  ),
                  _buildSection(
                    context,
                    '내 리뷰',
                    Icons.rate_review,
                    () {
                      // 내 리뷰 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('내 리뷰 기능은 아직 준비중입니다.')),
                      );
                    },
                  ),
                  _buildSection(
                    context,
                    '알림 설정',
                    Icons.notifications,
                    () {
                      // 알림 설정 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 설정 기능은 아직 준비중입니다.')),
                      );
                    },
                  ),
                  _buildSection(
                    context,
                    '친구 초대',
                    Icons.people,
                    () {
                      // 친구 초대 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('친구 초대 기능은 아직 준비중입니다.')),
                      );
                    },
                  ),
                  _buildSection(
                    context,
                    '로그아웃',
                    Icons.exit_to_app,
                    () async {
                      // 로그아웃 기능
                      final confirmed = await _showLogoutDialog(context);
                      if (confirmed && context.mounted) {
                        await authProvider.logout();
                        // 로그인 화면으로 이동
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.routeName, 
                          (route) => false
                        );
                      }
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '로그인이 필요합니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '로그인하여 여행 코스를 저장하고 관리하세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(LoginScreen.routeName);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('로그인하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 70,
          ),
      ],
    );
  }
  
  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    ) ?? false;
  }
}