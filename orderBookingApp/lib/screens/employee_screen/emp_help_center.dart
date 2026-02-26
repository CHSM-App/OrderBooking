import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmployeeHelpCenterPage extends StatefulWidget {
  const EmployeeHelpCenterPage({super.key});

  @override
  State<EmployeeHelpCenterPage> createState() => _EmployeeHelpCenterPageState();
}

class _EmployeeHelpCenterPageState extends State<EmployeeHelpCenterPage> {
  // Brand colors matching Retail Pulse
  static const Color _orange = Color(0xFFE8701A);
  static const Color _orangeLight = Color(0xFFFFF3E8);
  static const Color _ink = Color(0xFF0F1117);
  static const Color _inkSoft = Color(0xFF3B3F4D);
  static const Color _inkMuted = Color(0xFF7A7F90);
  static const Color _border = Color(0xFFE2E5ED);
  static const Color _bg = Color(0xFFF7F8FC);
  static const Color _white = Colors.white;

  int? _expandedCategory;
  int? _expandedFaq;

  final List<_HelpCategory> _categories = [
    _HelpCategory(
      icon: Icons.login_rounded,
      title: 'Check In',
      color: const Color(0xFF1A56DB),
      colorLight: const Color(0xFFE8EFFE),
      faqs: [
        _Faq(
          question: 'How do I check in at the start of my day?',
          answer:
              'Open Retail Pulse and tap the "Check In" button on your home screen. The app will automatically capture your current GPS location at that moment and record it as your start-of-day location. Make sure your location permission is enabled before checking in.',
        ),
        _Faq(
          question: 'What if my location is not accurate during check-in?',
          answer:
              'Step outside or move to an open area with a clear view of the sky for better GPS accuracy. Make sure your phone\'s GPS/Location is turned ON and set to "High Accuracy" mode in your device settings. Wait a few seconds for the GPS signal to stabilise before tapping Check In.',
        ),
        _Faq(
          question: 'Can I check in without internet?',
          answer:
              'No. An active internet connection is required to check in, as your location and timestamp are sent to the server immediately. Connect to mobile data or Wi-Fi before checking in.',
        ),
        _Faq(
          question: 'What does my admin see when I check in?',
          answer:
              'Your admin can see your check-in time and the exact GPS location where you checked in. They can view this on a map. No other information is captured at check-in.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.storefront_rounded,
      title: 'Adding a Shop',
      color: const Color(0xFF0E9F6E),
      colorLight: const Color(0xFFE3FCEF),
      faqs: [
        _Faq(
          question: 'How do I add a new shop?',
          answer:
              'From the home screen, tap "Add Shop". Fill in the shop details — shop name, owner name, phone number, and address. Tap Save. Note: Adding a shop does not capture your location. Location is only recorded when you punch into a shop visit.',
        ),
        _Faq(
          question: 'Can I edit a shop after adding it?',
          answer:
              'Yes. Go to your shop list, find the shop you want to update, tap on it, and select Edit. Make your changes and tap Save.',
        ),
        _Faq(
          question: 'Is my location captured when I add a shop?',
          answer:
              'No. Your GPS location is NOT captured when you create or add a shop. Location is only captured when you tap on an existing shop to start a visit (punch in).',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.place_rounded,
      title: 'Shop Visit & Punch In',
      color: const Color(0xFFE8701A),
      colorLight: const Color(0xFFFFF3E8),
      faqs: [
        _Faq(
          question: 'How do I punch into a shop visit?',
          answer:
              'Go to your shop list and tap on the shop you are currently visiting. The app will capture your current GPS location at that moment and record it as your visit location for that shop. Make sure you are physically at the shop before tapping.',
        ),
        _Faq(
          question: 'Why does the app need my location when I visit a shop?',
          answer:
              'Your GPS location is recorded when you punch into a shop visit to verify that you were physically present at or near the shop. Your admin uses this to track your daily field route and confirm shop visits.',
        ),
        _Faq(
          question: 'What if I accidentally punch into the wrong shop?',
          answer:
              'Contact your admin to inform them. They can view and note the discrepancy. Currently, punch-in entries cannot be deleted by the employee — your admin manages corrections.',
        ),
        _Faq(
          question: 'Can I visit multiple shops in a day?',
          answer:
              'Yes! You can visit as many shops as needed in a single day. Each shop you tap on will record its own punch-in location separately. All visits will appear in your daily route visible to your admin.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.receipt_long_rounded,
      title: 'Taking Orders',
      color: const Color(0xFF7E3AF2),
      colorLight: const Color(0xFFF3EEFF),
      faqs: [
        _Faq(
          question: 'How do I take an order from a shop?',
          answer:
              'After punching into a shop, tap "Take Order". Browse the product list added by your admin, enter the quantity for each product the shop wants to order, and tap Submit Order. The order will be saved and visible to your admin.',
        ),
        _Faq(
          question: 'Can I take an order without punching into the shop first?',
          answer:
              'You need to tap on the shop (which records your punch-in location) before placing an order for that shop. This ensures all orders are associated with a verified shop visit.',
        ),
        _Faq(
          question: 'Can I edit an order after submitting it?',
          answer:
              'Once an order is submitted, contact your admin if you need to make changes. Admins have the ability to view, edit, and manage all orders.',
        ),
        _Faq(
          question: 'What products can I order from?',
          answer:
              'You can only order from the products your admin has added to the company catalogue. If a product is missing, ask your admin to add it.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.logout_rounded,
      title: 'Check Out',
      color: const Color(0xFFE02424),
      colorLight: const Color(0xFFFDE8E8),
      faqs: [
        _Faq(
          question: 'How do I check out at the end of my day?',
          answer:
              'From your home screen, tap the "Check Out" button. The app will capture your current GPS location and record it as your end-of-day location. Always check out before closing the app for the day.',
        ),
        _Faq(
          question: 'What if I forgot to check out yesterday?',
          answer:
              'If you forgot to check out, inform your admin. Admins can see that a check-out was not recorded and can note this in the attendance records. You cannot check out for a previous day.',
        ),
        _Faq(
          question: 'Can I check out before visiting all my shops?',
          answer:
              'Yes, you can check out at any time. However, once you check out, your workday is considered complete. Make sure you have finished all your shop visits and orders before checking out.',
        ),
        _Faq(
          question: 'What does my admin see at check-out?',
          answer:
              'Your admin sees your check-out time and GPS location. Combined with your check-in and shop visit locations, they can view your complete daily route on a map.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.privacy_tip_rounded,
      title: 'Privacy & Location',
      color: const Color(0xFF057A55),
      colorLight: const Color(0xFFDEF7EC),
      faqs: [
        _Faq(
          question: 'When exactly is my location captured?',
          answer:
              'Your location is captured at exactly three points:\n\n1. When you Check In (start of day)\n2. When you tap on a shop to start a visit (punch in)\n3. When you Check Out (end of day)\n\nThe app does NOT track your location continuously or in the background.',
        ),
        _Faq(
          question: 'Does the app track me in the background?',
          answer:
              'No. Retail Pulse does not run location tracking in the background. Your GPS is accessed only at the three specific moments listed above. You are always in control — the location is captured only when you perform an action in the app.',
        ),
        _Faq(
          question: 'Who can see my location data?',
          answer:
              'Only the admin of your company can see your location data. Your location is not shared with any other employees or external parties. It is used solely for verifying your daily field activity.',
        ),
        _Faq(
          question: 'Can I request my data to be deleted?',
          answer:
              'Yes. You have the right to request deletion of your personal data. Contact your admin or reach out to us directly at privacy@vengurlatech.com and we will process your request within 30 days.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.build_rounded,
      title: 'Troubleshooting',
      color: const Color(0xFF1A56DB),
      colorLight: const Color(0xFFE8EFFE),
      faqs: [
        _Faq(
          question: 'The app says "Location permission denied". What do I do?',
          answer:
              'Go to your phone\'s Settings → Apps → Retail Pulse → Permissions → Location. Set it to "Allow only while using the app". Then return to Retail Pulse and try again.',
        ),
        _Faq(
          question: 'The app is not loading or keeps crashing.',
          answer:
              'Try these steps in order:\n1. Close the app completely and reopen it\n2. Check your internet connection\n3. Restart your phone\n4. Uninstall and reinstall the app\n\nIf the problem continues, contact your admin or our support team.',
        ),
        _Faq(
          question: 'I can\'t log in. What should I do?',
          answer:
              'Make sure you are entering the correct phone number and password. If you have forgotten your password, contact your admin — they can reset your access. Employees cannot reset passwords independently.',
        ),
        _Faq(
          question: 'My check-in / check-out button is greyed out.',
          answer:
              'This usually means you have already checked in or checked out for the day, or your location permission is disabled. Check your location settings and try again. If the issue persists, contact your admin.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeroCard()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryCard(index),
                childCount: _categories.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildContactCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: _white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: _border,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: _ink,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text(
                'RP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Help Center',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _orangeLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Employee Guide',
            style: TextStyle(
              color: _orange,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8701A), Color(0xFFF59638)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How can we help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find answers to common questions below',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickChip(Icons.login_rounded, 'Check In'),
              _buildQuickChip(Icons.place_rounded, 'Shop Visit'),
              _buildQuickChip(Icons.receipt_long_rounded, 'Orders'),
              _buildQuickChip(Icons.logout_rounded, 'Check Out'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(int categoryIndex) {
    final category = _categories[categoryIndex];
    final isExpanded = _expandedCategory == categoryIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? category.color.withOpacity(0.3) : _border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: category.color.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Category header
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _expandedCategory =
                    isExpanded ? null : categoryIndex;
                _expandedFaq = null;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: category.colorLight,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${category.faqs.length} articles',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _inkMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? category.color : _inkMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FAQ List
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                Divider(height: 1, color: _border),
                ...List.generate(
                  category.faqs.length,
                  (faqIndex) => _buildFaqItem(
                    categoryIndex,
                    faqIndex,
                    category.faqs[faqIndex],
                    category.color,
                    category.colorLight,
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    int categoryIndex,
    int faqIndex,
    _Faq faq,
    Color color,
    Color colorLight,
  ) {
    final key = categoryIndex * 100 + faqIndex;
    final isExpanded = _expandedFaq == key;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedFaq = isExpanded ? null : key;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isExpanded ? color : colorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.remove_rounded
                        : Icons.add_rounded,
                    color: isExpanded ? Colors.white : color,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.question,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isExpanded ? color : _inkSoft,
                          letterSpacing: -0.1,
                          height: 1.4,
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            faq.answer,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _inkSoft,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (faqIndex < _categories[categoryIndex].faqs.length - 1)
          Divider(
            height: 1,
            indent: 48,
            color: _border,
          ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Still need help?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'If you couldn\'t find your answer here, our support team is ready to help you.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
 GestureDetector(
            onLongPress: () async {
              await Clipboard.setData(
                const ClipboardData(text: 'support@vengurlatech.com'),
              );
              if (!mounted) return;

            },
            child: const Text(
              'support@vengurlatech.com',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
          // const SizedBox(height: 14),
          // GestureDetector(
          //   onTap: () {
          //     // Use url_launcher package:
          //     // launchUrl(Uri.parse('mailto:support@vengurlatech.com'));
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(vertical: 13),
          //     decoration: BoxDecoration(
          //       color: _orange,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Icons.mail_outline_rounded, color: Colors.white, size: 16),
          //         SizedBox(width: 8),
          //         Text(
          //           'Send us an Email',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 13,
          //             fontWeight: FontWeight.w700,
          //             letterSpacing: 0.1,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }


}

// ── Data Models ──────────────────────────────────────────

class _HelpCategory {
  final IconData icon;
  final String title;
  final Color color;
  final Color colorLight;
  final List<_Faq> faqs;

  const _HelpCategory({
    required this.icon,
    required this.title,
    required this.color,
    required this.colorLight,
    required this.faqs,
  });
}

class _Faq {
  final String question;
  final String answer;

  const _Faq({required this.question, required this.answer});
}