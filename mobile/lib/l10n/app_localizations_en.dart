// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lumina';

  @override
  String get atelierDeParfum => 'ATELIER DE PARFUM';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get emailAddress => 'EMAIL ADDRESS';

  @override
  String get password => 'PASSWORD';

  @override
  String get forgotPassword => 'FORGOT PASSWORD?';

  @override
  String get login => 'LOGIN';

  @override
  String get dontHaveAccount => 'DON\'T HAVE AN ACCOUNT? ';

  @override
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get cancelUpper => 'CANCEL';

  @override
  String get paymentMethodTitle => 'Payment Method';

  @override
  String get noPaymentMethods => 'No payment methods available.';

  @override
  String get paymentMethodSubtitle =>
      'Select your default payment method for future orders';

  @override
  String get recommended => 'Recommended';

  @override
  String get standby => 'Standby';

  @override
  String get payosNoteLong =>
      'PayOS allows instant QR scanning or bank transfer. COD is suitable if you prefer to check the goods before paying.';

  @override
  String get returnReasonExample =>
      'Example: The product leaked during delivery...';

  @override
  String get userCancelled => 'User cancelled';

  @override
  String get orderConfirmError => 'Could not confirm order';

  @override
  String get missingPaymentLink =>
      'Order created but no payment link found. Please retry.';

  @override
  String get unableOpenPayment =>
      'Unable to open payment page. Tap button to retry.';

  @override
  String get paymentInstructions =>
      'Complete payment in your browser, then return and tap check.';

  @override
  String get april => 'April';

  @override
  String get staffHome => 'Home';

  @override
  String get inventory => 'Inventory';

  @override
  String get pos => 'POS';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get totalOrdersLabel => 'Total Orders';

  @override
  String get paidLabel => 'Paid';

  @override
  String get avgPerOrder => 'Avg/Order';

  @override
  String get pendingProcess => 'Pending Process';

  @override
  String get paymentRate => 'Payment Rate';

  @override
  String get topBestSellers => 'Top Best Sellers';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get unableLoadData => 'Unable to load data';

  @override
  String totalOrdersCount(Object count) {
    return '$count orders';
  }

  @override
  String get searchOrdersHint => 'Search order code, phone, name...';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPendingPayment => 'Pending Payment';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusPending => 'Pending';

  @override
  String get confirmReturnTitle => 'Confirm Return';

  @override
  String confirmReturnDesc(Object code) {
    return 'Create return & refund request for order $code?';
  }

  @override
  String get returnRefundLabel => 'Return / Refund';

  @override
  String get returnSuccess => 'Return & refund request created successfully';

  @override
  String get returnError => 'Failed to process return';

  @override
  String get reasonCustomerReturnCounter => 'Customer returned at counter';

  @override
  String get ordersHistoryLabel => 'Orders';

  @override
  String get profileLabel => 'Profile';

  @override
  String itemCount(int count) {
    return '$count items';
  }

  @override
  String get repay => 'Repay';

  @override
  String get edit => 'Edit';

  @override
  String get guest => 'Guest';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get success => 'Success';

  @override
  String get no => 'No';

  @override
  String get confirmCancelOrderTitle => 'Confirm Cancel Order';

  @override
  String confirmCancelOrderDesc(Object code) {
    return 'Are you sure you want to cancel order $code? This action cannot be undone.';
  }

  @override
  String cancelOrderSuccess(Object code) {
    return 'Order $code cancelled';
  }

  @override
  String get cancelOrderError => 'Failed to cancel order';

  @override
  String get or => 'OR';

  @override
  String get google => 'GOOGLE';

  @override
  String get facebook => 'FACEBOOK';

  @override
  String get joinTheAtelier => 'Join the Atelier';

  @override
  String get fullName => 'FULL NAME';

  @override
  String get phoneOptional => 'PHONE NUMBER (OPTIONAL)';

  @override
  String get agreeToTerms => 'I AGREE TO THE TERMS AND PRIVACY POLICY';

  @override
  String get registrationSuccessful =>
      'REGISTRATION SUCCESSFUL. PLEASE VERIFY YOUR EMAIL.';

  @override
  String get pleaseFillFields => 'PLEASE FILL ALL FIELDS';

  @override
  String get pleaseAcceptTerms => 'PLEASE ACCEPT TERMS';

  @override
  String get accessDenied => 'ACCESS DENIED';

  @override
  String get pleaseProvideCredentials => 'PLEASE PROVIDE CREDENTIALS';

  @override
  String get dnaScent => 'DISCOVER YOUR SCENT DNA';

  @override
  String get onboarding1Title => 'THE ART OF SCENT';

  @override
  String get onboarding1Subtitle =>
      'Discover your unique olfactory identity through an AI-curated collection.';

  @override
  String get onboarding2Title => 'INTELLIGENT SELECTION';

  @override
  String get onboarding2Subtitle =>
      'AI analyzes thousands of notes to find your perfect resonance.';

  @override
  String get onboarding3Title => 'TIMELESS LUXURY';

  @override
  String get onboarding3Subtitle =>
      'Experience the future of fragrance, crafted with traditional excellence.';

  @override
  String get next => 'NEXT';

  @override
  String get beginJourney => 'BEGIN JOURNEY';

  @override
  String get neuralArchitect => 'NEURAL ARCHITECT';

  @override
  String get describeVision => 'DESCRIBE YOUR VISION...';

  @override
  String get welcomeMessage =>
      'Welcome to the Atelier. I am your Neural Architect. Tell me, what emotional landscape shall we explore through scent today?';

  @override
  String get yourProfile => 'YOUR PROFILE';

  @override
  String get atelierMember => 'ATELIER MEMBER';

  @override
  String get theAtelier => 'THE ATELIER';

  @override
  String get acquisitionHistory => 'ACQUISITION HISTORY';

  @override
  String get curatedCollection => 'CURATED COLLECTION';

  @override
  String get neuralDnaArchive => 'NEURAL DNA ARCHIVE';

  @override
  String get system => 'SYSTEM';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get language => 'LANGUAGE';

  @override
  String get concierge => 'CONCIERGE';

  @override
  String get disconnectSession => 'DISCONNECT';

  @override
  String get luminaAtelier => 'LUMINA ATELIER';

  @override
  String get intensity => 'INTENSITY';

  @override
  String get neuralInsight => 'NEURAL INSIGHT';

  @override
  String get scentProfile => 'SCENT PROFILE';

  @override
  String get theStory => 'THE STORY';

  @override
  String get acquireScent => 'ACQUIRE SCENT';

  @override
  String get topNotes => 'TOP NOTES';

  @override
  String get heartNotes => 'HEART NOTES';

  @override
  String get baseNotes => 'BASE NOTES';

  @override
  String get orderAtelier => 'CONFIRM ORDER';

  @override
  String get yourSelection => 'YOUR SELECTION';

  @override
  String get shippingAtelier => 'SHIPPING';

  @override
  String get change => 'CHANGE';

  @override
  String get paymentMethod => 'PAYMENT METHOD';

  @override
  String get priorityShipping => 'PRIORITY SHIPPING';

  @override
  String get complimentary => 'COMPLIMENTARY';

  @override
  String get totalAcquisition => 'TOTAL ACQUISITION';

  @override
  String get confirmOrder => 'CONFIRM ORDER';

  @override
  String get acquisitionComplete => 'ACQUISITION COMPLETE';

  @override
  String get orderCodified =>
      'Your molecular signature has been codified. Your scent is being prepared.';

  @override
  String get traceOrder => 'TRACE';

  @override
  String get returnToAtelier => 'RETURN TO ATELIER';

  @override
  String get shoppingCart => 'SHOPPING CART';

  @override
  String get yourCartEmpty => 'YOUR CART IS EMPTY';

  @override
  String get discoverCollection => 'Discover the curated collection';

  @override
  String get exploreCollection => 'EXPLORE COLLECTION';

  @override
  String get promoCode => 'PROMO CODE';

  @override
  String get apply => 'APPLY';

  @override
  String get proceedCheckout => 'PROCEED TO CHECKOUT';

  @override
  String get discountApplied => 'discount applied';

  @override
  String get invalidPromoCode => 'Invalid promo code';

  @override
  String get orderHistory => 'ORDER HISTORY';

  @override
  String get orderHistoryAppear => 'Your order history will appear here';

  @override
  String get startShopping => 'START SHOPPING';

  @override
  String get orderDetails => 'ORDER DETAILS';

  @override
  String get orderNumber => 'ORDER NUMBER';

  @override
  String get orderDate => 'ORDER DATE';

  @override
  String get orderTimeline => 'ORDER TIMELINE';

  @override
  String get trackingInformation => 'TRACKING INFORMATION';

  @override
  String get trackingNumber => 'Tracking Number';

  @override
  String get trackShipment => 'TRACK SHIPMENT';

  @override
  String get items => 'ITEMS';

  @override
  String get shippingAddress => 'SHIPPING ADDRESS';

  @override
  String get shippingFee => 'Shipping Fee';

  @override
  String get free => 'FREE';

  @override
  String get reorder => 'REORDER';

  @override
  String get cancelOrder => 'CANCEL ORDER';

  @override
  String get cancelOrderConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get yesCancelOrder => 'YES, CANCEL ORDER';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get orderPlacedSuccess => 'Order placed successfully';

  @override
  String get failedToReorder => 'Failed to reorder';

  @override
  String get failedToCancel => 'Failed to cancel';

  @override
  String get failedLoadOrders => 'Failed to load orders';

  @override
  String get failedLoadOrder => 'Failed to load order details';

  @override
  String get retry => 'RETRY';

  @override
  String get moreItems => 'more items';

  @override
  String get qty => 'QTY';

  @override
  String get orderNumberCopied => 'Order number copied';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusOutForDelivery => 'Out For Delivery';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusRefunded => 'Refunded';

  @override
  String get orderDescPending => 'Your order is pending confirmation';

  @override
  String get orderDescConfirmed => 'Your order has been confirmed';

  @override
  String get orderDescProcessing => 'We are preparing your scent';

  @override
  String get orderDescShipped => 'Your scent is on the way';

  @override
  String get orderDescOutForDelivery => 'Your order is out for delivery';

  @override
  String get orderDescDelivered => 'Delivered successfully';

  @override
  String get orderDescCancelled => 'This order was cancelled';

  @override
  String get orderDescRefunded => 'Order has been refunded';

  @override
  String get payment => 'PAYMENT';

  @override
  String get selectPaymentMethod => 'SELECT PAYMENT METHOD';

  @override
  String get vnpay => 'VNPay';

  @override
  String get momo => 'Momo';

  @override
  String get cod => 'Cash on Delivery';

  @override
  String get payNow => 'PAY NOW';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get paymentSuccess => 'Payment Success';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get paymentCancelled => 'Payment Cancelled';

  @override
  String get searchFragrance => 'SEARCH FRAGRANCE...';

  @override
  String get personalizedSelection => 'PERSONALIZED SELECTION';

  @override
  String get tailoredRecommendations => 'TAILORED RECOMMENDATIONS';

  @override
  String get viewCollection => 'VIEW COLLECTION';

  @override
  String get eauDeParfum => 'EAU DE PARFUM';

  @override
  String get rating => 'rating';

  @override
  String get noReviews => 'No reviews yet';

  @override
  String get viewReviews => 'View Reviews';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String get variantNotFound => 'Variant not found.';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get viewCart => 'View Cart';

  @override
  String get failedAddToCart => 'Failed to add to cart';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSubtitle =>
      'Track your orders, exclusive offers, and account activity.';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get readAll => 'Read All';

  @override
  String get allNotificationsRead => 'You\'ve read all notifications';

  @override
  String unreadNotifications(int count) {
    return 'You have $count unread notifications';
  }

  @override
  String get updateNotifications => 'Keep up with the latest offers';

  @override
  String get orderUpdates => 'Order Updates';

  @override
  String get orderUpdatesSub => 'Shipments, preparation, and payments';

  @override
  String get offersAndGifts => 'Offers and Gifts';

  @override
  String get offersAndGiftsSub =>
      'Member benefits, limited editions, and promos';

  @override
  String get accountActivity => 'Account Activity';

  @override
  String get accountActivitySub => 'Restock alerts and security notifications';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterOrders => 'Orders';

  @override
  String get filterOffers => 'Offers';

  @override
  String get filterAccount => 'Account';

  @override
  String get latest => 'LATEST';

  @override
  String get older => 'OLDER';

  @override
  String get paymentSummary => 'PAYMENT SUMMARY';

  @override
  String get totalAmount => 'TOTAL AMOUNT';

  @override
  String get shippingAddressUpper => 'SHIPPING ADDRESS';

  @override
  String get contactSupport => 'CONTACT SUPPORT';

  @override
  String get returnRequest => 'Return / Refund Request';

  @override
  String get supportContactMessage => 'Support will contact you shortly.';

  @override
  String get trackOrderUpper => 'TRACK ORDER';

  @override
  String get buyNow => 'BUY NOW';

  @override
  String get freeReturns => 'Free returns within 7 days';

  @override
  String get checkingPayment => 'Checking...';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get placedOn => 'Placed on';

  @override
  String get ordersActive => 'Active';

  @override
  String get ordersCompleted => 'Completed';

  @override
  String get ordersReturns => 'Returns';

  @override
  String get ordersCancelled => 'Cancelled';

  @override
  String get paymentStatusPaid => 'Payment Completed';

  @override
  String get paymentStatusPending => 'Payment Pending';

  @override
  String get paymentStatusFailed => 'Payment Failed';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get paymentMethodPayos => 'PayOS Gateway';

  @override
  String get paymentMethodCod => 'Cash On Delivery (COD)';

  @override
  String get paymentMethodVnpay => 'VNPay Wallet';

  @override
  String get paymentMethodMomo => 'MoMo Wallet';

  @override
  String get returnRequestTitle => 'Return Request';

  @override
  String get selectReturnItems => 'Select items to return';

  @override
  String get returnReason => 'Reason for return';

  @override
  String get returnReasonHint => 'Describe the product condition in detail...';

  @override
  String get refundInfo => 'Refund Destination';

  @override
  String get bankName => 'Bank / E-Wallet';

  @override
  String get bankNameHint => 'Ex: MB Bank, Momo...';

  @override
  String get accountNumber => 'Account / Phone Number';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNameHint => 'NGUYEN VAN A';

  @override
  String get evidenceTitle => 'Evidence';

  @override
  String get photoEvidence => 'Photos (Min 3)';

  @override
  String get videoEvidence => 'Video (3s - 60s)';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get addVideo => 'Add Video';

  @override
  String get submitReturn => 'Submit Return Request';

  @override
  String get errorSelectItems => 'Please select items to return';

  @override
  String get errorReason => 'Please provide a reason';

  @override
  String get errorBankInfo => 'Please provide full refund information';

  @override
  String get errorPhotoCount => 'Please provide at least 3 photos';

  @override
  String get errorVideoMissing => 'Please provide 1 evidence video';

  @override
  String get returnPolicyNote =>
      'Note: Items must be unused with tags attached.';

  @override
  String get reasonDamaged => 'Product Damaged';

  @override
  String get reasonWrongItem => 'Wrong Item Sent';

  @override
  String get reasonScentNotExpected => 'Scent Not As Expected';

  @override
  String get returnProcessNotice => 'Request will be processed within 24-48h';

  @override
  String get returnStatusRequested => 'Requested';

  @override
  String get returnStatusReviewing => 'Reviewing';

  @override
  String get returnStatusApproved => 'Approved';

  @override
  String get returnStatusReturning => 'Returning';

  @override
  String get returnStatusReceived => 'Received';

  @override
  String get returnStatusRefunding => 'Refunding';

  @override
  String get returnStatusCompleted => 'Completed';

  @override
  String get returnStatusRejected => 'Rejected';

  @override
  String get returnStatusCancelled => 'Cancelled';

  @override
  String get returnStep1 => 'Items';

  @override
  String get returnStep2 => 'Details';

  @override
  String get returnStep3 => 'Evidence';

  @override
  String get returnNext => 'Continue';

  @override
  String get returnBack => 'Back';

  @override
  String get returnGuidanceTitle => 'Return Guidance';

  @override
  String get returnGuidanceStep1 => 'Select items you wish to return';

  @override
  String get returnGuidanceStep2 => 'Provide a reason and refund info';

  @override
  String get returnGuidanceStep3 => 'Upload clear photos and video';

  @override
  String get returnEvidenceTip1 => 'Photograph all sides of product';

  @override
  String get returnEvidenceTip2 => 'Record unboxing or showing defects';

  @override
  String get shipmentTitle => 'Shipment Info';

  @override
  String get ghnPickupNotice => 'GHN will pick up from your address';

  @override
  String get ghnPickupDesc => 'Please hand over the package to the courier';

  @override
  String get trackMovement => 'Track Shipment';

  @override
  String get confirmHandover => 'Confirm Handed Over';

  @override
  String get submitShipment => 'Submit Shipment';

  @override
  String get refundNoticeTitle => 'REFUND PROCESSING';

  @override
  String get refundNoticeDesc =>
      'We have received the items. Refund will be issued within 24 business hours.';

  @override
  String get refundSuccessTitle => 'REFUND SUCCESS';

  @override
  String get refundSuccessSub => 'ADMIN HAS TRANSFERRED TO YOUR ACCOUNT';

  @override
  String get refundAmountLabel => 'REFUNDED AMOUNT';

  @override
  String get refundTimeLabel => 'TIME';

  @override
  String get receiptImageHeader => 'TRANSFER RECEIPT';

  @override
  String get resetDna => 'Reset DNA';

  @override
  String get resetDnaConfirm =>
      'Are you sure you want to reset all scent preferences to default?';

  @override
  String get dnaResetSuccess => 'DNA Profile has been reset';

  @override
  String get reset => 'Reset';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'APP';

  @override
  String get support => 'SUPPORT';

  @override
  String get legal => 'LEGAL';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get version => 'Version';

  @override
  String get scentClub => 'Scent Club';

  @override
  String get fragranceLibrary => 'Fragrance Library';

  @override
  String get boutiques => 'Boutiques';

  @override
  String get scentQuiz => 'Scent Quiz';

  @override
  String get exclusiveCollection => 'Exclusive Collection';

  @override
  String get journal => 'Journal';

  @override
  String get ingredientsDictionary => 'Ingredients Dictionary';

  @override
  String get giftService => 'Gift Service';

  @override
  String get brandStory => 'Brand Story';

  @override
  String get supportConcierge => 'Support Concierge';

  @override
  String get logout => 'Logout';

  @override
  String get searchHint => 'Search fragrance...';

  @override
  String get memberPlatinum => 'PLATINUM MEMBER';

  @override
  String get memberGold => 'GOLD MEMBER';

  @override
  String get memberSilver => 'SILVER MEMBER';

  @override
  String get memberStandard => 'MEMBER';

  @override
  String get loyaltyProgram => 'Loyalty Program';

  @override
  String get loading => 'Loading...';

  @override
  String get startPoints => 'Start earning points now';

  @override
  String get scentProfileSoon => 'Detail Scent Profile coming soon';

  @override
  String get loginToViewProfile => 'Please login to view your profile';

  @override
  String get pointsLabel => 'pts';

  @override
  String get tierLabel => 'Tier';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get accountManagement => 'ACCOUNT MANAGEMENT';

  @override
  String get myOrders => 'My Orders';

  @override
  String get shippingAddresses => 'Shipping Addresses';

  @override
  String get paymentAndCards => 'Payment & Cards';

  @override
  String get aiScentPreferences => 'AI Scent Preferences';

  @override
  String get searchExploreHint => 'Search brands, notes, or vibes...';

  @override
  String get topRated => 'TOP RATED';

  @override
  String get navHome => 'HOME';

  @override
  String get navExplore => 'EXPLORE';

  @override
  String get navAlerts => 'ALERTS';

  @override
  String get navProfile => 'PROFILE';

  @override
  String get scentFamily => 'Family';

  @override
  String get usageOccasion => 'Occasion';

  @override
  String get priceRange => 'Price';

  @override
  String get featuredScents => 'Featured Scents';

  @override
  String get searchResults => 'Search Results';

  @override
  String get productsFound => 'products';

  @override
  String get clearFilter => 'Clear';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get searchExploreHintHome => 'Search brands, notes, or vibes...';

  @override
  String get headlineElevate => 'Elevate ';

  @override
  String get headlineSignature => 'signature';

  @override
  String get headlineUniqueScent => '\nyour unique scent';

  @override
  String get aiScentSignature => 'AI SCENT SIGNATURE';

  @override
  String get uniqueScentSignature => 'Unique Scent Signature';

  @override
  String get exploreCta => 'EXPLORE';

  @override
  String get aiSelection => 'AI SELECTION';

  @override
  String get myProfile => 'MY PROFILE';

  @override
  String get cart => 'Cart';

  @override
  String get allProducts => 'ALL PRODUCTS';

  @override
  String get trackOrderCta => 'Track Order';

  @override
  String get viewOffers => 'View Offers';

  @override
  String get viewDetails => 'View Details';

  @override
  String get viewReview => 'Review';

  @override
  String get categoryOrders => 'ORDERS';

  @override
  String get categoryOffers => 'OFFERS';

  @override
  String get categoryAccount => 'TÀI KHOẢN';

  @override
  String get returnCode => 'Return Code';

  @override
  String get returnDetails => 'Return Details';

  @override
  String get review => 'Review';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get listedPrice => 'LISTED PRICE';

  @override
  String get selectSize => 'Select Size';

  @override
  String get aiScentAnalysis => 'AI Scent Analysis';

  @override
  String get scentStructure => 'Scent Structure';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get topNotesDesc => 'Sparkling and light';

  @override
  String get heartNotesDesc => 'Rich and complex';

  @override
  String get baseNotesDesc => 'Deep and long-lasting';

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Read less';

  @override
  String get aiScentAnalysisDesc1 =>
      'We recommend this product based on your love for ';

  @override
  String get aiScentAnalysisDesc2 =>
      ' notes. This perfect blend of notes will provide a sophisticated, elegant experience and long-lasting scent on your skin.';

  @override
  String get perfumeGptInsight => 'PERFUMEGPT INSIGHT';

  @override
  String get noAiSummary => 'No AI summary available for this product.';

  @override
  String get noReviewsYet => 'No reviews for this product yet.';

  @override
  String get allReviews => 'All Reviews';

  @override
  String get withImages => 'With Images';

  @override
  String get havePromoCode => 'Have a promo code?';

  @override
  String get notCalculated => 'Not calculated';

  @override
  String get estSubtotal => 'EST. SUBTOTAL';

  @override
  String get shippingFeeNotice => 'Shipping will be calculated at next step';

  @override
  String get goToCheckout => 'GO TO CHECKOUT';

  @override
  String get architectureOfScent => 'Architecture of Scent';

  @override
  String get architectureOfScentDesc =>
      'A journey through layers of scent, discovering unique notes crafted with precision.';

  @override
  String get heart => 'Heart';

  @override
  String get base => 'Base';

  @override
  String get top => 'Top';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get trialSize => 'TRIAL SIZE';

  @override
  String get informationPending => 'Information pending...';

  @override
  String get verifiedBuyer => 'Verified Buyer';

  @override
  String get failedLoadReviews => 'Failed to load reviews';

  @override
  String verifiedReviewsCount(int count) {
    return '$count verified reviews';
  }

  @override
  String peopleFoundHelpful(int count) {
    return '$count people found helpful';
  }

  @override
  String yearsAgo(int count) {
    return '${count}y ago';
  }

  @override
  String monthsAgo(int count) {
    return '${count}m ago';
  }

  @override
  String weeksAgo(int count) {
    return '${count}w ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get selectAll => 'Select All';

  @override
  String get memberDiscount => 'Member Discount';

  @override
  String get pleaseSelectItems => 'PLEASE SELECT ITEMS';

  @override
  String discountAppliedWithPercent(int percent) {
    return '$percent% discount applied';
  }

  @override
  String get removeCode => 'Remove';

  @override
  String get enterPromoCode => 'Enter promo code';

  @override
  String get availablePromoCodes => 'AVAILABLE PROMO CODES';

  @override
  String get useCode => 'USE';

  @override
  String get clearCartConfirm => 'Clear entire cart?';

  @override
  String get clearCartSubtitle =>
      'This will remove all items you have selected.';

  @override
  String get keepItems => 'Keep items';

  @override
  String get clearAll => 'Clear all';

  @override
  String get emptyCheckoutMessage =>
      'Add items to cart before proceeding to checkout.';

  @override
  String get orderSummary => 'ORDER SUMMARY';

  @override
  String get products => 'Products';

  @override
  String get estDelivery => 'Est. Delivery';

  @override
  String get totalUpper => 'TOTAL';

  @override
  String get paymentMethodUpper => 'PAYMENT METHOD';

  @override
  String get itemsUpper => 'ITEMS';

  @override
  String get defaultUpper => 'DEFAULT';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get checkPaymentOpen => 'Check / Reopen payment';

  @override
  String get securePayment => 'Secure Payment';

  @override
  String get expressShipping => 'Express Shipping';

  @override
  String get dayReturn7 => '7-day Return';

  @override
  String get returnToCart => 'Return to Cart';

  @override
  String get checkoutEmptyTitle => 'Your checkout is empty.';

  @override
  String get successfullyOwned => 'SUCCESSFULLY OWNED';

  @override
  String get authenticScent => 'AUTHENTIC SCENT';

  @override
  String get molecularSignature => 'MOLECULAR SIGNATURE';

  @override
  String get molecularSignatureDesc =>
      'Unique digital identifier for your olfactory profile.';

  @override
  String get fullStory => 'PRODUCT STORY';

  @override
  String get yesterday => 'Yesterday';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get basicInfo => 'BASIC INFO';

  @override
  String get displayName => 'Display Name';

  @override
  String get nameHint => 'Your full name';

  @override
  String get moreDetails => 'MORE DETAILS';

  @override
  String get gender => 'GENDER';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get birthday => 'Birthday';

  @override
  String get birthdayHint => 'Select your birthday';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get pleaseLogin => 'Please login.';

  @override
  String get enterName => 'Please enter name';

  @override
  String get addressBook => 'ADDRESS BOOK';

  @override
  String get defaultAddressUpper => 'DEFAULT ADDRESS';

  @override
  String get otherAddressesUpper => 'OTHER ADDRESSES';

  @override
  String get addNewAddressUpper => 'ADD NEW ADDRESS';

  @override
  String get addressDeleted => 'Address deleted successfully';

  @override
  String get orderDetail => 'Order Detail';

  @override
  String get returnDetail => 'RETURN DETAIL';

  @override
  String get returnedProducts => 'RETURNED PRODUCTS';

  @override
  String get quantity => 'Quantity';

  @override
  String get evidenceImages => 'EVIDENCE IMAGES';

  @override
  String get refundConfirmed => 'REFUND CONFIRMED';

  @override
  String get adminRefundNotice => 'ADMIN HAS ISSUED YOUR REFUND';

  @override
  String get refundedAmount => 'REFUNDED AMOUNT';

  @override
  String get timeUpper => 'TIME';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get addPaymentMethod => 'Add new method';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get category => 'Category';

  @override
  String get recipientName => 'Recipient Name';

  @override
  String get recipientNameHint => 'Enter recipient name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneHint => 'Enter phone number';

  @override
  String get deliveryNote => 'Delivery Note';

  @override
  String get location => 'Location';

  @override
  String get provinceCity => 'Province / City';

  @override
  String get district => 'District';

  @override
  String get ward => 'Ward';

  @override
  String get specificAddress => 'Specific Address';

  @override
  String get specificAddressHint => 'House number, street...';

  @override
  String get otherOptions => 'Other Options';

  @override
  String get ghnService => 'GHN Service';

  @override
  String get noteHint => 'Delivery instructions...';

  @override
  String get setDefaultAddress => 'Set as default address';

  @override
  String get updateAddress => 'Update Address';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get pickProvince => 'Pick Province';

  @override
  String get pickDistrict => 'Pick District';

  @override
  String get pickWard => 'Pick Ward';

  @override
  String get pickService => 'Pick Shipment Service';

  @override
  String get homeLabel => 'Home';

  @override
  String get officeLabel => 'Office';

  @override
  String get giftLabel => 'Gift';

  @override
  String get selectProvince => 'Select Province';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get selectWard => 'Select Ward';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get deleteAddressConfirm =>
      'Are you sure you want to delete this address?';

  @override
  String get noAddressesFound => 'No addresses found';

  @override
  String get addAddressHint => 'Add an address to start shopping';

  @override
  String get delete => 'Delete';

  @override
  String get returnIdLabel => 'Return ID';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get cancelRequestConfirm =>
      'Are you sure you want to cancel this request?';

  @override
  String get cancelSuccess => 'Cancelled successfully';

  @override
  String get cancelError => 'Error cancelling';

  @override
  String get confirmHandoverSuccess => 'Handover to courier confirmed';

  @override
  String get confirmHandoverError => 'Error confirming handover';

  @override
  String get refundBankLabel => 'Bank';

  @override
  String get refundAccountNameLabel => 'Account Name';

  @override
  String get refundAccountNumberLabel => 'Account Number';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get noReason => 'No reason';

  @override
  String get statusSuccess => 'SUCCESS';

  @override
  String get supportPickup => 'Pickup Supported';

  @override
  String get supportShowroomReturn =>
      'Please return to Showroom and update tracking.';

  @override
  String get aiScentDna => 'AI Scent DNA';

  @override
  String get suggestionMode => 'Suggestion Mode';

  @override
  String get exploreNewScents => 'Explore new olfactory layers';

  @override
  String get preferredNotesLabel => 'Preferred Notes';

  @override
  String get yourUniqueDna => 'Your unique DNA';

  @override
  String get avoidedNotesLabel => 'Avoided Notes';

  @override
  String get ingredientsToAvoid => 'Ingredients you\'d like to avoid';

  @override
  String get saveDnaConfig => 'SAVE DNA CONFIG';

  @override
  String get molecularAnalysis => 'MOLECULAR ANALYSIS';

  @override
  String get classic => 'Classic';

  @override
  String get daring => 'Daring';

  @override
  String get aiSafeSuggestion => 'AI suggests exactly what you love.';

  @override
  String get aiBalancedSuggestion =>
      'AI prioritizes your taste with some new notes.';

  @override
  String get aiDaringSuggestion =>
      'AI challenges your senses with breakout creations.';

  @override
  String get understandingYourDna => 'UNDERSTANDING\nYOUR DNA';

  @override
  String get dnaDescription =>
      'AI Scent DNA is the key to personalizing your sense of smell, connecting instinctive preferences with the art of fragrance.';

  @override
  String get molecularRadar => 'Molecular Radar';

  @override
  String get molecularRadarDesc =>
      '5-dimensional analysis, visualizing every scent molecule that defines your identity.';

  @override
  String get suggestionFocus => 'Suggestion Focus';

  @override
  String get suggestionFocusDesc =>
      'Automatically filters unwanted ingredients and focuses on preferred DNA.';

  @override
  String get discoveryCurve => 'Discovery Curve';

  @override
  String get discoveryCurveDesc =>
      'Control AI\'s breakout level, from safe steps to breakthrough experiences.';

  @override
  String get continueExploring => 'CONTINUE EXPLORING';

  @override
  String get exploreNotes => 'EXPLORE NOTES';

  @override
  String get searchNotesHint => 'Search notes...';

  @override
  String get currentTrends => 'CURRENT TRENDS';

  @override
  String get addNewNote => 'Add new note';

  @override
  String get woody => 'Woody';

  @override
  String get floral => 'Floral';

  @override
  String get citrus => 'Citrus';

  @override
  String get spicy => 'Spicy';

  @override
  String get musky => 'Musky';

  @override
  String get discoverYourScentSignature => 'Discover Your\nScent Signature';

  @override
  String get quizIntroDescription =>
      'Answer 5 quick questions and our AI will find the ideal scent for your personality.';

  @override
  String get startNow => 'START NOW';

  @override
  String get estimatedTime => 'Est: 2 mins';

  @override
  String stepProgress(Object current, Object total) {
    return 'STEP $current / $total';
  }

  @override
  String get auraAnalysis => 'AURA ANALYSIS...';

  @override
  String get personalizingScentExperience =>
      'Personalizing your olfactory experience';

  @override
  String get processingOlfactoryData => 'Processing olfactory data...';

  @override
  String get matchingResonantNotes => 'Matching resonant notes...';

  @override
  String get identifyingPersonalSignature =>
      'Identifying personal signature...';

  @override
  String get completingAuraAlgorithm => 'Completing Aura algorithm...';

  @override
  String get yourScentSignature => 'Your Scent Signature';

  @override
  String get resultsDescription =>
      'Based on your preferences, the Aura algorithm has selected the most suitable scents.';

  @override
  String get noRecommendations => 'No matching recommendations found.';

  @override
  String get retakeQuiz => 'RETAKE';

  @override
  String get exploreStore => 'EXPLORE STORE';

  @override
  String get scentDetails => 'SCENT DETAILS';

  @override
  String get q1Text => 'Who is this signature for?';

  @override
  String get q1Opt1 => 'Masculine';

  @override
  String get q1Opt2 => 'Feminine';

  @override
  String get q1Opt3 => 'Genderless';

  @override
  String get q2Text => 'When will you use this scent?';

  @override
  String get q2Opt1 => 'Daily / Casual';

  @override
  String get q2Opt2 => 'Office';

  @override
  String get q2Opt3 => 'Date Night';

  @override
  String get q2Opt4 => 'Party';

  @override
  String get q2Opt5 => 'Special Events';

  @override
  String get q3Text => 'What is your budget range?';

  @override
  String get q4Text => 'What scent style do you prefer?';

  @override
  String get q4Opt1 => 'Fresh';

  @override
  String get q4Opt2 => 'Floral';

  @override
  String get q4Opt3 => 'Woody';

  @override
  String get q4Opt4 => 'Oriental / Warm';

  @override
  String get q4Opt5 => 'Herbal';

  @override
  String get q5Text => 'Expected longevity & sillage?';

  @override
  String get q5Opt1 => '2-4h (Light)';

  @override
  String get q5Opt2 => '4-6h (Moderate)';

  @override
  String get q5Opt3 => '6-8h (Long)';

  @override
  String get q5Opt4 => '8h+ (Extreme)';

  @override
  String get setupPreferredPayment => 'Setup Preferred Payment';

  @override
  String get paymentMethodsDesc =>
      'Select your default payment way. We focus on two smoothest options: COD and PayOS online.';

  @override
  String paymentOptionsCount(Object count) {
    return '$count payment options';
  }

  @override
  String currentPriority(Object method) {
    return 'Current priority: $method.';
  }

  @override
  String get defaultLabel => 'Default';

  @override
  String get activateMethod => 'Activate Method';

  @override
  String get setDefault => 'Set Default';

  @override
  String get confirmSettings => 'Confirm Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get payosTitle => 'Online via PayOS';

  @override
  String get payosSubtitle =>
      'Open secure gateway for QR scan or fast transfer';

  @override
  String get payosDetails => 'Receive digital receipt instantly after payment.';

  @override
  String get codTitle => 'Cash On Delivery (COD)';

  @override
  String get codSubtitle => 'Inspect package then pay directly to courier';

  @override
  String get codDetails =>
      'Suitable if you want to hold payment until items arrive.';

  @override
  String get active => 'Active';

  @override
  String get noDefaultSet => 'No default set';

  @override
  String get setDefaultDesc => 'Pick a method for faster checkout.';

  @override
  String get editPaymentMethod => 'Edit Payment Method';

  @override
  String get editPayos => 'Edit PayOS online';

  @override
  String get editCod => 'Edit COD';

  @override
  String get paymentEditDesc =>
      'Customize description, status visibility and priority in profile.';

  @override
  String get shortDescription => 'Short Description';

  @override
  String get statusLabel => 'Status Label';

  @override
  String get detailedInfo => 'Detailed Info';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get isActive => 'Is Active';

  @override
  String get fillAllFields => 'Please fill all config fields';

  @override
  String get payosNote =>
      'PayOS is great for fast gateway, QR scanning or instant confirmation. COD should stay on as a fallback when needed.';

  @override
  String get loyaltyProgramTitle => 'Loyalty Program';

  @override
  String get memberLabel => 'MEMBER';

  @override
  String get accumulatedPoints => 'ACCUMULATED POINTS';

  @override
  String pointsToNextTier(int count) {
    return '$count points to next tier';
  }

  @override
  String get redeemRewardsTitle => 'REDEEM REWARDS';

  @override
  String get noRewardsAvailable =>
      'No points-based rewards available for you yet.';

  @override
  String get membershipTiersTitle => 'MEMBERSHIP TIERS';

  @override
  String get defaultTier => 'Default';

  @override
  String get howToStayTitle => 'HOW TO EARN?';

  @override
  String get howToStayDesc =>
      'Accumulate points through shopping and activities.';

  @override
  String get howToEatTitle => 'HOW TO EARN?';

  @override
  String get howToEarnTitle => 'HOW TO EARN?';

  @override
  String get shoppingEarnTitle => 'SHOPPING BEAUTY';

  @override
  String get shoppingEarnDesc => 'Every 10,000đ spent = 1 point';

  @override
  String get redeemEarnTitle => 'REDEEM BENEFITS';

  @override
  String get redeemEarnDesc =>
      'Use points (1 point = 500đ) for direct discount';

  @override
  String get upgradeEarnTitle => 'UPGRADE CLASS';

  @override
  String get upgradeEarnDesc =>
      'Accumulate enough points to unlock elite privileges';

  @override
  String get transactionHistoryTitle => 'TRANSACTION HISTORY';

  @override
  String get noTransactionsYet => 'Your journey hasn\'t started yet';

  @override
  String get orderEarnedPoints => 'Earned points from order';

  @override
  String get redeemedDiscount => 'Redeemed for discount';

  @override
  String get returnedRefundPoints => 'Refund points (Order cancelled)';

  @override
  String get redeemNow => 'REDEEM NOW';

  @override
  String get voucherDiscount => 'VOUCHER DISCOUNT';

  @override
  String get paymentVnpayDesc => 'Pay with VNPay wallet';

  @override
  String get paymentMomoDesc => 'Pay with MoMo wallet';

  @override
  String get paymentCodDesc => 'Cash on delivery';

  @override
  String get paymentPayosDesc => 'Scan QR or bank transfer';

  @override
  String get productReviewTitle => 'Product Review';

  @override
  String productCountHeader(int current, int total) {
    return 'Product $current/$total';
  }

  @override
  String get pleaseSelectStars => 'Please select a rating';

  @override
  String get reviewPlaceholder => 'Share your experience with this product...';

  @override
  String addPhotoCount(int count) {
    return 'Add photo ($count/5)';
  }

  @override
  String get submitReview => 'Submit Review';

  @override
  String get alreadyReviewed => 'You have already reviewed this product';

  @override
  String get reviewErrorOccurred => 'An error occurred, please try again';

  @override
  String get thankYouReview => 'Thank you for your review!';

  @override
  String get ratingVeryBad => 'Very Bad';

  @override
  String get ratingBad => 'Bad';

  @override
  String get ratingNormal => 'Normal';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get selectStars => 'Select stars';

  @override
  String get nextStep => 'Next';

  @override
  String get yesCancel => 'YES, CANCEL';

  @override
  String get relatedOrder => 'Related Order';

  @override
  String redeemVoucherConfirm(int points) {
    return 'Use $points points to redeem this voucher?';
  }

  @override
  String redeemSuccess(String code) {
    return 'Redeemed successfully! Code $code is now in your wallet.';
  }
}
