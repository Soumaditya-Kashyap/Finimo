Step 1 — Auth & Session: [DONE] Real Login/Register call karenge, server se mila JWT token secure locker me save karenge aur active user fetch karenge.
Step 2 — Home Dashboard & Family Orbit: [DONE] Live GET /api/v1/insights/summary aur GET /api/v1/family/members se liquidity card aur members populate karenge.
Step 3 — Add Expense Logger & Categories: [DONE] Logger sheet me real categories load karenge aur expense/income post karenge.
Step 4 — Activity Ledger: [DONE] Real transaction history load aur delete karenge with cursor pagination, dynamic month & member filters, search & zero mock fallback.
Step 5 — Targets & Events: [DONE] Real budget limits aur Durga Puja sinking fund connect karenge.
Step 6 — Protection Vault & Deep Dive: Insurance policies aur category breakdown chart bind karenge.



REMAING FOR AUTH:
"Log Out from All Devices" (POST /api/v1/auth/logout-all):

Agar user chahe ki sabhi phones/tablets se ek sath session terminate ho jaye.
Ise hum Profile 
→
→ Password & Security me ek red button "Log Out All Active Sessions" dekar jodh sakte hain.

Join Family via Invite Token (POST /api/v1/invitations/preview & /api/v1/invitations/accept):

Jab koi family owner kisi ko invite bhejta hai, toh doosra user apni nayi family banane ke bajaye usi existing family me join hota hai.
Auth screen par "Have an invite code? Join Family" ka option dekar invite token enter karne par preview aur join flow add kiya ja sakta hai.

Biometric Toggle Preference Persistence:

Profile page par jo FaceID/TouchID switch hai, uski state ko secure storage me save rakhna taaki app restart hone par bhi preference yaad rahe.