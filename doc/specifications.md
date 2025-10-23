# Project Specifications

## 2.1 General Project Description

Web platform connecting automotive professionals (mechanics, body shop workers, car washers) offering at-home services with individuals needing vehicle maintenance or repair. The platform facilitates appointment booking, pricing transparency, and online payment.

## 2.2 Features to Develop

### 🏗️ BRICK 1 - Base Platform and Booking System (€5000)

#### 👤 Admin (5000.dev)
- I can create and configure accounts during onboarding
- I can manually validate professional registrations
- I can supervise technical aspects without accessing customer data

#### 👑 Professional (Mechanic/Body Shop/Washer)
- I can create my profile with company name, photo, geographical service area (radius in km)
- I can upload my verification documents (diploma, insurance, SIREN for mechanics)
- I can select the services I offer (predefined multiple choices: annual maintenance, exterior wash, interior wash, etc.)
- I can set my rates (flat rate or hourly rate + travel fee)
- I can manage my availability calendar
- I can receive slot pre-bookings and validate/refuse them
- I can view request details (car model, mileage, need description)
- I can communicate with the client via integrated messaging
- I can view my service history

#### 🚗 Client (Individual)
- I can create my account anonymously (initials or pseudonym visible)
- I can search for professionals by service type and location (list with filters)
- I can view professional profiles (services, rates, reviews, service area)
- I can select an availability slot and make a pre-booking
- I can indicate my car model, mileage and describe my need
- I can communicate with the professional via integrated messaging
- I can view my current and past bookings

#### ⚙️ Brick 1 System Features
- Authentication and user profile management (3 types: Admin, Professional, Client)
- Geolocation system by radius (search within a defined perimeter)
- Management of offered services (predefined tags/categories)
- Slot pre-booking system with validation
- Internal messaging between professionals and clients
- Email notifications for key events (new request, validation, appointment reminder)
- Responsive web interface (web app)
- Client data anonymization (address hidden until final validation)

### 🔒 BRICK 2 - Payment, Reviews and Wallet (€5000)

#### 👑 Professional
- I can validate the final price after discussion with the client
- I can mark a service as completed
- I can view reviews left on my profile
- I can leave a review about the client (stars on criteria)

#### 🚗 Client
- I can pay online via integrated payment module (Stripe) after professional validation
- I can view my personal wallet with the history of all my invoices
- I can download my invoices
- I can leave a review about the professional (stars on 5 criteria: punctuality, quality, cleanliness, interpersonal skills, value for money)
- I can view other clients' reviews
- I receive reminder notifications for periodic maintenance

#### ⚙️ Brick 2 System Features
- Secure payment module integration (Stripe)
- Bank pre-authorization system (for hourly rate services)
- Automatic invoice generation
- Personal client wallet with service history
- Bidirectional review system (professional ↔ client)
- Multi-criteria star rating
- Automatic review moderation (inappropriate content detection)
- Automatic reminder system for periodic maintenance
- Document export (PDF invoices)

## 2.3 Explicitly Excluded Elements

The following elements are explicitly excluded from the scope of the first 2 bricks:

- Automatic generation of detailed quotes with parts
- Vehicle photo upload system
- Native mobile application (iOS/Android)
- Automotive manufacturer catalog integration
- Predictive AI assistant for maintenance
- Auto insurance comparator
- Native push notifications (replaced by email notifications)
- Referral system

This list of features constitutes the contractual scope of development to be performed.
