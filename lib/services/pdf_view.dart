import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../model/patient_invoice_model.dart';

Future<Uint8List> generateInvoicePDF(PatientInvoice invoice) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "KUMARAKOM",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Cheepunkal P.O, Kumarakom, Kottayam, Kerala - 686563"),
                    pw.Text("Mob: ${invoice.phone}"),
                    pw.Text("GST No: 32AABCU9603R1ZW"),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 10),

            // Patient Details
            pw.Text("Patient Details", style: pw.TextStyle(color: PdfColors.green, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Name: ${invoice.name}"),
                    pw.Text("Address: ${invoice.address}"),
                    pw.Text("Executive: ${invoice.executive}"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Payment: ${invoice.payment}"),
                    pw.Text("Date & Time: ${invoice.dateAndTime}"),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Treatment Table
            pw.Table(
              border: const pw.TableBorder(bottom: pw.BorderSide(style: pw.BorderStyle.dashed)),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text("Treatment", style: pw.TextStyle(color: PdfColors.green)),
                    pw.Text("Male", style: pw.TextStyle(color: PdfColors.green)),
                    pw.Text("Female", style: pw.TextStyle(color: PdfColors.green)),
                    pw.Text("Total", style: pw.TextStyle(color: PdfColors.green)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text("Treatment ${invoice.treatments}"), // You can map this id to name if needed
                    pw.Text(invoice.male.toString()),
                    pw.Text(invoice.female.toString()),
                    pw.Text((invoice.male + invoice.female).toString()),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Total Amount: ₹${invoice.totalAmount}"),
                  pw.Text("Discount: ₹${invoice.discountAmount}"),
                  pw.Text("Advance: ₹${invoice.advanceAmount}"),

                  pw.Text("Balance: ₹${invoice.balanceAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),

            pw.Spacer(),
            pw.Center(child: pw.Text("Thank you for choosing us", style: pw.TextStyle(color: PdfColors.green, fontSize: 18))),
          ],
        );
      },
    ),
  );

  return pdf.save();
}