import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/user_model.dart';
import '../domain/repository.dart';
import 'local_datasource.dart';
import 'remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;
  const AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<({String token, String userId, bool needsOtp})> login({
    required String identifier,
    required String password,
  }) async {
    // MOCK DATA FOR PROTOTYPE
    await Future.delayed(const Duration(seconds: 1));
    return (token: 'mock_token', userId: 'mock_user_1', needsOtp: false);
  }

  @override
  Future<void> register({
    required String prenom,
    required String nom,
    required String password,
    String? phone,
    String? email,
  }) async {
    // MOCK DATA FOR PROTOTYPE
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<String> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'mock_token';
  }

  @override
  Future<void> resendOtp({required String identifier}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> getMe() async {
    // MOCK DATA FOR PROTOTYPE
    await Future.delayed(const Duration(seconds: 1));
    return const UserModel(
      id: 'mock_user_1',
      prenom: 'Modou',
      nom: 'Diop',
      phone: '771234567',
      isVerified: true,
      communeNom: 'Dakar',
    );
  }

  @override Future<void> saveToken(String t) => local.saveToken(t);
  @override Future<void> saveUserId(String id) => local.saveUserId(id);
  @override Future<void> saveIdentifier(String i) => local.saveIdentifier(i);
  @override Future<void> setLoggedOut(bool v) => local.setLoggedOut(v);
  @override Future<String?> getToken() => local.getToken();
  @override Future<String?> getSavedIdentifier() => local.getSavedIdentifier();
  @override Future<bool> hasBeenLoggedOut() => local.hasBeenLoggedOut();
  @override Future<void> logout() => local.clearAll();
}
