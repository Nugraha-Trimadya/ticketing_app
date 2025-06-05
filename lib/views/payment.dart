import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heroicons/heroicons.dart';
import 'package:ticketing_app/views/receipt.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const PaymentScreen({
    super.key,
    required this.ticketData,
  });
  void _navigateToPaymentReceipt(BuildContext context) {
    Navigator.pop(context); // Close the dialog first
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BuktiPembayaranPage(ticketData: ticketData),
      ),
    );
  }

  Widget _buildPaymentContent(BuildContext context, String imagePath,
      String title, String description) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
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
          child: const Text('Konfirmasi Pembayaran'),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: content,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Total Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Payment Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Payment Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Tagihan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${NumberFormat('#,###').format(ticketData['price'] ?? 0).replaceAll(',', '.')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Order Details Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Order Name
                    Row(
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
                    const SizedBox(height: 12),
                    // Ticket Type
                    Row(
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
                    const SizedBox(height: 12),
                    // Purchase Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tanggal Pembelian',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          DateFormat.yMMMMd('id_ID').format(DateTime.now()),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
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
}
