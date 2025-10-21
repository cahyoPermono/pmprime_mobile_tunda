import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Login Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    const _LogoAndTitle(),

                    const SizedBox(height: 40),

                    // Login Form
                    _LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/tundatop.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_boat,
                  size: 60,
                  color: Color(0xFF0D47A1),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Vasa Mobile Tunda',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sistem Pemanduan Kapal Tunda',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          children: [
            // Kode Kapal Field
            TextFormField(
              controller: controller.kodeKapalController,
              decoration: InputDecoration(
                labelText: 'Kode Kapal',
                prefixIcon: const Icon(Icons.directions_boat, color: Color(0xFF1976D2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode Kapal harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Kode Cabang Field
            TextFormField(
              controller: controller.kodeCabangController,
              decoration: InputDecoration(
                labelText: 'Kode Cabang',
                prefixIcon: const Icon(Icons.business, color: Color(0xFF1976D2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode Cabang harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                    shadowColor: Colors.orange.withOpacity(0.5),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Error Message
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}