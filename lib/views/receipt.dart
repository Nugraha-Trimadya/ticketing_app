import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';

class BuktiPembayaranPage extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const BuktiPembayaranPage({
    super.key,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Warna background utama
      appBar: AppBar(
        centerTitle: true, // Judul berada di tengah
        backgroundColor: Colors.white, // Warna appbar
        elevation: 0, // Menghilangkan bayangan appbar
        title: const Text(
          'Bukti Pembayaran', // Judul halaman
          style: TextStyle(color: Colors.black), // Warna teks judul
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // Tombol kembali
          onPressed: () => Navigator.of(context)
              .pop(), // Navigasi kembali ke halaman sebelumnya
        ),
      ),
      body: Column(
        children: [
          // Notifikasi pembayaran berhasil
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBF0), // Warna latar hijau terang
              border: Border.all(color: const Color(0xFF12B76A)), // Garis hijau
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle,
                    color: Color(0xFF12B76A)), // Ikon berhasil
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bukti pembayaran berhasil di unduh!', // Pesan notifikasi
                    style: TextStyle(
                      color: Color(0xFF12B76A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Kartu utama bukti pembayaran
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                // Ikon berhasil di tengah
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0ECFF),
                  radius: 32,
                  child: const Icon(Icons.check,
                      size: 36, color: Color(0xFF2E5AAC)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pembayaran Berhasil', // Judul konfirmasi
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Transaksi kamu telah selesai.\nDetail pembelian ada di bawah ini.', // Deskripsi tambahan
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                // Informasi tiket yang dibeli
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticketData['title'] ?? 'N/A', // Nama tiket
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticketData['type'] ?? 'N/A', // Jenis tiket
                        style: const TextStyle(color: Colors.black45),
                      ),
                      const SizedBox(height: 12),
                      const Divider(), // Garis pemisah
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pembayaran', // Label total
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${NumberFormat('#,###').format(ticketData['price'] ?? 0).replaceAll(',', '.')}',
                            // Format harga menjadi Rp xxx.xxx
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E5AAC), // Warna biru tua
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .pop(), // Kembali ke halaman sebelumnya
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF2E5AAC)), // Garis luar tombol
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(color: Color(0xFF2E5AAC)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _generatePDF(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E5AAC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.download, size: 18),
                            SizedBox(width: 8),
                            Text('Unduh Bukti'),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(BuildContext context) async {
    try {
      final pdf = await _createPDFDocument();

      if (kIsWeb) {
        await _downloadPDFWeb(pdf, context);
      } else {
        // Check permissions for Android
        if (Platform.isAndroid) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Izin penyimpanan diperlukan untuk mengunduh PDF'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          }
        }
        await _savePDFMobile(context, pdf);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<pw.Document> _createPDFDocument() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'BUKTI PEMBAYARAN',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Transaction Details
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Detail Transaksi',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    _buildPDFRow('Nama Tiket', ticketData['title'] ?? 'N/A'),
                    _buildPDFRow('Jenis Tiket', ticketData['type'] ?? 'N/A'),
                    _buildPDFRow(
                      'Tanggal Pembelian',
                      DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    ),
                    pw.Divider(),
                    _buildPDFRow(
                      'Total Pembayaran',
                      'Rp ${NumberFormat('#,###').format(ticketData['price'] ?? 0).replaceAll(',', '.')}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              // Footer
              pw.Text(
                'Terima kasih telah melakukan pembelian',
                style: pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _downloadPDFWeb(pw.Document pdf, BuildContext context) async {
    try {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..setAttribute('download', 'bukti_pembayaran_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
      
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti pembayaran berhasil diunduh'),
            backgroundColor: Color(0xFF12B76A),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _savePDFMobile(BuildContext context, pw.Document pdf) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw Exception('Platform tidak didukung');
    }

    if (directory == null) {
      throw Exception('Tidak dapat menemukan direktori penyimpanan');
    }

    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = 'bukti_pembayaran_$timestamp.pdf';
    final String filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bukti pembayaran berhasil diunduh'),
              const SizedBox(height: 4),
              Text(
                'Lokasi: ${file.path}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF12B76A),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  pw.Widget _buildPDFRow(String label, String value, {bool isBold = false}) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
