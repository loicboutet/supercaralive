# Data Model

## Overview

This document describes the database schema for the automotive service marketplace platform.

## Core Entities

### Users Table
Main authentication and user management table using Single Table Inheritance (STI) pattern.

**Table: `users`**
```
- id: bigint (PK)
- type: string (STI: Admin, Professional, Client)
- email: string (unique, indexed)
- encrypted_password: string
- reset_password_token: string
- reset_password_sent_at: datetime
- remember_created_at: datetime
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_users_on_email` (unique)
- `index_users_on_type`
- `index_users_on_reset_password_token` (unique)

---

### Professional Profiles Table
Extended profile information for professionals (mechanics, body shop workers, washers).

**Table: `professional_profiles`**
```
- id: bigint (PK)
- user_id: bigint (FK -> users.id, unique)
- company_name: string
- professional_type: string (enum: mechanic, body_shop, washer)
- photo: string (Active Storage attachment)
- service_radius_km: integer
- latitude: decimal(10,6)
- longitude: decimal(10,6)
- address: string
- city: string
- postal_code: string
- phone: string
- description: text
- siren: string (for mechanics)
- pricing_type: string (enum: flat_rate, hourly_rate)
- hourly_rate: decimal(8,2) (nullable)
- travel_fee: decimal(8,2)
- status: string (enum: pending, approved, rejected, suspended)
- approved_at: datetime
- approved_by_id: bigint (FK -> users.id, nullable)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_professional_profiles_on_user_id` (unique)
- `index_professional_profiles_on_latitude_and_longitude`
- `index_professional_profiles_on_status`
- `index_professional_profiles_on_professional_type`
- `index_professional_profiles_on_city`

---

### Verification Documents Table
Store uploaded verification documents for professionals.

**Table: `verification_documents`**
```
- id: bigint (PK)
- professional_profile_id: bigint (FK -> professional_profiles.id)
- document_type: string (enum: diploma, insurance, siren)
- file: string (Active Storage attachment)
- status: string (enum: pending, approved, rejected)
- notes: text
- verified_at: datetime
- verified_by_id: bigint (FK -> users.id, nullable)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_verification_documents_on_professional_profile_id`
- `index_verification_documents_on_status`

---

### Client Profiles Table
Extended profile information for clients (anonymized).

**Table: `client_profiles`**
```
- id: bigint (PK)
- user_id: bigint (FK -> users.id, unique)
- display_name: string (pseudonym or initials)
- phone: string
- address: string (encrypted, hidden until booking validation)
- city: string
- postal_code: string
- latitude: decimal(10,6)
- longitude: decimal(10,6)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_client_profiles_on_user_id` (unique)

---

### Services Table
Predefined service catalog (annual maintenance, exterior wash, etc.).

**Table: `services`**
```
- id: bigint (PK)
- name: string
- slug: string (unique, indexed)
- description: text
- category: string (enum: maintenance, wash, repair, bodywork)
- icon: string (optional)
- active: boolean (default: true)
- position: integer (for ordering)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_services_on_slug` (unique)
- `index_services_on_category`
- `index_services_on_active`

---

### Professional Services Table (Join Table)
Links professionals to the services they offer with custom pricing.

**Table: `professional_services`**
```
- id: bigint (PK)
- professional_profile_id: bigint (FK -> professional_profiles.id)
- service_id: bigint (FK -> services.id)
- base_price: decimal(8,2) (nullable, for flat rate)
- estimated_duration_minutes: integer (nullable)
- description: text (optional custom description)
- active: boolean (default: true)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_professional_services_on_professional_profile_id`
- `index_professional_services_on_service_id`
- `index_professional_services_on_professional_and_service` (unique composite)

---

### Vehicles Table
Client vehicles information.

**Table: `vehicles`**
```
- id: bigint (PK)
- client_profile_id: bigint (FK -> client_profiles.id)
- make: string (e.g., Renault, Peugeot)
- model: string
- year: integer
- mileage: integer
- license_plate: string (optional, encrypted)
- vin: string (optional, encrypted)
- notes: text
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_vehicles_on_client_profile_id`

---

### Availability Slots Table
Professional availability calendar.

**Table: `availability_slots`**
```
- id: bigint (PK)
- professional_profile_id: bigint (FK -> professional_profiles.id)
- start_time: datetime
- end_time: datetime
- status: string (enum: available, booked, blocked)
- recurring: boolean (default: false)
- recurrence_rule: string (iCal RRULE format, nullable)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_availability_slots_on_professional_profile_id`
- `index_availability_slots_on_start_time_and_end_time`
- `index_availability_slots_on_status`

---

### Bookings Table
Core booking/appointment entity.

**Table: `bookings`**
```
- id: bigint (PK)
- client_profile_id: bigint (FK -> client_profiles.id)
- professional_profile_id: bigint (FK -> professional_profiles.id)
- vehicle_id: bigint (FK -> vehicles.id)
- service_id: bigint (FK -> services.id)
- availability_slot_id: bigint (FK -> availability_slots.id, nullable)
- scheduled_at: datetime
- estimated_duration_minutes: integer
- status: string (enum: pending, confirmed, in_progress, completed, cancelled, rejected)
- client_description: text
- client_address: string (actual intervention address)
- client_latitude: decimal(10,6)
- client_longitude: decimal(10,6)
- estimated_price: decimal(8,2)
- final_price: decimal(8,2) (nullable, set after validation - Brick 2)
- pricing_type: string (enum: flat_rate, hourly_rate)
- travel_fee: decimal(8,2)
- cancellation_reason: text (nullable)
- cancelled_by: string (enum: client, professional, system)
- cancelled_at: datetime
- confirmed_at: datetime
- completed_at: datetime
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_bookings_on_client_profile_id`
- `index_bookings_on_professional_profile_id`
- `index_bookings_on_vehicle_id`
- `index_bookings_on_service_id`
- `index_bookings_on_status`
- `index_bookings_on_scheduled_at`

---

### Messages Table
Internal messaging system between clients and professionals.

**Table: `messages`**
```
- id: bigint (PK)
- booking_id: bigint (FK -> bookings.id)
- sender_id: bigint (FK -> users.id)
- recipient_id: bigint (FK -> users.id)
- content: text
- read_at: datetime (nullable)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_messages_on_booking_id`
- `index_messages_on_sender_id`
- `index_messages_on_recipient_id`
- `index_messages_on_read_at`
- `index_messages_on_created_at`

---

## Brick 2 Entities

### Payments Table
Payment transactions via Stripe.

**Table: `payments`**
```
- id: bigint (PK)
- booking_id: bigint (FK -> bookings.id)
- client_profile_id: bigint (FK -> client_profiles.id)
- amount: decimal(10,2)
- currency: string (default: 'eur')
- status: string (enum: pending, authorized, captured, failed, refunded)
- stripe_payment_intent_id: string (indexed)
- stripe_charge_id: string
- payment_method: string
- paid_at: datetime
- refunded_at: datetime
- refund_amount: decimal(10,2)
- refund_reason: text
- metadata: jsonb
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_payments_on_booking_id`
- `index_payments_on_client_profile_id`
- `index_payments_on_stripe_payment_intent_id` (unique)
- `index_payments_on_status`

---

### Invoices Table
Generated invoices for completed bookings.

**Table: `invoices`**
```
- id: bigint (PK)
- booking_id: bigint (FK -> bookings.id)
- payment_id: bigint (FK -> payments.id, nullable)
- client_profile_id: bigint (FK -> client_profiles.id)
- professional_profile_id: bigint (FK -> professional_profiles.id)
- invoice_number: string (unique, indexed)
- issue_date: date
- due_date: date
- subtotal: decimal(10,2)
- tax_rate: decimal(5,2)
- tax_amount: decimal(10,2)
- total_amount: decimal(10,2)
- status: string (enum: draft, issued, paid, cancelled)
- pdf_generated_at: datetime
- pdf_file: string (Active Storage attachment)
- notes: text
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_invoices_on_booking_id` (unique)
- `index_invoices_on_payment_id`
- `index_invoices_on_client_profile_id`
- `index_invoices_on_professional_profile_id`
- `index_invoices_on_invoice_number` (unique)
- `index_invoices_on_status`

---

### Reviews Table
Bidirectional review system (client ↔ professional).

**Table: `reviews`**
```
- id: bigint (PK)
- booking_id: bigint (FK -> bookings.id)
- reviewer_id: bigint (FK -> users.id) (polymorphic: client or professional)
- reviewee_id: bigint (FK -> users.id) (polymorphic: professional or client)
- reviewer_type: string (Client, Professional)
- reviewee_type: string (Professional, Client)
- rating: integer (1-5)
- comment: text
- moderation_status: string (enum: pending, approved, rejected, flagged)
- moderated_at: datetime
- moderated_by_id: bigint (FK -> users.id, nullable)
- moderation_notes: text
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_reviews_on_booking_id`
- `index_reviews_on_reviewer`
- `index_reviews_on_reviewee`
- `index_reviews_on_moderation_status`

---

### Review Criteria Table
Specific criteria ratings for professional reviews (5 criteria system).

**Table: `review_criteria`**
```
- id: bigint (PK)
- review_id: bigint (FK -> reviews.id)
- criterion_name: string (enum: punctuality, quality, cleanliness, interpersonal, value_for_money)
- rating: integer (1-5)
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_review_criteria_on_review_id`
- `index_review_criteria_on_review_and_criterion` (unique composite)

---

### Maintenance Reminders Table
Periodic maintenance reminder system.

**Table: `maintenance_reminders`**
```
- id: bigint (PK)
- client_profile_id: bigint (FK -> client_profiles.id)
- vehicle_id: bigint (FK -> vehicles.id)
- service_id: bigint (FK -> services.id)
- reminder_type: string (enum: time_based, mileage_based)
- next_reminder_date: date
- reminder_interval_months: integer (nullable)
- mileage_interval: integer (nullable)
- last_service_date: date
- last_service_mileage: integer
- status: string (enum: active, completed, cancelled)
- notification_sent_at: datetime
- created_at: datetime
- updated_at: datetime
```

**Indexes:**
- `index_maintenance_reminders_on_client_profile_id`
- `index_maintenance_reminders_on_vehicle_id`
- `index_maintenance_reminders_on_next_reminder_date`
- `index_maintenance_reminders_on_status`

---

## Active Storage Tables

Rails Active Storage is used for file uploads (photos, documents, PDFs).

### Active Storage Blobs
```
- id: bigint (PK)
- key: string (unique, indexed)
- filename: string
- content_type: string
- metadata: text
- service_name: string
- byte_size: bigint
- checksum: string
- created_at: datetime
```

### Active Storage Attachments
```
- id: bigint (PK)
- name: string
- record_type: string
- record_id: bigint
- blob_id: bigint (FK -> active_storage_blobs.id)
- created_at: datetime
```

**Indexes:**
- `index_active_storage_attachments_on_record` (composite)
- `index_active_storage_attachments_on_blob_id`

---

## Key Relationships Summary

```
User (STI)
  ├─ has_one :professional_profile (if type: Professional)
  ├─ has_one :client_profile (if type: Client)
  ├─ has_many :sent_messages (as sender)
  └─ has_many :received_messages (as recipient)

ProfessionalProfile
  ├─ belongs_to :user
  ├─ has_many :verification_documents
  ├─ has_many :professional_services
  ├─ has_many :services (through: professional_services)
  ├─ has_many :availability_slots
  ├─ has_many :bookings
  ├─ has_many :reviews (as reviewee)
  ├─ has_many :invoices
  └─ has_one_attached :photo

ClientProfile
  ├─ belongs_to :user
  ├─ has_many :vehicles
  ├─ has_many :bookings
  ├─ has_many :payments
  ├─ has_many :invoices
  ├─ has_many :reviews (as reviewee)
  └─ has_many :maintenance_reminders

Booking
  ├─ belongs_to :client_profile
  ├─ belongs_to :professional_profile
  ├─ belongs_to :vehicle
  ├─ belongs_to :service
  ├─ belongs_to :availability_slot (optional)
  ├─ has_many :messages
  ├─ has_one :payment
  ├─ has_one :invoice
  └─ has_many :reviews

Service
  ├─ has_many :professional_services
  ├─ has_many :professional_profiles (through: professional_services)
  ├─ has_many :bookings
  └─ has_many :maintenance_reminders

Review
  ├─ belongs_to :booking
  ├─ belongs_to :reviewer (polymorphic: User)
  ├─ belongs_to :reviewee (polymorphic: User)
  └─ has_many :review_criteria

Payment
  ├─ belongs_to :booking
  ├─ belongs_to :client_profile
  └─ has_one :invoice

Invoice
  ├─ belongs_to :booking
  ├─ belongs_to :payment (optional)
  ├─ belongs_to :client_profile
  ├─ belongs_to :professional_profile
  └─ has_one_attached :pdf_file
```

---

## Database Considerations

### Geolocation
- Use PostgreSQL with PostGIS extension for efficient radius-based searches
- Store latitude/longitude as decimal(10,6) for precision
- Index on lat/long columns for performance

### Security & Privacy
- Use Rails encrypted attributes for sensitive data (address, license_plate, VIN)
- Implement row-level security where needed
- Anonymize client data until booking confirmation

### Performance
- Add appropriate indexes on foreign keys
- Use composite indexes for common query patterns
- Consider materialized views for complex aggregations (review averages)
- Use JSONB for flexible metadata storage (payments)

### Scalability
- Design for horizontal scaling
- Use Active Job for background processing (emails, reminders)
- Consider caching strategy for professional listings and reviews

---

## Notes

- All monetary values use decimal(8,2) or decimal(10,2) for precision
- All timestamps use Rails conventions (created_at, updated_at)
- Soft deletes are not implemented initially but can be added if needed
- Enums are stored as strings for readability and flexibility
- Active Storage is used for all file uploads with local/cloud storage flexibility
