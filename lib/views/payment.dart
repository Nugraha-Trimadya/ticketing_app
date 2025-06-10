import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticketing_app/services/firebase.dart';
import 'package:ticketing_app/views/receipt.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final FirebaseServices _firebaseServices = FirebaseServices();
  PaymentScreen({
    Key? key,
    required this.ticketData,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    final monthNames = <int, String>{
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'Mei',
      6: 'Jun',
      7: 'Jul',
      8: 'Agu',
      9: 'Sep',
      10: 'Okt',
      11: 'Nov',
      12: 'Des',
    };
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _navigateToPaymentReceipt(BuildContext context) async {
    try {
      // Prepare purchase data
      final purchaseData = {
        'title': ticketData['title'],
        'type': ticketData['type'],
        'price': ticketData['price'],
        'purchaseDate': DateTime.now(),
      };

      // Save to Firestore
      await _firebaseServices.savePurchase(purchaseData);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil disimpan'),
            backgroundColor: Color(0xFF12B76A),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to receipt page
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BuktiPembayaranPage(ticketData: ticketData),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pembayaran: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildPaymentContent(BuildContext context, String imagePath,
      String title, String description) {
    final transactionCode = title.contains('Kartu')
        ? 'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Image.asset(
          imagePath,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        if (title.contains('Kartu'))
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    transactionCode,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: transactionCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kode transaksi berhasil disalin'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Salin',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _navigateToPaymentReceipt(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Konfirmasi Pembayaran',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showPaymentAlert(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.grey[50],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Combined Total Tagihan and Order Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Tagihan Section
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.payment_rounded,
                            color: Color(0xFF3730A3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Tagihan',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(ticketData['price'] ?? 0),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 16),

                    // Order Details Section
                    // Order Name
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nama Pesanan',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            ticketData['title'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Ticket Type
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tipe Tiket',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            ticketData['type'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Purchase Date
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tanggal Pembelian',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            _formatDate(DateTime.now()),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Methods Section
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildPaymentMethodButton(
                    icon: Icons.money,
                    title: 'Tunai (Cash)',
                    onTap: () {
                      _showPaymentAlert(
                        context,
                        'Pembayaran Tunai',
                        Icons.money,
                        _buildPaymentContent(
                          context,
                          'assets/images/tunai.png',
                          'Pembayaran Tunai',
                          'Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi.',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodButton(
                    icon: Icons.credit_card,
                    title: 'Kartu Kredit',
                    onTap: () {
                      _showPaymentAlert(
                        context,
                        'Pembayaran Kartu Kredit',
                        Icons.credit_card,
                        _buildPaymentContent(
                          context,
                          'assets/images/kartuKredit.png',
                          'Pembayaran Kartu Kredit',
                          'Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi.',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodButton(
                    icon: Icons.qr_code,
                    title: 'QRIS / QR Pay',
                    onTap: () {
                      _showPaymentAlert(
                        context,
                        'Pembayaran QRIS',
                        Icons.qr_code,
                        _buildPaymentContent(
                          context,
                          'assets/images/qr.png',
                          'Pembayaran QRIS',
                          'Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi.',
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Punya pertanyaan?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hubungi admin untuk bantuan pembayaran',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
