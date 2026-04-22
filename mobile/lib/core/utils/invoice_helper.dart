import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:perfume_gpt_app/features/staff/pos/models/pos_models.dart';
import 'package:perfume_gpt_app/features/stores/services/stores_service.dart';

class InvoiceHelper {
  static Future<void> generateAndPrintInvoice(PosOrder order, [Store? store]) async {
    final pdf = pw.Document();
    
    // Attempting to load fonts that support Vietnamese characters
    final font = await PdfGoogleFonts.beVietnamProRegular();
    final fontBold = await PdfGoogleFonts.beVietnamProBold();
    final fontItalic = await PdfGoogleFonts.beVietnamProItalic();
    
    final currencyFmt = NumberFormat('#,###', 'vi_VN');
    final dateFmt = DateFormat('HH:mm dd/MM/yy');

    final accentGold = PdfColor.fromHex('#EAB308'); // tailwind yellow-500
    final darkGrey = PdfColor.fromHex('#1F2937');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.SizedBox(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header with Gold Background
                pw.Container(
                  color: accentGold,
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('PerfumeGPT', 
                        style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.white)),
                      pw.SizedBox(height: 6),
                      pw.Text('Hệ thống tư vấn nước hoa AI', 
                        style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.white, letterSpacing: 1)),
                    ],
                  ),
                ),

                // Store Info Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(store?.name.toUpperCase() ?? 'QN SHOP', 
                        style: pw.TextStyle(font: fontBold, fontSize: 14, color: darkGrey)),
                      pw.SizedBox(height: 8),
                      _buildStoreInfoRow(font, 'Địa chỉ: ${store?.address ?? "123 Nguyễn Tất Thành, Quy Nhơn, Gia Lai"}'),
                      _buildStoreInfoRow(font, 'Điện thoại: ${store?.phone ?? "1900 XXX XXX"}'),
                      _buildStoreInfoRow(font, 'Email: contact@perfumegpt.vn'),
                      _buildStoreInfoRow(font, 'Mã số thuế: 0123456789'),
                    ],
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                  child: pw.Divider(thickness: 1, color: PdfColors.grey300),
                ),

                // Order ID and Date
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Mã đơn hàng:', style: pw.TextStyle(font: fontBold, fontSize: 10, color: darkGrey)),
                          pw.Text(order.code, style: pw.TextStyle(font: fontBold, fontSize: 10, color: darkGrey)),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Ngày giờ:', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                          pw.Text(dateFmt.format(DateTime.now()), style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                  child: pw.Divider(thickness: 1, color: PdfColors.grey300),
                ),

                // Product details
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Chi tiết sản phẩm', style: pw.TextStyle(font: fontBold, fontSize: 11, color: darkGrey)),
                      pw.SizedBox(height: 15),
                      ...order.items.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 15),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(item.variant?.product?.name ?? 'Sản phẩm', 
                                    style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.black)),
                                  if (item.variant != null)
                                    pw.Text(item.variant!.name, 
                                      style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
                                  pw.Text('${currencyFmt.format(item.unitPrice)}đ x ${item.quantity}', 
                                    style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500)),
                                ],
                              ),
                            ),
                            pw.Text('${currencyFmt.format(item.totalPrice)} đ', 
                              style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.black)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                child: pw.Divider(thickness: 1, color: PdfColors.grey300),
              ),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                child: pw.Column(
                  children: [
                    _buildSummaryRow('Tạm tính:', '${currencyFmt.format(order.totalAmount)} đ', font, fontBold),
                    if (order.discountAmount > 0)
                      _buildSummaryRow('Giảm giá:', '-${currencyFmt.format(order.discountAmount)} đ', font, fontBold),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tổng cộng:', style: pw.TextStyle(font: fontBold, fontSize: 15)),
                        pw.Text('${currencyFmt.format(order.finalAmount)} đ', 
                          style: pw.TextStyle(font: fontBold, fontSize: 18, color: accentGold)),
                      ],
                    ),
                  ],
                ),
              ),

              // Payment Status
              pw.Container(
                margin: const pw.EdgeInsets.all(15),
                padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Phương thức thanh toán:', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(order.paymentStatus == 'PAID' ? 'Đã thanh toán' : 'Chờ thanh toán', 
                      style: pw.TextStyle(font: fontBold, fontSize: 10, color: darkGrey)),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text('Cảm ơn quý khách đã mua hàng tại PerfumeGPT!', 
                  style: pw.TextStyle(font: fontItalic, fontSize: 9, color: PdfColors.grey500)),
              ),
              pw.SizedBox(height: 30),
            ],
          ),
        );
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
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey700)),
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, pw.Font font, pw.Font fontBold) {
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
