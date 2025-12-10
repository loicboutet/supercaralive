# Retours sur le projet

## 🔧 Fixes à effectuer

### Page de réservation
- [x] **Modifier le message d'information**  
  URL: `https://supercaralive.5000.dev/client/bookings/new?professional_id=3`  
  On ne peut pas sélectionner de date d'intervention quand on n'a pas tout renseigné. Par exemple quand on rentre juste le garage (ici garage test) mais qu'on ne met pas de service, l'encart « Veuillez d'abord sélectionner un professionnel pour voir ses services » n'apparaît plus. Du coup il faudrait modifier la phrase : « Veuillez remplir tous les champs du formulaire pour voir les disponibilités du professionnel ».

- [x] **Corriger l'affichage de la prochaine disponibilité**  
  URL: `https://supercaralive.5000.dev/client/professionals/3`  
  Il y a écrit "prochaine dispo demain 14h" mais c'est erroné à priori, sur le profil on peut réserver à partir du 9/12 18h.

### Dashboard client
- [x] **Mise à jour de l'encart "Mon profil"**  
  URL: `https://supercaralive.5000.dev/client`  
  J'ai l'impression que l'encart « Mon profil » dans le dashboard ne se met pas à jour quand on modifie.

### Page de recherche avec filtres
- [x] **Corriger l'erreur 500 lors du clic sur "Nouveau"**  
  URL de départ: `https://supercaralive.5000.dev/client/professionals?commit=Rechercher&location=&popular=true&radius_km=&service_category=mecanique`  
  URL d'erreur: `https://supercaralive.5000.dev/client/professionals?commit=Rechercher&location=&new=true&radius_km=&service_category=mecanique`  
  Erreur 500 sur cette page quand je viens de celle-là en cliquant sur "Nouveau", je ne sais pas si c'est normal. Il faudrait que ça donne cet écran là : `https://supercaralive.5000.dev/professional`

### Page de vérification des documents
- [x] **Bloquer la création d'un document sans upload**  
  URL: `https://supercaralive.5000.dev/professional/verification_documents`  
  J'ai fait un test pour uploader un document et même sans mettre de document en attaché il a été créé (test 12345). Est-ce que vous pourriez ajouter un pop-up et bloquer la création d'un doc si aucun doc n'est uploadé ? Merci.

### Page d'édition des services professionnels
- [x] **Griser les autres services après sélection d'un service**  
  URL: `https://supercaralive.5000.dev/professional/professional_services/3/edit`  
  Pour cette page on peut choisir plusieurs services en même temps à ajouter alors qu'après on doit ajouter un "Nom de service" en Informations générales obligatoirement et un tarif. Il faudrait griser les autres services une fois qu'on en a sélectionné un sinon c'est confusant.

### Calendrier des créneaux
- [x] **Corriger l'incohérence entre le footer et le calendrier**  
  URL: `https://supercaralive.5000.dev/professional/availability_slots/calendar?month=12&year=2025`  
  Incohérence entre le footer (nbre de résa) et le calendrier. Je ne vois qu'une seule résa et le compteur footer en indique 2.

### Page de gestion des créneaux
- [x] **Ajouter une phrase explicative dans l'encart bleu**  
  URL: `https://supercaralive.5000.dev/professional/availability_slots`  
  Ajouter dans l'encart bleu à la suite des 2 phrases "Définissez....Ces créneaux..." : "Vous pourrez modifier manuellement les créneaux pour chaque journée directement dans votre Agenda".

### Page d'ajout de spécialité (admin)
- [x] **Supprimer l'obligation de mettre un émoji**  
  URL: `https://supercaralive.5000.dev/admin/specialties/new`  
  Je n'arrive pas à ajouter d'autres émojis, du coup est-ce que vous pourriez supprimer l'obligation de mettre un émoji ?

### Icônes des types de service
- [x] **Mettre une icône de bulles pour le lavage**  
  Dans le choix « type de service » même icône pour détailing et lavage. Mettre une icône de bulles pour le lavage si possible.

### Incohérence entre écrans
- [x] **Corriger l'incohérence sur l'état des rappels**  
  Incohérence entre les 2 écrans suivants : l'un est noté "rappel activé" et l'autre "rappels désactivés".
  https://supercaralive.5000.dev/client/vehicles/1
  https://supercaralive.5000.dev/client

---

## ❓ Questions à clarifier

- [x] **Critères de popularité des professionnels**  
  URL: `https://supercaralive.5000.dev/client/professionals`  
  Populaire : sur quelles bases dans le système un pro remonte-t-il comme populaire ? Merci.
  
  **Réponse :** Un professionnel apparaît comme "populaire" lorsqu'il a au moins 5 réservations complétées (terminées avec succès). C'est un calcul automatique qui se base sur le nombre de prestations réalisées. Dès qu'un professionnel atteint ce seuil de 5 réservations complétées, il apparaît automatiquement dans les résultats de recherche avec le filtre "Populaire".

- [x] **Statistiques du compte**  
  URL: `https://supercaralive.5000.dev/client/profile`  
  Je ne sais pas si c'est normal que les infos "Statistiques du compte" ne reflètent pas la réalité ?
  
  **Réponse :** Effectivement, il y avait un problème. Les statistiques affichées étaient des valeurs fixes qui ne correspondaient pas aux données réelles. Ce problème a été corrigé : les statistiques sont maintenant calculées automatiquement à partir de vos données réelles. Vous verrez désormais le nombre total de vos réservations, celles qui sont complétées, vos véhicules enregistrés, et le nombre d'avis que vous avez laissés (actuellement 0 car cette fonctionnalité n'est pas encore implémentée).

- [x] **Calcul automatique des services populaires (admin)**  
  URL: `https://supercaralive.5000.dev/admin/services`  
  Idem ici il y a un calcul auto des services populaires ? Merci.
  
  **Réponse :** Oui, nous avons modifié le système pour qu'il y ait maintenant un calcul automatique des services populaires. Le statut "populaire" d'un service est désormais calculé automatiquement en fonction du nombre de réservations complétées. Un service est marqué comme populaire lorsqu'il atteint au moins 10 réservations complétées. Ce calcul se met à jour automatiquement à chaque fois qu'une réservations est complétée. Dans l'interface admin, le champ "populaire" n'est plus modifiable manuellement car il est géré automatiquement par le système.

- [x] **Validation des moyens de contact lors de la création de profil**  
  Lors de la création des profils pro et particuliers le fait de ne pas mettre à minima un moyen de contact (mail ou tel) bloque bien la création du profil ? Je dois au moins avoir un mail. D'ailleurs est-ce qu'on a une vérification par l'envoi d'un lien cliquable que nous avons la bonne adresse mail ? Merci à dispo si besoin.
  
  **Réponse :** 
  - **Email obligatoire :** Oui, l'adresse email est obligatoire lors de la création d'un compte (que ce soit pour un client ou un professionnel). Le système bloque la création du profil si aucun email n'est renseigné. En revanche, le numéro de téléphone n'est pas obligatoire.
  - **Vérification par email :** Non, actuellement il n'y a pas de vérification par email avec un lien cliquable. Le système accepte l'adresse email renseignée sans vérifier qu'elle appartient bien à la personne qui crée le compte.

- [x] **Anonymiser les informations sensibles**  
  URL: `https://supercaralive.5000.dev/client/professionals/3`  
  Le numéro de SIRET et le numéro de téléphone apparaissent lors d'une recherche. Il faut anonymiser ces infos (laisser les champs apparaître pour que le client sache qu'elles existent mais les anonymiser comme demandé).
  
  **Réponse :** Les informations sensibles (numéro de SIRET et numéro de téléphone) sont bien anonymisées pour protéger la vie privée des professionnels. Voici comment cela fonctionne :
  - **Si vous n'avez pas encore eu de rendez-vous complété avec le professionnel :** Les champs téléphone et SIRET sont affichés mais montrent "Non disponible" à la place des valeurs. Cela permet au client de savoir que ces informations existent sans les révéler.
  - **Si vous avez au moins un rendez-vous complété avec le professionnel :** Les valeurs du téléphone et du SIRET sont alors affichées, car une relation de confiance a été établie entre vous et le professionnel.
  
  Si vous voyez les informations, c'est que vous avez déjà eu au moins un rendez-vous complété avec ce professionnel. Pour vérifier le comportement d'anonymisation, vous pouvez consulter le profil d'un professionnel avec qui vous n'avez jamais eu de rendez-vous.

---

## ❓ Questions / Demandes de précision au client

- [x] **Encart de vue rapide sur les rappels (dashboard professionnel)**  
  URL: `https://supercaralive.5000.dev/professional`  
  Sur cet écran il manque l'encart de vue rapide sur les rappels.  
  **Réponse :** Un encart similaire à celui du dashboard client a été ajouté dans la section "Mon profil pro" du dashboard professionnel. Il affiche maintenant l'état des rappels de rendez-vous (activés/désactivés) et des notifications de réservation (activées/désactivées).
