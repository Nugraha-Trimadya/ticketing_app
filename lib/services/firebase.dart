import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final CollectionReference tickets =
      FirebaseFirestore.instance.collection('tickets');

  // Read all tickets
  Stream<QuerySnapshot> getTickets() {
    return tickets.snapshots();
  }

  // Get single ticket by ID
  Future<DocumentSnapshot> getTicketById(String id) {
    return tickets.doc(id).get();
  }
}
