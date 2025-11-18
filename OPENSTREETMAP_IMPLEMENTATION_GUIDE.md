# Guide d'implémentation OpenStreetMap

Ce guide documente comment OpenStreetMap (OSM) est implémenté dans l'application Hyperviseur, une plateforme de gestion d'événements géographiques construite avec Rails 8 et Hotwire.

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture technique](#architecture-technique)
3. [Bibliothèque Leaflet](#bibliothèque-leaflet)
4. [Contrôleurs Stimulus](#contrôleurs-stimulus)
5. [Fournisseurs de tuiles](#fournisseurs-de-tuiles)
6. [API de géocodage](#api-de-géocodage)
7. [Intégration dans les vues](#intégration-dans-les-vues)
8. [Styles CSS personnalisés](#styles-css-personnalisés)
9. [Configuration et API Keys](#configuration-et-api-keys)
10. [Cas d'usage](#cas-dusage)

---

## Vue d'ensemble

L'application utilise **OpenStreetMap** comme source de données cartographiques principale via :
- **Leaflet.js** : Bibliothèque JavaScript pour les cartes interactives
- **Tuiles OSM** : Rendu des cartes (plusieurs fournisseurs disponibles)
- **Nominatim** : Service de géocodage pour la recherche d'adresses

### Pourquoi OpenStreetMap ?

- ✅ **Gratuit et open source**
- ✅ **Pas de limite de requêtes stricte** (avec usage raisonnable)
- ✅ **Données mondiales complètes**
- ✅ **Communauté active**
- ✅ **Alternatives multiples** pour les tuiles et services

---

## Architecture technique

### Stack technologique

```
Rails 8 (Backend)
  ↓
Hotwire/Stimulus (Frontend Framework)
  ↓
Leaflet.js (Map Library)
  ↓
OpenStreetMap Tiles (Map Rendering)
  ↓
Nominatim API (Geocoding)
```

### Composants principaux

1. **Leaflet.js 1.9.4** : Bibliothèque de cartographie
2. **Stimulus Controllers** : Logique interactive des cartes
3. **Tuiles OSM** : Rendu visuel des cartes
4. **Nominatim** : Recherche et géocodage

---

## Bibliothèque Leaflet

### Installation

Leaflet est chargé via CDN dans tous les layouts de l'application :

**Fichiers concernés :**
- `app/views/layouts/application.html.erb`
- `app/views/layouts/admin.html.erb`
- `app/views/layouts/creator.html.erb`
- `app/views/layouts/public.html.erb`

**Code d'intégration :**

```erb
<head>
  <!-- Leaflet CSS -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  
  <!-- Leaflet JavaScript -->
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
</head>
```

### Pourquoi via CDN ?

- ✅ Pas de gestion de packages JavaScript complexe
- ✅ Compatible avec importmap (Rails 8)
- ✅ Mise en cache par les navigateurs
- ✅ Chargement rapide depuis CDN global

---

## Contrôleurs Stimulus

L'application utilise **3 contrôleurs Stimulus** principaux pour gérer les cartes :

### 1. `map_controller.js` - Affichage des événements

**Localisation :** `app/javascript/controllers/map_controller.js`

**Responsabilités :**
- Afficher une carte interactive avec événements
- Gérer plusieurs thèmes de carte (6 thèmes disponibles)
- Afficher des marqueurs GPS et polygones
- Gérer les zones géographiques prédéfinies
- Afficher les conflits d'événements

**Valeurs Stimulus :**

```javascript
static values = {
  lat: Number,              // Latitude initiale
  lng: Number,              // Longitude initiale
  zoom: Number,             // Niveau de zoom
  events: Array,            // Liste des événements à afficher
  zones: Array,             // Zones géographiques prédéfinies
  primaryColor: String,     // Couleur principale de l'organisation
  thunderforestApiKey: String,  // Clé API Thunderforest (optionnel)
  jawgAccessToken: String,      // Token Jawg Maps (optionnel)
  stadiaApiKey: String          // Clé API Stadia Maps (optionnel)
}
```

**Fonctionnalités clés :**

```javascript
// Initialisation de la carte
initializeMap() {
  this.map = L.map(this.containerTarget).setView(
    [this.latValue || 48.8566, this.lngValue || 2.3522],
    this.zoomValue || 12
  )
  this.addTileLayers()
  this.addEventMarkers()
  this.addZonePolygons()
}

// Ajout des tuiles OSM
addTileLayers() {
  // 6 thèmes disponibles avec fallbacks gratuits
  this.baseMaps = {
    'Satellite': L.tileLayer(...),
    'Terrain': L.tileLayer(...),
    'Transport': L.tileLayer(...),
    'Streets': L.tileLayer(...),
    'Outdoors': L.tileLayer(...),
    'Transport Dark': L.tileLayer(...)
  }
}
```

**Gestion des événements :**

- **Marqueurs GPS** : Pins personnalisés avec icônes SVG
- **Polygones** : Zones dessinées sur la carte
- **Zones prédéfinies** : Affichage en pointillés
- **Conflits** : Coloration orange pour les chevauchements

### 2. `map_draw_controller.js` - Création/édition d'événements

**Localisation :** `app/javascript/controllers/map_draw_controller.js`

**Responsabilités :**
- Permettre la création d'événements par GPS (clic sur la carte)
- Permettre le dessin de polygones (zones personnalisées)
- Gérer la sélection de zones prédéfinies
- Recherche d'adresses via Nominatim
- Géolocalisation de l'utilisateur

**Modes de localisation :**

1. **GPS** : Clic sur la carte pour placer un marqueur
2. **Polygon** : Dessiner une zone en cliquant plusieurs points
3. **Zone** : Sélectionner une zone prédéfinie

**Fonctionnalités clés :**

```javascript
// Recherche d'adresse via Nominatim
async searchPlace(query) {
  const response = await fetch(
    `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1&addressdetails=1`
  )
  const results = await response.json()
  // Centrer la carte sur le résultat
  this.map.setView([lat, lng], 15)
}

// Géolocalisation de l'utilisateur
getCurrentPosition() {
  return new Promise((resolve, reject) => {
    navigator.geolocation.getCurrentPosition(
      (position) => resolve(position),
      (error) => reject(error),
      { enableHighAccuracy: true, timeout: 3000 }
    )
  })
}

// Dessin de polygone
addPolygonPoint(lat, lng) {
  this.polygonPoints.push([lat, lng])
  this.drawPolygon()
  this.updateCoordinatesField()
}
```

### 3. `zone_map_controller.js` - Gestion des zones

**Localisation :** `app/javascript/controllers/zone_map_controller.js`

**Responsabilités :**
- Créer des zones géographiques prédéfinies
- Dessiner des polygones pour les zones
- Recherche d'adresses pour centrer la carte

**Similaire à `map_draw_controller.js`** mais spécifique aux zones administratives.

---

## Fournisseurs de tuiles

L'application supporte **6 thèmes de carte** avec des fournisseurs premium et des fallbacks gratuits.

### Thèmes disponibles

| Thème | Fournisseur Premium | Fallback Gratuit | API Key Requise |
|-------|---------------------|------------------|-----------------|
| **Satellite** | Stadia Alidade Satellite | Esri World Imagery | Stadia |
| **Terrain** | Stadia Stamen Terrain | OpenTopoMap | Stadia |
| **Transport** | Thunderforest Transport | OSM Standard | Thunderforest |
| **Streets** | Jawg Streets | CartoDB Voyager | Jawg |
| **Outdoors** ⭐ | Thunderforest Outdoors | CartoDB Light | Thunderforest |
| **Transport Dark** | Thunderforest Transport Dark | CartoDB Dark | Thunderforest |

⭐ **Thème par défaut** : Outdoors (CartoDB Light en fallback)

### Configuration des tuiles

**Exemple : Tuiles OSM France (utilisé dans map_draw_controller.js)**

```javascript
L.tileLayer('https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png', {
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(this.map)
```

**Exemple : Tuiles avec API Key (Thunderforest)**

```javascript
if (this.thunderforestApiKeyValue) {
  this.baseMaps['Transport'] = L.tileLayer(
    'https://{s}.tile.thunderforest.com/transport/{z}/{x}/{y}{r}.png?apikey={apikey}',
    {
      attribution: '&copy; Thunderforest, &copy; OpenStreetMap contributors',
      apikey: this.thunderforestApiKeyValue,
      maxZoom: 22
    }
  )
} else {
  // Fallback gratuit
  this.baseMaps['Transport'] = L.tileLayer(
    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    {
      attribution: '&copy; OpenStreetMap',
      maxZoom: 19
    }
  )
}
```

### Fournisseurs de tuiles gratuits

1. **OpenStreetMap Standard** : `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`
2. **OpenStreetMap France** : `https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png`
3. **OpenTopoMap** : `https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png`
4. **CartoDB** : `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png`
5. **Esri World Imagery** : `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}`

---

## API de géocodage

### Nominatim (OpenStreetMap)

**Service utilisé :** https://nominatim.openstreetmap.org/

**Fonctionnalités :**
- Recherche d'adresses (forward geocoding)
- Conversion coordonnées → adresse (reverse geocoding)
- Recherche internationale

### Exemples d'utilisation

**1. Recherche d'adresse (dans map_draw_controller.js)**

```javascript
async searchPlace(query) {
  const response = await fetch(
    `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1&addressdetails=1`
  )
  const results = await response.json()
  
  if (results && results.length > 0) {
    const result = results[0]
    const lat = parseFloat(result.lat)
    const lng = parseFloat(result.lon)
    this.map.setView([lat, lng], 15)
  }
}
```

**2. Géocodage inverse (dans public/events_controller.rb)**

```ruby
def geocode_coordinates(lat, lng)
  uri = URI("https://nominatim.openstreetmap.org/search")
  uri.query = URI.encode_www_form({
    format: 'json',
    lat: lat,
    lon: lng,
    zoom: 18,
    addressdetails: 1
  })
  
  response = Net::HTTP.get_response(uri)
  data = JSON.parse(response.body)
  
  if data && data.any?
    data.first['display_name']
  else
    nil
  end
rescue => e
  Rails.logger.error "Geocoding error: #{e.message}"
  nil
end
```

### Bonnes pratiques Nominatim

⚠️ **Limites d'utilisation :**
- Maximum 1 requête par seconde
- Ajouter un User-Agent personnalisé en production
- Mettre en cache les résultats

**Configuration recommandée pour production :**

```ruby
# config/initializers/nominatim.rb
NOMINATIM_CONFIG = {
  base_url: 'https://nominatim.openstreetmap.org',
  user_agent: 'Hyperviseur/1.0 (contact@example.com)',
  timeout: 5,
  rate_limit: 1 # requête par seconde
}
```

---

## Intégration dans les vues

### Vue publique : Carte des événements

**Fichier :** `app/views/public/events/map.html.erb`

```erb
<%
  # Préparer les données JSON pour la carte
  events_json = @events.map do |event|
    {
      id: event.id,
      name: event.name,
      description: event.description,
      status: event.status,
      event_type: event.event_type.name,
      start_date: event.start_date&.strftime('%d/%m/%Y'),
      end_date: event.end_date&.strftime('%d/%m/%Y'),
      location_type: event.location_type,
      latitude: event.latitude,
      longitude: event.longitude,
      coordinates: event.coordinates,
      polygon_coordinates: event.coordinates,
      zone_id: event.zone_id,
      zone_coordinates: event.zone_id ? @organization.geo_areas.find_by(id: event.zone_id)&.coordinates : nil,
      has_conflict: event.has_conflict?,
      creator_name: @organization.name
    }
  end
%>

<div class="map-fullscreen"
     data-controller="map"
     data-map-lat-value="<%= @creator[:default_lat] || 48.8566 %>"
     data-map-lng-value="<%= @creator[:default_lng] || 2.3522 %>"
     data-map-zoom-value="<%= @creator[:default_zoom] || 12 %>"
     data-map-primary-color-value="<%= @primary_color %>"
     data-map-events-value="<%= events_json.to_json %>"
     data-map-zones-value="<%= @zones.to_json %>">
  <div data-map-target="container" class="w-full h-full"></div>
</div>
```

### Vue création/édition : Formulaire avec carte

**Fichier :** `app/views/creator/events/_form.html.erb` (exemple)

```erb
<div data-controller="map-draw"
     data-map-draw-zones-value="<%= @zones.to_json %>"
     data-map-draw-existing-lat-value="<%= @event.latitude %>"
     data-map-draw-existing-lng-value="<%= @event.longitude %>"
     data-map-draw-existing-coordinates-value="<%= @event.coordinates %>"
     data-map-draw-existing-location-type-value="<%= @event.location_type %>"
     data-map-draw-organization-map-start-value="<%= @organization.map_start %>">
  
  <!-- Sélection du type de localisation -->
  <select id="location_type_select">
    <option value="gps">Point GPS</option>
    <option value="polygon">Polygone</option>
    <option value="zone">Zone prédéfinie</option>
  </select>
  
  <!-- Carte -->
  <div data-map-draw-target="container" class="w-full h-96"></div>
  
  <!-- Champs cachés pour stocker les coordonnées -->
  <input type="hidden" data-map-draw-target="latitude" name="event[latitude]">
  <input type="hidden" data-map-draw-target="longitude" name="event[longitude]">
  <input type="hidden" data-map-draw-target="coordinates" name="event[coordinates]">
</div>
```

---

## Styles CSS personnalisés

**Fichier :** `app/assets/stylesheets/application.css`

### Personnalisation des marqueurs

```css
/* Marqueurs personnalisés (pins) */
.custom-pin-marker {
  background: transparent !important;
  border: none !important;
}

.pin-marker {
  position: relative;
  width: 32px;
  height: 40px;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.pin-marker:hover {
  transform: scale(1.1);
}

/* Animation de pulsation pour événements actifs */
@keyframes pulse-pin {
  0% {
    filter: drop-shadow(0 0 0 rgba(34, 197, 94, 0.7));
  }
  70% {
    filter: drop-shadow(0 0 10px rgba(34, 197, 94, 0));
  }
  100% {
    filter: drop-shadow(0 0 0 rgba(34, 197, 94, 0));
  }
}

.marker-pulse-pin {
  animation: pulse-pin 2s infinite;
}
```

### Personnalisation des popups

```css
/* Popups Leaflet - Design plat */
.leaflet-popup-content-wrapper {
  padding: 0;
  border-radius: 0; /* Design plat */
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.event-popup-card-flat {
  min-width: 300px;
}
```

### Contrôle des couches (Layer Control)

```css
/* Contrôle des couches - Design plat */
.leaflet-control-layers {
  border: 2px solid #e5e7eb !important;
  border-radius: 0 !important;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1) !important;
}

.leaflet-control-layers-toggle {
  background: #9333ea !important; /* Couleur principale */
  border-radius: 0 !important;
}
```

### Gestion du z-index

```css
/* Carte en arrière-plan */
.leaflet-container {
  z-index: 1 !important;
}

/* Popups au-dessus */
.leaflet-popup-pane {
  z-index: 700 !important;
}

/* Modal au-dessus de tout */
#event-modal {
  z-index: 9999 !important;
}
```

---

## Configuration et API Keys

### Variables d'environnement

**Fichier :** `.env` (local) ou configuration Kamal (production)

```bash
# API Keys optionnelles pour thèmes premium
THUNDERFOREST_API_KEY=your_thunderforest_key
JAWG_ACCESS_TOKEN=your_jawg_token
STADIA_API_KEY=your_stadia_key
```

### Obtenir les API Keys

**1. Thunderforest** (Transport, Outdoors, Transport Dark)
- URL : https://www.thunderforest.com/
- Gratuit : 150k requêtes/mois
- Inscription requise

**2. Jawg Maps** (Streets)
- URL : https://www.jawg.io/
- Gratuit : 25k requêtes/mois
- Inscription requise

**3. Stadia Maps** (Satellite, Terrain)
- URL : https://stadiamaps.com/
- Gratuit : 200k requêtes/mois
- Inscription requise

### Passage des clés aux vues

```erb
<div data-controller="map"
     data-map-thunderforest-api-key-value="<%= ENV['THUNDERFOREST_API_KEY'] %>"
     data-map-jawg-access-token-value="<%= ENV['JAWG_ACCESS_TOKEN'] %>"
     data-map-stadia-api-key-value="<%= ENV['STADIA_API_KEY'] %>">
</div>
```

### Fallbacks automatiques

Si les API keys ne sont pas fournies, le système utilise automatiquement des fournisseurs gratuits :

```javascript
if (this.stadiaApiKeyValue) {
  // Version premium
  this.baseMaps['Satellite'] = L.tileLayer('https://tiles.stadiamaps.com/...')
} else {
  // Fallback gratuit
  this.baseMaps['Satellite'] = L.tileLayer('https://server.arcgisonline.com/...')
}
```

---

## Cas d'usage

### 1. Affichage de la carte publique

**Contrôleur :** `PublicController#map`
**Vue :** `app/views/public/events/map.html.erb`
**Stimulus :** `map_controller.js`

**Fonctionnalités :**
- Affichage de tous les événements actifs
- Filtrage par type, statut, période
- Changement de thème de carte
- Clic sur événement → popup détaillée
- Détection des conflits (orange)

### 2. Création d'événement

**Contrôleur :** `Creator::EventsController#new`
**Stimulus :** `map_draw_controller.js`

**Fonctionnalités :**
- Choix du mode : GPS, Polygone, ou Zone
- Recherche d'adresse
- Géolocalisation automatique
- Dessin de polygone personnalisé
- Sélection de zone prédéfinie

### 3. Gestion des zones

**Contrôleur :** `Admin::GeoAreasController`
**Stimulus :** `zone_map_controller.js`

**Fonctionnalités :**
- Création de zones géographiques
- Dessin de polygones
- Recherche d'adresse pour centrage
- Sauvegarde des coordonnées

### 4. Affichage d'un événement

**Contrôleur :** `PublicController#show`
**Stimulus :** `map_display_controller.js`

**Fonctionnalités :**
- Affichage d'un seul événement
- Centrage automatique sur l'événement
- Affichage du type de localisation (GPS/Polygone/Zone)

---

## Résumé technique

### Points clés de l'implémentation

✅ **Leaflet.js 1.9.4** chargé via CDN  
✅ **3 contrôleurs Stimulus** pour différents cas d'usage  
✅ **6 thèmes de carte** avec fallbacks gratuits  
✅ **Nominatim** pour le géocodage  
✅ **Tuiles OSM** comme source principale  
✅ **Design plat** personnalisé avec CSS  
✅ **Gestion des conflits** visuels (orange)  
✅ **Responsive** et optimisé mobile  

### Avantages de cette architecture

- 🚀 **Performance** : CDN + tuiles en cache
- 💰 **Coût** : Gratuit avec fallbacks
- 🔧 **Maintenabilité** : Code modulaire avec Stimulus
- 🎨 **Personnalisation** : Styles CSS complets
- 🌍 **International** : Support mondial via OSM
- 📱 **Mobile-friendly** : Responsive design

### Fichiers importants

```
app/
├── javascript/controllers/
│   ├── map_controller.js           # Affichage événements
│   ├── map_draw_controller.js      # Création/édition
│   ├── map_display_controller.js   # Affichage simple
│   └── zone_map_controller.js      # Gestion zones
├── views/
│   ├── public/events/map.html.erb  # Vue publique
│   └── layouts/*.html.erb          # Chargement Leaflet
└── assets/stylesheets/
    └── application.css             # Styles Leaflet

docs/
└── MAP_API_KEYS.md                 # Guide API keys
```

---

## Ressources

- **Leaflet Documentation** : https://leafletjs.com/reference.html
- **OpenStreetMap** : https://www.openstreetmap.org/
- **Nominatim API** : https://nominatim.org/release-docs/latest/api/Overview/
- **Tile Providers** : https://leaflet-extras.github.io/leaflet-providers/preview/

---

**Guide créé le :** 18/11/2025  
**Version de l'application :** Hyperviseur v1.2  
**Auteur :** Documentation technique
