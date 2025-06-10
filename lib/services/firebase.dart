import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final CollectionReference tickets =
      FirebaseFirestore.instance.collection('tickets');

  final CollectionReference purchases =
      FirebaseFirestore.instance.collection('purchases');

  // Read all tickets
  Stream<QuerySnapshot> getTickets() {
    return tickets.snapshots();
  }

  // Get single ticket by ID
  Future<DocumentSnapshot> getTicketById(String id) {
    return tickets.doc(id).get();
  }

  // Save purchase data
  Future<void> savePurchase(Map<String, dynamic> purchaseData) async {
    try {
      await purchases.add({
        ...purchaseData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save purchase: $e');
    }
  }
}
