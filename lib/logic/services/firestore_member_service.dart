import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:logger/logger.dart';

class FirestoreMemberService {
  final logger = Logger();
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection('members');

  /// Agrega un nuevo miembro a Firestore.
  Future<void> addMember(Member member) async {
    try {
      await _membersCollection
          .add(member.toJson()); // Usa el método toJson() del modelo
      logger.i('Member added successfully');
    } catch (e) {
      logger.e('Error adding member: $e');
    }
  }

  /// Actualiza un miembro existente en Firestore por su ID.
  Future<void> updateMember(String id, Member member) async {
    try {
      await _membersCollection
          .doc(id)
          .update(member.toJson()); // Usa el método toJson() del modelo
      logger.i('Member updated successfully');
    } catch (e) {
      logger.e('Error updating member: $e');
    }
  }

  /// Elimina un miembro existente en Firestore por su ID.
  Future<void> deleteMember(String id) async {
    try {
      await _membersCollection.doc(id).delete();
      logger.i('Member deleted successfully');
    } catch (e) {
      logger.e('Error deleting member: $e');
    }
  }

  /// Obtiene un Stream de miembros desde Firestore.
  Stream<List<Member>> getMembers() {
    return _membersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Member.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
