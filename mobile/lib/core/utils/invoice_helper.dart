import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:perfume_gpt_app/features/staff/pos/models/pos_models.dart';
import 'package:perfume_gpt_app/features/stores/services/stores_service.dart';

class InvoiceHelper {
  static Future<void> generateAndPrintInvoice(
    PosOrder order, [
    Store? store,
  ]) async {
    final pdf = pw.Document();

    // Attempting to load fonts that support Vietnamese characters
    final font = await PdfGoogleFonts.beVietnamProRegular();
    final fontBold = await PdfGoogleFonts.beVietnamProBold();
    final fontItalic = await PdfGoogleFonts.beVietnamProItalic();

    final currencyFmt = NumberFormat('#,###', 'vi_VN');
    final dateFmt = DateFormat('HH:mm dd/MM/yy');

    final accentGold = PdfColor.fromHex('#EAB308'); // tailwind yellow-500
    final brightGold = PdfColor.fromHex('#FBBF24'); // tailwind yellow-400
    final darkGrey = PdfColor.fromHex('#1F2937');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        build: (pw.Context context) {
          return [
            pw.SizedBox(
              width: double.infinity,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                // Header with gradient (matching web)
                pw.Container(
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [accentGold, brightGold],
                      begin: pw.Alignment.centerLeft,
                      end: pw.Alignment.centerRight,
                    ),
                  ),
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'PerfumeGPT',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 22,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'HỆ THỐNG TƯ VẤN NƯỚC HOA AI',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: PdfColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Store Info Section
                pw.Container(
                  padding: const pw.EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        store?.name.toUpperCase() ?? 'CỬA HÀNG PERFUMEGPT',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 14,
                          color: darkGrey,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildStoreInfoRow(
                        font,
                        'Địa chỉ: ${store?.address ?? "123 Đường ABC, Quận XYZ, TP.HCM"}',
                      ),
                      _buildStoreInfoRow(
                        font,
                        'Điện thoại: ${store?.phone ?? "1900 XXX XXX"}',
                      ),
                      _buildStoreInfoRow(font, 'Email: contact@perfumegpt.vn'),
                      _buildStoreInfoRow(font, 'Mã số thuế: 0123456789'),
                    ],
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                ),

                // Order Info
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Mã đơn hàng:',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            order.code,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: darkGrey,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Ngày giờ:',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            dateFmt.format(DateTime.now()),
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Customer Info Section (Synced with Web)
                if (order.user != null || order.phone != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'THÔNG TIN KHÁCH HÀNG',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          order.user?.fullName ??
                              (order.user != null
                                  ? 'Thành viên'
                                  : 'Khách vãng lai'),
                          style: pw.TextStyle(font: fontBold, fontSize: 10),
                        ),
                        pw.Text(
                          order.phone ?? order.user?.phone ?? '',
                          style: pw.TextStyle(font: font, fontSize: 9),
                        ),
                        if (order.paymentStatus == 'PAID')
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 4),
                            child: pw.Text(
                              '+${(order.finalAmount / 10000).floor()} điểm thưởng tích lũy',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 9,
                                color: accentGold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Divider(thickness: 1, color: darkGrey),
                ),

                // Product details
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CHI TIẾT SẢN PHẨM',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: darkGrey,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      ...order.items.map(
                        (item) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      item.variant?.product?.name ?? 'Sản phẩm',
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: 11,
                                        color: PdfColors.black,
                                      ),
                                    ),
                                    if (item.variant != null)
                                      pw.Text(
                                        item.variant!.name,
                                        style: pw.TextStyle(
                                          font: font,
                                          fontSize: 9,
                                          color: PdfColors.grey600,
                                        ),
                                      ),
                                    pw.Text(
                                      '${currencyFmt.format(item.unitPrice)} đ x ${item.quantity}',
                                      style: pw.TextStyle(
                                        font: font,
                                        fontSize: 9,
                                        color: PdfColors.grey500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Text(
                                '${currencyFmt.format(item.totalPrice)} đ',
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 11,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                ),

                // Summary
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  child: pw.Column(
                    children: [
                      _buildSummaryRow(
                        'Tạm tính:',
                        '${currencyFmt.format(order.totalAmount)} đ',
                        font,
                        fontBold,
                      ),
                      if (order.discountAmount > 0)
                        _buildSummaryRow(
                          'Giảm giá:',
                          '-${currencyFmt.format(order.discountAmount)} đ',
                          font,
                          fontBold,
                        ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey50,
                          border: pw.Border.all(color: PdfColors.grey200),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'TỔNG CỘNG:',
                              style: pw.TextStyle(font: fontBold, fontSize: 12),
                            ),
                            pw.Text(
                              '${currencyFmt.format(order.finalAmount)} đ',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 16,
                                color: accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Payment Status
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Trạng thái thanh toán:',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: pw.BoxDecoration(
                              color: order.paymentStatus == 'PAID'
                                  ? PdfColors.green100
                                  : PdfColors.orange100,
                              borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4),
                              ),
                            ),
                            child: pw.Text(
                              order.paymentStatus == 'PAID'
                                  ? 'ĐÃ THANH TOÁN'
                                  : 'CHỜ THANH TOÁN',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 8,
                                color: order.paymentStatus == 'PAID'
                                    ? PdfColors.green800
                                    : PdfColors.orange800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (order.paymentMethod != null) ...[
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Hình thức:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              order.paymentMethod == 'CASH'
                                  ? 'Tiền mặt'
                                  : 'Chuyển khoản / QR',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 9,
                                color: darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // Footer with thank you message (matching web style)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Cảm ơn quý khách đã mua hàng tại PerfumeGPT!',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Hàng hóa đã được kiểm tra kỹ trước khi giao.',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
        ];
      },
    ),
  );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'HoaDon_${order.code}.pdf',
    );
  }

  static pw.Widget _buildStoreInfoRow(pw.Font font, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey700),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 10)),
        ],
      ),
    );
  }
}
