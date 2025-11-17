# Guide d'implémentation de Solid Queue

## Vue d'ensemble

Ce guide explique comment Solid Queue est configuré dans cette application Rails 8 et comment reproduire cette configuration dans de futurs projets.

Solid Queue est le système de gestion de jobs par défaut de Rails 8, remplaçant les anciens adapters comme Sidekiq ou Delayed Job. Il utilise SQLite pour stocker les jobs, ce qui le rend simple à déployer et à maintenir.

## ✅ Vérification de l'installation actuelle

L'installation a été testée et vérifiée avec succès :
```ruby
TestJob.perform_later('Verification test - Solid Queue is working!')
# => Job enqueued et exécuté avec succès
```

## Configuration dans cette application

### 1. Gemfile

Solid Queue est déjà inclus dans le Gemfile par défaut de Rails 8 :

```ruby
gem "solid_queue"
```

Après ajout, exécuter :
```bash
bundle install
```

### 2. Configuration de la base de données (config/database.yml)

Solid Queue utilise une base de données séparée pour les jobs :

```yaml
development:
  primary:
    <<: *default
    database: storage/rlist_development.sqlite3
  queue:
    <<: *default
    database: storage/rlist_development_queue.sqlite3
    migrations_paths: db/queue_migrate

production:
  primary:
    <<: *default
    database: storage/rlist_production.sqlite3
  queue:
    <<: *default
    database: storage/rlist_production_queue.sqlite3
    migrations_paths: db/queue_migrate
```

**Points clés :**
- Base de données séparée pour les jobs (`queue`)
- Chemin de migrations spécifique (`db/queue_migrate`)
- Même configuration pour development et production

### 3. Configuration des environnements

#### Development (config/environments/development.rb)

```ruby
# Use SolidQueue as the Active Job adapter
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

#### Production (config/environments/production.rb)

```ruby
# Replace the default in-process and non-durable queuing backend for Active Job.
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

### 4. Configuration de la queue (config/queue.yml)

```yaml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 3
      processes: <%= ENV.fetch("JOB_CONCURRENCY", 1) %>
      polling_interval: 0.1

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
```

**Paramètres importants :**
- `polling_interval`: Fréquence de vérification des nouveaux jobs (en secondes)
- `batch_size`: Nombre de jobs traités par batch
- `threads`: Nombre de threads par processus worker
- `processes`: Nombre de processus workers (configurable via `JOB_CONCURRENCY`)
- `queues: "*"`: Traite toutes les queues

### 5. Script bin/jobs

Le fichier `bin/jobs` doit être exécutable et contenir :

```ruby
#!/usr/bin/env ruby

require_relative "../config/environment"
require "solid_queue/cli"

SolidQueue::Cli.start(ARGV)
```

Rendre le script exécutable :
```bash
chmod +x bin/jobs
```

### 6. Procfile.dev

Pour démarrer automatiquement les workers avec `bin/dev` :

```yaml
web: bin/rails server
css: bin/rails tailwindcss:watch
jobs: bin/jobs
```

### 7. Initialisation de la base de données

Créer la base de données et les tables nécessaires :

```bash
bin/rails db:prepare
```

Cette commande va :
- Créer `storage/rlist_development_queue.sqlite3`
- Exécuter les migrations Solid Queue
- Créer toutes les tables nécessaires (solid_queue_jobs, solid_queue_processes, etc.)

## Comment reproduire dans un nouveau projet Rails 8

### Étape 1 : Créer le projet

```bash
rails new mon_projet
cd mon_projet
```

### Étape 2 : Vérifier le Gemfile

Solid Queue devrait déjà être présent. Si ce n'est pas le cas :

```ruby
gem "solid_queue"
```

Puis :
```bash
bundle install
```

### Étape 3 : Installer Solid Queue

```bash
bin/rails generate solid_queue:install
```

Cette commande va créer :
- `config/queue.yml`
- `config/recurring.yml`
- `db/queue_schema.rb`
- Mettre à jour `config/database.yml`

### Étape 4 : Configurer les environnements

Ajouter dans `config/environments/development.rb` et `config/environments/production.rb` :

```ruby
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }
```

### Étape 5 : Créer la base de données

```bash
bin/rails db:prepare
```

### Étape 6 : Configurer Procfile.dev

Créer ou modifier `Procfile.dev` :

```yaml
web: bin/rails server
jobs: bin/jobs
```

Si vous utilisez Tailwind CSS :
```yaml
web: bin/rails server
css: bin/rails tailwindcss:watch
jobs: bin/jobs
```

### Étape 7 : Vérifier bin/jobs

S'assurer que `bin/jobs` existe et est exécutable :

```bash
chmod +x bin/jobs
```

Contenu de `bin/jobs` :
```ruby
#!/usr/bin/env ruby

require_relative "../config/environment"
require "solid_queue/cli"

SolidQueue::Cli.start(ARGV)
```

## Utilisation

### Démarrer l'application avec les workers

```bash
bin/dev
```

Cela démarre automatiquement :
- Le serveur web Rails
- Le watcher CSS (si configuré)
- Les workers Solid Queue

### Créer un job

```bash
bin/rails generate job MonJob
```

Exemple de job :

```ruby
class MonJob < ApplicationJob
  queue_as :default

  def perform(message)
    Rails.logger.info "Job exécuté: #{message}"
    puts "Job exécuté: #{message}"
  end
end
```

### Enqueuer un job

```ruby
# Exécution immédiate
MonJob.perform_later("Mon message")

# Exécution différée
MonJob.set(wait: 5.minutes).perform_later("Message différé")

# Exécution à une heure précise
MonJob.set(wait_until: Date.tomorrow.noon).perform_later("Message planifié")

# Queue spécifique
class JobUrgent < ApplicationJob
  queue_as :urgent
  
  def perform
    # Logique du job
  end
end
```

### Surveiller les jobs

Dans la console Rails (`bin/rails console`) :

```ruby
# Nombre total de jobs
SolidQueue::Job.count

# Jobs en attente
SolidQueue::Job.where(finished_at: nil)

# Jobs terminés
SolidQueue::Job.where.not(finished_at: nil)

# Jobs échoués
SolidQueue::FailedExecution.all

# Processus actifs
SolidQueue::Process.all
```

## Configuration avancée

### Queues multiples avec priorités

Dans `config/queue.yml` :

```yaml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "urgent,default"
      threads: 5
      processes: 2
      polling_interval: 0.1
    - queues: "low_priority"
      threads: 2
      processes: 1
      polling_interval: 1

development:
  <<: *default

production:
  <<: *default
```

### Jobs récurrents

Dans `config/recurring.yml` :

```yaml
production:
  cleanup_old_data:
    class: CleanupJob
    schedule: every day at 2am
    queue: maintenance
  
  send_daily_report:
    class: DailyReportJob
    schedule: every day at 9am
    args: ["daily"]
```

### Variables d'environnement

Ajuster le nombre de processus workers :

```bash
# Development
JOB_CONCURRENCY=2 bin/dev

# Production
export JOB_CONCURRENCY=4
```

## Dépannage

### Les jobs ne s'exécutent pas

1. Vérifier que `bin/jobs` est en cours d'exécution
2. Vérifier les logs : `tail -f log/development.log`
3. Vérifier la base de données queue existe : `ls storage/*queue*`

### Réinitialiser la queue

```bash
bin/rails db:drop:queue
bin/rails db:prepare
```

### Voir les jobs en erreur

```ruby
# Console Rails
SolidQueue::FailedExecution.all.each do |failed|
  puts "Job ID: #{failed.job_id}"
  puts "Error: #{failed.error}"
  puts "---"
end
```

### Relancer un job échoué

```ruby
# Console Rails
failed_job = SolidQueue::FailedExecution.first
failed_job.job.retry_job
```

## Avantages de Solid Queue

1. **Simplicité** : Pas de dépendance externe (Redis, PostgreSQL avec pg_notify, etc.)
2. **Déploiement facile** : Tout est dans SQLite
3. **Intégration native** : Fait partie de Rails 8
4. **Performance** : Suffisant pour la plupart des applications
5. **Monitoring** : Tables SQL faciles à interroger
6. **Fiabilité** : Transactions ACID de SQLite

## Limitations à connaître

1. **Scalabilité** : Pour des volumes très élevés (>10k jobs/min), considérer Sidekiq
2. **Distribution** : Solid Queue fonctionne mieux sur un seul serveur
3. **Temps réel** : Polling interval minimum de 0.1s (vs push instantané avec Redis)

## Conclusion

Solid Queue est parfaitement adapté pour :
- Applications Rails 8 standard
- Projets avec volume modéré de jobs
- Déploiements simples
- Équipes qui préfèrent éviter les dépendances externes

Pour cette application (rlist), Solid Queue est configuré et prêt à l'emploi. Il suffit de lancer `bin/dev` pour démarrer l'application avec les workers actifs.
