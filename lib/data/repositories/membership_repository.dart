import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:platia/data/models/membership.dart';
import 'package:platia/data/models/membership_package.dart';

class MembershipRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MembershipPackage>> getPackages() async {
    try {
      final snapshot = await _firestore
          .collection('membershipPackages')
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();

      return snapshot.docs.map((doc) {
        return MembershipPackage.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get membership packages: $e');
    }
  }

  Future<Membership?> getActiveMembership(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .where('endDate', isGreaterThan: DateTime.now())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Membership.fromJson({
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get active membership: $e');
    }
  }

  Future<void> createMembership(Membership membership) async {
    try {
      await _firestore.collection('memberships').add(membership.toJson());
    } catch (e) {
      throw Exception('Failed to create membership: $e');
    }
  }
}
