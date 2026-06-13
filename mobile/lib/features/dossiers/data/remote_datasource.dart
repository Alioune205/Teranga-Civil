import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/errors/exceptions.dart';
import 'models/dossier_model.dart';

class DossiersRemoteDatasource {
  final DioClient client;
  const DossiersRemoteDatasource({required this.client});

  Future<List<DossierModel>> getDossiers() async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    return [
      DossierModel(
        id: '1',
        type: 'Acte de naissance',
        status: 'termine',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        communeNom: 'Dakar Plateau',
        beneficiaryNom: 'Modou Diop',
        fraisFCFA: 1000,
        progress: 1.0,
      ),
      DossierModel(
        id: '2',
        type: 'Certificat de mariage',
        status: 'en_cours',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        communeNom: 'Fass',
        beneficiaryNom: 'Modou Diop & Aminata Sow',
        fraisFCFA: 2000,
        progress: 0.6,
      ),
      DossierModel(
        id: '3',
        type: 'Autorisation de construire',
        status: 'en_attente',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        communeNom: 'Rufisque',
        beneficiaryNom: 'Entreprise Diop',
        fraisFCFA: 50000,
        progress: 0.2,
      ),
      DossierModel(
        id: '4',
        type: 'Certificat de bonne vie et mœurs',
        status: 'incomplet',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        communeNom: 'Guédiawaye',
        beneficiaryNom: 'Fatou Ndiaye',
        fraisFCFA: 1500,
        progress: 0.1,
      ),
    ];
  }

  Future<DossierModel> getDossierById(String id) async {
    // MOCK DATA
    await Future.delayed(const Duration(milliseconds: 500));
    final all = await getDossiers();
    return all.firstWhere((d) => d.id == id, orElse: () => all.first);
  }

  Future<String> submitCertificate(Map<String, dynamic> payload) async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    return 'mock_dossier_123';
  }

  /// Télécharge le certificat PDF pour un dossier.
  /// Retourne le chemin local du fichier sauvegardé.
  Future<String> downloadCertificate(
    String dossierId, {
    void Function(int received, int total)? onProgress,
  }) async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/certificat_$dossierId.pdf';
    return savePath;
  }
}
