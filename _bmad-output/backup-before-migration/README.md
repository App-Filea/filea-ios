# Backup de la Base de Données - Avant Migration

## Statut

✅ **Dossier de backup créé**
❌ **Aucune base de données à sauvegarder** - L'application n'a pas encore été lancée avec des données.

## Localisation de la Base de Données

- **Chemin par défaut** : `~/Library/Application Support/com.nicolasbarb.filea/invoicer.db`
- **Format** : SQLite (GRDB)
- **Fichiers associés** :
  - `invoicer.db` (base principale)
  - `invoicer.db-wal` (Write-Ahead Log)
  - `invoicer.db-shm` (Shared Memory)

## Comment Créer un Backup Manuel

Si vous souhaitez créer un backup de votre base de données actuelle, exécutez :

```bash
# Copier tous les fichiers de la base de données
cp ~/Library/Application\ Support/com.nicolasbarb.filea/invoicer.db* \
   _bmad-output/backup-before-migration/

# Vérifier le backup
ls -lh _bmad-output/backup-before-migration/
```

## Restauration

Pour restaurer depuis un backup :

```bash
# Copier les fichiers de backup vers le dossier Application Support
cp _bmad-output/backup-before-migration/invoicer.db* \
   ~/Library/Application\ Support/com.nicolasbarb.filea/
```

## Notes

- La migration vers `sqlite-data` 1.4.3 est **compatible** avec les données existantes
- Les fichiers JSON `.vehicle_metadata.json` servent également de backup portable
- Aucune perte de données attendue lors de la migration
