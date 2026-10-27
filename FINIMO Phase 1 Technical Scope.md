# FINIMO: Phase 1 MVP Technical & Schema Specification
**Target Release Date:** Prior to October 17, 2026  
**Document Goal:** Handover guide for Backend & Database Engineers to build schemas, models, and core REST/GraphQL/tRPC endpoints for a functional working app.  
**Architecture Context:** Zero-External-Banking API, Privacy-First, Multi-Member Attribution, Manual Cashflow.

---

## 1. Executive Summary & Sprint Goal (Pre-Oct 17)

The objective of this sprint is to ship a **functional, end-to-end working family cashflow application** before October 17th. 

### Core User Journey Supported in Phase 1:
1. An **Admin User** registers, logs in, and initializes a **Family Circle**.
2. The Admin adds **Family Members** (e.g., Self: Arpa, Spouse: Chandrani, Dependent/Child: Aryahi).
3. Any member can log **Income** and **Expenses** with dual attribution:
   * **Who Paid** (Payer)
   * **Who It Was For** (Beneficiary)
4. Members can record **Insurance Policies** mapped to specific family members.
5. Users can set up **Targets & Budgets** with fixed caps.
6. Users can group multiple scattered receipts into a **Conjoined Event** (e.g., "Pujo Festival" with itemized garments, dining, and offerings) to track total event spend against a fixed budget pool.
7. The **Insights (Deep Dive)** screen displays basic aggregations: Net Liquidity, Category Burn, Event Totals, and Member-wise spend breakdown.

---

## 2. Database Schema & Data Models (Entity-Relationship)

The backend developer should implement the following relational schema (PostgreSQL / Supabase / Prisma schema format).

```
 ┌────────────────┐         ┌────────────────────────┐
 │     Users      │ 1     1 │        Families        │
 │  (Admin Auth)  ├─────────┤ (Holds Household Pool) │
 └───────┬────────┘         └───────────┬────────────┘
         │                              │ 1
         │                              │
         │                              │ N
         │                  ┌───────────▼────────────┐
         │ 1              1 │     FamilyMembers      │
         └──────────────────┤ (Arpa, Chandrani, etc.)│
                            └─────┬──────────────┬───┘
                                  │ 1            │ 1
        ┌─────────────────────────┘              │
        │ N                                      │ N
┌───────▼────────┐                      ┌────────▼────────┐
│  Transactions  │                      │InsurancePolicies│
│(Expense/Income)│                      │(Term, Health)   │
└───────┬────────┘                      └─────────────────┘
        │ N
        │ 
        │ 0..1
┌───────▼────────┐
│ ConjoinedEvents│
│(Pujo Sinking)  │
└────────────────┘
```

---

### 2.1 Table: `users` (Admin Authentication)
Stores credentials for the primary account owner.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key, Default `gen_random_uuid()` | Unique user identifier |
| `email` | `VARCHAR(255)` | Unique, Not Null | Admin email for authentication |
| `password_hash` | `TEXT` | Not Null | Bcrypt / Argon2 password hash |
| `phone_number` | `VARCHAR(20)` | Nullable | Optional mobile number |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |
| `updated_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

### 2.2 Table: `families` (Household Container)
The multi-tenant container for family data.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Household unique ID |
| `family_name` | `VARCHAR(100)` | Not Null | e.g., "Roy Family" |
| `currency` | `VARCHAR(10)` | Default `'INR'` | Currency code (INR, USD, etc.) |
| `opening_cash_balance`| `NUMERIC(14,2)`| Default `0.00` | Initial liquid balance entered during onboarding |
| `admin_user_id` | `UUID` | Foreign Key (`users.id`) | Family owner |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

### 2.3 Table: `family_members` (Profiles & Dependents)
Represents individuals in the household (including children who do not have login credentials).

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Member ID |
| `family_id` | `UUID` | Foreign Key (`families.id`), On Delete CASCADE | Links to family container |
| `user_id` | `UUID` | Foreign Key (`users.id`), Nullable | If null, member is an offline dependent (e.g., Aryahi) |
| `name` | `VARCHAR(100)` | Not Null | Member name (e.g., "Arpa", "Chandrani", "Aryahi") |
| `relation_type` | `ENUM` | Not Null | `ADMIN`, `SPOUSE`, `CHILD`, `PARENT`, `OTHER` |
| `avatar_url` | `TEXT` | Nullable | Profile avatar image or color token |
| `is_active` | `BOOLEAN` | Default `TRUE` | Soft delete / active state |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

### 2.4 Table: `categories` (Taxonomy)
Categorization for expenses and incomes.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Category ID |
| `family_id` | `UUID` | Foreign Key (`families.id`), Nullable | NULL = System default, Value = Custom category |
| `name` | `VARCHAR(50)` | Not Null | e.g., Household, Groceries, Dining, Medical, Garments |
| `type` | `ENUM` | Not Null | `EXPENSE`, `INCOME` |
| `icon_key` | `VARCHAR(50)` | Default `'default'` | Icon name mapped in mobile app |
| `color_hex` | `VARCHAR(10)` | Default `'#CCFF00'` | Accent color for visual chips |

---

### 2.5 Table: `conjoined_events` (Sinking Funds & Multi-Item Events)
Used for grouping multiple receipts under one temporary umbrella (e.g., "Pujo Expenses 2026", "Family Trip").

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Event ID |
| `family_id` | `UUID` | Foreign Key (`families.id`), On Delete CASCADE | Household ID |
| `title` | `VARCHAR(120)` | Not Null | e.g., "Pujo Expenses 2026", "Diwali Renovation" |
| `budget_cap` | `NUMERIC(14,2)`| Not Null | Allocated spending pool (e.g., 10000.00) |
| `start_date` | `DATE` | Not Null | Start of event |
| `end_date` | `DATE` | Nullable | End date |
| `status` | `ENUM` | Default `'ACTIVE'` | `ACTIVE`, `COMPLETED`, `ARCHIVED` |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

### 2.6 Table: `transactions` (Ledger Entries)
Core ledger supporting dual attribution and conjoined event linking.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Transaction unique ID |
| `family_id` | `UUID` | Foreign Key (`families.id`), On Delete CASCADE | Belongs to household |
| `type` | `ENUM` | Not Null | `EXPENSE`, `INCOME`, `TRANSFER` |
| `amount` | `NUMERIC(14,2)`| Not Null | Amount in standard currency units (e.g., 840.00) |
| `title` | `VARCHAR(150)` | Not Null | Title/Merchant (e.g., "Neon Noodle Bar", "Medicine") |
| `category_id` | `UUID` | Foreign Key (`categories.id`), Not Null | Category link |
| `paid_by_member_id` | `UUID` | Foreign Key (`family_members.id`), Not Null | Member who paid the bill |
| `beneficiary_member_id` | `UUID` | Foreign Key (`family_members.id`), Nullable | Person for whom expense was made (e.g., Aryahi) |
| `event_id` | `UUID` | Foreign Key (`conjoined_events.id`), Nullable | Set if part of a multi-receipt event (e.g., Pujo) |
| `transaction_date` | `TIMESTAMPTZ` | Not Null | Date and time expense occurred |
| `payment_mode` | `ENUM` | Default `'UPI'` | `CASH`, `UPI`, `DEBIT_CARD`, `CREDIT_CARD`, `NET_BANKING` |
| `notes` | `TEXT` | Nullable | Sub-notes or receipt descriptions |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

### 2.7 Table: `insurance_policies` (Protection Vault)
Offline insurance documentation linked to household members.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Policy ID |
| `family_id` | `UUID` | Foreign Key (`families.id`), On Delete CASCADE | Household ID |
| `insured_member_id` | `UUID` | Foreign Key (`family_members.id`), Not Null | Member covered by policy |
| `policy_name` | `VARCHAR(150)`| Not Null | e.g., "HDFC Term Life", "Star Health Floater" |
| `policy_type` | `ENUM` | Not Null | `TERM_LIFE`, `HEALTH`, `AUTO`, `OTHER` |
| `policy_number` | `VARCHAR(100)`| Nullable | Policy reference number |
| `sum_assured` | `NUMERIC(14,2)`| Not Null | Coverage amount (e.g., 10000000.00 for ₹1 Cr) |
| `premium_amount` | `NUMERIC(14,2)`| Not Null | Recurring premium cost (e.g., 1000.00) |
| `premium_frequency` | `ENUM` | Default `'ANNUAL'` | `MONTHLY`, `QUARTERLY`, `ANNUAL` |
| `renewal_due_date` | `DATE` | Not Null | Next premium payment date |
| `status` | `ENUM` | Default `'ACTIVE'` | `ACTIVE`, `LAPSED`, `PENDING_RENEWAL` |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

### 2.8 Table: `targets` (Budgets & Spending Limits)
Core targets displayed on Tab 3.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Target ID |
| `family_id` | `UUID` | Foreign Key (`families.id`), On Delete CASCADE | Household ID |
| `category_id` | `UUID` | Foreign Key (`categories.id`), Nullable | NULL = Global family budget cap |
| `target_name` | `VARCHAR(100)`| Not Null | e.g., "Daily Safe Cap", "Household Rent Pool" |
| `limit_amount` | `NUMERIC(14,2)`| Not Null | Cap amount (e.g., 20000.00) |
| `time_frame` | `ENUM` | Not Null | `DAILY`, `WEEKLY`, `MONTHLY` |
| `notify_threshold_pct` | `INT` | Default `80` | Trigger warning when spend reaches 80% |
| `is_active` | `BOOLEAN` | Default `TRUE` | Active tracking state |
| `created_at` | `TIMESTAMPTZ` | Default `NOW()` | Timestamp |

---

## 3. Core API Endpoints for Backend Dev (Pre-Oct 17 Release)

All routes require standard Bearer JWT authorization (`Authorization: Bearer <token>`).

### 3.1 Auth & Family Management
* `POST /api/v1/auth/register`
  * Body: `{ email, password, family_name, opening_cash_balance }`
  * Response: Creates `users`, `families`, and initial `family_members` (Admin profile). Returns JWT + Family Context.
* `POST /api/v1/auth/login`
  * Body: `{ email, password }`
  * Response: Returns user info, active family object, and member roster.
* `GET /api/v1/family/members`
  * Response: Array of members (`id`, `name`, `relation_type`, `avatar_url`).
* `POST /api/v1/family/members`
  * Body: `{ name, relation_type: "CHILD" | "SPOUSE" | "PARENT", user_id: null }`
  * Response: Newly created member.

---

### 3.2 Transactions & Ledger
* `GET /api/v1/transactions`
  * Query Params:
    * `month=10&year=2026`
    * `member_id=<uuid>` (optional: filter by payer or beneficiary)
    * `category_id=<uuid>` (optional)
    * `type=EXPENSE | INCOME` (optional)
  * Response: Paginated list of transactions with populated member and category names.
* `POST /api/v1/transactions`
  * Body:
    ```json
    {
      "type": "EXPENSE",
      "amount": 500.00,
      "title": "Aryahi Pediatric Cough Syrup",
      "category_id": "c61b...",
      "paid_by_member_id": "m1_arpa",
      "beneficiary_member_id": "m3_aryahi",
      "event_id": null,
      "transaction_date": "2026-10-04T14:30:00Z",
      "payment_mode": "UPI",
      "notes": "Apollo Pharmacy"
    }
    ```
  * Business Logic: Decrements family current liquid balance. Returns transaction object.
* `DELETE /api/v1/transactions/:id`
  * Soft/hard delete and recalculate liquid balance.

---

### 3.3 Conjoined Events (Multi-Receipt Sinking Funds)
* `GET /api/v1/events`
  * Response: List of active events with real-time calculated financial status:
    ```json
    [
      {
        "id": "ev_pujo",
        "title": "Pujo Expenses 2026",
        "budget_cap": 10000.00,
        "total_spent": 8672.00,
        "remaining_budget": 1328.00,
        "percentage_used": 86.72,
        "item_count": 4,
        "status": "ACTIVE"
      }
    ]
    ```
* `POST /api/v1/events`
  * Body: `{ title, budget_cap, start_date, end_date }`
* `GET /api/v1/events/:id/items`
  * Response: Returns the event details and an array of all `transactions` linked to this `event_id` (e.g., FabIndia Garments ₹4,025, Sweets ₹2,299, Food ₹1,608).
* `POST /api/v1/events/:id/add-receipt`
  * Sugar endpoint that creates a transaction with `event_id` preset.

---

### 3.4 Insurance Vault
* `GET /api/v1/insurance`
  * Response: List of all insurance policies grouped by `insured_member_id`.
  * Calculated fields in payload: `total_sum_assured_umbrella` (Sum of all coverage amounts).
* `POST /api/v1/insurance`
  * Body:
    ```json
    {
      "insured_member_id": "m1_arpa",
      "policy_name": "HDFC Click 2 Protect Term",
      "policy_type": "TERM_LIFE",
      "policy_number": "POL-981249",
      "sum_assured": 10000000.00,
      "premium_amount": 1000.00,
      "premium_frequency": "MONTHLY",
      "renewal_due_date": "2026-11-15"
    }
    ```
* `PUT /api/v1/insurance/:id`
  * Updates renewal dates, status, or premium amounts.

---

### 3.5 Targets & Budget Health
* `GET /api/v1/targets`
  * Response: List of targets with dynamic spend calculation for the current active period:
    ```json
    [
      {
        "id": "tgt_01",
        "target_name": "Household Rent & Core",
        "limit_amount": 20000.00,
        "current_period_spent": 20000.00,
        "percentage_consumed": 100.0,
        "is_exceeded": false
      },
      {
        "id": "tgt_02",
        "target_name": "Daily Discretionary Limit",
        "limit_amount": 1500.00,
        "current_period_spent": 840.00,
        "percentage_consumed": 56.0,
        "is_exceeded": false
      }
    ]
    ```
* `POST /api/v1/targets`
  * Body: `{ target_name, limit_amount, time_frame, category_id, notify_threshold_pct }`

---

### 3.6 Deep Dive & Insights Aggregation
* `GET /api/v1/insights/summary?month=10&year=2026`
  * Response payload delivering figures needed for Screen 1.0 (Home) and Screen 4.0 (Deep Dive):
    ```json
    {
      "consolidated_liquidity": 216949.00,
      "total_monthly_income": 182500.00,
      "total_monthly_expense": 58281.00,
      "daily_safe_to_spend": 420.00,
      "budget_health_score_pct": 74,
      "category_breakdown": [
        { "category_name": "Household", "amount": 20000.00, "percentage": 34.3 },
        { "category_name": "Pujo Festival", "amount": 8672.00, "percentage": 14.88 },
        { "category_name": "Dining", "amount": 1608.00, "percentage": 2.75 },
        { "category_name": "Medical", "amount": 500.00, "percentage": 0.85 }
      ],
      "member_breakdown": [
        { "member_id": "m1_arpa", "name": "Arpa", "total_paid": 52781.00, "total_benefited": 20000.00 },
        { "member_id": "m2_chandrani", "name": "Chandrani", "total_paid": 5500.00, "total_benefited": 9025.00 },
        { "member_id": "m3_aryahi", "name": "Aryahi", "total_paid": 0.00, "total_benefited": 5500.00 }
      ]
    }
    ```

---

## 4. Screen-to-API Mapping Matrix (Working App: Pre-Oct 17)

| App Screen | Core Visual Element | API Endpoint Used |
| :--- | :--- | :--- |
| **Tab 1: Status (Home)** | Liquidity Card (`₹2,16,949`) & Daily Gauge | `GET /api/v1/insights/summary` |
| | Family Profile Dropdown (`Family (All) ▾`) | `GET /api/v1/family/members` |
| | Protection Hub Preview Card | `GET /api/v1/insurance` |
| | Universal Logger (`+ Expense`) | `POST /api/v1/transactions` |
| **Tab 2: Activity** | Transaction Ledger Feed | `GET /api/v1/transactions` |
| | Member Attribution Badge (`Aryahi`, `Arpa`) | Attached to transaction object |
| | Multi-Item Event Expansion (Pujo) | `GET /api/v1/events/:id/items` |
| **Tab 3: Targets** | Budget Health Ring (74%) | `GET /api/v1/insights/summary` |
| | Active Limits (Household, Daily Cap) | `GET /api/v1/targets` |
| | Event Sinking Fund Cards (Pujo Fund) | `GET /api/v1/events` |
| **Tab 4: Deep Dive** | Category Donut Chart | `GET /api/v1/insights/summary` |
| | Member Spending Split | `GET /api/v1/insights/summary` |
| **Sub-Screen: Insurance**| Member-wise Policy Repository | `GET /api/v1/insurance` & `POST` |

---

## 5. Post-October 20 Roadmap (Deferred to Phase 2)

The following advanced specifications are explicitly **excluded from the Oct 17 sprint** to prevent scope creep. Backend and Frontend will pick these up post-Oct 20:

1. **Automated Scheduled Cron / Rule Engine:**
   * Automated monthly posting of recurring salaries on the 1st.
   * Auto-debit ledger transfers moving funds from Liquid Cash into Invested Portfolio on the 10th (e.g., executing ₹16,000 across MF SIPs and RD).
2. **SMS & Bank Notification Scraper / Parser:**
   * Client-side Android SMS broadcast receiver parsing transaction text into draft entries.
   * "Approve SMS Outflow" swipe tray on Screen 2.2.
3. **Compound Wealth Projections & Portfolio Revaluation:**
   * Mathematical interest compounding curves (e.g., Aryahi's 18th birthday corpus estimator).
   * AMC NAV / Portfolio net worth manual update sliders.
4. **Deterministic Smart Insights Rule Engine:**
   * Automated warnings for OTT subscription redundancies ("3 active OTTs detected").
   * Late-night food delivery impulse alerts.
   * Sinking fund overage auto-mitigation micro-goals.
5. **Secure Policy PDF Locker:**
   * S3/Cloud Storage encrypted document uploads for health cards and auto insurance policies.