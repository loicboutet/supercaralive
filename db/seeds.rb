# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Services standards pour garagistes indépendants
# Ne créer les services que si aucun service n'existe déjà
if Service.count == 0
  puts "Création des services standards..."

  services_data = [
    # MÉCANIQUE - Entretien courant
    {
      name: "Révision complète",
      description: "Contrôle complet du véhicule : niveaux, freins, éclairage, pneus, batterie. Vérification des éléments de sécurité et de l'état général du véhicule.",
      category: "mecanique",
      icon: "🔧",
      estimated_duration: 90,
      suggested_price: 120.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Véhicule accessible, carnet d'entretien si disponible"
    },
    {
      name: "Vidange moteur",
      description: "Remplacement de l'huile moteur et du filtre à huile. Contrôle des niveaux de liquides (lave-glace, liquide de refroidissement, frein).",
      category: "mecanique",
      icon: "🛢️",
      estimated_duration: 30,
      suggested_price: 45.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Huile moteur adaptée au véhicule, filtre à huile"
    },
    {
      name: "Changement de plaquettes de frein",
      description: "Remplacement des plaquettes de frein avant ou arrière. Contrôle des disques de frein et du liquide de frein.",
      category: "mecanique",
      icon: "🛑",
      estimated_duration: 60,
      suggested_price: 80.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Plaquettes de frein adaptées au véhicule"
    },
    {
      name: "Changement de disques de frein",
      description: "Remplacement des disques de frein avant ou arrière avec les plaquettes associées. Contrôle du système de freinage complet.",
      category: "mecanique",
      icon: "⚙️",
      estimated_duration: 90,
      suggested_price: 150.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Disques et plaquettes de frein adaptés au véhicule"
    },
    {
      name: "Diagnostic électronique",
      description: "Lecture des codes défaut avec valise de diagnostic. Identification des pannes et estimation des réparations nécessaires.",
      category: "mecanique",
      icon: "💻",
      estimated_duration: 45,
      suggested_price: 60.00,
      active: true,
      popular: false,
      requires_quote: false,
      prerequisites: "Véhicule accessible, prise OBD fonctionnelle"
    },
    {
      name: "Changement de pneus",
      description: "Remplacement de 4 pneus avec équilibrage et géométrie. Contrôle de la pression et de l'état des valves.",
      category: "mecanique",
      icon: "🛞",
      estimated_duration: 60,
      suggested_price: 40.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Pneus adaptés au véhicule (dimension et indice de charge)"
    },
    {
      name: "Réparation de freinage",
      description: "Intervention sur le système de freinage : purge, remplacement de flexibles, réparation de l'étrier. Diagnostic complet du système.",
      category: "mecanique",
      icon: "🔩",
      estimated_duration: 120,
      suggested_price: 100.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Diagnostic préalable recommandé"
    },
    {
      name: "Changement de batterie",
      description: "Remplacement de la batterie avec test de l'alternateur et du système de charge. Reprogrammation si nécessaire.",
      category: "mecanique",
      icon: "🔋",
      estimated_duration: 30,
      suggested_price: 90.00,
      active: true,
      popular: false,
      requires_quote: false,
      prerequisites: "Batterie adaptée au véhicule (ampérage et dimensions)"
    },
    {
      name: "Changement de courroie de distribution",
      description: "Remplacement de la courroie de distribution avec kit complet (courroie, galets, pompe à eau si nécessaire).",
      category: "mecanique",
      icon: "⚙️",
      estimated_duration: 180,
      suggested_price: 350.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Kit de distribution adapté au véhicule"
    },
    {
      name: "Révision des filtres",
      description: "Remplacement des filtres : filtre à air, filtre à huile, filtre à carburant, filtre d'habitacle.",
      category: "mecanique",
      icon: "🌬️",
      estimated_duration: 45,
      suggested_price: 70.00,
      active: true,
      popular: false,
      requires_quote: false,
      prerequisites: "Filtres adaptés au véhicule"
    },
    {
      name: "Réparation de démarreur",
      description: "Diagnostic et réparation ou remplacement du démarreur. Vérification de la batterie et des connexions électriques.",
      category: "mecanique",
      icon: "🔌",
      estimated_duration: 90,
      suggested_price: 120.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Diagnostic préalable nécessaire"
    },
    {
      name: "Réparation d'alternateur",
      description: "Diagnostic et réparation ou remplacement de l'alternateur. Test du système de charge complet.",
      category: "mecanique",
      icon: "⚡",
      estimated_duration: 120,
      suggested_price: 180.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Diagnostic préalable nécessaire"
    },
    {
      name: "Révision de la climatisation",
      description: "Recharge de gaz, contrôle des fuites, nettoyage du circuit. Test de performance du système de climatisation.",
      category: "mecanique",
      icon: "❄️",
      estimated_duration: 60,
      suggested_price: 80.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Véhicule accessible, système de climatisation fonctionnel"
    },
    {
      name: "Changement de bougies",
      description: "Remplacement des bougies d'allumage ou de préchauffage. Contrôle de l'état des câbles et des bobines.",
      category: "mecanique",
      icon: "🔥",
      estimated_duration: 45,
      suggested_price: 60.00,
      active: true,
      popular: false,
      requires_quote: false,
      prerequisites: "Bougies adaptées au véhicule"
    },

    # CARROSSERIE
    {
      name: "Réparation de carrosserie",
      description: "Réparation de chocs et bosses sur la carrosserie. Remise en forme et préparation pour peinture si nécessaire.",
      category: "carrosserie",
      icon: "🔨",
      estimated_duration: 180,
      suggested_price: 200.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Accès à la zone endommagée, devis préalable"
    },
    {
      name: "Peinture de carrosserie",
      description: "Peinture complète ou partielle d'un élément de carrosserie. Préparation, peinture et vernis avec finition professionnelle.",
      category: "carrosserie",
      icon: "🎨",
      estimated_duration: 240,
      suggested_price: 300.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Devis préalable avec code couleur exact"
    },
    {
      name: "Débosselage sans peinture",
      description: "Technique de débosselage sans peinture pour les petites bosses. Remise en forme de la tôle sans altérer la peinture d'origine.",
      category: "carrosserie",
      icon: "🔧",
      estimated_duration: 60,
      suggested_price: 80.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Bosse accessible, peinture non endommagée"
    },
    {
      name: "Remplacement de pare-chocs",
      description: "Démontage et remplacement d'un pare-chocs avant ou arrière. Réglage et fixation selon les spécifications constructeur.",
      category: "carrosserie",
      icon: "🛡️",
      estimated_duration: 90,
      suggested_price: 150.00,
      active: true,
      popular: false,
      requires_quote: true,
      prerequisites: "Pare-chocs adapté au véhicule"
    },

    # LAVAGE
    {
      name: "Lavage extérieur",
      description: "Lavage complet de l'extérieur du véhicule : carrosserie, jantes, vitres. Séchage à la main pour un résultat impeccable.",
      category: "lavage",
      icon: "💧",
      estimated_duration: 45,
      suggested_price: 25.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Accès à l'eau et espace de travail"
    },
    {
      name: "Lavage intérieur",
      description: "Nettoyage complet de l'habitacle : aspiration, nettoyage des sièges, tableau de bord, vitres intérieures, coffre.",
      category: "lavage",
      icon: "🧽",
      estimated_duration: 60,
      suggested_price: 35.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Véhicule accessible, habitacle vide de préférence"
    },
    {
      name: "Lavage complet",
      description: "Lavage extérieur et intérieur complet. Nettoyage approfondi avec cire de protection pour la carrosserie.",
      category: "lavage",
      icon: "✨",
      estimated_duration: 90,
      suggested_price: 50.00,
      active: true,
      popular: true,
      requires_quote: false,
      prerequisites: "Accès à l'eau et espace de travail, habitacle accessible"
    },
    {
      name: "Nettoyage de moteur",
      description: "Nettoyage approfondi du compartiment moteur. Décrassage et protection des éléments sensibles.",
      category: "lavage",
      icon: "🔩",
      estimated_duration: 45,
      suggested_price: 40.00,
      active: true,
      popular: false,
      requires_quote: false,
      prerequisites: "Moteur froid, accès au compartiment moteur"
    }
  ]

  services_data.each do |service_attrs|
    Service.create!(service_attrs)
    puts "  ✓ Service créé : #{service_attrs[:name]}"
  end

  puts "✅ #{services_data.count} services créés avec succès !"
else
  puts "Les services existent déjà. Aucun service n'a été créé."
end
