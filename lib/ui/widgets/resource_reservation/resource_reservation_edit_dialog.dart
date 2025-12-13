import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/ui/widgets/custom_text_field.dart';

class ResourceReservationEditDialog extends StatefulWidget {
  final ResourceReservation reservation;
  final Function(double reserved, double used) onApply;

  const ResourceReservationEditDialog({
    super.key,
    required this.reservation,
    required this.onApply,
  });

  @override
  State<ResourceReservationEditDialog> createState() =>
      _ResourceReservationEditDialogState();
}

class _ResourceReservationEditDialogState
    extends State<ResourceReservationEditDialog> {
  late TextEditingController _reservedController;
  late TextEditingController _usedController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reservedController = TextEditingController(
      text: widget.reservation.reservedQuantity.toString(),
    );
    _usedController = TextEditingController(
      text: widget.reservation.usedQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _reservedController.dispose();
    _usedController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final reserved = double.tryParse(_reservedController.text);
    final used = double.tryParse(_usedController.text);

    if (reserved == null || used == null) {
      setState(() {
        _errorMessage = 'Будь ласка, введіть коректні числа';
      });
      return;
    }

    if (reserved < 0 || used < 0) {
      setState(() {
        _errorMessage = 'Кількість не може бути від\'ємною';
      });
      return;
    }

    if (used > reserved) {
      setState(() {
        _errorMessage = 'Використана кількість не може перевищувати зарезервовану!';
      });
      return;
    }

    widget.onApply(reserved, used);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагування резервації'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _reservedController,
            labelText: 'Кількість резервації',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _usedController,
            labelText: 'Кількість використаного',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        TextButton(
           onPressed: _validateAndSubmit,
           child: const Text('Застосувати'),
        ),
      ],
    );
  }
}