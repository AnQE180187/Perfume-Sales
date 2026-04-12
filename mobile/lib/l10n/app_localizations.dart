import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lumina'**
  String get appName;

  /// No description provided for @atelierDeParfum.
  ///
  /// In en, this message translates to:
  /// **'ATELIER DE PARFUM'**
  String get atelierDeParfum;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'FORGOT PASSWORD?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'DON\'T HAVE AN ACCOUNT? '**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'GOOGLE'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'FACEBOOK'**
  String get facebook;

  /// No description provided for @joinTheAtelier.
  ///
  /// In en, this message translates to:
  /// **'Join the Atelier'**
  String get joinTheAtelier;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'PHONE (OPTIONAL)'**
  String get phoneOptional;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I AGREE TO THE TERMS AND PRIVACY POLICY'**
  String get agreeToTerms;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'REGISTRATION SUCCESSFUL. PLEASE VERIFY YOUR EMAIL.'**
  String get registrationSuccessful;

  /// No description provided for @pleaseFillFields.
  ///
  /// In en, this message translates to:
  /// **'PLEASE FILL IN ALL REQUIRED FIELDS'**
  String get pleaseFillFields;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'PLEASE ACCEPT THE TERMS & CONDITIONS'**
  String get pleaseAcceptTerms;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'ACCESS DENIED'**
  String get accessDenied;

  /// No description provided for @pleaseProvideCredentials.
  ///
  /// In en, this message translates to:
  /// **'PLEASE PROVIDE CREDENTIALS'**
  String get pleaseProvideCredentials;

  /// No description provided for @dnaScent.
  ///
  /// In en, this message translates to:
  /// **'CREATE YOUR DNA SCENT'**
  String get dnaScent;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'THE ART OF SCENT'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover your unique fragrance identity through our AI-curated collection.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'NEURAL CURATION'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Our AI analyzes thousands of scent notes to find your perfect match.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'TIMELESS LUXURY'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience the future of fragrance, crafted with traditional excellence.'**
  String get onboarding3Subtitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @beginJourney.
  ///
  /// In en, this message translates to:
  /// **'BEGIN THE JOURNEY'**
  String get beginJourney;

  /// No description provided for @neuralArchitect.
  ///
  /// In en, this message translates to:
  /// **'NEURAL ARCHITECT'**
  String get neuralArchitect;

  /// No description provided for @describeVision.
  ///
  /// In en, this message translates to:
  /// **'DESCRIBE YOUR VISION...'**
  String get describeVision;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Atelier. I am your Neural Architect. Tell me, what emotional landscape do you wish to explore through scent today?'**
  String get welcomeMessage;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROFILE'**
  String get yourProfile;

  /// No description provided for @atelierMember.
  ///
  /// In en, this message translates to:
  /// **'ATELIER MEMBER'**
  String get atelierMember;

  /// No description provided for @theAtelier.
  ///
  /// In en, this message translates to:
  /// **'THE ATELIER'**
  String get theAtelier;

  /// No description provided for @acquisitionHistory.
  ///
  /// In en, this message translates to:
  /// **'ACQUISITION HISTORY'**
  String get acquisitionHistory;

  /// No description provided for @curatedCollection.
  ///
  /// In en, this message translates to:
  /// **'CURATED COLLECTION'**
  String get curatedCollection;

  /// No description provided for @neuralDnaArchive.
  ///
  /// In en, this message translates to:
  /// **'NEURAL DNA ARCHIVE'**
  String get neuralDnaArchive;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get system;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @concierge.
  ///
  /// In en, this message translates to:
  /// **'CONCIERGE'**
  String get concierge;

  /// No description provided for @disconnectSession.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT SESSION'**
  String get disconnectSession;

  /// No description provided for @luminaAtelier.
  ///
  /// In en, this message translates to:
  /// **'LUMINA ATELIER'**
  String get luminaAtelier;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'INTENSITY'**
  String get intensity;

  /// No description provided for @neuralInsight.
  ///
  /// In en, this message translates to:
  /// **'NEURAL INSIGHT'**
  String get neuralInsight;

  /// No description provided for @scentProfile.
  ///
  /// In en, this message translates to:
  /// **'SCENT PROFILE'**
  String get scentProfile;

  /// No description provided for @theStory.
  ///
  /// In en, this message translates to:
  /// **'THE STORY'**
  String get theStory;

  /// No description provided for @acquireScent.
  ///
  /// In en, this message translates to:
  /// **'ACQUIRE SCENT'**
  String get acquireScent;

  /// No description provided for @topNotes.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get topNotes;

  /// No description provided for @heartNotes.
  ///
  /// In en, this message translates to:
  /// **'HEART'**
  String get heartNotes;

  /// No description provided for @baseNotes.
  ///
  /// In en, this message translates to:
  /// **'BASE'**
  String get baseNotes;

  /// No description provided for @orderAtelier.
  ///
  /// In en, this message translates to:
  /// **'ORDER ATELIER'**
  String get orderAtelier;

  /// No description provided for @yourSelection.
  ///
  /// In en, this message translates to:
  /// **'YOUR SELECTION'**
  String get yourSelection;

  /// No description provided for @shippingAtelier.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING ATELIER'**
  String get shippingAtelier;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'SUBTOTAL'**
  String get subtotal;

  /// No description provided for @priorityShipping.
  ///
  /// In en, this message translates to:
  /// **'PRIORITY SHIPPING'**
  String get priorityShipping;

  /// No description provided for @complimentary.
  ///
  /// In en, this message translates to:
  /// **'COMPLIMENTARY'**
  String get complimentary;

  /// No description provided for @totalAcquisition.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ACQUISITION'**
  String get totalAcquisition;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM ORDER'**
  String get confirmOrder;

  /// No description provided for @acquisitionComplete.
  ///
  /// In en, this message translates to:
  /// **'ACQUISITION COMPLETE'**
  String get acquisitionComplete;

  /// No description provided for @orderCodified.
  ///
  /// In en, this message translates to:
  /// **'Your molecular signature has been codified. Your fragrance is being prepared.'**
  String get orderCodified;

  /// No description provided for @traceOrder.
  ///
  /// In en, this message translates to:
  /// **'TRACE ORDER'**
  String get traceOrder;

  /// No description provided for @returnToAtelier.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO ATELIER'**
  String get returnToAtelier;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'SHOPPING CART'**
  String get shoppingCart;

  /// No description provided for @yourCartEmpty.
  ///
  /// In en, this message translates to:
  /// **'YOUR CART IS EMPTY'**
  String get yourCartEmpty;

  /// No description provided for @discoverCollection.
  ///
  /// In en, this message translates to:
  /// **'Discover our curated collection'**
  String get discoverCollection;

  /// No description provided for @exploreCollection.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE COLLECTION'**
  String get exploreCollection;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'PROMO CODE'**
  String get promoCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get apply;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @proceedCheckout.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO CHECKOUT'**
  String get proceedCheckout;

  /// No description provided for @discountApplied.
  ///
  /// In en, this message translates to:
  /// **'discount applied'**
  String get discountApplied;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code'**
  String get invalidPromoCode;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'ORDER HISTORY'**
  String get orderHistory;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'NO ORDERS YET'**
  String get noOrdersYet;

  /// No description provided for @orderHistoryAppear.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here'**
  String get orderHistoryAppear;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'START SHOPPING'**
  String get startShopping;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'ORDER DETAILS'**
  String get orderDetails;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'ORDER NUMBER'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'ORDER DATE'**
  String get orderDate;

  /// No description provided for @orderTimeline.
  ///
  /// In en, this message translates to:
  /// **'ORDER TIMELINE'**
  String get orderTimeline;

  /// No description provided for @trackingInformation.
  ///
  /// In en, this message translates to:
  /// **'TRACKING INFORMATION'**
  String get trackingInformation;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get trackingNumber;

  /// No description provided for @trackShipment.
  ///
  /// In en, this message translates to:
  /// **'TRACK SHIPMENT'**
  String get trackShipment;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get items;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING ADDRESS'**
  String get shippingAddress;

  /// No description provided for @shippingFee.
  ///
  /// In en, this message translates to:
  /// **'Shipping Fee'**
  String get shippingFee;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'REORDER'**
  String get reorder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'CANCEL ORDER'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @yesCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'YES, CANCEL'**
  String get yesCancelOrder;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get orderPlacedSuccess;

  /// No description provided for @failedToReorder.
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder'**
  String get failedToReorder;

  /// No description provided for @failedToCancel.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel'**
  String get failedToCancel;

  /// No description provided for @failedLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get failedLoadOrders;

  /// No description provided for @failedLoadOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to load order'**
  String get failedLoadOrder;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'more items'**
  String get moreItems;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @orderNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Order number copied'**
  String get orderNumberCopied;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get orderStatusOutForDelivery;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get orderStatusRefunded;

  /// No description provided for @orderDescPending.
  ///
  /// In en, this message translates to:
  /// **'Your order is being processed'**
  String get orderDescPending;

  /// No description provided for @orderDescConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed and preparing'**
  String get orderDescConfirmed;

  /// No description provided for @orderDescProcessing.
  ///
  /// In en, this message translates to:
  /// **'Packaging your fragrance'**
  String get orderDescProcessing;

  /// No description provided for @orderDescShipped.
  ///
  /// In en, this message translates to:
  /// **'On the way to you'**
  String get orderDescShipped;

  /// No description provided for @orderDescOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Arriving today'**
  String get orderDescOutForDelivery;

  /// No description provided for @orderDescDelivered.
  ///
  /// In en, this message translates to:
  /// **'Successfully delivered'**
  String get orderDescDelivered;

  /// No description provided for @orderDescCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderDescCancelled;

  /// No description provided for @orderDescRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refund processed'**
  String get orderDescRefunded;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT'**
  String get payment;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'SELECT PAYMENT METHOD'**
  String get selectPaymentMethod;

  /// No description provided for @vnpay.
  ///
  /// In en, this message translates to:
  /// **'VNPay'**
  String get vnpay;

  /// No description provided for @momo.
  ///
  /// In en, this message translates to:
  /// **'Momo'**
  String get momo;

  /// No description provided for @cod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cod;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'PAY NOW'**
  String get payNow;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// No description provided for @searchFragrance.
  ///
  /// In en, this message translates to:
  /// **'SEARCH FRAGRANCE...'**
  String get searchFragrance;

  /// No description provided for @personalizedSelection.
  ///
  /// In en, this message translates to:
  /// **'PERSONALIZED SELECTION'**
  String get personalizedSelection;

  /// No description provided for @tailoredRecommendations.
  ///
  /// In en, this message translates to:
  /// **'TAILORED RECOMMENDATIONS'**
  String get tailoredRecommendations;

  /// No description provided for @viewCollection.
  ///
  /// In en, this message translates to:
  /// **'VIEW COLLECTION'**
  String get viewCollection;

  /// No description provided for @eauDeParfum.
  ///
  /// In en, this message translates to:
  /// **'EAU DE PARFUM'**
  String get eauDeParfum;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get rating;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @viewReviews.
  ///
  /// In en, this message translates to:
  /// **'View reviews'**
  String get viewReviews;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCart;

  /// No description provided for @variantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Suitable product variant not found.'**
  String get variantNotFound;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @failedAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get failedAddToCart;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track orders, custom offers, and account activity.'**
  String get notificationSubtitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @readAll.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get readAll;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications read'**
  String get allNotificationsRead;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unread notifications'**
  String unreadNotifications(Object count);

  /// No description provided for @updateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with our latest offers'**
  String get updateNotifications;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesSub.
  ///
  /// In en, this message translates to:
  /// **'Shipping, preparing, and payment'**
  String get orderUpdatesSub;

  /// No description provided for @offersAndGifts.
  ///
  /// In en, this message translates to:
  /// **'Offers and Gifts'**
  String get offersAndGifts;

  /// No description provided for @offersAndGiftsSub.
  ///
  /// In en, this message translates to:
  /// **'Member offers, limited drops, and codes'**
  String get offersAndGiftsSub;

  /// No description provided for @accountActivity.
  ///
  /// In en, this message translates to:
  /// **'Account Activity'**
  String get accountActivity;

  /// No description provided for @accountActivitySub.
  ///
  /// In en, this message translates to:
  /// **'Back in stock and account security'**
  String get accountActivitySub;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @filterOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get filterOrders;

  /// No description provided for @filterOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get filterOffers;

  /// No description provided for @filterAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get filterAccount;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'LATEST'**
  String get latest;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'OLDER'**
  String get older;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT SUMMARY'**
  String get paymentSummary;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmount;

  /// No description provided for @shippingAddressUpper.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING ADDRESS'**
  String get shippingAddressUpper;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'CONTACT SUPPORT'**
  String get contactSupport;

  /// No description provided for @returnRequest.
  ///
  /// In en, this message translates to:
  /// **'Return Request / Refund'**
  String get returnRequest;

  /// No description provided for @supportContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Support team will contact you soon.'**
  String get supportContactMessage;

  /// No description provided for @trackOrderUpper.
  ///
  /// In en, this message translates to:
  /// **'TRACK ORDER'**
  String get trackOrderUpper;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'BUY NOW'**
  String get buyNow;

  /// No description provided for @freeReturns.
  ///
  /// In en, this message translates to:
  /// **'Free returns within 7 days'**
  String get freeReturns;

  /// No description provided for @checkingPayment.
  ///
  /// In en, this message translates to:
  /// **'Checking payment...'**
  String get checkingPayment;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on'**
  String get placedOn;

  /// No description provided for @ordersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersActive;

  /// No description provided for @ordersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersCompleted;

  /// No description provided for @ordersReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get ordersReturns;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Payment completed'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Payment refunded'**
  String get paymentStatusRefunded;

  /// No description provided for @paymentMethodPayos.
  ///
  /// In en, this message translates to:
  /// **'PayOS Gateway'**
  String get paymentMethodPayos;

  /// No description provided for @paymentMethodCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery (COD)'**
  String get paymentMethodCod;

  /// No description provided for @paymentMethodVnpay.
  ///
  /// In en, this message translates to:
  /// **'VNPay Wallet'**
  String get paymentMethodVnpay;

  /// No description provided for @paymentMethodMomo.
  ///
  /// In en, this message translates to:
  /// **'MoMo Wallet'**
  String get paymentMethodMomo;

  /// No description provided for @returnRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Request'**
  String get returnRequestTitle;

  /// No description provided for @selectReturnItems.
  ///
  /// In en, this message translates to:
  /// **'Select items to return'**
  String get selectReturnItems;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for return'**
  String get returnReason;

  /// No description provided for @returnReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Detailed description of the issue...'**
  String get returnReasonHint;

  /// No description provided for @refundInfo.
  ///
  /// In en, this message translates to:
  /// **'Refund Payment Info'**
  String get refundInfo;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank / E-Wallet'**
  String get bankName;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chase, PayPal...'**
  String get bankNameHint;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number / Phone'**
  String get accountNumber;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountName;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'JOHN DOE'**
  String get accountNameHint;

  /// No description provided for @evidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence Required'**
  String get evidenceTitle;

  /// No description provided for @photoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Photos (At least 3)'**
  String get photoEvidence;

  /// No description provided for @videoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Video (3s - 60s)'**
  String get videoEvidence;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @submitReturn.
  ///
  /// In en, this message translates to:
  /// **'Submit Return Request'**
  String get submitReturn;

  /// No description provided for @returnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Return request submitted successfully'**
  String get returnSuccess;

  /// No description provided for @errorSelectItems.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one item'**
  String get errorSelectItems;

  /// No description provided for @errorReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason for return'**
  String get errorReason;

  /// No description provided for @errorBankInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide full refund payment info'**
  String get errorBankInfo;

  /// No description provided for @errorPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least 3 photos'**
  String get errorPhotoCount;

  /// No description provided for @errorVideoMissing.
  ///
  /// In en, this message translates to:
  /// **'Please providing 1 video evidence'**
  String get errorVideoMissing;

  /// No description provided for @returnPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Product must be in original condition with tags.'**
  String get returnPolicyNote;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Item is damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong item delivered'**
  String get reasonWrongItem;

  /// No description provided for @reasonScentNotExpected.
  ///
  /// In en, this message translates to:
  /// **'Scent not as expected'**
  String get reasonScentNotExpected;

  /// No description provided for @returnProcessNotice.
  ///
  /// In en, this message translates to:
  /// **'Your request will be processed within 24-48h'**
  String get returnProcessNotice;

  /// No description provided for @returnStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get returnStatusRequested;

  /// No description provided for @returnStatusReviewing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get returnStatusReviewing;

  /// No description provided for @returnStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get returnStatusApproved;

  /// No description provided for @returnStatusReturning.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get returnStatusReturning;

  /// No description provided for @returnStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get returnStatusReceived;

  /// No description provided for @returnStatusRefunding.
  ///
  /// In en, this message translates to:
  /// **'Refunding'**
  String get returnStatusRefunding;

  /// No description provided for @returnStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get returnStatusCompleted;

  /// No description provided for @returnStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get returnStatusRejected;

  /// No description provided for @returnStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get returnStatusCancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
