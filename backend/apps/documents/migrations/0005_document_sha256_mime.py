# Migration manuelle — Fix bilan intégration 14/06
# Ajout des champs sha256_hash et mime_type au modèle Document
# (requis par la logique de déduplication dans documents/views.py)

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('documents', '0004_timbrefiscal_generatedcertificate'),
    ]

    operations = [
        migrations.AddField(
            model_name='document',
            name='sha256_hash',
            field=models.CharField(
                blank=True,
                default='',
                help_text="Empreinte SHA-256 du fichier uploadé (anti-doublon).",
                max_length=64,
                verbose_name='Hash SHA-256',
            ),
        ),
        migrations.AddField(
            model_name='document',
            name='mime_type',
            field=models.CharField(
                blank=True,
                default='',
                help_text="Type MIME détecté lors de l'upload (ex: image/jpeg, application/pdf).",
                max_length=100,
                verbose_name='Type MIME',
            ),
        ),
        migrations.AddIndex(
            model_name='document',
            index=models.Index(fields=['sha256_hash'], name='documents_d_sha256__hash_idx'),
        ),
    ]
