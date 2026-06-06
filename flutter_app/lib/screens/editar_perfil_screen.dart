import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final UserModel user;
  const EditarPerfilScreen({super.key, required this.user});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _service   = AuthService();
  bool _guardando  = false;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl  = TextEditingController(text: widget.user.lastName);
    _emailCtrl     = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final result = await _service.updateProfile(
      firstName: _firstNameCtrl.text.trim(),
      lastName:  _lastNameCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context, result['user'] as UserModel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al guardar'),
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
        title: const Text('Editar perfil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF2E7D32).withOpacity(0.15),
              child: Text(
                widget.user.fullName.isNotEmpty
                    ? widget.user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32)),
              ),
            ),
            const SizedBox(height: 8),
            Text('@${widget.user.username}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 28),

            // Campo nombre
            _buildField(
              controller: _firstNameCtrl,
              label: 'Nombre',
              icon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 16),

            // Campo apellido
            _buildField(
              controller: _lastNameCtrl,
              label: 'Apellido',
              icon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'El apellido es requerido' : null,
            ),
            const SizedBox(height: 16),

            // Campo email
            _buildField(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El correo es requerido';
                if (!v.contains('@')) return 'Ingresa un correo válido';
                return null;
              },
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Guardar cambios',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildField({
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
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
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
