import 'package:flutter/material.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/logReg/login_screen.dart';
import 'package:aplikasi_kampus/core/storage/local_storage.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _pages = [
    (title: "Informasi Pendidikan\nTerintegrasi", desc: "Akses informasi akademik, jadwal kuliah, dan pengumuman resmi Universitas Bumigora dalam satu genggaman.", img: "assets/images/UBG.png"),
    (title: "Pantau Event\nAkademik", desc: "Ikuti perkembangan seminar, workshop, dan kegiatan akademik lainnya secara real-time.", img: "assets/images/UBG.png"),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  _animController.reset();
                  _animController.forward();
                },
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.all(40).copyWith(
                        left: Responsive.padding(context),
                        right: Responsive.padding(context),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Center(
                                child: Image.asset(p.img, errorBuilder: (context, error, stackTrace) => const Icon(Icons.event, size: 120, color: AppColors.primary)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(p.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          Text(p.desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: _page == i ? 24 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _page == i ? AppColors.primary : Colors.grey.shade300,
                ),
              )),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _navigateToLogin(),
                      child: const Text("Mulai Sekarang →", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _navigateToLogin(),
                      child: const Text("Sudah punya akun", style: TextStyle(color: Colors.black, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20, top: 16),
              child: Text.rich(
                TextSpan(
                  text: "Dengan melanjutkan, kamu menyetujui ",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  children: [TextSpan(text: "Syarat & Privasi", style: TextStyle(color: Colors.blue))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToLogin() async {
    await LocalStorage.setOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacement(context, RouteTransitions.fadeThrough(const LoginScreen()));
  }
}
