# FINIMO: Next-Gen Neo-Fintech Family Financial OS
Master Mobile UI Architecture & Component Specification for High-Fidelity UI Generators
---
## 1. DESIGN TOKENS & VISUAL SYSTEM (Vivid Simplex)
### Color Palette
- Canvas Base (OLED Black): #0A0A0C
- Surface 01 (Elevated Squircle): #141418
- Surface 02 (Nested / Modal Containers): #1C1C22
- Border / Stroke: 1px solid rgba(255, 255, 255, 0.08)
- Primary Accent (Neon Electric Lime): #CCFF00 (Active states, Primary CTAs, Budget Health Rings)
- Secondary Accent (Vivid Neon Purple): #BF5AF2 (Mutual Funds, SIPs, Wealth Vault, AI/Rule Banners)
- Tertiary Accent (Cyber Cyan): #00F5FF (Liquid Balances, Safe-to-Spend, Insurance Vault)
- Danger / Outflow Accent (Vivid Coral): #FF453A (Expenses, High Burn Alerts, Overdue Premiums)
- Neutral Tints: #8E8E93 (Sub-labels), #FFFFFF (Primary Headings)
### Typography Hierarchy
- Display / Currency Numerals: 'Space Grotesk', Semi-Bold / Bold (Tight letter spacing: -0.03em)
- Body / Meta / Controls: 'Manrope', Regular (400) & Medium (500)
- Micro Badges / System Chips: 'Manrope' 10px–11px, Uppercase with 0.08em letter spacing
### Component Foundations
- Card Radius: 20px squircle
- Button Radius: 14px rounded-pill / squircle
- Navigation: Strict persistent 4-tab bar at bottom (Height: 80px, Frosted glass: background #0A0A0C with 80% opacity and 20px blur)
- Nav Items (Left to Right):
  1. Status (Home Logomark / Status Ring)
  2. Activity (Dual-receipt Ledger Icon)
  3. Targets (Target / Precision Bullseye)
  4. Deep Dive (Multi-bar Velocity / Chart Icon)
---
## 2. SCREEN ARCHITECTURE & DRILLDOWN MAPPING
*   **Tab 1: Status Hub**
    *   Screen 1.0: Status Screen (Main Home Dashboard)
    *   Screen 1.1: Family Profile & Multi-Member Switcher (Bottom Sheet / Overlay)
    *   Screen 1.2: Wealth & Mutual Fund Portfolio (Full Sub-Screen)
    *   Screen 1.3: Insurance & Protection Vault (Full Sub-Screen)
    *   Screen 1.4: Universal Action Hub & Fast Transaction Logger (Modal Sheet)
*   **Tab 2: Activity Ledger**
    *   Screen 2.0: Activity Ledger & Filter Center (Main Tab Screen)
    *   Screen 2.1: Multi-Receipt Split & Compound Transaction Detail (Full Sub-Screen)
    *   Screen 2.2: Automated SMS / UPI Reconciliation Tray (Half Sheet)
    *   Screen 2.3: Fixed Commitments & Subscriptions Manager (Full Sub-Screen)
*   **Tab 3: Targets & Budgets**
    *   Screen 3.0: Targets & Budget Health Overview (Main Tab Screen)
    *   Screen 3.1: Create New Target / Sinking Fund (Step-by-step Modal)
    *   Screen 3.2: Target Breakdown & Velocity Analysis (Full Sub-Screen)
*   **Tab 4: Deep Dive & Intelligence**
    *   Screen 4.0: Deep Dive Analytics & Burn Radar (Main Tab Screen)
    *   Screen 4.1: Member-wise Financial Autopsy (Sub-Screen)
    *   Screen 4.2: Rule-Based Micro-Action & Optimization Hub (Drawer / Sub-Screen)
---
## 3. SCREEN-BY-SCREEN UI SPECIFICATIONS
### TAB 1: STATUS & WEALTH HUB
#### Screen 1.0: Status Dashboard (Home)
- Top Navigation:
  - Left: "FINIMO" logotype in Space Grotesk Bold with a neon green micro-dot.
  - Right: Family context pill showing stacked mini-avatars (Arpa, Chandrani, Aryahi) with dropdown chevron: "Family (All) ▾".
- Hero Card (Liquidity & Rollover):
  - Dark squircle with subtle Cyan (#00F5FF) radial ambient light.
  - Sub-label: "CONSOLIDATED LIQUID CASH".
  - Large Metric: "₹2,16,949.00" (Space Grotesk 36px).
  - Footer Strip (3 columns): "Inflow: +₹1,82,500" (#CCFF00), "Committed Burn: ₹58,281" (#FF453A), "Safe to Spend: ₹420/day" (#00F5FF).
- Velocity Indicator Widget:
  - 70% completed circular arc gauge in Neon Lime (#CCFF00).
  - Centered text: "70%" / "Daily Cap Under ₹1,500".
- 4-Grid Quick Actions:
  - "+ Expense" (Filled #CCFF00 button with dark text)
  - "Scan QR" (Elevated dark card with neon frame icon)
  - "+ Income" (Elevated dark card with plus glyph)
  - "Transfer / SIP" (Elevated dark card with switch glyph)
- Family Wealth & Protection Launcher (Split 2-Card Row):
  - Left Card (Investments): Accent #BF5AF2 border. Text: "Wealth & SIPs" / "₹21,000/mo Active" / Tap arrow.
  - Right Card (Insurance): Accent #00F5FF border. Text: "Protection Vault" / "3 Policies Active" / Tap arrow.
- Recent Activity Feed:
  - 3 rows with member avatar chips on top of transaction title:
    * Groceries (-₹965) • Tag: Family
    * iPhone EMI (-₹1,691) • Tag: Arpa
    * MF Chandrani (-₹5,000) • Tag: Chandrani
#### Screen 1.1: Family Switcher & Member Configuration (Bottom Sheet)
- Drag handle at top; dark backdrop blur.
- Header: "Switch Financial Profile" with "+ Add Dependent" button.
- Member Carousel Cards:
  - Card 1 (Active): "All Family" (Aggregated cashflow, 3 active members).
  - Card 2: "Arpa (Self)" (Salary earner, 1 active EMI, 1 SIP).
  - Card 3: "Chandrani (Wife)" (1 MF SIP ₹5,000/mo, dedicated spending cap).
  - Card 4: "Aryahi (Child)" (Medical expense tracking, Sukanya / Education SIP ₹5,000/mo).
- Per-member quick summary toggle: View discrete personal liquidity vs shared household pool.
#### Screen 1.2: Family Wealth & Mutual Fund Portfolio (Sub-Screen)
- Top App Bar: Back chevron, "Wealth & Portfolios", right-side "+ New SIP" button.
- Portfolio Summary Hero:
  - Total Invested Value: "₹4,85,000" in Space Grotesk with purple neon badge "+14.2% XIRR".
  - Monthly Outflow: "₹21,000 debited on 10th of every month".
- Segmented Horizontal Tabs: [All Assets] [Mutual Funds] [Recurring Deposits (RD)].
- Asset Cards:
  - Card 1: "Chandrani Growth MF" • Allocation: ₹5,000/mo • Next SIP: 10 Oct • Beneficiary: Chandrani.
  - Card 2: "Aryahi Future Star SIP" • Allocation: ₹5,000/mo • Next SIP: 10 Oct • Beneficiary: Aryahi.
  - Card 3: "Arpa Equity Hybrid" • Allocation: ₹5,000/mo • Next SIP: 10 Oct • Beneficiary: Arpa.
  - Card 4: "UCO Bank Recurring Deposit" • Allocation: ₹1,000/mo • Tenure: 24/36 Months.
- Auto-debit Calendar: Mini strip showing upcoming deduction days with purple glowing dots.
#### Screen 1.3: Insurance & Protection Vault (Sub-Screen)
- Top App Bar: Back chevron, "Protection & Policies", shield icon.
- Vault Overview Card:
  - Cyan illuminated container: "Total Protection Umbrella: ₹1.25 Cr".
  - Annual Commitment: "₹34,500/year" with renewal timeline indicator.
- Policy Categorization Tabs: [All Policies] [Health] [Term Life] [Automobile].
- Policy Cards:
  - Card 1: "HDFC Life Term Insurance" • Insured: Arpa • Sum Assured: ₹1.00 Cr • Status: ACTIVE • Next Due: Nov 2026.
  - Card 2: "Family Health Floater" • Covered: Arpa, Chandrani, Aryahi • Sum Insured: ₹25 Lakhs • Cashless TPA card download button.
  - Card 3: "Auto Insurance + Maintenance" • Covered: Hyundai Creta • Cost: ₹1,000/mo reserved • Expiry: 12 days left (Warning banner: #FF453A).
- Emergency Vault Section: Encrypted PDF locker button to fetch policy numbers & claim forms offline.
#### Screen 1.4: Universal Transaction Logger (Modal Sheet)
- Type Switcher (Segmented pill): [Expense] [Income] [Investment / SIP].
- Number Pad / Keypad Area:
  - Big responsive display: "₹ 0.00" in Space Grotesk with #CCFF00 cursor.
- Attribution & Tagging Row:
  - "Paid By": Horizontal circular avatar picker (Arpa / Chandrani).
  - "Spent For / Beneficiary": Picker (Family / Aryahi / Chandrani / Arpa).
- Category Dropdown: Household, Medical, OTT, Dining, Garments, Pujo Festival.
- Multi-Bill Split Trigger: Toggle "Split into itemized sub-receipts".
- Primary Action: Full-width button "Record Outflow" (#CCFF00 background, black text).
---
### TAB 2: ACTIVITY & BILLING SYSTEM
#### Screen 2.0: Activity Ledger (Main Tab)
- Search & Date Header: Search input with magnifying glass + Calendar chip "[Oct 2026 ▾]".
- Filter Pill Carousel: [All Transactions] [Expenses] [Investments / SIP] [Income] [EMIs & Subs].
- Pending SMS Notification Banner:
  - Deep purple (#1F162B) rounded banner: "⚡ 3 SMS transactions detected from HDFC/UCO Bank" → Action: "Review & Reconcile".
- Grouped Date Sections ("Today", "Yesterday", "04 Oct 2026"):
  - Transaction Row Component:
    * Left: Rounded category icon with color-coded background.
    * Middle: Title (e.g., "Neon Noodle Bar"), subtitle ("Dining • 12:48 PM • Paid by Arpa"), member pill ("Aryahi").
    * Right: Amount with color distinction (-₹840.00 in red, +₹45,000 in green, -₹5,000 in purple for MF).
#### Screen 2.1: Multi-Receipt Split / Event Breakdown (Sub-Screen)
- Context: Designed for composite festival or trip expenses (e.g., Excel's "Pujo Expenses = 2916+2498-50+1009+2299").
- Header: Back chevron, "Pujo Expenses 2026", total pill "₹8,672.00".
- Event Metadata Card:
  - "Occasion / Sinking Fund": Durga Puja 2026.
  - "Allocated Budget": ₹10,000.00 (Progress bar showing 86.7% consumed).
- Sub-Itemized Receipt List:
  - Row 1: "Garments & Accessories (FabIndia)" • ₹4,025.00 • Member: Chandrani.
  - Row 2: "Bhog & Puja Offerings" • ₹2,299.00 • Member: Family.
  - Row 3: "Restaurant Dinners" • ₹1,608.00 • Member: All.
  - Row 4: "Store Adjustment Discount" • -₹50.00 (Green credit).
- Action Bar: "+ Add Receipt to this Event" and "Export Event Summary".
#### Screen 2.2: Automated SMS / UPI Reconciliation Tray (Bottom Sheet)
- Header: "Detected Outflows (3)" with quick "Approve All" link.
- Card Stack:
  - Item 1: "₹899 debited via UPI to Fancode" • Auto-detected: Entertainment (yearly) • Confirm / Edit button.
  - Item 2: "₹2,000 debited to APDCL (Electricity)" • Auto-detected: Utilities • Member pre-assigned: Arpa.
  - Item 3: "₹500 at Apollo Pharmacy" • Auto-detected: Medical • Suggested tag: Aryahi.
- One-tap swipe to approve into ledger.
#### Screen 2.3: Fixed Commitments & Subscriptions Manager (Sub-Screen)
- Header: "Committed Outflows", subtext: "₹24,588 locked every month before discretionary spend".
- Section A: Active Loan & Hardware EMIs:
  - Card: "iPhone 15 Pro EMI" • Monthly: ₹1,691.00 • Tenure bar: Month 13 of 24 • Due: 05th of month.
- Section B: Entertainment & Subscriptions:
  - Card 1: "OTT Monthly Bundle (Netflix + Prime)" • ₹998.00/mo.
  - Card 2: "Fancode Yearly Pass" • ₹899.00/yr (Next renewal: Oct 2027).
- Section C: Essential Household Utilities:
  - Household & Rent pool: ₹20,000.00 reserved.
  - Gas & Electric estimates: ₹3,000.00.
---
### TAB 3: TARGETS & BUDGET HEALTH
#### Screen 3.0: Targets Dashboard (Main Tab)
- Hero Widget: "Budget Health Matrix":
  - Concentric dual rings: Outer ring #CCFF00 (74% optimized overall), Inner ring #BF5AF2 (Savings velocity).
  - Health Card Copy: "Safe trajectory. Based on current trends, your ₹2.16L liquidity will cushion all October commitments."
- Active Limits Accordion:
  - "Household & Living Cap": ₹20,000 / ₹20,000 allocated (Bar in #CCFF00).
  - "Weekly Dining & Discretionary": ₹350.00 spent of ₹1,200.00 safe cap.
- Sinking Funds Section (Long-Term & Festival Goals):
  - Goal Card 1: "Pujo Festival 2026" • ₹8,672 spent of ₹10,000 cap • 87% progress bar • Status: "Watch Burn".
  - Goal Card 2: "Japan Trip 2027" • ₹3,750 saved of ₹5,000 monthly goal • Ring gauge 75%.
- Rule-Based Micro-Goal Suggestions:
  - Suggestion 1: "☕ Skip 3 takeout coffees this week → Save ₹750 for Pujo festival overrun."
  - Suggestion 2: "✂️ 3 OTT platforms active this month → Pause unused plan to save ₹799."
- Floating CTA: "+ New Target / Goal" (Pill with #CCFF00 glow).
#### Screen 3.1: Create New Target / Sinking Fund Modal (Step Wizard)
- Step 1: "What are you budgeting for?"
  - Preset icons: [Household Core] [Festival / Sinking Fund] [Vacation] [Child Milestone] [Emergency Buffer].
- Step 2: "Set Allocation & Frequency":
  - Input amount: "₹ ____" • Frequency toggles: [One-Time Pool] [Monthly Recurring] [Weekly Cap].
- Step 3: "Assign Members & Accountability":
  - Checkboxes for Arpa, Chandrani, or Shared Family.
- Step 4: Overspending Safety Mechanism:
  - Slider: "Send push warning when reaching 80% / 90% / 100% of threshold".
#### Screen 3.2: Target Breakdown & Velocity Analysis (Sub-Screen)
- Detailed analytical view of a single target (e.g., "Household Core Expenses").
- Month-over-Month Velocity Curve: Line chart showing September vs October burn rates.
- Burn Attribution: Bar chart breaking down how much was eaten up by Rent (₹20k), Groceries (₹965), Electricity (₹2k), Gas (₹1k).
- Health Advisory: "Household expenses are 12% lower than September due to zero recorded utility spikes."
---
### TAB 4: DEEP DIVE & INTELLIGENCE
#### Screen 4.0: Deep Dive Analytics (Main Tab)
- Top Switcher: Segmented control: [Category View] vs [Family Member View].
- Category View State:
  - Central Donut Chart: Total Outflow "₹58,281.00" in center.
  - Multi-colored segments:
    * Household: 34.3% (#CCFF00)
    * Investments & SIPs: 27.5% (#BF5AF2)
    * Festivals & Garments: 14.9% (#00F5FF)
    * Insurance & EMIs: 4.6% (#FF453A)
    * Dining & Misc: 18.7% (#8E8E93)
- Family Member View State:
  - Comparative stacked horizontal bars:
    * Arpa (Salary / EMIs / Personal): 45%
    * Chandrani (MF / Personal / Garments): 35%
    * Aryahi (Child Fund / Medical): 20%
- Weekly Burn Velocity: Vertical bar chart comparing week 1 to week 4 with monthly benchmark dotted line.
- Rule-Based Insight Feed:
  - Card 1 (Warning): "Late Night Taxi & Food: 68% of delivery spending occurred after 10 PM."
  - Card 2 (Celebration): "Savings Legend: 27.5% of total income diverted directly into Wealth & SIPs."
  - Card 3 (Action): "Insurance Audit: Term policy has no claim nominee updated. Verify documents."
#### Screen 4.1: Member-wise Financial Autopsy (Sub-Screen)
- Member Profile Header: Avatar (e.g., "Aryahi - Dependent Child").
- Lifetime & YTD Inflow vs Outflow:
  - Total allocated this month: "₹10,500" (SIP ₹5k + Medical ₹500 + Festival gifts ₹5k).
- Dedicated Ledger Filter: All transactions exclusively impacting Aryahi.
- Investment Maturity Projection: Compound growth preview of her ₹5,000/month SIP across 10 years at 12% expected return.
#### Screen 4.2: Rule-Based Micro-Action & Optimization Hub (Sub-Screen)
- Actionable screen allowing users to execute savings recommendations:
  - Action Card 1: "Cancel / Pause OTT Subscriptions" → Toggle triggers direct portal shortcut.
  - Action Card 2: "Reallocate Surplus Cash" → One-tap prompt: "₹74,549 rollover balance detected from September. Move ₹20,000 to High-Yield Liquid Fund?"
  - Button: "Execute Rebalancing" (#CCFF00 outline).