import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../inventory/models/inventory_models.dart';
import '../../inventory/providers/inventory_provider.dart';

class TabletInventoryImportDialog extends ConsumerStatefulWidget {
  const TabletInventoryImportDialog({super.key});

  @override
  ConsumerState<TabletInventoryImportDialog> createState() => _TabletInventoryImportDialogState();
}

class _TabletInventoryImportDialogState extends ConsumerState<TabletInventoryImportDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  SystemVariant? _selectedVariant;
  String _qtyInput = "";
  List<SystemVariant> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onSearch("");
    });
  }

  void _onSearch(String val) async {
    setState(() => _isSearching = true);
    try {
      final service = ref.read(staffInventoryServiceProvider);
      final results = await service.searchAllProducts(query: val.isEmpty ? null : val);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _onDigitPress(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_qtyInput.length < 9) {
        _qtyInput += digit;
      }
    });
  }

  void _onClear() {
    HapticFeedback.selectionClick();
    setState(() => _qtyInput = "");
  }

  Future<void> _submit() async {
    if (_selectedVariant == null || _qtyInput.isEmpty) return;
    final qty = int.tryParse(_qtyInput) ?? 0;
    if (qty <= 0) return;

    final storeId = ref.read(selectedStoreIdProvider);
    if (storeId == null) return;

    final success = await ref.read(inventoryProvider.notifier).importStock(
      storeId: storeId,
      variantId: _selectedVariant!.variantId,
      quantity: qty,
      reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
    );

    if (success != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Yêu cầu nhập kho đã được gửi và chờ phê duyệt."),
          backgroundColor: AppTheme.accentGold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Left Side: Selection & Info
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildHeader(),
                    const Divider(color: Colors.white10, height: 1),
                    Expanded(
                      child: _selectedVariant == null ? _buildSearchStep() : _buildInputStep(),
                    ),
                  ],
                ),
              ),
              
              const VerticalDivider(color: Colors.white10, width: 1),

              // Right Side: Keypad
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    _buildKeypadHeader(),
                    Expanded(child: _buildNumericKeypad()),
                    _buildSubmitBtn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.black26,
      child: Row(
        children: [
          const Icon(Icons.add_box_rounded, color: AppTheme.accentGold, size: 24),
          const SizedBox(width: 16),
          Text(
            "NHẬP KHO HỆ THỐNG",
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppTheme.accentGold, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Tìm tên sản phẩm, SKU, thương hiệu...",
                      hintStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 11, letterSpacing: 1),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _isSearching 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) {
                  final v = _searchResults[i];
                  return InkWell(
                    onTap: () => setState(() => _selectedVariant = v),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white10)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(4),
                              image: v.imageUrl != null ? DecorationImage(image: NetworkImage(v.imageUrl!), fit: BoxFit.cover) : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.productName.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                                Text("${v.brand} • ${v.variantName}", style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.accentGold, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          Text(v.sku ?? "", style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white24)),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildInputStep() {
    final v = _selectedVariant!;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                  image: v.imageUrl != null ? DecorationImage(image: NetworkImage(v.imageUrl!), fit: BoxFit.cover) : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.brand?.toUpperCase() ?? "BRAND", style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.accentGold, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(v.productName.toUpperCase(), style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(v.variantName, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white60)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedVariant = null),
                icon: const Icon(Icons.edit_outlined, color: Colors.white24),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text("GHI CHÚ / LÝ DO (TÙY CHỌN)", style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _reasonController,
              style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: "VÍ DỤ: NHẬP KHO ĐỊNH KỲ, HÀNG VỀ MỚI...",
                hintStyle: GoogleFonts.montserrat(color: Colors.white10, fontSize: 10, letterSpacing: 1),
                border: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text("SỐ LƯỢNG NHẬP", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text(
            _qtyInput.isEmpty ? "0" : _qtyInput,
            style: GoogleFonts.robotoMono(fontSize: 48, fontWeight: FontWeight.w300, color: AppTheme.accentGold, letterSpacing: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        children: [
          ...["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map((d) {
            return InkWell(
              onTap: () => _onDigitPress(d),
              child: Center(child: Text(d, style: GoogleFonts.robotoMono(fontSize: 24, color: Colors.white60, fontWeight: FontWeight.w300))),
            );
          }),
          InkWell(
            onTap: _onClear,
            child: Center(child: Text("C", style: GoogleFonts.robotoMono(fontSize: 24, color: Colors.redAccent.withOpacity(0.5), fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
          child: Text("GỬI YÊU CẦU", style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        ),
      ),
    );
  }
}
