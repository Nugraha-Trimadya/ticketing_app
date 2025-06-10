import 'package:firebase_core/firebase_core.dart'; // Import library untuk menghubungkan aplikasi ke Firebase
import 'package:flutter/material.dart'; // Import library UI Material Design dari Flutter
import 'package:ticketing_app/firebase_options.dart'; // Import konfigurasi Firebase sesuai platform
import 'package:ticketing_app/views/purchase.dart'; // Import halaman pembelian tiket
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts untuk custom font seperti Poppins

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan Flutter sudah siap sebelum menjalankan async
  await Firebase.initializeApp( // Inisialisasi Firebase saat aplikasi dijalankan
    options: DefaultFirebaseOptions.currentPlatform, // Mengambil opsi Firebase sesuai platform (Android/iOS)
  );
  runApp(const MyApp()); // Menjalankan aplikasi utama MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticketing App', // Judul aplikasi
      debugShowCheckedModeBanner: false, // Menyembunyikan label "debug" di pojok kanan atas
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(), // Menggunakan font Poppins untuk seluruh teks
        useMaterial3: true, // Mengaktifkan Material 3 untuk tampilan modern
      ),
      home: const OnboardingPage(), // Menampilkan halaman onboarding saat pertama dibuka
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Warna latar belakang onboarding
      body: SafeArea( // Membuat tampilan tidak menabrak notch atau status bar
        child: Column(
          children: [
            const SizedBox(height: 50), // Jarak atas 50 pixel
            Center(
              child: SizedBox(
                height: 300, // Tinggi gambar 300 pixel
                child: Image.asset(
                  'assets/images/onboard.png', // Menampilkan gambar onboarding dari folder assets
                  fit: BoxFit.contain, // Gambar menyesuaikan ukuran tanpa terpotong
                ),
              ),
            ),
            const Spacer(), // Mengisi ruang kosong antara gambar dan konten bawah
            Container(
              margin: const EdgeInsets.all(20), // Margin luar container 20 pixel
              padding: const EdgeInsets.all(20), // Padding dalam container 20 pixel
              decoration: BoxDecoration(
                color: Colors.white, // Warna latar container
                borderRadius: BorderRadius.circular(20), // Membuat sudut container membulat
              ),
              child: Column(
                children: [
                  const Text(
                    'Ticketing App', // Judul aplikasi
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10), // Jarak antar teks
                  const Text(
                    'Membantu anda untuk\nmanagemen pembelian Tiket agar lebih efisien', // Deskripsi aplikasi
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20), // Jarak ke tombol
                  SizedBox(
                    width: double.infinity, // Tombol selebar container
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push( // Navigasi ke halaman pembelian tiket saat tombol ditekan
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PurchaseTicket(), // Arahkan ke PurchaseTicket
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Warna tombol
                        padding: const EdgeInsets.symmetric(vertical: 15), // Padding atas-bawah tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Tombol dengan sudut melengkung
                        ),
                      ),
                      child: const Text(
                        'Get Started', // Teks pada tombol
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
