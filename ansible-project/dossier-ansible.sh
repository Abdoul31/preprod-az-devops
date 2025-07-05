#!/bin/bash

PROJECT_DIR="ansible-project"

# Vérifier si le dossier existe déjà
if [ -d "$PROJECT_DIR" ]; then
    echo "Le dossier $PROJECT_DIR existe déjà. Création de la structure à l'intérieur..."
else
    echo "Création du dossier $PROJECT_DIR et de la structure..."
    sudo mkdir -p "$PROJECT_DIR"
fi

# Créer les fichiers à la racine
sudo touch "$PROJECT_DIR/inventory.ini"
sudo touch "$PROJECT_DIR/playbook.yml"
sudo touch "$PROJECT_DIR/ansible.cfg"

# Créer l'arborescence des rôles
sudo mkdir -p "$PROJECT_DIR/roles/nginx/tasks"
sudo mkdir -p "$PROJECT_DIR/roles/nodejs/tasks"
sudo mkdir -p "$PROJECT_DIR/roles/postgresql/tasks"

# Créer les fichiers main.yml pour chaque rôle
sudo touch "$PROJECT_DIR/roles/nginx/tasks/main.yml"
sudo touch "$PROJECT_DIR/roles/nodejs/tasks/main.yml"
sudo touch "$PROJECT_DIR/roles/postgresql/tasks/main.yml"

echo "Structure créée avec succès !"
echo "Contenu du projet :"
tree -a "$PROJECT_DIR"