import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/pharmacy_bill_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> printReceipt(PharmacyBill bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('ZENVYRO HOSPITAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ),
              pw.Center(
                child: pw.Text('PHARMACY RECEIPT', style: pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text('Bill ID: ${bill.id.substring(0, 8).toUpperCase()}'),
              pw.Text('Date: ${DateFormat('dd-MM-yyyy HH:mm').format(bill.date)}'),
              pw.Text('Source: ${bill.source}'),
              pw.SizedBox(height: 10),
              pw.Text('Patient: ${bill.patientName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Age: ${bill.patientAge} • Mob: ${bill.patientMobile}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Container(width: 50, child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(),
              ...bill.medicines.map((m) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${m.type} ${m.name}')),
                    pw.Text('${m.quantity}'),
                    pw.Container(width: 50, child: pw.Text('Rs. ${m.totalPrice.toStringAsFixed(0)}', textAlign: pw.TextAlign.right)),
                  ],
                ),
              )),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text('Rs. ${bill.grandTotal.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Thank you!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ),
              pw.Center(
                child: pw.Text('Software by Zenvyro', style: pw.TextStyle(fontSize: 8)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
