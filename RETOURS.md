# Retours et corrections à effectuer
---

## Pages client

### `/client/maintenance_reminders`
1. **Ajouter le récapitulatif des factures** : Dans cette page de mémoire il y avait le récapitulatif des factures (avec leur statut, réglée, en attente… et le filtrage possible). D'ailleurs c'est spécifié dans l'entête de la page au travers de : « Suivez vos dépenses et les maintenances périodiques de vos véhicules ». Est-ce que vous pourriez ajouter les éléments concernant les factures ? Merci. Dans l'exemple on devrait voir apparaître le « Nettoyage extra » à 150€.
   - *Note : Ce point appartient à la brique 2. Il n'y a pas de notion de facturation implémentée actuellement, c'est pour ça que ce n'est pas présent dans l'application.*
2.1. ✅ **Correction orthographique** : Mettre un « S » majuscule à "Supercarnet d'entretien".
2.2. ✅ **Modifier la phrase d'entête** : Enlever "vos dépenses et" de la phrase "Suivez vos dépenses et les maintenances périodiques de vos véhicules" pour avoir juste "Suivez les maintenances périodiques de vos véhicules" puisqu'on ne suit pas les dépenses en fait.

### `/client/professionals`
3. ✅ **Ajouter "Detailing" dans les services** : Ajouter « Detailing » dans les services « liste ».
4. ✅ **Ajouter des filtres de recherche rapide** : Sur cette page en dessous de l'encart « Type de service » Localisation… Dans les maquettes il y avait des boutons/filtres de recherches rapides comme « Disponible dans la journée » « Populaire »… de mémoire, mais on ne les retrouve pas du tout sur cette version. Pourriez-vous les rajouter ?

### `/client/bookings/3/edit`
5. ✅ **Supprimer une phrase** : Supprimer cette phrase : « Les créneaux affichés sont basés sur les disponibilités du professionnel et excluent les réservations déjà confirmées. »

### `/client/bookings?status=pending` (et autres statuts)
6. ✅ **Enlever le bouton "Créer ma 1ere réservation" du corps de page** : Sur les pages « Toutes, En attente, Validées, Refusées, Annulées, Terminées » pas besoin d'ajouter dans le corps de la page « Créer ma 1ere réservation » car on a déjà le bouton en haut à droite « Nouvelles réservation ».

### `/client/profile`
7. ✅ **Enlever une phrase** : Enlever la phrase «…. pour les administrateurs afin de protéger votre vie privée. » car j'y ai accès à présent.

### `/client` (Dashboard)
8. ✅ **Corriger les incohérences dans les statistiques** :
   - On a 1 résa notée « A venir » alors que dans l'encart plus bas on a 0 pour prochaines réservations. Je n'ai pas de résa prévue ou en attente dans le système.
   - Dans service terminé il est noté 0 alors que nous avons une prestation terminée qui est enregistrée dans le système.

---

## Pages professionnel

### `/professional/profile`
9. ✅ **Modifier le texte sur la confidentialité** : « Vos informations personnelles (nom, entreprise, téléphone, SIRET) restent confidentielles et ne seront visibles par les clients qu'après validation d'au moins deux rendez-vous avec eux ». Remplacer par : « Vos informations personnelles (nom, entreprise, téléphone, SIRET) restent confidentielles et seront visibles par le particulier dès le RDV validé. »

### `/professional/profile/edit`
10. ✅ **Enlever la notion de 2 rdv** : Enlever la notion de 2 rdv pour l'affichage de l'adresse comme précédemment indiqué.

### `/professional`
11. ✅ **Corriger le doublon dans "Catégories populaires"** : Dans l'encart « Catégories populaires » il y a 2 fois « 3 » indiqués. En enlever 1.

---

## Pages admin

### `/admin/services`
12. ✅ **Ajouter "detailing" dans la liste** : Ajouter "detailing" dans la liste.

---

## Pages utilisateur

### `/users/sign_in`
13. ✅ **Supprimer tous les logos** : Il faut vraiment supprimer tous les logos même sur la page de connexion. Est-ce qu'il sera possible d'en rajouter un après sur la page de connexion ? J'aurais la bonne version dans une dizaine de jours.
   - *Note : On pourra rajouter l'icone à jour sans soucis*
14. ✅ **Ajouter la possibilité de voir le mot de passe** : Pour l'encart de connexion il faudrait qu'on puisse voir (avec « l'œil ») le mdp qu'on rentre car là on est à l'aveugle.

### `/users/edit`
15. ✅ **Corriger la mise en page** : Pour la page « Paramètres du compte » j'ai l'impression que la mise en page est cassée (unhappy ? ne renvoie vers rien) et on a vraiment l'impression d'être sorti de l'appli. Est-ce possible d'avoir un écran qui rend mieux ?
   - *Note : Le lien "Paramètres du compte" et la page liée ont été supprimés de la page de profil car cela n'avait pas lieu d'être, nous avons déja un bouton pour modifier son profil.*

---

## Notes diverses

### Notes des points

**Point 1 - Ajouter le récapitulatif des factures** :
Dans cette page de mémoire il y avait le récapitulatif des factures (avec leur statut, réglée, en attente… et le filtrage possible). D'ailleurs c'est spécifié dans l'entête de la page au travers de : « Suivez vos dépenses et les maintenances périodiques de vos véhicules ». Est-ce que vous pourriez ajouter les éléments concernant les factures ? Merci. Dans l'exemple on devrait voir apparaître le « Nettoyage extra » à 150€.
- *Note : Ce point appartient à la brique 2. Il n'y a pas de notion de facturation implémentée actuellement, c'est pour ça que ce n'est pas présent dans l'application.*

**Point 13 - Supprimer tous les logos** :
Il faut vraiment supprimer tous les logos même sur la page de connexion. Est-ce qu'il sera possible d'en rajouter un après sur la page de connexion ? J'aurais la bonne version dans une dizaine de jours.
- *Note : Fait, et oui on pourra rajouter l'icone à jour sans soucis*

**Point 15 - Corriger la mise en page** :
Pour la page « Paramètres du compte » j'ai l'impression que la mise en page est cassée (unhappy ? ne renvoie vers rien) et on a vraiment l'impression d'être sorti de l'appli. Est-ce possible d'avoir un écran qui rend mieux ?
- *Note : Le lien "Paramètres du compte" et la page liée ont été supprimés de la page de profil car cela n'avait pas lieu d'être, nous avons déja un bouton pour modifier son profil.*

