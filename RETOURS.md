# Liste des retours - SuperCarAlive

## 📹 Retours vidéo

### Documents professionnel
- [x] **Chargement de documents** - Lorsque le professionnel charge ses documents, il manque un bouton "Envoyer les documents" ou un encart en surcouche confirmant le bon envoi des documents. On ne comprend pas bien que les documents ont bien été chargés.
  - URL concernée : Page de chargement des documents du professionnel
  - ✅ Résolu : Ajout d'une alerte flash explicite avec le nom du document ajouté

### Accès aux données
- [x] **Numéros de téléphone** - Pourquoi est-ce que je ne peux pas avoir accès aux numéros de téléphone enregistrés dans le système ?
  - ✅ Résolu : Ajout de l'affichage du numéro de téléphone dans la page show des utilisateurs (admin/users/:id), visible même s'il n'est pas renseigné (affiche "Non renseigné")

### CGV et politique de confidentialité
- [ ] **Mise à jour des CGV et politique de confidentialité** - Comment procéder pour les mettre à jour ? Lien avec les pages développées par Simplébeau ?

---

## 🌐 Retours site

### Services - Détailing manquant
- [ ] **Ajout du Détailing dans les choix de services** - Sur l'ensemble du site, dès qu'un service (Mécanique, Carrossier, Lavage) est à choisir, il manque le Détailing.
  - URLs concernées : Toutes les pages avec sélection de services
  - URL spécifique : https://supercaralive.5000.dev/client/professionals

### Logo et identité visuelle
- [ ] **Suppression du logo vignette** - Supprimer le logo vignette de chaque onglet et pour le portail admin
- [ ] **Logo sur les pages de connexion** - Le logo n'est pas supprimé sur les pages de connexion. Vous pouvez juste ajouter SUPERCARALIVE avec le code couleur habituel.
  - URL concernée : https://supercaralive.5000.dev/client

### Paramétrage admin
- [ ] **Lien "Contacter le support" paramétrable** - Le lien "Contacter le support" devrait être paramétrable côté admin pour intégrer WhatsApp par exemple.
  - URL concernée : https://supercaralive.5000.dev/client/professionals

### Calendrier professionnel
- [ ] **Flexibilité du calendrier** - Le calendrier est limité par jour, par exemple j'ajoute un créneau le lundi et cela impacte tous les lundis. Je pensais qu'il y avait plus de flexibilité dans la gestion de l'agenda et qu'il pouvait être modifié de façon journalière et non pas une duplication exacte de la même journée chaque semaine.
  - URL concernée : https://supercaralive.5000.dev/professional/availability_slots

### Réservations professionnel
- [ ] **Boutons Accepter/Refuser sur prestation terminée** - Sur la page de réservation, la prestation est terminée et on a encore les 2 boutons "Accepter" et "Refuser". Je pense que ça n'est pas le fonctionnement attendu.
  - URL concernée : https://supercaralive.5000.dev/professional/bookings/2

- [ ] **Bouton Refuser sur prestation créée manuellement** - Sur cette page, la prestation a été créée manuellement et on a le bouton "refuser". Je ne sais pas si c'est normal.
  - URL concernée : https://supercaralive.5000.dev/professional/bookings/1

### Profil professionnel
- [ ] **Modification du rappel** - Est-ce que c'est possible de modifier le rappel à 1 jour avant (la veille) ? 7 jours ça fait très long je trouve…
  - URL concernée : https://supercaralive.5000.dev/professional/profile/edit

### Réservations client
- [ ] **Erreur 500 sur "mes réservations"** - Quand je clique sur "mes réservations" j'ai une erreur 500 alors que j'ai une résa en attente. Je ne pense pas que ça soit le fonctionnement attendu.
  - URL concernée : https://supercaralive.5000.dev/client/bookings

### Nouvelle réservation
- [ ] **Encart adresse précise d'intervention** - Sur une nouvelle résa, pas d'encart pour indiquer l'adresse précise d'intervention (avec encart de rappel pour indiquer que l'intervention peut avoir lieu ailleurs que chez soi). On avait travaillé les encarts adresses 1 et 2 (principales…), avec le laïus qui va bien.
  - URL concernée : https://supercaralive.5000.dev/client/bookings/new

- [ ] **Adresse d'intervention non visible** - Sur les interventions en statut "acceptée" ou "terminée", l'adresse d'intervention n'apparaît pas. Statut "En attente" l'adresse n'apparaît pas encore, on est d'accord.
  - URL concernée : https://supercaralive.5000.dev/professional/bookings/3

### Véhicules client
- [ ] **Impossible d'ajouter un véhicule** - Je n'arrive pas à ajouter de véhicule.
  - URL concernée : https://supercaralive.5000.dev/client/vehicles/new

- [ ] **Bouton "Ajouter mon véhicule" en double** - Il y a 2 fois le bouton "Ajouter mon véhicule".
  - URL concernée : https://supercaralive.5000.dev/client/vehicles

---

## 🔧 Retours admin

### Approbation professionnel
- [ ] **Suppression du logo "voiture style cars"** - Supprimer le logo sur la page d'approbation professionnel.
  - URL concernée : https://supercaralive.5000.dev/admin/professional_approvals/3

- [ ] **Boutons Approuver/Refuser si déjà approuvé** - Si le profil a déjà été approuvé, alors à mon sens pas besoin d'avoir encore les 2 boutons "Approuver" et "Refuser" et notamment dans la décision finale.
  - URL concernée : https://supercaralive.5000.dev/admin/professional_approvals/3

- [ ] **Bouton "Demande de documents" avec notes** - Il serait opportun d'avoir un bouton "Demande de documents" avec un encart "Notes" pour détailler les pièces attendues/documents et que cela fasse partir un message en automatique au professionnel. Si c'est possible ?
  - URL concernée : https://supercaralive.5000.dev/admin/professional_approvals/3

### Paramétrage contact
- [ ] **Modification des informations "Contact"** - Je pensais que ce serait dans l'admin que je pourrais modifier les informations de "Contact" pour paramétrer les informations de contact sur chaque bouton du site. Sinon où puis-je le faire ?

### Statuts professionnel
- [ ] **Différence entre "Approuvé" et "Vérifié"** - Quelle est la différence entre le statut "Approuvé" et "Vérifié" ? Vérifié c'est manuellement et approuvé c'est quand il y aura de l'automatisation ?
  - URL concernée : https://supercaralive.5000.dev/admin/professional_approvals/3

### Services admin
- [ ] **Affichage des prérequis/matériel nécessaire** - Pour cette page, les infos renseignées dans "Prérequis / Matériel nécessaire" pour chaque spécialité doivent se retrouver sur cette page c'est bien ça ? => https://supercaralive.5000.dev/client/professionals/3
  
  Ca permettra au client final de comprendre de quelles installations le professionnel a besoin.
  
  Il faudrait donc que ce qui est renseigné dans l'admin pour chaque spécialité puisse se retrouver à la suite de "diagnostic électrique" par exemple => "Diagnostic électrique : pré-requis = avoir accès à l'électricité" "Peinture : pré-requis = avoir accès à un lieu à l'abri du vent".
  - URL admin : https://supercaralive.5000.dev/admin/services/new
  - URL client : https://supercaralive.5000.dev/client/professionals/3

