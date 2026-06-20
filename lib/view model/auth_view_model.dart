import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  User? currentUser;

  // ✅ LOGIN Function
  Future<String?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // Step 1: Firebase Auth se login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Firestore se role verify karo
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        isLoading = false;
        notifyListeners();
        return 'User data nahi mila';
      }

      String userRole = doc['role'] ?? '';

      // Step 3: Role match check
      if (userRole != role) {
        await _auth.signOut();
        isLoading = false;
        notifyListeners();
        return 'Aap $role nahi hain. Sahi role select karein.';
      }

      currentUser = userCredential.user;
      isLoading = false;
      notifyListeners();

      return null; // null = success
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      switch (e.code) {
        case 'user-not-found':
          return 'Email registered nahi hai';
        case 'wrong-password':
          return 'Password galat hai';
        case 'invalid-email':
          return 'Email sahi nahi hai';
        case 'user-disabled':
          return 'Account disable kar diya gaya hai';
        case 'network-request-failed':
          return 'Internet connection check karein';
        case 'invalid-credential':
          return 'Email ya password galat hai';
        default:
          return e.message ?? 'Kuch ghalat hua';
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Error: ${e.toString()}';
    }
  }

  // ✅ SIGNUP Function
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = '',
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,

        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user!.updateDisplayName(name);

      currentUser = userCredential.user;
      isLoading = false;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      switch (e.code) {
        case 'email-already-in-use':
          return 'Yeh email pehle se registered hai';
        case 'weak-password':
          return 'Password kam az kam 6 characters ka hona chahiye';
        case 'invalid-email':
          return 'Email sahi nahi hai';
        case 'network-request-failed':
          return 'Internet connection check karein';
        default:
          return e.message ?? 'Kuch ghalat hua';
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Error: ${e.toString()}';
    }
  }

  // ✅ LOGOUT Function
  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  Future<String?> createStaffAccount({
    required String name,
    required String email,
    required String password,
    required String role,
    String specialist = 'General Physician',
    String phone = '',
    String experience = '',
    String fee = '',
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      FirebaseApp secondaryApp;

      // ✅ Pehle delete karo agar exist kare
      try {
        secondaryApp = Firebase.app('secondaryApp');
        await secondaryApp.delete();
      } catch (_) {}

      // ✅ Naya banao
      secondaryApp = await Firebase.initializeApp(
        name: 'secondaryApp',
        options: Firebase.app().options,
      );

      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCredential = await secondaryAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'specialist': specialist,
        'phone': phone,
        'experience': experience,
        'fee': int.tryParse(fee) ?? 0,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await secondaryApp.delete();

      isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'email-already-in-use':
          return 'Yeh email pehle se registered hai';
        case 'weak-password':
          return 'Password minimum 6 characters ka hona chahiye';
        default:
          return e.message ?? 'Kuch ghalat hua';
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Error: ${e.toString()}';
    }
  }

  // ✅ Sare Doctors fetch karo
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ Sare Patients fetch karo
  Future<List<Map<String, dynamic>>> getAllPatients() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ Doctor delete karo
  Future<String?> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return null;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
