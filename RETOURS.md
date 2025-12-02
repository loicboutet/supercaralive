# Liste des retours - SuperCarAlive

## 📹 Retours vidéo

### Documents professionnel
- [x] **Chargement de documents** - Lorsque le professionnel charge ses documents, il manque un bouton "Envoyer les documents" ou un encart en surcouche confirmant le bon envoi des documents. On ne comprend pas bien que les documents ont bien été chargés.
  - URL concernée : Page de chargement des documents du professionnel
  - ✅ Résolu : Ajout d'une alerte flash explicite avec le nom du document ajouté

### Accès aux données
- [x] **Numéros de téléphone** - Pourquoi est-ce que je ne peux pas avoir accès aux numéros de téléphone enregistrés dans le système ?
  - ✅ Résolu : Ajout de l'affichage du numéro de téléphone dans la page show des utilisateurs (admin/users/:id), visible même s'il n'est pas renseigné (affiche "Non renseigné")

---

## 🌐 Retours site

### Services - Détailing manquant
- [ ] **Ajout du Détailing dans les choix de services** - Sur l'ensemble du site, dès qu'un service (Mécanique, Carrossier, Lavage) est à choisir, il manque le Détailing.
  - URLs concernées : Toutes les pages avec sélection de services
  - URL spécifique : https://supercaralive.5000.dev/client/professionals
- ✅ Résolu : Select custom créé avec affichage détaillé de chaque service (nom, types de services, durée, prix, prix de déplacement) quand déplié

### Logo et identité visuelle
- [x] **Suppression du logo vignette** - Supprimer le logo vignette de chaque onglet et pour le portail admin
  - ✅ Résolu : Favicons supprimées des layouts admin, professional et client. Logo supprimé des sidebars admin (desktop et mobile) et remplacé par "SupercarAlive" (Supercar en blanc, Alive en jaune pour la sidebar admin)
- [x] **Logo sur les pages de connexion** - Le logo n'est pas supprimé sur les pages de connexion. Vous pouvez juste ajouter SUPERCARALIVE avec le code couleur habituel.
  - URL concernée : https://supercaralive.5000.dev/client
  - ✅ Résolu : Ajout de "SupercarAlive" (Supercar en noir, Alive en rouge) sous les logos sur les pages sign in, mot de passe oublié et créer un compte

### Paramétrage admin

### Calendrier professionnel
- [ ] **Flexibilité du calendrier** - Le calendrier est limité par jour, par exemple j'ajoute un créneau le lundi et cela impacte tous les lundis. Je pensais qu'il y avait plus de flexibilité dans la gestion de l'agenda et qu'il pouvait être modifié de façon journalière et non pas une duplication exacte de la même journée chaque semaine.
  - URL concernée : https://supercaralive.5000.dev/professional/availability_slots

### Réservations professionnel
- [x] **Boutons Accepter/Refuser sur prestation terminée** - Sur la page de réservation, la prestation est terminée et on a encore les 2 boutons "Accepter" et "Refuser". Je pense que ça n'est pas le fonctionnement attendu.
  - URL concernée : https://supercaralive.5000.dev/professional/bookings/2
  - ✅ Résolu : Les boutons Accepter/Refuser ne s'affichent plus si la date est passée. Seul le bouton "Terminer" est disponible. Le statut "En attente" devient "Date passée" si la date est passée.

- [x] **Bouton Refuser sur prestation créée manuellement** - Sur cette page, la prestation a été créée manuellement et on a le bouton "refuser". Je ne sais pas si c'est normal.
  - URL concernée : https://supercaralive.5000.dev/professional/bookings/1
  - ✅ Résolu : Les réservations créées manuellement n'affichent plus les boutons "Accepter" et "Refuser". Seul le bouton "Terminer" est disponible si la réservation n'est pas déjà terminée ou annulée.

### Profil professionnel
- [x] **Modification du rappel** - Est-ce que c'est possible de modifier le rappel à 1 jour avant (la veille) ? 7 jours ça fait très long je trouve…
  - URL concernée : https://supercaralive.5000.dev/professional/profile/edit
  - ✅ Résolu : Modification des jobs de rappel (ClientBookingRemindersJob et ProfessionalBookingRemindersJob) pour envoyer les rappels 1 jour avant au lieu de 7 jours. Mise à jour des textes dans les vues et mailers pour refléter ce changement.

### Réservations client
- [x] **Erreur 500 sur "mes réservations"** - Quand je clique sur "mes réservations" j'ai une erreur 500 alors que j'ai une résa en attente. Je ne pense pas que ça soit le fonctionnement attendu.
  - URL concernée : https://supercaralive.5000.dev/client/bookings
  - ✅ Résolu : Correction de plusieurs problèmes potentiels :
    - Ajout de la méthode `reviewed?` manquante dans le modèle Booking
    - Protection de `professional_name` contre les valeurs nil
    - Protection de `service_type_name` contre les valeurs nil
    - Protection de `vehicle_model` contre les valeurs nil (brand, model, year)
    - Protection de la pagination contre les valeurs nil
    - Utilisation de `vehicle_model` dans le dashboard au lieu d'accès direct aux attributs

### Nouvelle réservation
- [x] **Encart adresse précise d'intervention** - Sur une nouvelle résa, pas d'encart pour indiquer l'adresse précise d'intervention (avec encart de rappel pour indiquer que l'intervention peut avoir lieu ailleurs que chez soi). On avait travaillé les encarts adresses 1 et 2 (principales…), avec le laïus qui va bien.
  - URL concernée : https://supercaralive.5000.dev/client/bookings/new
  - ✅ Résolu : Ajout du champ `intervention_address` dans le formulaire de réservation avec un encart informatif. Ajout du champ `address` dans le profil client. Pré-remplissage automatique de l'adresse d'intervention avec l'adresse du profil client si disponible.

- [x] **Adresse d'intervention non visible** - Sur les interventions en statut "acceptée" ou "terminée", l'adresse d'intervention n'apparaît pas. Statut "En attente" l'adresse n'apparaît pas encore, on est d'accord.
  - URL concernée : https://supercaralive.5000.dev/professional/bookings/3
  - ✅ Résolu : L'adresse d'intervention s'affiche maintenant dans la vue professionnel bookings/show uniquement si le statut est "accepted" ou "completed".

### Véhicules client
- [x] **Impossible d'ajouter un véhicule** - Je n'arrive pas à ajouter de véhicule.
  - URL concernée : https://supercaralive.5000.dev/client/vehicles/new
  - ✅ Résolu : Mise en clarté des champs requis pour pouvoir créer son véhicule :
    - Ajout d'astérisques rouges (*) sur les labels des champs requis (Marque, Modèle, Année, Kilométrage)
    - Ajout de l'attribut `required: true` sur les champs requis pour la validation front-end
    - Amélioration de l'affichage des erreurs de validation avec bordure rouge et messages d'erreur spécifiques sous chaque champ

- [x] **Bouton "Ajouter mon véhicule" en double** - Il y a 2 fois le bouton "Ajouter mon véhicule".
  - URL concernée : https://supercaralive.5000.dev/client/vehicles
  - ✅ Résolu : Suppression du doublon de bouton. Le bouton "Ajouter un véhicule" en haut de page n'apparaît maintenant que s'il y a déjà des véhicules enregistrés. Quand il n'y a aucun véhicule, seul le bouton "Ajouter mon premier véhicule" dans la section vide s'affiche.

---

## 🔧 Retours admin

### Approbation professionnel
- [x] **Suppression du logo "voiture style cars"** - Supprimer le logo sur la page d'approbation professionnel.
  - URL concernée : https://supercaralive.5000.dev/admin/professional_approvals/3
  - ✅ Résolu : Le logo de la barre latérale (sidebar) admin a été supprimé précédemment et remplacé par le texte "SUPERCARALIVE". Il n'y a plus de logo visible sur la page d'approbation professionnelle.

- [x] **Boutons Approuver/Refuser si déjà approuvé** - Si le profil a déjà été approuvé, alors à mon sens pas besoin d'avoir encore les 2 boutons "Approuver" et "Refuser" et notamment dans la décision finale.
  - URL concernée : https://supercaralive.5000.dev/admin/professional_approvals/3
  - ✅ Résolu : Les boutons "Approuver" et "Refuser" ne s'affichent plus si le professionnel a déjà été approuvé (statut "active") ou refusé (statut "suspended"). À la place, un message informatif s'affiche indiquant la décision prise et la date de la décision.

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

---

## ❓ Questions / À décider

### Paramétrage contact
- [ ] **Lien "Contacter le support" paramétrable** - Le lien "Contacter le support" devrait être paramétrable côté admin pour intégrer WhatsApp par exemple.
  - URL concernée : https://supercaralive.5000.dev/client/professionals
  - **Question** : Actuellement configuré avec `Rails.application.credentials.support_email`. Est-ce qu'on devrait créer un objet (modèle Setting/Configuration) pour le rendre paramétrable côté admin, ou garder les credentials ?
  - **Utilisation actuelle** : Utilisé dans plusieurs endroits via le helper `support_email` (pages profil, factures, contact, statuts de compte, etc.)

### CGV et politique de confidentialité
- [ ] **Mise à jour des CGV et politique de confidentialité** - Comment procéder pour les mettre à jour ? Lien avec les pages développées par Simplébeau ?
  - **Question** : Comment s'organisent habituellement les CGV/CGU ? Est-ce que je dois en faire un objet contrôlable côté admin ?
  - **Situation actuelle** : Les CGV et la politique de confidentialité sont dans des vues statiques (`app/views/pages/cgu.html.erb` et `app/views/pages/confidentiality.html.erb`). La date de mise à jour est codée en dur (`Date.today.strftime("%d/%m/%Y")`).
  - **Options possibles** :
    - Créer un modèle `LegalDocument` avec `document_type` (cgu, cgv, privacy_policy), `content` (text), `version`, `published_at`
    - Garder les vues statiques mais permettre l'édition via un éditeur WYSIWYG côté admin
    - Utiliser un système de versioning pour tracer les modifications

