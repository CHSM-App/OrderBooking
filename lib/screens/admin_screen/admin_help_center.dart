import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminHelpCenterPage extends StatefulWidget {
  const AdminHelpCenterPage({super.key});

  @override
  State<AdminHelpCenterPage> createState() => _AdminHelpCenterPageState();
}

class _AdminHelpCenterPageState extends State<AdminHelpCenterPage> {
  // Brand colors matching Retail Pulse
  static const Color _orange = Color(0xFFE8701A);
  static const Color _orangeLight = Color(0xFFFFF3E8);
  static const Color _ink = Color(0xFF1E2A3A);
  static const Color _inkSoft = Color(0xFF3D4F63);
  static const Color _inkMuted = Color(0xFF7A8FA6);
  static const Color _border = Color(0xFFE2E5ED);
  static const Color _bg = Color(0xFFF7F8FC);

  int? _expandedCategory;
  int? _expandedFaq;

  final List<_HelpCategory> _categories = [
    _HelpCategory(
      icon: Icons.business_rounded,
      title: 'Account & Company Setup',
      color: Color(0xFF1A56DB),
      colorLight: Color(0xFFE8EFFE),
      faqs: [
        _Faq(
          question: 'How do I create a company account?',
          answer:
              'Download Retail Pulse and register as an Admin. Fill in your company details:\n\n• Company Name\n• Owner Name\n• Mobile Number\n• Email Address\n• Company Address\n• GSTIN Number\n\nOnce submitted, your company account is created and you can start adding employees and products.',
        ),
        _Faq(
          question: 'Can I edit my company details after registration?',
          answer:
              'Yes. Go to Profile section → Click on edit icon → update your company details → Save changes. You can edit your company details at any time.',
        ),
        _Faq(
          question: 'Can there be more than one admin for a company?',
          answer:
              'Yes. Each company account can have multiple admins. The company Owner can add multiple admins for the company. Excluding the add admins and delete employee, all rights will have to the newly added admins',
        ),
        _Faq(
          question: 'What is the GSTIN used for?',
          answer:
              'The GSTIN (Goods and Services Tax Identification Number) is stored as part of your company profile for identification and business purposes within the app. It is not shared with any external party.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.people_rounded,
      title: 'Managing Employees',
      color: Color(0xFF0E9F6E),
      colorLight: Color(0xFFE3FCEF),
      faqs: [
        _Faq(
          question: 'How do I add a new employee?',
          answer:
              'Go to the Employees section and tap the "+" button. Fill the employee\'s details:\n\n• Full Name\n• Phone Number\n• Address\n• Identity Proof (upload document)\n\nTap Save. The employee will receive login access using their phone number.',
        ),
        _Faq(
          question: 'What identity proof documents can I upload?',
          answer:
              'You can upload any government-issued identity document such as Aadhaar card, PAN card, Voter ID, or Driving Licence. The document is stored securely and is only visible to you as the admin.',
        ),
        _Faq(
          question: 'How do I edit an employee\'s details?',
          answer:
              'Go to Employees → tap the employee you want to edit → tap the Edit icon. Update the required fields and tap Save.',
        ),
        _Faq(
          question: 'How do I delete an employee?',
          answer:
              'Go to Employees → tap the employee → tap Delete icon. Note: Deleting an employee will remove their access to the app. Their past activity records (orders, attendance, location history) will still be retained for your records. It will visible at Profile section → Deleted Employees',
        ),
        _Faq(
          question: 'How many employees can I add?',
          answer:
              'There is no fixed limit on the number of employees you can add under your company account. Add as many field sales employees as your team requires.',
        ),
        _Faq(
          question: 'Can an employee see other employee\'s data?',
          answer:
              'No. Employees can only see their own shops, orders, and activity. Only the admin can view data across all employees.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.inventory_2_rounded,
      title: 'Managing Products',
      color: Color(0xFF7E3AF2),
      colorLight: Color(0xFFF3EEFF),
      faqs: [
        _Faq(
          question: 'How do I add a product?',
          answer:
              'Go to Products section → tap "Add Product". Enter the product name, select type, unit (e.g. kg, litre, piece), unit value and its price. Submit Product. The product will immediately appear in your Product section and all employee\'s Product section.',
        ),
        _Faq(
          question: 'How do I edit or delete a product?',
          answer:
              'Go to Products → tap the edit icon next to product you want to modify → tap Edit to update details, and remove all unit values to delete the product. Deleting a product will not affect past orders that already included it.',
        ),
        _Faq(
          question: 'How many products can I add?',
          answer:
              'You can add as many products as your company carries. There is no upper limit on the product catalogue.',
        ),
        _Faq(
          question: 'Can employees add or edit products?',
          answer:
              'No. Only admins can add, edit, or delete products. Employees can only select from the existing product catalogue when taking orders.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.bar_chart_rounded,
      title: 'Viewing Orders', 
      color: Color(0xFFE8701A),
      colorLight: Color(0xFFFFF3E8),
      faqs: [
        _Faq(
          question: 'How do I view orders placed by my employees?',
          answer:
              'Go to the Orders section. You can view all orders placed across all employees. Each order shows the shop name, products ordered, quantities, and the employee who placed it.',
        ),
        _Faq(
          question: 'Can I filter orders by employee or date?',
          answer:
              'Yes. If you want view employeewise orders then go to "Employees" section and tap on employee for which you want to see orders. If you want to filter orders bt date then use the provided date filters',
        ),
        // _Faq(
        //   question: 'Can I edit or delete an order?',
        //   answer:
        //       'Yes. As admin you can view, edit, and delete any order. Tap on the order and use the Edit or Delete option. Employees cannot edit their submitted orders.',
        // ),
        _Faq(
          question: 'Can I export order data?',
          answer:
              'If you want to print a order then go to Orders → tap on a order to be print → tap on print icon on top',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.calendar_today_rounded,
      title: 'Attendance',
      color: Color(0xFF057A55),
      colorLight: Color(0xFFDEF7EC),
      faqs: [
        _Faq(
          question: 'How do I view employee attendance?',
          answer:
              'Go to the Employees section → tap on employee → tap on Attendance button → You will see all attendance record with their check-in and check-out times for each working day. Tap on the date to see checkin/checkout time',
        ),
        _Faq(
          question: 'What counts as attendance?',
          answer:
              'An employee is marked as present for a day when they perform a Check In through the app. Check-out time is also recorded but is not required for attendance to be marked.',
        ),
        _Faq(
          question: 'What if an employee forgot to check in or check out?',
          answer:
              'If an employee did not check in, they will show as absent for that day. If they checked in but forgot to check out, only the check-in will be recorded and check-out will be blank. You can make a manual note in your own records if needed.',
        ),
        _Faq(
          question: 'Can I view attendance history for past months?',
          answer:
              'Yes. Use the date filter in the Attendance section to view records for any past date or month since the employee was added.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.map_rounded,
      title: 'Employee Location & Routes',
      color: Color(0xFFE02424),
      colorLight: Color(0xFFFDE8E8),
      faqs: [
        _Faq(
          question: 'How do I view an employee\'s location for the day?',
          answer:
              'Go to the Employees section → Tap on view map → Select date. You will see the route of employee for selected date. You can able to see:\n\n• Check-In location (start of day)\n• Shop punch-in locations (each shop visited)\n• Check-Out location (end of day)\n\nThe map will draw a route connecting all these points in order.',
        ),
        _Faq(
          question: 'How is the employee route drawn on the map?',
          answer:
              'The app uses Google Maps Directions API to draw the route between the recorded location points — from check-in, through each shop visit in sequence, to check-out. This gives you a clear visual of the employee\'s daily field route.',
        ),
        _Faq(
          question: 'Is the employee\'s location tracked continuously?',
          answer:
              'No. The app only records location at three specific moments: check-in, each shop punch-in, and check-out. There is no continuous or background GPS tracking between these points.',
        ),
        _Faq(
          question: 'What if an employee\'s location looks incorrect on the map?',
          answer:
              'Location accuracy depends on the employee\'s device GPS signal at the time of the action. Poor GPS signal (indoors, crowded areas) can result in a slightly inaccurate pin. The employee should ensure their GPS is set to High Accuracy mode.',
        ),
        _Faq(
          question: 'Can I view the location of multiple employees at once?',
          answer:
              'Currently, location routes are viewed per employee per day. Select an employee and a date to view their individual route.',
        ),
      ],
    ),
    _HelpCategory(
      icon: Icons.build_rounded,
      title: 'Troubleshooting',
      color: Color(0xFF1A56DB),
      colorLight: Color(0xFFE8EFFE),
      faqs: [
        _Faq(
          question: 'An employee says they can\'t log in. What should I do?',
          answer:
              'Verify that the employee\'s phone number in the system matches the one they are trying to log in with. If the details are correct and they still cannot log in, delete and re-add the employee, or contact our support team.',
        ),
        _Faq(
          question: 'An employee\'s check-in location looks wrong on the map.',
          answer:
              'This is likely a GPS accuracy issue on the employee\'s device. Ask them to enable High Accuracy GPS mode in their phone settings and ensure they are in an open area when checking in.',
        ),
        _Faq(
          question: 'I can\'t see a recently added employee in the list.',
          answer:
              'Pull down to refresh the employee list. If the employee still does not appear, close and reopen the app. If the problem persists, contact support.',
        ),
        _Faq(
          question: 'Orders from a specific employee are not showing up.',
          answer:
              'Check the date filter in the Orders section — make sure it is not set to a specific date that excludes today. If orders are genuinely missing, contact our support team with the employee name and date.',
        ),
        _Faq(
          question: 'The app is slow or crashing.',
          answer:
              'Try these steps:\n1. Close the app fully and reopen it\n2. Check your internet connection\n3. Restart your device\n4. Uninstall and reinstall the app\n\nIf the issue continues, email us at support@vengurlatech.com with details.',
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
      backgroundColor: Colors.white,
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
            'Admin Guide',
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
            color: Color(0xFFE8701A).withOpacity(0.35),
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
                  Icons.admin_panel_settings_rounded,
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
                      'Admin Help Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Everything you need to manage your team',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick topic chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickChip(Icons.people_rounded, 'Employees'),
              _buildQuickChip(Icons.inventory_2_rounded, 'Products'),
              _buildQuickChip(Icons.bar_chart_rounded, 'Orders'),
              _buildQuickChip(Icons.map_rounded, 'Routes'),
              _buildQuickChip(Icons.calendar_today_rounded, 'Attendance'),
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
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
        color: Colors.white,
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
                _expandedCategory = isExpanded ? null : categoryIndex;
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
                          style: const TextStyle(
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
                    isExpanded ? Icons.remove_rounded : Icons.add_rounded,
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
        color: const Color(0xFF1A3558),
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
            'Our support team is available to help you with any account, employee, or technical issue.',
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
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text('Email copied'),
              //     backgroundColor: Color(0xFFE5E7EB),
              //     behavior: SnackBarBehavior.floating,
              //   ),
              // );
            },
            child: const Text(
              'support@vengurlatech.com',
              style: TextStyle(
                color: Color(0xFFF59638),
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
