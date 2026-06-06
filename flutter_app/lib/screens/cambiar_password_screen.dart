import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _service      = AuthService();
  final _actualCtrl   = TextEditingController();
  final _nuevaCtrl    = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _guardando      = false;
  bool _ocultarActual  = true;
  bool _ocultarNueva   = true;
  bool _ocultarConfirm = true;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final result = await _service.changePassword(
      currentPassword: _actualCtrl.text,
      newPassword:     _nuevaCtrl.text,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (result['success'] == true) {
      // Mostrar éxito y redirigir al login (el token fue regenerado)
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Contraseña actualizada'),
          ]),
          content: const Text(
              'Tu contraseña fue actualizada correctamente. Debes iniciar sesión nuevamente.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ir al inicio de sesión'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al cambiar contraseña'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Cambiar contraseña',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Aviso informativo
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Al cambiar tu contraseña tu sesión se cerrará y deberás iniciar sesión nuevamente.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade800, height: 1.4),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Contraseña actual
            _buildPasswordField(
              controller: _actualCtrl,
              label: 'Contraseña actual',
              ocultar: _ocultarActual,
              onToggle: () => setState(() => _ocultarActual = !_ocultarActual),
              validator: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña actual' : null,
            ),
            const SizedBox(height: 16),

            // Nueva contraseña
            _buildPasswordField(
              controller: _nuevaCtrl,
              label: 'Nueva contraseña',
              ocultar: _ocultarNueva,
              onToggle: () => setState(() => _ocultarNueva = !_ocultarNueva),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                if (v.length < 4) return 'Mínimo 4 caracteres';
                if (v == _actualCtrl.text) return 'Debe ser diferente a la actual';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirmar nueva contraseña
            _buildPasswordField(
              controller: _confirmaCtrl,
              label: 'Confirmar nueva contraseña',
              ocultar: _ocultarConfirm,
              onToggle: () => setState(() => _ocultarConfirm = !_ocultarConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirma la nueva contraseña';
                if (v != _nuevaCtrl.text) return 'Las contraseñas no coinciden';
                return null;
              },
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _guardando ? null : _cambiar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Cambiar contraseña',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
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
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
        suffixIcon: IconButton(
          icon: Icon(ocultar ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }
}
