import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../inventory/models/inventory_models.dart';

class TabletInventoryAdjustDialog extends StatefulWidget {
  final InventoryVariant variant;
  final Function(int delta, String reason) onSubmit;

  const TabletInventoryAdjustDialog({
    super.key,
    required this.variant,
    required this.onSubmit,
  });

  @override
  State<TabletInventoryAdjustDialog> createState() => _TabletInventoryAdjustDialogState();
}

class _TabletInventoryAdjustDialogState extends State<TabletInventoryAdjustDialog> {
  String _currentInput = "";
  final TextEditingController _reasonController = TextEditingController();

  void _onDigitPress(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      if (digit == "-" && _currentInput.startsWith("-")) {
        _currentInput = _currentInput.substring(1);
      } else if (digit == "-" && !_currentInput.startsWith("-")) {
        _currentInput = "-$_currentInput";
      } else {
        if (_currentInput.length < 8) {
          _currentInput += digit;
        }
      }
    });
  }

  void _onClear() {
    HapticFeedback.selectionClick();
    setState(() => _currentInput = "");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 500,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              
              const Divider(color: Colors.white10, height: 1),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Info Bar
                      _buildProductInfoBar(),

                      const Divider(color: Colors.white10, height: 1),

                      // Numeric Input Display
                      _buildValueDisplay(),

                      // Keypad
                      _buildNumericKeypad(),

                      // Reason Field
                      _buildReasonField(),
                    ],
                  ),
                ),
              ),

              // Submit Action
              _buildSubmitAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            "ĐIỀU CHỈNH KHO",
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentGold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.black26,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.variant.name.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                Text("${widget.variant.variantName} ml", style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white60)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("TỒN KHO HIỆN TẠI", style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.bold)),
              Text("${widget.variant.stock}", style: GoogleFonts.robotoMono(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        _currentInput.isEmpty ? "0" : _currentInput,
        style: GoogleFonts.robotoMono(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 2.0, // More compact
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...["1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "0"].map((d) {
            return _KeyPadBtn(label: d, onTap: () => _onDigitPress(d));
          }),
          _KeyPadBtn(label: "C", color: Colors.redAccent.withOpacity(0.05), onTap: _onClear),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _reasonController,
          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 11),
          decoration: InputDecoration(
            hintText: "NHẬP LÝ DO ĐIỀU CHỈNH...",
            hintStyle: GoogleFonts.montserrat(color: Colors.white60, fontSize: 9, letterSpacing: 1),
            border: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitAction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            final delta = int.tryParse(_currentInput) ?? 0;
            final reason = _reasonController.text.trim();
            if (delta == 0) return;
            widget.onSubmit(delta, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            elevation: 8,
            shadowColor: AppTheme.accentGold.withOpacity(0.3),
          ),
          child: Text(
            "XÁC NHẬN GIAO DỊCH",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}

class _KeyPadBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _KeyPadBtn({required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: color ?? Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.white, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
