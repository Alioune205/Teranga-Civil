import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class OtherPersonScreen extends ConsumerStatefulWidget {
  final String docId;
  final String docName;

  const OtherPersonScreen({
    super.key,
    this.docId = 'extrait_naissance',
    this.docName = 'Extrait de naissance',
  });

  @override
  ConsumerState<OtherPersonScreen> createState() => _OtherPersonScreenState();
}

class _OtherPersonScreenState extends ConsumerState<OtherPersonScreen> {
  // OCR Status
  bool _ocrLoading = false;
  bool _ocrSuccess = false;

  // Form Controllers
  final TextEditingController _registreController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  
  String? _selectedRegion;
  String? _selectedCommune;
  String? _lienParente;
  
  bool _cniUploaded = false;

  bool get _isFormValid =>
      _registreController.text.isNotEmpty &&
      _anneeController.text.isNotEmpty &&
      _nomController.text.isNotEmpty &&
      _selectedRegion != null &&
      _selectedCommune != null &&
      _lienParente != null &&
      _cniUploaded;

  @override
  void dispose() {
    _registreController.dispose();
    _anneeController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  void _simulateOcrUpload() async {
    setState(() {
      _ocrLoading = true;
    });

    // Simulate OCR delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _ocrLoading = false;
      _ocrSuccess = true;
      _registreController.text = '1042'; 
      _anneeController.text = '2015';
      _nomController.text = 'Amina Fall'; // Simulated child name
      _selectedRegion = 'Dakar';
      _selectedCommune = 'Rufisque';
    });
  }

  void _simulateUpload() {
    setState(() {
      _cniUploaded = true;
    });
  }

  void _submitForm() {
    if (!_isFormValid) return;
    
    context.push(AppRoutes.naissanceRecapOther, extra: {
      'docId': widget.docId,
      'docName': widget.docName,
      'forSelf': false,
      'registre': _registreController.text,
      'annee': _anneeController.text,
      'nom': _nomController.text,
      'region': _selectedRegion,
      'commune': _selectedCommune,
      'lienParente': _lienParente,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.docName} (Proche)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demande de ${widget.docName.toLowerCase()} pour un proche', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                widget.docId == 'copie_litterale' ? 'Délai : 48h • Validité : 3 mois' : 'Délai : 48h',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 32),

              // SECTION OCR (Optionnel)
              Text('Optionnel : Scanner l\'ancien document', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Text(
                'Uploadez une photo du document de votre proche pour pré-remplir les informations ci-dessous.',
                style: TextStyle(color: const Color(0xFF64748B), fontSize: 13, fontFamily: 'Inter', height: 1.4),
              ),
              const SizedBox(height: 16),
              _buildOcrCard(),
              
              const SizedBox(height: 32),

              Text('Identité du titulaire', style: AppTextStyles.labelLarge),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('N° Registre', _registreController, keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Année', _anneeController, keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField('Prénom et nom (Titulaire)', _nomController),
              const SizedBox(height: 16),

              _buildDropdown('Région de naissance', _selectedRegion, ['Dakar', 'Thiès', 'Saint-Louis'], (val) {
                setState(() => _selectedRegion = val);
              }),
              const SizedBox(height: 16),

              _buildDropdown('Commune de naissance', _selectedCommune, ['Dakar Plateau', 'Médina', 'Rufisque'], (val) {
                setState(() => _selectedCommune = val);
              }),

              const SizedBox(height: 32),
              
              Text('Votre relation (Demandeur)', style: AppTextStyles.labelLarge),
              const SizedBox(height: 16),
              
              _buildDropdown('Lien de parenté', _lienParente, ['Père', 'Mère', 'Conjoint(e)', 'Enfant'], (val) {
                setState(() => _lienParente = val);
              }),
              
              const SizedBox(height: 16),
              
              _buildUploadItem('Votre carte d\'identité (CNI)', _cniUploaded, _simulateUpload),

              const SizedBox(height: 40),

              // Bouton Soumettre
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _submitForm,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _isFormValid ? const LinearGradient(
                        colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ) : null,
                      color: _isFormValid ? null : const Color(0xFFE2E8F0),
                    ),
                    child: Text(
                      'Voir le récapitulatif',
                      style: TextStyle(
                        color: _isFormValid ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOcrCard() {
    if (_ocrSuccess) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF16A34A), size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Données extraites avec succès !',
                    style: TextStyle(color: Color(0xFF166534), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Vérifiez les champs pré-remplis ci-dessous.',
                    style: TextStyle(color: Color(0xFF15803D), fontSize: 12, fontFamily: 'Inter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _ocrLoading ? null : _simulateOcrUpload,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _ocrLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.document_scanner_rounded, color: Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ocrLoading ? 'Analyse en cours...' : 'Uploader le document',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ocrLoading ? 'Veuillez patienter.' : 'Format PDF, JPG ou PNG',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            if (!_ocrLoading)
              const Icon(Icons.upload_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildUploadItem(String title, bool isUploaded, VoidCallback onUpload) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUploaded ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUploaded ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle_rounded : Icons.badge_outlined,
              color: isUploaded ? const Color(0xFF16A34A) : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isUploaded ? const Color(0xFF166534) : const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (!isUploaded)
            GestureDetector(
              onTap: onUpload,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B285D), Color(0xFF1B4A9C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.upload_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Upload',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
            )
          else
            const Text(
              'Ajouté',
              style: TextStyle(color: Color(0xFF16A34A), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
            ),
        ],
      ),
    );
  }
}
