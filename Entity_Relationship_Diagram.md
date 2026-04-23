### 3.1.5 Entity Relationship Diagram

[This section provides the conceptual semantic entity-relationship mapping mimicking the standard Chen ERD notation (Entities as Rectangles, Relationships as Diamonds) mapped to the core schemas of Perfume-Sales, alongside their entity definitions.]

```mermaid
graph TD
    %% Styling
    classDef entity fill:#4a90e2,stroke:#333,stroke-width:1px,color:#fff;
    classDef relation fill:#5bc0de,stroke:#333,stroke-width:1px,shape:diamond,color:#fff;

    %% Entities
    U[User]:::entity
    O[Order]:::entity
    C[Cart]:::entity
    P[Product]:::entity
    Cat[Category]:::entity
    B[Brand]:::entity
    S[Store]:::entity
    Rev[Review]:::entity
    RReq[ReturnRequest]:::entity
    Promo[PromotionCode]:::entity

    %% Relationships (Diamonds)
    places{places}:::relation
    owns_cart{owns}:::relation
    writes{writes}:::relation
    managed_by{managed by}:::relation
    order_items{contains}:::relation
    cart_items{holds}:::relation
    groups{groups}:::relation
    produces{produces}:::relation
    stocks{stocks}:::relation
    generates{generates}:::relation
    discounted_by{discounted by}:::relation

    %% Connections User
    U ---|1| places ---|M| O
    U ---|1| owns_cart ---|1| C
    U ---|1| writes ---|M| Rev
    S ---|M| managed_by ---|M| U

    %% Connections Order
    O ---|1| order_items ---|M| P
    O ---|1| generates ---|0..1| RReq
    O ---|M| discounted_by ---|0..1| Promo

    %% Connections Cart
    C ---|1| cart_items ---|M| P

    %% Connections Catalog & Review
    Cat ---|1| groups ---|M| P
    B ---|1| produces ---|M| P
    S ---|1| stocks ---|M| P
    P ---|1| writes ---|M| Rev
```

#### Entities Description

| # | Entity | Description |
| :--- | :--- | :--- |
| 1 | **User** | The core actor of the system encompassing all roles (Customer, Staff, Admin). Stores identity, loyalty points, and references to their physical address books. |
| 2 | **Order** | The immutable transaction ledger representing a complete Checkout (either Online via gateway or In-store POS), locked prices, and shipping logistics. |
| 3 | **Product** | The central catalog entity representing a unique perfume, holding attributes like fragrance notes, longevity, and mapping to distinct physical variant sizes. |
| 4 | **Cart** | The volatile, temporary basket assigned 1-to-1 to a shopping Customer to hold anticipated items before finalizing the checkout process. |
| 5 | **Store** | Geographical boutique point-of-sale locations where physical Inventory (stock) is localized and managed individually by assigned Staff. |
| 6 | **Category** | High-level taxonomies categorizing products into application sets (e.g., EDP, EDT, Parfum). |
| 7 | **Brand** | The manufacturer organizations producing the perfumes (e.g., Chanel, Dior, Zara). |
| 8 | **Review** | User-generated feedback (1-5 Star Ratings and textual insights) logically tied to authorized purchased Products to prevent falsification. |
| 9 | **ReturnRequest** | Reverse-logistics entity generated post-delivery when a Customer claims damages or requests refunds, requiring Admin workflow approval. |
| 10 | **PromotionCode** | Marketing mechanism providing financial discounts mapping percentage or fixed-amount deductibles enforced with usage bounds. |

*(Note: While the physical database contains 50 granular tables to handle conjunctions like `CartItem` or `OrderHistory`, this Diagram isolates the major Conceptual Entities mapping the raw business interactions logic of the Perfume-Sales platform).*
