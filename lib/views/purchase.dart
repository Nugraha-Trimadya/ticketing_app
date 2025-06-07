import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketing_app/services/firebase.dart';
import 'package:intl/intl.dart';
import 'package:ticketing_app/views/payment.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseTicket extends StatefulWidget {
  const PurchaseTicket({super.key});

  @override
  State<PurchaseTicket> createState() => _PurchaseTicketState();
}

class _PurchaseTicketState extends State<PurchaseTicket> {
  final FirebaseServices firestoreService = FirebaseServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticketing App',
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
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTickets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            dynamic error = snapshot.error;
            String errorMessage = "Terjadi kesalahan yang tidak diketahui.";

            if (error is FirebaseException) {
              errorMessage = "Firebase Error: ${error.code} - ${error.message}";
            } else if (error.toString().contains('FirebaseException')) {
              errorMessage =
                  "Kesalahan dalam memproses data Firebase. Mohon coba lagi.";
              print("Original Web TypeError: $error");
            } else {
              errorMessage = "Kesalahan: $error";
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada tiket."));
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = tickets[index];
              final data = doc.data() as Map<String, dynamic>;

              final String namaTiket = data['title'] ?? 'Nama Tiket Tidak Ada';
              final String kategori = data['type'] ?? 'Kategori Tidak Ada';

              int harga;
              dynamic rawHarga = data['price'];

              if (rawHarga is int) {
                harga = rawHarga;
              } else if (rawHarga is String) {
                try {
                  harga = int.parse(rawHarga);
                } catch (e) {
                  print("Error parsing harga: $e. Default to 0");
                  harga = 0;
                }
              } else {
                harga = 0;
              }

              final dynamic rawTanggal = data['tanggal'];
              DateTime tanggal;

              if (rawTanggal is Timestamp) {
                tanggal = rawTanggal.toDate();
              } else {
                tanggal = DateTime.now();
              }

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              namaTiket,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              kategori,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp ${NumberFormat('#,###').format(harga).replaceAll(',', '.')}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                ticketData: {
                                  'title': namaTiket,
                                  'type': kategori,
                                  'price': harga,
                                  'date': DateFormat('dd MMMM yyyy')
                                      .format(tanggal),
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart,
                            size: 16, color: Colors.white),
                        label: Text(
                          'Beli',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
