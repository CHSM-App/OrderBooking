import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}


class NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<NotificationItem> notifications = [
    NotificationItem(
      icon: Icons.shopping_bag_rounded,
      iconColor: Colors.blue,
      title: "Region Assigned",
      description: "Employee John Doe has received a new order #1234.",
      time: "2h ago",
      isUnread: true,
    ),
    NotificationItem(
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      title: "Order Completed",
      description: "Order #1230 has been successfully delivered.",
      time: "5h ago",
      isUnread: true,
    ),
    NotificationItem(
      icon: Icons.person_add_rounded,
      iconColor: Colors.purple,
      title: "New Employee Added",
      description: "Sarah Smith joined as a field executive.",
      time: "1d ago",
      isUnread: false,
    ),
    NotificationItem(
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      title: "Low Stock Alert",
      description: "Product XYZ is running low in inventory.",
      time: "2d ago",
      isUnread: false,
    ),
    NotificationItem(
      icon: Icons.info_rounded,
      iconColor: Colors.cyan,
      title: "System Update",
      description: "App has been updated to version 2.1.0.",
      time: "3d ago",
      isUnread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6F00),
         iconTheme: const IconThemeData(color: Colors.white),
         centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
              },
              child: const Text(
                "Clear",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),

      // 🔔 NOTIFICATION LIST ONLY
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _AnimatedNotificationCard(
                  notification: notifications[index],
                  delay: index * 100,
                  onTap: () {
                    setState(() {
                      notifications[index].isUnread = false;
                    });
                  },
                );
              },
            ),
    );
  }
}

// 🔹 NOTIFICATION DATA MODEL
class NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;
  bool isUnread;

  NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
  });
}

// 🔹 ANIMATED NOTIFICATION CARD
class _AnimatedNotificationCard extends StatefulWidget {
  final NotificationItem notification;
  final int delay;
  final VoidCallback onTap;

  const _AnimatedNotificationCard({
    required this.notification,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<_AnimatedNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: n.isUnread ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: n.isUnread
                ? Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: n.iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(n.icon, color: n.iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (n.isUnread)
                              const CircleAvatar(
                                radius: 4,
                                backgroundColor: Color(0xFF2196F3),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              n.time,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
