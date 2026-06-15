import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from io import BytesIO
import qrcode
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.utils import ImageReader

from apps.dossiers.services.pdf_generator import (
    _draw_pdf_content,
    _draw_birth_certificate_content,
    _draw_residence_pdf_content,
    _draw_deces_pdf_content,
    _draw_mariage_pdf_content,
)

class CommuneMock:
    name = "Keur Massar"
    region = "Dakar"
    department = "Keur Massar"
    nom_officier_etat_civil = "Khadija FAYE"

class OfficierMock:
    full_name = "Khadija FAYE"

def get_base_dossier(ref, doc_type):
    class DossierMock:
        reference = ref
        type = doc_type
        commune = CommuneMock()
        citizen = None
        updated_at = None
        created_at = None
        def get_type_display(self):
            mapping = {
                'birth_certificate': 'Acte de naissance',
                'marriage_certificate': 'Acte de mariage',
                'death_certificate': 'Acte de décès',
                'residence_certificate': 'Certificat de résidence'
            }
            return mapping.get(self.type, 'Autre')
        metadata = {}
    return DossierMock()

def make_qr_reader(ref):
    qr = qrcode.QRCode(version=1, box_size=10, border=1)
    qr.add_data(f"https://teranga-civil.sn/verify/{ref}")
    qr.make(fit=True)
    img_qr = qr.make_image(fill_color="black", back_color="white")
    qr_buffer = BytesIO()
    img_qr.save(qr_buffer, format="PNG")
    qr_buffer.seek(0)
    return ImageReader(qr_buffer)

cachet_path = r"C:\Users\senep\Desktop\Hackathon\Cachet Etat civil keur Massar.jpg"
cachet_nominal_path = r"C:\Users\senep\Desktop\Hackathon\Cachet nominale Keur Massar.jpg"
signature_path = r"C:\Users\senep\Desktop\Hackathon\signature keur massar.jpg"

if not os.path.exists(cachet_path): cachet_path = ''
if not os.path.exists(cachet_nominal_path): cachet_nominal_path = ''
if not os.path.exists(signature_path): signature_path = ''

def gen_mariage():
    dossier = get_base_dossier("MAR-2026-0089", "marriage_certificate")
    dossier.metadata = {
        'registre_marriage': '142',
        'annee_marriage': 'deux mille vingt-six',
        'nom_epoux': 'NDIAYE',
        'prenom_epoux': 'Amadou',
        'profession_epoux': 'Ingénieur',
        'domicile_epoux': 'Keur Massar',
        'date_naissance_epoux': '12/04/1990',
        'lieu_naissance_epoux': 'Dakar',
        'prenom_pere_epoux': 'Moussa',
        'nom_pere_epoux': 'NDIAYE',
        'prenom_mere_epoux': 'Fatou',
        'nom_mere_epoux': 'SOW',
        'nom_epouse': 'DIOP',
        'prenom_epouse': 'Awa',
        'profession_epouse': 'Commerçante',
        'domicile_epouse': 'Pikine',
        'date_naissance_epouse': '05/08/1995',
        'lieu_naissance_epouse': 'Pikine',
        'prenom_pere_epouse': 'Oumar',
        'nom_pere_epouse': 'DIOP',
        'prenom_mere_epouse': 'Aminata',
        'nom_mere_epouse': 'FALL',
        'date_marriage': '15/06/2026',
        'option_souscrite': 'Monogamie',
        'regime_matrimonial': 'Séparation des biens',
        'ville': 'Keur Massar',
        'centre_nom': 'Keur Massar',
        'date_enregistrement': '15/06/2026',
        'lieu_enregistrement': 'Keur Massar',
        'officier_nom': 'Khadija FAYE'
    }
    buffer = BytesIO()
    p = canvas.Canvas(buffer, pagesize=A4)
    _draw_mariage_pdf_content(
        p, A4[0], A4[1], dossier, OfficierMock(), "TF-MAR-99X2",
        cachet_path, signature_path, cachet_nominal_path, make_qr_reader(dossier.reference)
    )
    p.showPage()
    p.save()
    with open('certificat_mariage_test_final.pdf', 'wb') as f:
        f.write(buffer.getvalue())

def gen_deces():
    dossier = get_base_dossier("DEC-2026-0042", "death_certificate")
    dossier.metadata = {
        'nom_defunt': 'NDIAYE',
        'prenom_defunt': 'Mamadou Lamine',
        'sexe_defunt': 'Masculin',
        'date_naissance_defunt': '15 Mars 1950',
        'lieu_naissance_defunt': 'Saint-Louis',
        'nationalite_defunt': 'Sénégalaise',
        'profession_defunt': 'Enseignant Retraité',
        'adresse_defunt': 'Unité 15, Keur Massar',
        'date_deces': '10 Juin 2026',
        'heure_deces': '14h30',
        'lieu_deces': 'Hôpital Militaire de Ouakam',
        'nom_declarant': 'Fatou NDIAYE',
        'lien_declarant': 'Fille',
        'cni_declarant': '1 756 1990 01234'
    }
    buffer = BytesIO()
    pagesize = landscape(A4)
    p = canvas.Canvas(buffer, pagesize=pagesize)
    _draw_deces_pdf_content(
        p, pagesize[0], pagesize[1], dossier, OfficierMock(), "TF-DEC-88Y1",
        cachet_path, signature_path, cachet_nominal_path, make_qr_reader(dossier.reference)
    )
    p.showPage()
    p.save()
    with open('certificat_deces_test_final.pdf', 'wb') as f:
        f.write(buffer.getvalue())

def gen_residence():
    dossier = get_base_dossier("RES-2026-0089", "residence_certificate")
    dossier.metadata = {
        'nom_demandeur': 'Mamadou Diop',
        'date_naissance_demandeur': '12 Mai 1985',
        'lieu_naissance_demandeur': 'Dakar',
        'adresse_demandeur': 'Villa 123, Unité 15',
        'quartier_demandeur': 'Unité 15',
        'annee_residence': '2010',
        'numero_sd': '45',
        'numero_registre': '890'
    }
    buffer = BytesIO()
    pagesize = landscape(A4)
    p = canvas.Canvas(buffer, pagesize=pagesize)
    _draw_residence_pdf_content(
        p, pagesize[0], pagesize[1], dossier, OfficierMock(), "TF-RES-5421",
        cachet_path, signature_path, cachet_nominal_path, make_qr_reader(dossier.reference)
    )
    p.showPage()
    p.save()
    with open('certificat_residence_test_final.pdf', 'wb') as f:
        f.write(buffer.getvalue())

def gen_naissance():
    dossier = get_base_dossier("NAI-2026-1020", "birth_certificate")
    dossier.metadata = {
        'prenoms_enfant': 'Saliou',
        'nom_enfant': 'DIOP',
        'date_naissance_personne': '20 Février 2026',
        'heure_naissance': '08h15',
        'lieu_naissance': 'Hôpital de Pikine',
        'sexe': 'Masculin',
        'nom_pere': 'Ousmane DIOP',
        'prenom_mere': 'Aïssatou',
        'nom_mere': 'SOW',
        'annee_registre': '2026',
        'numero_registre': '1020'
    }
    buffer = BytesIO()
    p = canvas.Canvas(buffer, pagesize=A4)
    _draw_birth_certificate_content(
        p, A4[0], A4[1], dossier, OfficierMock(), "TF-NAI-991A",
        cachet_path, signature_path, cachet_nominal_path, make_qr_reader(dossier.reference)
    )
    p.showPage()
    p.save()
    with open('certificat_naissance_test_final.pdf', 'wb') as f:
        f.write(buffer.getvalue())

if __name__ == '__main__':
    gen_mariage()
    print("certificat_mariage_test_final.pdf généré")
    gen_deces()
    print("certificat_deces_test_final.pdf généré")
    gen_residence()
    print("certificat_residence_test_final.pdf généré")
    gen_naissance()
    print("certificat_naissance_test_final.pdf généré")
