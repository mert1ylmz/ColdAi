import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import 'browse_pending_page.dart';
import 'leave_pending_page.dart';
import 'my_pending_page.dart';

class PendingPage extends StatefulWidget {
  final Language lang;

  const PendingPage({super.key, required this.lang});

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  bool _isMapExpanded = false;

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFFFF7ED),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              AppTexts.of("pending_title", lang),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.of("pending_subtitle", lang),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),

            // Info Card
            _buildInfoCard(lang),
            const SizedBox(height: 20),

            // Map Card
            _buildMapCard(lang),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionCard(
              icon: Icons.volunteer_activism_rounded,
              title: AppTexts.of("pending_leave_product", lang),
              subtitle: lang == Language.tr
                  ? "Fazla ürünlerini paylaş"
                  : "Share your surplus products",
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF4F46E5)],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeavePendingPage(lang: lang),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.inventory_2_rounded,
              title: AppTexts.of("pending_my_items", lang),
              subtitle: lang == Language.tr
                  ? "Askıya bıraktığın ürünleri gör"
                  : "View your pending items",
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyPendingPage(lang: lang),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.explore_rounded,
              title: AppTexts.of("pending_browse", lang),
              subtitle: lang == Language.tr
                  ? "Yakınındaki askıdaki ürünlere bak"
                  : "Browse pending items near you",
              gradient: const LinearGradient(
                colors: [AppColors.secondary, Color(0xFF059669)],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BrowsePendingPage(lang: lang),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Language lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppTexts.of("pending_info_title", lang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppTexts.of("pending_info_desc", lang),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(Language lang) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMapExpanded = !_isMapExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: _isMapExpanded ? 400 : 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isMapExpanded
                ? AppColors.primary.withOpacity(0.3)
                : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Map placeholder – will be replaced with Google Maps
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE0F2FE),
                      const Color(0xFFBAE6FD),
                      const Color(0xFF7DD3FC),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _MapPlaceholderPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
              // Overlay content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isMapExpanded
                              ? AppTexts.of("pending_map_title", lang)
                              : AppTexts.of("pending_tap_map", lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        _isMapExpanded
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              // Map pin markers (decorative)
              Positioned(
                top: _isMapExpanded ? 80 : 40,
                left: 60,
                child: _buildMapPin(AppColors.primary),
              ),
              Positioned(
                top: _isMapExpanded ? 120 : 60,
                right: 80,
                child: _buildMapPin(AppColors.secondary),
              ),
              Positioned(
                top: _isMapExpanded ? 160 : 80,
                left: 140,
                child: _buildMapPin(AppColors.accent),
              ),
              if (_isMapExpanded) ...[
                Positioned(
                  top: 200,
                  right: 40,
                  child: _buildMapPin(AppColors.error),
                ),
                Positioned(
                  top: 250,
                  left: 100,
                  child: _buildMapPin(AppColors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPin(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final colors = (gradient as LinearGradient).colors;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(Language lang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTexts.of("pending_coming_soon", lang)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Custom painter for map placeholder background
class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid lines to simulate map
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some road-like paths
    final roadPaint = Paint()
      ..color = const Color(0xFF60A5FA).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.5,
        size.width, size.height * 0.4,
      );
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..quadraticBezierTo(
        size.width * 0.4, size.height * 0.5,
        size.width * 0.6, size.height,
      );
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
