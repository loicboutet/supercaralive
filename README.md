# README

## Description générale du projet

Plateforme web connectant des professionnels de l'automobile (mécaniciens, carrossiers, laveurs de voitures) proposant des services à domicile avec des particuliers ayant besoin d'entretien ou de réparation de véhicule. La plateforme facilite la réservation de rendez-vous, la transparence des prix et le paiement en ligne.

## Fonctionnalités à développer

### 🏗️ BRIQUE 1 - Plateforme de base et système de réservation (€5000)

#### 👤 Admin (5000.dev)
- ✅ Je peux créer et configurer des compte utilisateurs lors de l'onboarding
- ✅ Je peux valider manuellement les inscriptions de professionnels
- ✅ Je peux superviser les aspects techniques sans accéder aux données clients

#### 👑 Professionnel (Mécanicien/Carrossier/Laveur)
- ✅ Je peux créer mon profil avec nom d'entreprise, photo, zone géographique de service (rayon en km)
- ✅ Je peux télécharger mes documents de vérification (diplôme, assurance, SIREN pour les mécaniciens)
- ✅ Je peux sélectionner les services que j'offre (choix multiples prédéfinis : entretien annuel, lavage extérieur, lavage intérieur, etc.)
- ✅ Je peux définir mes tarifs (forfait ou tarif horaire + frais de déplacement)
- ✅ Je peux gérer mon calendrier de disponibilité
- ✅ Je peux recevoir des pré-réservations de créneaux et les valider/refuser
- ✅ Je peux consulter les détails de la demande (modèle de voiture, kilométrage, description du besoin)
- [ ] Je peux communiquer avec le client via la messagerie intégrée
- ✅ Je peux consulter mon historique de services

#### 🚗 Client (Particulier)
- ✅ Je peux créer mon compte de manière anonyme (initiales ou pseudonyme visible)
- ✅ Je peux rechercher des professionnels par type de service et localisation (liste avec filtres)
- ✅ Je peux consulter les profils de professionnels (services, tarifs, avis, zone de service)
- ✅ Je peux sélectionner un créneau de disponibilité et faire une pré-réservation
- ✅ Je peux indiquer mon modèle de voiture, le kilométrage et décrire mon besoin
- [ ] Je peux communiquer avec le professionnel via la messagerie intégrée
- ✅ Je peux consulter mes réservations en cours et passées

#### ⚙️ Fonctionnalités système Brique 1
- ✅ Authentification et gestion de profils utilisateurs (3 types : Admin, Professionnel, Client)
- ✅ Système de géolocalisation par rayon (recherche dans un périmètre défini)
- ✅ Gestion des services proposés (tags/catégories prédéfinis)
- ✅ Système de pré-réservation de créneaux avec validation
- [ ] Messagerie interne entre professionnels et clients
- [ ] Notifications par email pour les événements clés (nouvelle demande, validation, rappel de rendez-vous)
- [ ] Interface web responsive (application web)
- [ ] Anonymisation des données clients (adresse masquée jusqu'à la validation finale)

### 🔒 BRIQUE 2 - Paiement, avis et portefeuille (€5000)

#### 👑 Professionnel
- [ ] Je peux valider le prix final après discussion avec le client
- [ ] Je peux marquer un service comme terminé
- [ ] Je peux consulter les avis laissés sur mon profil
- [ ] Je peux laisser un avis sur le client (étoiles sur des critères)

#### 🚗 Client
- [ ] Je peux payer en ligne via le module de paiement intégré (Stripe) après validation du professionnel
- [ ] Je peux consulter mon portefeuille personnel avec l'historique de toutes mes factures
- [ ] Je peux télécharger mes factures
- [ ] Je peux laisser un avis sur le professionnel (étoiles sur 5 critères : ponctualité, qualité, propreté, relationnel, rapport qualité-prix)
- [ ] Je peux consulter les avis d'autres clients
- [ ] Je reçois des notifications de rappel pour l'entretien périodique

#### ⚙️ Fonctionnalités système Brique 2
- [ ] Intégration du module de paiement sécurisé (Stripe)
- [ ] Système de pré-autorisation bancaire (pour les services au tarif horaire)
- [ ] Génération automatique de factures
- [ ] Portefeuille client personnel avec historique des services
- [ ] Système d'avis bidirectionnel (professionnel ↔ client)
- [ ] Notation par étoiles multi-critères
- [ ] Modération automatique des avis (détection de contenu inapproprié)
- [ ] Système de rappel automatique pour l'entretien périodique
- [ ] Export de documents (factures PDF)

## Éléments explicitement exclus

Les éléments suivants sont explicitement exclus du périmètre des 2 premières briques :

- Génération automatique de devis détaillés avec pièces
- Système de téléchargement de photos de véhicule
- Application mobile native (iOS/Android)
- Intégration de catalogue constructeur automobile
- Assistant IA prédictif pour l'entretien
- Comparateur d'assurance auto
- Notifications push natives (remplacées par les notifications email)
- Système de parrainage

Cette liste de fonctionnalités constitue le périmètre contractuel de développement à réaliser.
