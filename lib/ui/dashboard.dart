import 'package:flutter/material.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/main.dart';
import 'package:salonapp/ui/common/drawer_dashboard.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Color(COLOR_PRIMARY);
    final user = MyAppState.currentUser;
    final salonName = user?.salonname ?? 'Salon';
    final username = user?.username ?? 'Guest';
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final actions = <_DashboardAction>[
      const _DashboardAction(
        title: 'Appointment',
        icon: Icons.event_outlined,
        route: '/booking',
      ),
      const _DashboardAction(
        title: 'Go Sale',
        icon: Icons.point_of_sale_outlined,
        route: '/pos',
      ),
      const _DashboardAction(
        title: 'Go Check-in',
        icon: Icons.login_rounded,
        route: '/checkin',
      ),
      const _DashboardAction(
        title: 'Go Check-out',
        icon: Icons.logout_rounded,
        route: '/checkout',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const AppDrawerDashboard(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.10),
              const Color(0xFFF4F6FA),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.store_mall_directory_outlined,
                          color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $salonName',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'User: $username',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                itemCount: actions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 4 : 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: isTablet ? 1.3 : 1.08,
                ),
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildDashboardButton(
                    context,
                    action.title,
                    action.icon,
                    color,
                    action.route,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: color,
        child: SizedBox(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  safePushReplacementNamed(context, '/booking');
                },
                icon: const Icon(Icons.event, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  safePushReplacementNamed(context, '/pos');
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  safePushReplacementNamed(context, '/checkin');
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  safePushReplacementNamed(context, '/checkout');
                },
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title,
      IconData icon, Color color, String route) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Navigator.push( context, MaterialPageRoute(builder: (context) => screen));
          safePushReplacementNamed(context, route);
        },
        child: Card(
          elevation: 3,
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardAction {
  final String title;
  final IconData icon;
  final String route;

  const _DashboardAction({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        backgroundColor: Colors.blue, // Set app bar color
      ),
      body: const Center(
        child: Text('Check-in Screen'),
      ),
    );
  }
}

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-out'),
        backgroundColor: Colors.blue, // Set app bar color
      ),
      body: const Center(
        child: Text('Check-out Screen'),
      ),
    );
  }
}
