# 5. Requirement Appendix

## 5.1 Business Rules
Below are the core business rules applicable to the AI-powered Perfume Consultation and Sales System (PerfumeGPT).

| ID | Rule Definition |
| :--- | :--- |
| **BR-01** | Customers must complete the AI Scent Quiz or define their scent preferences before receiving initial personalized AI recommendations. |
| **BR-02** | To successfully place an order, a user must have at least one available product in their shopping cart and provide a valid delivery address. |
| **BR-03** | Cash-on-Delivery (COD) orders are only permissible for order totals less than 5,000,000 VND. Orders exceeding this limit require online payment via VNPay or Momo. |
| **BR-04** | Promotion codes can only be applied once per order and cannot be combined with products currently running on a Flash Sale campaign unless explicitly configured by the Admin. |
| **BR-05** | Customers accrue loyalty points at a rate of 1 Point for every 10,000 VND spent upon successful order delivery. Points can be redeemed for future order discounts. |
| **BR-06** | Order cancellations by the Customer are only permitted when the order status is "Pending" or "Processing" (i.e., before the order is handed to the shipping provider). |
| **BR-07** | Return and refund requests must be initiated within 7 days from the "Delivered" date. Photographic evidence of the product condition is mandatory when requesting a return for damaged goods. |
| **BR-08** | Order shipping fees are calculated dynamically using the GHN API, based on the package's dimensional weight and the distance to the destination address. |
| **BR-09** | A "Low Stock" alert is automatically triggered to Staff and Admin workflows when the physical inventory level of any perfume variant falls below 10 units. |
| **BR-10** | Only Admin-level accounts carry the authority to reassign Staff roles, permanently adjust base product prices, and configure core AI recommendation prompts. |

---

## 5.2 Common Requirements
The following requirements apply globally to govern standard interactions within the system.

| ID | Requirement Description |
| :--- | :--- |
| **CR-01** | **Multi-language Support:** All customer interfaces (Web/Mobile) must support language switching between English (EN) and Vietnamese (VI), with Vietnamese set as the default language. |
| **CR-02** | **Responsive Web Design:** The application's UI must adapt dynamically to provide an optimized experience across Desktop, Tablet, and Mobile devices (Mobile-First approach). |
| **CR-03** | **Data Pagination:** Any list or grid displaying data sets (e.g., Products, Orders, Reviews, Journals) exceeding 20 records must implement Server-side Pagination or "Load More" functionality to minimize payload size. |
| **CR-04** | **Timezone Handling:** All temporal data must be safely stored in the database in standard UTC format and correctly translated to the user's local timezone (GMT+7 for Vietnam) strictly on the client side. |
| **CR-05** | **Security Validation:** All API endpoints performing mutations (POST, PUT, PATCH, DELETE) must strictly validate the presence of a JWT Bearer token and enforce Role-Based Access Control to prevent privilege escalation. |

---

## 5.3 Application Messages List
Common interactive messages and alerts provided to users navigating the user interface.

| # | Message code | Message Type | Context | Content |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **MSG01** | In line | Search query returns no matching results | No perfumes found matching your criteria. |
| 2 | **MSG02** | In red, under text box | Submitting form with empty required fields | This field is required. |
| 3 | **MSG03** | Toast message | Customer adds product to cart | Added {product_name} to cart. |
| 4 | **MSG04** | Toast message | Customer completes AI quiz / saves profile | Your personal scent profile has been saved. |
| 5 | **MSG05** | Toast message | Customer successfully checks out an order | Order #{order_id} placed successfully. An email confirmation has been sent. |
| 6 | **MSG06** | Toast (Error) | Applying an invalid or expired promo code | Invalid or expired promotion code. |
| 7 | **MSG07** | In red, under text box | Passwords do not match in registration form | The passwords entered do not match. |
| 8 | **MSG08** | In line | Authentication failed during login attempt | Incorrect email or password. Please try again. |
| 9 | **MSG09** | Toast message | Staff updates order or stock status | Information updated successfully. |
| 10 | **MSG10** | In red, button disabled| Viewing checkout with an out-of-stock product | This item is currently out of stock. |

---

## 5.4 Other Requirements

**Performance Requirements:**
*   **PR-01:** The AI Consultant natural language integration must generate and output perfume recommendations in under 3.5 seconds to maintain conversational fluidity.
*   **PR-02:** The primary eCommerce components (Homepage, Product Catalog) must score above an 80 on Google PageSpeed Insights (Fast First Contentful Paint).

**Audit & Compliance Requirements:**
*   **AL-01:** Any CRUD operational alterations to active Inventory levels or Product pricing must be indelibly logged to the database (Audit Trail) mapping the action to the respective user ID and precise timestamp.
