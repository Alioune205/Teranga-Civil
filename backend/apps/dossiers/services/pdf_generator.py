"""
pdf_generator.py — Génération de certificats officiels avec liaison cryptographique
====================================================================================
Processus en 5 étapes :
  1. Dessiner le PDF avec ReportLab (texte, cachets SVG, signature SVG, timbre)
  2. Calculer le SHA-256 du PDF brut
  3. Construire le payload canonique (données + pdf_hash)
  4. Signer le payload avec HMAC-SHA256
  5. Générer le QR Code pointant vers l'endpoint de vérification publique
  6. Re-générer le PDF final avec le QR Code inclus
"""
import os
import io
import logging
from io import BytesIO

import qrcode
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.units import cm, mm
from reportlab.lib.utils import ImageReader
from reportlab.lib.colors import HexColor
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_CENTER
import hashlib

def _draw_secure_timbre(p, x, y, reference):
    from reportlab.lib.colors import HexColor
    from reportlab.lib.units import cm
    VERT = HexColor('#00853F')
    ROUGE = HexColor('#E31B23')
    NOIR = HexColor('#000000')
    p.saveState()
    stamp_width = 3.3 * cm
    stamp_height = 2.0 * cm
    p.setFillColor(HexColor('#FFFFF0'))
    p.setStrokeColor(VERT)
    p.setLineWidth(1.5)
    p.roundRect(x, y, stamp_width, stamp_height, 4, stroke=1, fill=1)
    p.setStrokeColor(HexColor('#E0F0E0'))
    p.setLineWidth(0.5)
    for i in range(0, int(stamp_width), 5):
        p.line(x + i, y, x + i, y + stamp_height)
    p.setFillColor(VERT)
    p.setFont("Helvetica-Bold", 6)
    p.drawCentredString(x + stamp_width / 2, y + 1.5 * cm, "TIMBRE FISCAL ÉLECTRONIQUE")
    p.setFillColor(ROUGE)
    p.setFont("Helvetica-Bold", 11)
    p.drawCentredString(x + stamp_width / 2, y + 0.8 * cm, "500 FCFA")
    p.setFillColor(NOIR)
    p.setFont("Courier-Bold", 6)
    p.drawCentredString(x + stamp_width / 2, y + 0.2 * cm, f"Réf: {reference}")
    p.restoreState()

from django.conf import settings
from django.core.files.base import ContentFile

from apps.documents.models import GeneratedCertificate, TimbreFiscal
from apps.documents.crypto import compute_pdf_hash, build_payload, sign_payload

logger = logging.getLogger(__name__)

# Répertoire des assets (cachets, signatures)
ASSETS_DIR = os.path.join(settings.BASE_DIR, 'assets', 'seals')


def _try_draw_svg(c, svg_path, x, y, width, height):
    """
    Tente de dessiner un fichier SVG sur le canvas ReportLab.
    Fallback silencieux si le fichier n'existe pas ou si svglib échoue.
    """
    if not svg_path or not os.path.exists(svg_path):
        logger.warning(f"[PDF] Fichier SVG introuvable: {svg_path}")
        return False
    try:
        from svglib.svglib import svg2rlg
        from reportlab.graphics import renderPDF
        drawing = svg2rlg(svg_path)
        if drawing:
            # Redimensionner le dessin
            sx = width / drawing.width
            sy = height / drawing.height
            scale = min(sx, sy)
            drawing.width = drawing.width * scale
            drawing.height = drawing.height * scale
            drawing.scale(scale, scale)
            renderPDF.draw(drawing, c, x, y)
            return True
    except Exception as e:
        logger.warning(f"[PDF] Erreur rendu SVG {svg_path}: {e}")
    return False


def _try_draw_image(c, img_path, x, y, width, height):
    """
    Tente de dessiner un fichier image (PNG/JPG) sur le canvas.
    Fallback silencieux si le fichier n'existe pas.
    """
    if not img_path or not os.path.exists(img_path):
        return False
    try:
        c.drawImage(img_path, x, y, width=width, height=height, mask='auto')
        return True
    except Exception as e:
        logger.warning(f"[PDF] Erreur rendu image {img_path}: {e}")
    return False


def _draw_seal(c, path, x, y, size):
    """Dessine un cachet (SVG ou PNG) à la position donnée."""
    if path and path.endswith('.svg'):
        if not _try_draw_svg(c, path, x, y, size, size):
            _draw_placeholder_seal(c, x, y, size, "CACHET")
    elif path:
        if not _try_draw_image(c, path, x, y, size, size):
            _draw_placeholder_seal(c, x, y, size, "CACHET")
    else:
        _draw_placeholder_seal(c, x, y, size, "CACHET")


def _draw_placeholder_seal(c, x, y, size, label):
    """Dessine un cercle pointillé comme placeholder de cachet."""
    cx = x + size / 2
    cy = y + size / 2
    c.saveState()
    c.setStrokeColor(HexColor('#999999'))
    c.setDash(3, 3)
    c.circle(cx, cy, size / 2 - 2, stroke=1, fill=0)
    c.setFont("Helvetica", 7)
    c.setFillColor(HexColor('#999999'))
    c.drawCentredString(cx, cy - 3, f"[{label}]")
    c.restoreState()


def _generate_raw_pdf(dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path):
    """
    Génère le contenu PDF brut (SANS QR Code).
    On génère d'abord sans QR pour pouvoir hasher le contenu,
    puis on re-génère avec le QR.
    """
    buffer = BytesIO()
    pagesize = landscape(A4) if dossier.type == 'residence_certificate' else A4
    p = canvas.Canvas(buffer, pagesize=pagesize)
    width, height = pagesize

    if dossier.type == 'residence_certificate':
        _draw_residence_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader=None)
    elif dossier.type == 'marriage_certificate':
        _draw_mariage_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader=None)
    elif dossier.type == 'death_certificate':
        _draw_deces_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader=None)
    else:
        _draw_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader=None)

    p.showPage()
    p.save()
    buffer.seek(0)
    return buffer.getvalue()


def _generate_final_pdf(dossier, officier, timbre_ref, cachet_path,
                        signature_path, cachet_nominal_path, verification_url):
    """
    Génère le PDF final AVEC le QR Code de vérification.
    """
    # Générer le QR Code
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=10,
        border=2,
    )
    qr.add_data(verification_url)
    qr.make(fit=True)
    img_qr = qr.make_image(fill_color="black", back_color="white")

    qr_buffer = BytesIO()
    img_qr.save(qr_buffer, format="PNG")
    qr_buffer.seek(0)
    qr_image_reader = ImageReader(qr_buffer)

    # Générer le PDF final
    buffer = BytesIO()
    pagesize = landscape(A4) if dossier.type == 'residence_certificate' else A4
    p = canvas.Canvas(buffer, pagesize=pagesize)
    width, height = pagesize

    if dossier.type == 'residence_certificate':
        _draw_residence_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader)
    elif dossier.type == 'marriage_certificate':
        _draw_mariage_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader)
    elif dossier.type == 'death_certificate':
        _draw_deces_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader)
    else:
        _draw_pdf_content(p, width, height, dossier, officier, timbre_ref,
                          cachet_path, signature_path, cachet_nominal_path, qr_image_reader)

    p.showPage()
    p.save()
    buffer.seek(0)
    return buffer.getvalue()




# --- NEW DESIGN CONSTANTS ---
COLOR_VERT = HexColor('#00853F')
COLOR_JAUNE = HexColor('#FDEF42')
COLOR_ROUGE = HexColor('#E31B23')
COLOR_NOIR = HexColor('#000000')
COLOR_BG_CARTOUCHE = HexColor('#F9FAFB')
COLOR_BORDER = HexColor('#E5E7EB')
COLOR_GRIS = HexColor('#6B7280')

def _draw_watermark(p, width, height):
    p.saveState()
    baobab_path = os.path.join(settings.BASE_DIR, 'assets', 'baobab.png')
    if os.path.exists(baobab_path):
        # Image is a transparent PNG so mask='auto' is optional, but good for safety
        # We make it large and centered
        img_size = 18 * cm
        p.translate(width/2 - img_size/2, height/2 - img_size/2)
        p.drawImage(baobab_path, 0, 0, width=img_size, height=img_size, mask='auto')
    p.restoreState()

def _draw_official_header(p, width, height, commune, title, reference):
    banner_h = 0.3 * cm
    p.setFillColor(COLOR_VERT)
    p.rect(0, height - banner_h, width/3, banner_h, stroke=0, fill=1)
    p.setFillColor(COLOR_JAUNE)
    p.rect(width/3, height - banner_h, width/3, banner_h, stroke=0, fill=1)
    p.setFillColor(COLOR_ROUGE)
    p.rect(2*width/3, height - banner_h, width/3, banner_h, stroke=0, fill=1)

    y = height - 2.0 * cm
    p.setFillColor(COLOR_NOIR)
    p.setFont("Helvetica-Bold", 14)
    p.drawCentredString(width / 2, y, "RÉPUBLIQUE DU SÉNÉGAL")

    y -= 0.5 * cm
    p.setFont("Helvetica-Oblique", 10)
    p.drawCentredString(width / 2, y, "Un Peuple — Un But — Une Foi")

    y -= 0.8 * cm
    p.setFont("Helvetica-Bold", 10)
    region = commune.region if commune and hasattr(commune, 'region') and commune.region else "N/A"
    p.drawCentredString(width / 2, y, f"RÉGION DE {region.upper()}")

    y -= 0.5 * cm
    p.setFont("Helvetica-Bold", 11)
    p.setFillColor(COLOR_VERT)
    commune_name = commune.name if commune else "N/A"
    p.drawCentredString(width / 2, y, f"CENTRE D'ÉTAT CIVIL DE {commune_name.upper()}")

    p.setStrokeColor(COLOR_BORDER)
    p.setLineWidth(1)
    y -= 0.3 * cm
    p.line(4 * cm, y, width - 4 * cm, y)

    y -= 1.0 * cm
    p.setFillColor(COLOR_NOIR)
    p.setFont("Helvetica-Bold", 16)
    p.drawCentredString(width / 2, y, title.upper())

    y -= 0.6 * cm
    p.setFont("Helvetica", 10)
    p.drawCentredString(width / 2, y, f"Réf. Document : {reference}")

    return y - 1.0 * cm

def _draw_cartouche_section(p, width, start_y, title, lines_data):
    row_h = 0.7 * cm
    content_h = len(lines_data) * row_h
    total_h = content_h + 1.2 * cm

    box_x = 2.0 * cm
    box_w = width - 4.0 * cm
    box_y = start_y - total_h

    p.setFillColor(COLOR_BG_CARTOUCHE)
    p.setStrokeColor(COLOR_BORDER)
    p.setLineWidth(1)
    p.roundRect(box_x, box_y, box_w, total_h, 4, stroke=1, fill=1)

    p.setFillColor(COLOR_VERT)
    p.roundRect(box_x, box_y, 0.3*cm, total_h, 4, stroke=0, fill=1)
    p.rect(box_x + 0.15*cm, box_y, 0.15*cm, total_h, stroke=0, fill=1)

    p.setFillColor(COLOR_VERT)
    p.setFont("Helvetica-Bold", 11)
    p.drawString(box_x + 0.8 * cm, start_y - 0.7 * cm, title.upper())

    current_y = start_y - 1.4 * cm
    for i, row in enumerate(lines_data):
        if i % 2 == 1:
            p.setFillColor(HexColor('#F3F4F6'))
            p.rect(box_x + 0.3*cm, current_y - 0.2*cm, box_w - 0.3*cm, row_h, stroke=0, fill=1)

        p.setFillColor(COLOR_GRIS)
        p.setFont("Helvetica", 9)
        if len(row) >= 2:
            p.drawString(box_x + 1.0 * cm, current_y, f"{row[0]} : ")
            p.setFillColor(COLOR_NOIR)
            p.setFont("Helvetica-Bold", 9)
            p.drawString(box_x + 4.0 * cm, current_y, str(row[1]))

        if len(row) == 4 and row[2]:
            p.setFillColor(COLOR_GRIS)
            p.setFont("Helvetica", 9)
            p.drawString(box_x + 10.0 * cm, current_y, f"{row[2]} : ")
            p.setFillColor(COLOR_NOIR)
            p.setFont("Helvetica-Bold", 9)
            p.drawString(box_x + 13.0 * cm, current_y, str(row[3]))

        current_y -= row_h

    return box_y - 0.5 * cm

def _draw_official_footer(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader):
    footer_y = 6.0 * cm
    p.setStrokeColor(COLOR_BORDER)
    p.setLineWidth(1)
    p.line(2 * cm, footer_y, width - 2 * cm, footer_y)

    qr_x = 2.0 * cm
    qr_size = 2.5 * cm
    qr_y = footer_y - 3.5 * cm
    if qr_image_reader:
        p.drawImage(qr_image_reader, qr_x, qr_y, width=qr_size, height=qr_size)
        p.setFillColor(COLOR_NOIR)
        p.setFont("Helvetica", 7)
        p.drawCentredString(qr_x + qr_size / 2, qr_y - 0.3 * cm, "Vérifier l'authenticité")

    if timbre_ref:
        _draw_secure_timbre(p, qr_x + qr_size + 1.0 * cm, qr_y, timbre_ref)

    sig_zone_x = width - 11.0 * cm
    p.setFillColor(COLOR_NOIR)
    p.setFont("Helvetica", 9)
    commune_name = dossier.commune.name.capitalize() if dossier.commune else "N/A"
    from datetime import datetime
    date_str = dossier.updated_at.strftime('%d/%m/%Y') if dossier.updated_at else datetime.now().strftime('%d/%m/%Y')
    p.drawCentredString(sig_zone_x + 4.5 * cm, footer_y - 0.6 * cm, f"Fait à {commune_name}, le {date_str}")
    p.setFont("Helvetica-Bold", 9)
    officier_name = officier.full_name if officier else "L'Officier de l'État Civil"
    p.drawCentredString(sig_zone_x + 4.5 * cm, footer_y - 1.1 * cm, officier_name)

    seal_size = 3.2 * cm
    seal_y = footer_y - 4.5 * cm
    _draw_seal(p, cachet_path, sig_zone_x, seal_y, seal_size)
    if signature_path and os.path.exists(signature_path):
        p.drawImage(ImageReader(signature_path), sig_zone_x + 3.0*cm, seal_y + 0.5*cm, width=3.0*cm, height=1.5*cm, mask='auto')
    if cachet_nominal_path:
        _draw_seal(p, cachet_nominal_path, sig_zone_x + 5.8*cm, seal_y, seal_size)

    p.setFillColor(COLOR_GRIS)
    p.setFont("Helvetica-Oblique", 7)
    p.drawCentredString(width / 2, 0.8 * cm, "Document généré électroniquement - SUNU CIVIL / Teranga Civil. Ce document est sécurisé par une empreinte cryptographique (HMAC-SHA256).")

def _draw_residence_pdf_content(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader):
    _draw_watermark(p, width, height)
    y = _draw_official_header(p, width, height, dossier.commune, "CERTIFICAT DE RÉSIDENCE", dossier.reference)

    metadata = dossier.metadata or {}
    citizen = dossier.citizen
    prenoms = metadata.get('prenoms_requerant') or (citizen.first_name if citizen else "")
    nom = metadata.get('nom_requerant') or (citizen.last_name if citizen else "")
    nom_complet = f"{prenoms} {nom}".strip()
    date_naissance = metadata.get('date_naissance') or (str(citizen.profile.date_of_birth) if citizen and hasattr(citizen, 'profile') else "")
    lieu_naissance = metadata.get('lieu_naissance') or (citizen.profile.place_of_birth if citizen and hasattr(citizen, 'profile') else "")
    adresse = metadata.get('adresse') or (citizen.profile.address if citizen and hasattr(citizen, 'profile') else "")
    quartier = metadata.get('quartier', '')
    date_installation = metadata.get('date_installation', '')

    y = _draw_cartouche_section(p, width, y, "Informations du Résident", [
        ("Nom Complet", nom_complet, "Né(e) le", date_naissance),
        ("Lieu de Naissance", lieu_naissance, "", ""),
    ])

    y = _draw_cartouche_section(p, width, y, "Détails de la Résidence", [
        ("Adresse Principale", adresse, "Quartier", quartier),
        ("Date d'installation", date_installation, "", ""),
    ])

    commune_name = dossier.commune.name if dossier.commune else "INCONNUE"
    quartier_text = f" au quartier {quartier}" if quartier and quartier.strip() else ""
    texte_complet = (f"Nous soussigné(e) Maire de la Commune de {commune_name.capitalize()} certifions "
                     f"que {nom_complet} né(e) le {date_naissance} à {lieu_naissance} et qu'il (elle) "
                     f"réside à {adresse}{quartier_text} depuis {date_installation}.")

    p.setFillColor(COLOR_NOIR)
    p.setFont("Helvetica-Oblique", 11)
    para = Paragraph(texte_complet, ParagraphStyle(name='Center', fontName='Helvetica-Oblique', fontSize=12, leading=18, alignment=TA_CENTER))
    para.wrap(width - 6 * cm, 5 * cm)
    para.drawOn(p, 3 * cm, y - para.height - 0.5 * cm)

    _draw_official_footer(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader)

def _draw_mariage_pdf_content(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader):
    _draw_watermark(p, width, height)
    y = _draw_official_header(p, width, height, dossier.commune, "EXTRAIT DU REGISTRE DES ACTES DE MARIAGE", dossier.reference)

    metadata = dossier.metadata or {}

    y = _draw_cartouche_section(p, width, y, "Époux", [
        ("Nom", metadata.get('nom_epoux', ''), "Prénoms", metadata.get('prenom_epoux', '')),
        ("Date Naiss.", metadata.get('date_naissance_epoux', ''), "Lieu", metadata.get('lieu_naissance_epoux', '')),
        ("Profession", metadata.get('profession_epoux', ''), "Domicile", metadata.get('domicile_epoux', '')),
        ("Fils de", f"{metadata.get('prenom_pere_epoux', '')} {metadata.get('nom_pere_epoux', '')}", "Et de", f"{metadata.get('prenom_mere_epoux', '')} {metadata.get('nom_mere_epoux', '')}"),
    ])

    y = _draw_cartouche_section(p, width, y, "Épouse", [
        ("Nom", metadata.get('nom_epouse', ''), "Prénoms", metadata.get('prenom_epouse', '')),
        ("Date Naiss.", metadata.get('date_naissance_epouse', ''), "Lieu", metadata.get('lieu_naissance_epouse', '')),
        ("Profession", metadata.get('profession_epouse', ''), "Domicile", metadata.get('domicile_epouse', '')),
        ("Fille de", f"{metadata.get('prenom_pere_epouse', '')} {metadata.get('nom_pere_epouse', '')}", "Et de", f"{metadata.get('prenom_mere_epouse', '')} {metadata.get('nom_mere_epouse', '')}"),
    ])

    y = _draw_cartouche_section(p, width, y, "Détails du Mariage", [
        ("Célébré le", metadata.get('date_marriage', ''), "Option", metadata.get('option_souscrite', 'Monogamie')),
        ("Régime", metadata.get('regime_matrimonial', 'séparation des biens'), "Registre N°", str(metadata.get('registre_marriage') or metadata.get('registre', 'N/A'))),
    ])

    _draw_official_footer(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader)

def _draw_deces_pdf_content(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader):
    _draw_watermark(p, width, height)
    y = _draw_official_header(p, width, height, dossier.commune, "CERTIFICAT DE DÉCÈS", dossier.reference)

    metadata = dossier.metadata or {}

    y = _draw_cartouche_section(p, width, y, "Informations du Défunt(e)", [
        ("Nom", metadata.get('nom_defunt', ''), "Prénoms", metadata.get('prenom_defunt', '')),
        ("Sexe", metadata.get('sexe_defunt', ''), "Nationalité", metadata.get('nationalite_defunt', '')),
        ("Né(e) le", metadata.get('date_naissance_defunt', ''), "À", metadata.get('lieu_naissance_defunt', '')),
        ("Profession", metadata.get('profession_defunt', ''), "Domicile", metadata.get('adresse_defunt', '')),
    ])

    y = _draw_cartouche_section(p, width, y, "Détails du Décès", [
        ("Date du décès", metadata.get('date_deces', ''), "Heure", metadata.get('heure_deces', '')),
        ("Lieu du décès", metadata.get('lieu_deces', ''), "", ""),
    ])

    y = _draw_cartouche_section(p, width, y, "Déclarant", [
        ("Nom & Prénom", metadata.get('nom_declarant', ''), "Lien", metadata.get('lien_declarant', '')),
        ("Pièce d'Identité", metadata.get('cni_declarant', ''), "", ""),
    ])

    _draw_official_footer(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader)

def _draw_pdf_content(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader):
    _draw_watermark(p, width, height)

    type_display = dossier.get_type_display().upper() if hasattr(dossier, 'get_type_display') else "EXTRAIT DE NAISSANCE"
    title = "EXTRAIT DU REGISTRE DES ACTES DE NAISSANCE" if dossier.type == 'birth_certificate' else type_display

    y = _draw_official_header(p, width, height, dossier.commune, title, dossier.reference)

    metadata = dossier.metadata or {}
    citizen = dossier.citizen

    prenoms_enfant = metadata.get('prenoms_enfant')
    nom_enfant = metadata.get('nom_enfant')
    date_naissance_personne = metadata.get('date_naissance_personne')
    lieu_naissance = metadata.get('lieu_naissance')
    sexe = metadata.get('sexe')

    if not dossier.metadata.get('is_for_third_party') and citizen:
        prenoms_enfant = prenoms_enfant or citizen.first_name
        nom_enfant = nom_enfant or citizen.last_name
        if hasattr(citizen, 'profile'):
            date_naissance_personne = date_naissance_personne or str(citizen.profile.date_of_birth)
            lieu_naissance = lieu_naissance or citizen.profile.place_of_birth
            sexe = sexe or citizen.profile.get_gender_display()

    nom_enfant = nom_enfant or metadata.get('nom') or 'N/A'
    prenoms_enfant = prenoms_enfant or 'N/A'
    date_naissance_personne = date_naissance_personne or metadata.get('date_naissance') or 'N/A'
    lieu_naissance = lieu_naissance or 'N/A'
    sexe = sexe or 'N/A'

    annee_registre = str(metadata.get('annee_registre', 'N/A'))
    numero_registre = str(metadata.get('numero_registre') or metadata.get('registre', 'N/A'))

    dept_name = dossier.commune.department if dossier.commune and hasattr(dossier.commune, 'department') and dossier.commune.department else "N/A"
    commune_name = dossier.commune.name if dossier.commune else "N/A"

    y = _draw_cartouche_section(p, width, y, "Informations Administratives", [
        ("Département", dept_name, "Commune", commune_name),
        ("Année Registre", annee_registre, "Numéro Registre", numero_registre),
    ])

    y = _draw_cartouche_section(p, width, y, "Informations de l'Enfant", [
        ("Prénoms", prenoms_enfant, "Nom", nom_enfant),
        ("Né(e) le", date_naissance_personne, "Heure", metadata.get('heure_naissance', 'Non précisée')),
        ("Lieu", lieu_naissance, "Sexe", sexe),
    ])

    y = _draw_cartouche_section(p, width, y, "Informations des Parents", [
        ("Nom Père", metadata.get('nom_pere', 'N/A'), "", ""),
        ("Prénoms Mère", metadata.get('prenom_mere', metadata.get('nom_mere', 'N/A')), "Nom Mère", metadata.get('nom_mere', 'N/A')),
    ])

    if metadata.get('est_jugement_suppletif'):
        y = _draw_cartouche_section(p, width, y, "Jugement d'Autorisation d'Inscription", [
            ("Tribunal", metadata.get('tribunal_competent', 'N/A'), "N° Jugement", metadata.get('numero_jugement', 'N/A')),
            ("Date Jugement", metadata.get('date_jugement', 'N/A'), "Date Inscription", f"{metadata.get('date_inscription', 'N/A')} ({metadata.get('annee_inscription', '')})"),
        ])

    _draw_official_footer(p, width, height, dossier, officier, timbre_ref, cachet_path, signature_path, cachet_nominal_path, qr_image_reader)


def generate_signed_certificate(dossier, officier):
    """
    Fonction principale : génère un certificat PDF signé cryptographiquement.

    Processus :
      1. Crée un timbre fiscal
      2. Génère le PDF brut (sans QR)
      3. Hash le PDF brut (SHA-256)
      4. Construit le payload : ref|commune|nom|date|officier_id|pdf_sha256
      5. Signe le payload avec HMAC-SHA256
      6. Génère le QR Code avec l'URL de vérification
      7. Régénère le PDF final avec le QR Code
      8. Sauvegarde le GeneratedCertificate en BDD

    Returns:
        GeneratedCertificate: L'objet certificat créé avec sa signature.
    """
    # --- 1. Créer le timbre fiscal ---
    timbre = TimbreFiscal.objects.create(is_used=True)

    cachet_communal_path = ''
    signature_officier_path = ''
    cachet_nominal_path = ''

    if dossier.commune:
        if dossier.commune.chemin_cachet_communal:
            cachet_communal_path = os.path.join(settings.BASE_DIR, dossier.commune.chemin_cachet_communal)
        if dossier.commune.chemin_signature_officier:
            signature_officier_path = os.path.join(settings.BASE_DIR, dossier.commune.chemin_signature_officier)
        if dossier.commune.chemin_cachet_nominal:
            cachet_nominal_path = os.path.join(settings.BASE_DIR, dossier.commune.chemin_cachet_nominal)
                    
    # FALLBACK FOR DEMO/DEV: If cachets are still missing, use dakar_plateau as fallback
    if not cachet_communal_path or not signature_officier_path or not cachet_nominal_path:
        folder_path = os.path.join(ASSETS_DIR, 'dakar_plateau')
        if os.path.exists(folder_path):
            for file in os.listdir(folder_path):
                if file.startswith('Cachet_Communal') and file.endswith('.png'):
                    cachet_communal_path = os.path.join(folder_path, file)
                elif file.startswith('Signarure_Officier') and file.endswith('.png'):
                    signature_officier_path = os.path.join(folder_path, file)
                elif file.startswith('Cachet_Nominal') and file.endswith('.png'):
                    cachet_nominal_path = os.path.join(folder_path, file)

    # --- Règle Métier R3 : Vérification des 4 éléments de validation ---
    if not cachet_communal_path or not signature_officier_path or not cachet_nominal_path or not timbre:
        raise ValueError(
            "Règle R3 non respectée : Un extrait sans les 4 éléments de validation "
            "(signature + cachet Baobab + cachet nominal + Timbre) est invalide "
            "et ne peut être délivré."
        )

    # --- 3. Générer le PDF brut (sans QR) ---
    raw_pdf_bytes = _generate_raw_pdf(
        dossier, officier, timbre.reference,
        cachet_communal_path, signature_officier_path, cachet_nominal_path
    )

    # --- 4. Hash du PDF brut ---
    pdf_hash = compute_pdf_hash(raw_pdf_bytes)

    # --- 5. Construire et signer le payload ---
    commune_name = dossier.commune.name if dossier.commune else 'N/A'
    
    # Gérer le cas du Guichet Rapide où citizen est None et citoyen_guichet est utilisé
    citizen_name = "N/A"
    if dossier.citizen:
        citizen_name = dossier.citizen.full_name
    elif hasattr(dossier, 'citoyen_guichet') and dossier.citoyen_guichet:
        citizen_name = dossier.citoyen_guichet.nom_complet
        
    metadata = dossier.metadata or {}
    date_naissance = metadata.get('date_naissance_verification', 'N/A')

    payload = build_payload(
        dossier_reference=dossier.reference,
        commune_name=commune_name,
        citizen_name=citizen_name,
        date_naissance=str(date_naissance),
        officier_id=str(officier.id) if officier else 'N/A',
        pdf_sha256=pdf_hash,
    )
    signature = sign_payload(payload)

    # --- 6. Construire l'URL de vérification ---
    frontend_url = getattr(settings, 'FRONTEND_URL', 'http://localhost:3000')
    verification_url = f"{frontend_url}/verify/{dossier.reference}?sig={signature}"

    # --- 7. Régénérer le PDF final avec le QR ---
    final_pdf_bytes = _generate_final_pdf(
        dossier, officier, timbre.reference,
        cachet_communal_path, signature_officier_path, cachet_nominal_path,
        verification_url
    )

    # --- 8. Sauvegarder en BDD ---
    cert = GeneratedCertificate(
        dossier=dossier,
        officier=officier,
        data_payload=payload,
        pdf_sha256=pdf_hash,
        hmac_signature=signature,
        timbre=timbre,
        cachet_communal_svg=cachet_communal_path,
        signature_officier_svg=signature_officier_path,
    )

    pdf_filename = f"Certificat_{dossier.reference}.pdf"
    cert.pdf_file.save(pdf_filename, ContentFile(final_pdf_bytes), save=False)
    cert.save()

    logger.info(
        f"[CRYPTO][OK] Certificat généré pour {dossier.reference}. "
        f"PDF Hash: {pdf_hash[:16]}... Signature: {signature[:16]}..."
    )

    return cert
