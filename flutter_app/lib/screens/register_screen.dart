import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _authService   = AuthService();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  bool _isLoading       = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await _authService.register(
      username:  _usernameCtrl.text.trim(),
      password:  _passwordCtrl.text,
      email:     _emailCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeScreen(user: result['user']),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() { _isLoading = false; _errorMessage = result['error']; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF388E3C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // Ícono + título
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(Icons.eco_rounded, size: 42, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      const Text('CaféDetect',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                              color: Colors.white, letterSpacing: 1.0)),
                      const SizedBox(height: 4),
                      Text('Crea tu cuenta para comenzar',
                          style: TextStyle(fontSize: 13,
                              color: Colors.white.withOpacity(0.75))),
                      const SizedBox(height: 28),

                      // Formulario
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20, offset: const Offset(0, 10),
                          )],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            const Text('Crear cuenta',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20))),
                            const SizedBox(height: 4),
                            Text('Completa los datos para registrarte',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            const SizedBox(height: 20),

                            // Error
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_errorMessage!,
                                      style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                                ]),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Nombre y Apellido en fila
                            Row(children: [
                              Expanded(child: _field(
                                controller: _firstNameCtrl,
                                label: 'Nombre',
                                icon: Icons.person_outline,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Requerido' : null,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _field(
                                controller: _lastNameCtrl,
                                label: 'Apellido',
                                icon: Icons.person_outline,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Requerido' : null,
                              )),
                            ]),
                            const SizedBox(height: 14),

                            // Email
                            _field(
                              controller: _emailCtrl,
                              label: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'El correo es requerido';
                                if (!v.contains('@')) return 'Correo inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Usuario
                            _field(
                              controller: _usernameCtrl,
                              label: 'Nombre de usuario',
                              icon: Icons.alternate_email,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'El usuario es requerido';
                                if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                                if (v.contains(' ')) return 'Sin espacios';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Contraseña
                            _passwordField(
                              controller: _passwordCtrl,
                              label: 'Contraseña',
                              ocultar: _obscurePassword,
                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'La contraseña es requerida';
                                if (v.length < 4) return 'Mínimo 4 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirmar contraseña
                            _passwordField(
                              controller: _confirmCtrl,
                              label: 'Confirmar contraseña',
                              ocultar: _obscureConfirm,
                              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                                if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Botón registrar
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFF2E7D32).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5, color: Colors.white))
                                    : const Text('CREAR CUENTA',
                                        style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                              ),
                            ),
                          ]),
                        ),
                      ),

                      // Ir al login
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('¿Ya tienes cuenta? ',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Inicia sesión',
                              style: TextStyle(color: Colors.white, fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text('CaféDetect v1.0 — Grupo 05',
                          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool ocultar,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: ocultar,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(ocultar ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
