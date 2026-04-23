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
  /// **'Perfume GPT'**
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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cancelUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelUpper;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodTitle;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods available.'**
  String get noPaymentMethods;

  /// No description provided for @paymentMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your default payment method for future orders'**
  String get paymentMethodSubtitle;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @standby.
  ///
  /// In en, this message translates to:
  /// **'Standby'**
  String get standby;

  /// No description provided for @payosNoteLong.
  ///
  /// In en, this message translates to:
  /// **'PayOS allows instant QR scanning or bank transfer. COD is suitable if you prefer to check the goods before paying.'**
  String get payosNoteLong;

  /// No description provided for @returnReasonExample.
  ///
  /// In en, this message translates to:
  /// **'Example: The product leaked during delivery...'**
  String get returnReasonExample;

  /// No description provided for @userCancelled.
  ///
  /// In en, this message translates to:
  /// **'User cancelled'**
  String get userCancelled;

  /// No description provided for @posOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get posOutOfStock;

  /// No description provided for @posLowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String posLowStockWarning(int count);

  /// No description provided for @posStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count}'**
  String posStockLabel(int count);

  /// No description provided for @orderConfirmError.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm order'**
  String get orderConfirmError;

  /// No description provided for @missingPaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Order created but no payment link found. Please retry.'**
  String get missingPaymentLink;

  /// No description provided for @unableOpenPayment.
  ///
  /// In en, this message translates to:
  /// **'Unable to open payment page. Tap button to retry.'**
  String get unableOpenPayment;

  /// No description provided for @paymentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Complete payment in your browser, then return and tap check.'**
  String get paymentInstructions;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @staffHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get staffHome;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrdersLabel;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @avgPerOrder.
  ///
  /// In en, this message translates to:
  /// **'Avg/Order'**
  String get avgPerOrder;

  /// No description provided for @pendingProcess.
  ///
  /// In en, this message translates to:
  /// **'Pending Process'**
  String get pendingProcess;

  /// No description provided for @paymentRate.
  ///
  /// In en, this message translates to:
  /// **'Payment Rate'**
  String get paymentRate;

  /// No description provided for @topBestSellers.
  ///
  /// In en, this message translates to:
  /// **'Top Best Sellers'**
  String get topBestSellers;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @unableLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data'**
  String get unableLoadData;

  /// No description provided for @totalOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String totalOrdersCount(Object count);

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search order code, phone, name...'**
  String get searchOrdersHint;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get statusPendingPayment;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @confirmReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Return'**
  String get confirmReturnTitle;

  /// No description provided for @confirmReturnDesc.
  ///
  /// In en, this message translates to:
  /// **'Create return & refund request for order {code}?'**
  String confirmReturnDesc(Object code);

  /// No description provided for @returnRefundLabel.
  ///
  /// In en, this message translates to:
  /// **'Return / Refund'**
  String get returnRefundLabel;

  /// No description provided for @returnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Return & refund request created successfully'**
  String get returnSuccess;

  /// No description provided for @returnError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process return'**
  String get returnError;

  /// No description provided for @reasonCustomerReturnCounter.
  ///
  /// In en, this message translates to:
  /// **'Customer returned at counter'**
  String get reasonCustomerReturnCounter;

  /// No description provided for @ordersHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersHistoryLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// No description provided for @repay.
  ///
  /// In en, this message translates to:
  /// **'Repay'**
  String get repay;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirmCancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel Order'**
  String get confirmCancelOrderTitle;

  /// No description provided for @confirmCancelOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel order {code}? This action cannot be undone.'**
  String confirmCancelOrderDesc(Object code);

  /// No description provided for @cancelOrderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order {code} cancelled'**
  String cancelOrderSuccess(Object code);

  /// No description provided for @cancelOrderError.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel order'**
  String get cancelOrderError;

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
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER (OPTIONAL)'**
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
  /// **'PLEASE FILL ALL FIELDS'**
  String get pleaseFillFields;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'PLEASE ACCEPT TERMS'**
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
  /// **'DISCOVER YOUR SCENT DNA'**
  String get dnaScent;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'THE ART OF SCENT'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover your unique olfactory identity through an AI-curated collection.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'INTELLIGENT SELECTION'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI analyzes thousands of notes to find your perfect resonance.'**
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
  /// **'BEGIN JOURNEY'**
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
  /// **'Welcome to the Atelier. I am your Neural Architect. Tell me, what emotional landscape shall we explore through scent today?'**
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
  /// **'Language'**
  String get language;

  /// No description provided for @concierge.
  ///
  /// In en, this message translates to:
  /// **'CONCIERGE'**
  String get concierge;

  /// No description provided for @disconnectSession.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT'**
  String get disconnectSession;

  /// No description provided for @luminaAtelier.
  ///
  /// In en, this message translates to:
  /// **'PERFUME GPT'**
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

  /// No description provided for @storyHeader.
  ///
  /// In en, this message translates to:
  /// **'The story behind the scent'**
  String get storyHeader;

  /// No description provided for @storyInspiration.
  ///
  /// In en, this message translates to:
  /// **'INSPIRATION'**
  String get storyInspiration;

  /// No description provided for @storyCraftsmanship.
  ///
  /// In en, this message translates to:
  /// **'CRAFTSMANSHIP'**
  String get storyCraftsmanship;

  /// No description provided for @backToProductStory.
  ///
  /// In en, this message translates to:
  /// **'BACK TO PRODUCT'**
  String get backToProductStory;

  /// No description provided for @discoverNotesStory.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER SCENT NOTES'**
  String get discoverNotesStory;

  /// No description provided for @acquireScent.
  ///
  /// In en, this message translates to:
  /// **'ACQUIRE SCENT'**
  String get acquireScent;

  /// No description provided for @topNotes.
  ///
  /// In en, this message translates to:
  /// **'TOP NOTES'**
  String get topNotes;

  /// No description provided for @heartNotes.
  ///
  /// In en, this message translates to:
  /// **'HEART NOTES'**
  String get heartNotes;

  /// No description provided for @baseNotes.
  ///
  /// In en, this message translates to:
  /// **'BASE NOTES'**
  String get baseNotes;

  /// No description provided for @orderAtelier.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM ORDER'**
  String get orderAtelier;

  /// No description provided for @yourSelection.
  ///
  /// In en, this message translates to:
  /// **'YOUR SELECTION'**
  String get yourSelection;

  /// No description provided for @shippingAtelier.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING'**
  String get shippingAtelier;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethod;

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
  /// **'Your molecular signature has been codified. Your scent is being prepared.'**
  String get orderCodified;

  /// No description provided for @traceOrder.
  ///
  /// In en, this message translates to:
  /// **'TRACE'**
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
  /// **'Discover the curated collection'**
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

  /// No description provided for @yesCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'YES, CANCEL ORDER'**
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
  /// **'Failed to load order details'**
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
  /// **'QTY'**
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
  /// **'Out For Delivery'**
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

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR WISHLIST IS EMPTY'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorites list is waiting for the scents you truly love.'**
  String get wishlistEmptySubtitle;

  /// No description provided for @exploreFragrances.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE FRAGRANCES'**
  String get exploreFragrances;

  /// No description provided for @orderStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get orderStatusRefunded;

  /// No description provided for @orderDescPending.
  ///
  /// In en, this message translates to:
  /// **'Your order is pending confirmation'**
  String get orderDescPending;

  /// No description provided for @orderDescConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed'**
  String get orderDescConfirmed;

  /// No description provided for @orderDescProcessing.
  ///
  /// In en, this message translates to:
  /// **'We are preparing your scent'**
  String get orderDescProcessing;

  /// No description provided for @orderDescShipped.
  ///
  /// In en, this message translates to:
  /// **'Your scent is on the way'**
  String get orderDescShipped;

  /// No description provided for @orderDescOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Your order is out for delivery'**
  String get orderDescOutForDelivery;

  /// No description provided for @orderDescDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered successfully'**
  String get orderDescDelivered;

  /// No description provided for @orderDescCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled'**
  String get orderDescCancelled;

  /// No description provided for @orderDescRefunded.
  ///
  /// In en, this message translates to:
  /// **'Order has been refunded'**
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
  /// **'Payment Success'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment Cancelled'**
  String get paymentCancelled;

  /// No description provided for @paymentMethodPayos.
  ///
  /// In en, this message translates to:
  /// **'PayOS Gateway'**
  String get paymentMethodPayos;

  /// No description provided for @paymentMethodPayosDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code or instant bank transfer'**
  String get paymentMethodPayosDesc;

  /// No description provided for @paymentMethodCod.
  ///
  /// In en, this message translates to:
  /// **'Cash On Delivery (COD)'**
  String get paymentMethodCod;

  /// No description provided for @paymentMethodCodDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay when you receive the product'**
  String get paymentMethodCodDesc;

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

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get paymentStatusProcessing;

  /// No description provided for @paymentStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get paymentStatusSuccess;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get paymentStatusCancelled;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentStatusRefunded;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @exclusiveOffer.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE OFFER'**
  String get exclusiveOffer;

  /// No description provided for @taxVat.
  ///
  /// In en, this message translates to:
  /// **'Tax (VAT)'**
  String get taxVat;

  /// No description provided for @incTaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Inclusive of all taxes'**
  String get incTaxLabel;

  /// No description provided for @totalAmountUpper.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmountUpper;

  /// No description provided for @productValue.
  ///
  /// In en, this message translates to:
  /// **'Product Value'**
  String get productValue;

  /// No description provided for @addShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Shipping Address'**
  String get addShippingAddress;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @selectShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Shipping Address'**
  String get selectShippingAddress;

  /// No description provided for @syncAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'This list is synced directly from your account.'**
  String get syncAccountDesc;

  /// No description provided for @noAddressFound.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any addresses. Please add one before ordering.'**
  String get noAddressFound;

  /// No description provided for @manageAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage Addresses'**
  String get manageAddresses;

  /// No description provided for @openAddressManager.
  ///
  /// In en, this message translates to:
  /// **'Open Address Manager'**
  String get openAddressManager;

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
  /// **'View all'**
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
  /// **'View Reviews'**
  String get viewReviews;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCart;

  /// No description provided for @variantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Variant not found.'**
  String get variantNotFound;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
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
  /// **'Track your orders, exclusive offers, and account activity.'**
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
  /// **'Read All'**
  String get readAll;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'You\'ve read all notifications'**
  String get allNotificationsRead;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unread notifications'**
  String unreadNotifications(int count);

  /// No description provided for @updateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Keep up with the latest offers'**
  String get updateNotifications;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesSub.
  ///
  /// In en, this message translates to:
  /// **'Shipments, preparation, and payments'**
  String get orderUpdatesSub;

  /// No description provided for @offersAndGifts.
  ///
  /// In en, this message translates to:
  /// **'Offers and Gifts'**
  String get offersAndGifts;

  /// No description provided for @offersAndGiftsSub.
  ///
  /// In en, this message translates to:
  /// **'Member benefits, limited editions, and promos'**
  String get offersAndGiftsSub;

  /// No description provided for @accountActivity.
  ///
  /// In en, this message translates to:
  /// **'Account Activity'**
  String get accountActivity;

  /// No description provided for @accountActivitySub.
  ///
  /// In en, this message translates to:
  /// **'Restock alerts and security notifications'**
  String get accountActivitySub;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

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
  /// **'Total Amount'**
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
  /// **'Return / Refund Request'**
  String get returnRequest;

  /// No description provided for @supportContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Support will contact you shortly.'**
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
  /// **'Checking...'**
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

  /// No description provided for @ordersCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersCancelled;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Payment Completed'**
  String get paymentStatusPaid;

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
  /// **'Describe the product condition in detail...'**
  String get returnReasonHint;

  /// No description provided for @refundInfo.
  ///
  /// In en, this message translates to:
  /// **'Refund Destination'**
  String get refundInfo;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank / E-Wallet'**
  String get bankName;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: MB Bank, Momo...'**
  String get bankNameHint;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account / Phone Number'**
  String get accountNumber;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'NGUYEN VAN A'**
  String get accountNameHint;

  /// No description provided for @evidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get evidenceTitle;

  /// No description provided for @photoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Photos (Min 3)'**
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

  /// No description provided for @errorSelectItems.
  ///
  /// In en, this message translates to:
  /// **'Please select items to return'**
  String get errorSelectItems;

  /// No description provided for @errorReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason'**
  String get errorReason;

  /// No description provided for @errorBankInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide full refund information'**
  String get errorBankInfo;

  /// No description provided for @errorPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least 3 photos'**
  String get errorPhotoCount;

  /// No description provided for @errorVideoMissing.
  ///
  /// In en, this message translates to:
  /// **'Please provide 1 evidence video'**
  String get errorVideoMissing;

  /// No description provided for @returnPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Items must be unused with tags attached.'**
  String get returnPolicyNote;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Product Damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonWrongItem.
  ///
  /// In en, this message translates to:
  /// **'Wrong Item Sent'**
  String get reasonWrongItem;

  /// No description provided for @reasonScentNotExpected.
  ///
  /// In en, this message translates to:
  /// **'Scent Not As Expected'**
  String get reasonScentNotExpected;

  /// No description provided for @returnProcessNotice.
  ///
  /// In en, this message translates to:
  /// **'Request will be processed within 24-48h'**
  String get returnProcessNotice;

  /// No description provided for @returnStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
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

  /// No description provided for @returnStep1.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get returnStep1;

  /// No description provided for @returnStep2.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get returnStep2;

  /// No description provided for @returnStep3.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get returnStep3;

  /// No description provided for @returnNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get returnNext;

  /// No description provided for @returnBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get returnBack;

  /// No description provided for @returnGuidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Guidance'**
  String get returnGuidanceTitle;

  /// No description provided for @returnGuidanceStep1.
  ///
  /// In en, this message translates to:
  /// **'Select items you wish to return'**
  String get returnGuidanceStep1;

  /// No description provided for @returnGuidanceStep2.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason and refund info'**
  String get returnGuidanceStep2;

  /// No description provided for @returnGuidanceStep3.
  ///
  /// In en, this message translates to:
  /// **'Upload clear photos and video'**
  String get returnGuidanceStep3;

  /// No description provided for @returnEvidenceTip1.
  ///
  /// In en, this message translates to:
  /// **'Photograph all sides of product'**
  String get returnEvidenceTip1;

  /// No description provided for @returnEvidenceTip2.
  ///
  /// In en, this message translates to:
  /// **'Record unboxing or showing defects'**
  String get returnEvidenceTip2;

  /// No description provided for @shipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Info'**
  String get shipmentTitle;

  /// No description provided for @ghnPickupNotice.
  ///
  /// In en, this message translates to:
  /// **'GHN will pick up from your address'**
  String get ghnPickupNotice;

  /// No description provided for @ghnPickupDesc.
  ///
  /// In en, this message translates to:
  /// **'Please hand over the package to the courier'**
  String get ghnPickupDesc;

  /// No description provided for @trackMovement.
  ///
  /// In en, this message translates to:
  /// **'Track Shipment'**
  String get trackMovement;

  /// No description provided for @confirmHandover.
  ///
  /// In en, this message translates to:
  /// **'Confirm Handed Over'**
  String get confirmHandover;

  /// No description provided for @submitShipment.
  ///
  /// In en, this message translates to:
  /// **'Submit Shipment'**
  String get submitShipment;

  /// No description provided for @refundNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'REFUND PROCESSING'**
  String get refundNoticeTitle;

  /// No description provided for @refundNoticeDesc.
  ///
  /// In en, this message translates to:
  /// **'We have received the items. Refund will be issued within 24 business hours.'**
  String get refundNoticeDesc;

  /// No description provided for @refundSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'REFUND SUCCESS'**
  String get refundSuccessTitle;

  /// No description provided for @refundSuccessSub.
  ///
  /// In en, this message translates to:
  /// **'ADMIN HAS TRANSFERRED TO YOUR ACCOUNT'**
  String get refundSuccessSub;

  /// No description provided for @refundAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'REFUNDED AMOUNT'**
  String get refundAmountLabel;

  /// No description provided for @refundTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get refundTimeLabel;

  /// No description provided for @receiptImageHeader.
  ///
  /// In en, this message translates to:
  /// **'TRANSFER RECEIPT'**
  String get receiptImageHeader;

  /// No description provided for @resetDna.
  ///
  /// In en, this message translates to:
  /// **'Reset DNA'**
  String get resetDna;

  /// No description provided for @resetDnaConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all scent preferences to default?'**
  String get resetDnaConfirm;

  /// No description provided for @dnaResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'DNA Profile has been reset'**
  String get dnaResetSuccess;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'APP INFORMATION'**
  String get appSettings;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get legal;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @scentClub.
  ///
  /// In en, this message translates to:
  /// **'Scent Club'**
  String get scentClub;

  /// No description provided for @fragranceLibrary.
  ///
  /// In en, this message translates to:
  /// **'Fragrance Library'**
  String get fragranceLibrary;

  /// No description provided for @boutiques.
  ///
  /// In en, this message translates to:
  /// **'Boutiques'**
  String get boutiques;

  /// No description provided for @scentQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz AI'**
  String get scentQuiz;

  /// No description provided for @exclusiveCollection.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Collection'**
  String get exclusiveCollection;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @ingredientsDictionary.
  ///
  /// In en, this message translates to:
  /// **'Ingredients Dictionary'**
  String get ingredientsDictionary;

  /// No description provided for @giftService.
  ///
  /// In en, this message translates to:
  /// **'Gift Service'**
  String get giftService;

  /// No description provided for @brandStory.
  ///
  /// In en, this message translates to:
  /// **'Brand Story'**
  String get brandStory;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @supportConcierge.
  ///
  /// In en, this message translates to:
  /// **'Support Concierge'**
  String get supportConcierge;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fragrance...'**
  String get searchHint;

  /// No description provided for @memberPlatinum.
  ///
  /// In en, this message translates to:
  /// **'PLATINUM MEMBER'**
  String get memberPlatinum;

  /// No description provided for @memberGold.
  ///
  /// In en, this message translates to:
  /// **'GOLD MEMBER'**
  String get memberGold;

  /// No description provided for @memberSilver.
  ///
  /// In en, this message translates to:
  /// **'SILVER MEMBER'**
  String get memberSilver;

  /// No description provided for @memberStandard.
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get memberStandard;

  /// No description provided for @loyaltyProgram.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Program'**
  String get loyaltyProgram;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @startPoints.
  ///
  /// In en, this message translates to:
  /// **'Start earning points now'**
  String get startPoints;

  /// No description provided for @scentProfileSoon.
  ///
  /// In en, this message translates to:
  /// **'Detail Scent Profile coming soon'**
  String get scentProfileSoon;

  /// No description provided for @loginToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Please login to view your profile'**
  String get loginToViewProfile;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsLabel;

  /// No description provided for @tierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get tierLabel;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT MANAGEMENT'**
  String get accountManagement;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @shippingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Shipping Addresses'**
  String get shippingAddresses;

  /// No description provided for @paymentAndCards.
  ///
  /// In en, this message translates to:
  /// **'Payment & Cards'**
  String get paymentAndCards;

  /// No description provided for @aiScentPreferences.
  ///
  /// In en, this message translates to:
  /// **'AI Scent Preferences'**
  String get aiScentPreferences;

  /// No description provided for @searchExploreHint.
  ///
  /// In en, this message translates to:
  /// **'Search brands, notes, or vibes...'**
  String get searchExploreHint;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'TOP RATED'**
  String get topRated;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get navExplore;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'ALERTS'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get navProfile;

  /// No description provided for @scentFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get scentFamily;

  /// No description provided for @usageOccasion.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get usageOccasion;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceRange;

  /// No description provided for @featuredScents.
  ///
  /// In en, this message translates to:
  /// **'Featured Scents'**
  String get featuredScents;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @productsFound.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get productsFound;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilter;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @searchExploreHintHome.
  ///
  /// In en, this message translates to:
  /// **'Search brands, notes, or vibes...'**
  String get searchExploreHintHome;

  /// No description provided for @headlineElevate.
  ///
  /// In en, this message translates to:
  /// **'Elevate '**
  String get headlineElevate;

  /// No description provided for @headlineSignature.
  ///
  /// In en, this message translates to:
  /// **'signature'**
  String get headlineSignature;

  /// No description provided for @headlineUniqueScent.
  ///
  /// In en, this message translates to:
  /// **'\nyour unique scent'**
  String get headlineUniqueScent;

  /// No description provided for @aiScentSignature.
  ///
  /// In en, this message translates to:
  /// **'AI SCENT SIGNATURE'**
  String get aiScentSignature;

  /// No description provided for @uniqueScentSignature.
  ///
  /// In en, this message translates to:
  /// **'Unique Scent Signature'**
  String get uniqueScentSignature;

  /// No description provided for @exploreCta.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get exploreCta;

  /// No description provided for @aiSelection.
  ///
  /// In en, this message translates to:
  /// **'AI SELECTION'**
  String get aiSelection;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'MY PROFILE'**
  String get myProfile;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'ALL PRODUCTS'**
  String get allProducts;

  /// No description provided for @trackOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrderCta;

  /// No description provided for @viewOffers.
  ///
  /// In en, this message translates to:
  /// **'View Offers'**
  String get viewOffers;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get viewReview;

  /// No description provided for @categoryOrders.
  ///
  /// In en, this message translates to:
  /// **'ORDERS'**
  String get categoryOrders;

  /// No description provided for @categoryOffers.
  ///
  /// In en, this message translates to:
  /// **'OFFERS'**
  String get categoryOffers;

  /// No description provided for @categoryAccount.
  ///
  /// In en, this message translates to:
  /// **'TÀI KHOẢN'**
  String get categoryAccount;

  /// No description provided for @returnCode.
  ///
  /// In en, this message translates to:
  /// **'Return Code'**
  String get returnCode;

  /// No description provided for @returnDetails.
  ///
  /// In en, this message translates to:
  /// **'Return Details'**
  String get returnDetails;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @listedPrice.
  ///
  /// In en, this message translates to:
  /// **'LISTED PRICE'**
  String get listedPrice;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select Size'**
  String get selectSize;

  /// No description provided for @aiScentAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Scent Analysis'**
  String get aiScentAnalysis;

  /// No description provided for @scentStructure.
  ///
  /// In en, this message translates to:
  /// **'Scent Structure'**
  String get scentStructure;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @topNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Sparkling and light'**
  String get topNotesDesc;

  /// No description provided for @heartNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Rich and complex'**
  String get heartNotesDesc;

  /// No description provided for @baseNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep and long-lasting'**
  String get baseNotesDesc;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readMoreUpper.
  ///
  /// In en, this message translates to:
  /// **'READ MORE'**
  String get readMoreUpper;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @readTime.
  ///
  /// In en, this message translates to:
  /// **'{count} MIN READ'**
  String readTime(int count);

  /// No description provided for @aiScentAnalysisDesc1.
  ///
  /// In en, this message translates to:
  /// **'We recommend this product based on your love for '**
  String get aiScentAnalysisDesc1;

  /// No description provided for @aiScentAnalysisDesc2.
  ///
  /// In en, this message translates to:
  /// **' notes. This perfect blend of notes will provide a sophisticated, elegant experience and long-lasting scent on your skin.'**
  String get aiScentAnalysisDesc2;

  /// No description provided for @perfumeGptInsight.
  ///
  /// In en, this message translates to:
  /// **'PERFUMEGPT INSIGHT'**
  String get perfumeGptInsight;

  /// No description provided for @noAiSummary.
  ///
  /// In en, this message translates to:
  /// **'No AI summary available for this product.'**
  String get noAiSummary;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this product yet.'**
  String get noReviewsYet;

  /// No description provided for @allReviews.
  ///
  /// In en, this message translates to:
  /// **'All Reviews'**
  String get allReviews;

  /// No description provided for @withImages.
  ///
  /// In en, this message translates to:
  /// **'With Images'**
  String get withImages;

  /// No description provided for @havePromoCode.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code?'**
  String get havePromoCode;

  /// No description provided for @notCalculated.
  ///
  /// In en, this message translates to:
  /// **'Not calculated'**
  String get notCalculated;

  /// No description provided for @estSubtotal.
  ///
  /// In en, this message translates to:
  /// **'EST. SUBTOTAL'**
  String get estSubtotal;

  /// No description provided for @shippingFeeNotice.
  ///
  /// In en, this message translates to:
  /// **'Shipping will be calculated at next step'**
  String get shippingFeeNotice;

  /// No description provided for @goToCheckout.
  ///
  /// In en, this message translates to:
  /// **'GO TO CHECKOUT'**
  String get goToCheckout;

  /// No description provided for @architectureOfScent.
  ///
  /// In en, this message translates to:
  /// **'Architecture of Scent'**
  String get architectureOfScent;

  /// No description provided for @architectureOfScentDesc.
  ///
  /// In en, this message translates to:
  /// **'A journey through layers of scent, discovering unique notes crafted with precision.'**
  String get architectureOfScentDesc;

  /// No description provided for @heart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get heart;

  /// No description provided for @base.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get base;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @trialSize.
  ///
  /// In en, this message translates to:
  /// **'TRIAL SIZE'**
  String get trialSize;

  /// No description provided for @informationPending.
  ///
  /// In en, this message translates to:
  /// **'Information pending...'**
  String get informationPending;

  /// No description provided for @verifiedBuyer.
  ///
  /// In en, this message translates to:
  /// **'Verified Buyer'**
  String get verifiedBuyer;

  /// No description provided for @failedLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedLoadReviews;

  /// No description provided for @verifiedReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verified reviews'**
  String verifiedReviewsCount(int count);

  /// No description provided for @peopleFoundHelpful.
  ///
  /// In en, this message translates to:
  /// **'{count} people found helpful'**
  String peopleFoundHelpful(int count);

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String yearsAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String monthsAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String weeksAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @memberDiscount.
  ///
  /// In en, this message translates to:
  /// **'Member Discount'**
  String get memberDiscount;

  /// No description provided for @pleaseSelectItems.
  ///
  /// In en, this message translates to:
  /// **'PLEASE SELECT ITEMS'**
  String get pleaseSelectItems;

  /// No description provided for @discountAppliedWithPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% discount applied'**
  String discountAppliedWithPercent(int percent);

  /// No description provided for @removeCode.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeCode;

  /// No description provided for @enterPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get enterPromoCode;

  /// No description provided for @availablePromoCodes.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE PROMO CODES'**
  String get availablePromoCodes;

  /// No description provided for @useCode.
  ///
  /// In en, this message translates to:
  /// **'USE'**
  String get useCode;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear entire cart?'**
  String get clearCartConfirm;

  /// No description provided for @clearCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will remove all items you have selected.'**
  String get clearCartSubtitle;

  /// No description provided for @keepItems.
  ///
  /// In en, this message translates to:
  /// **'Keep items'**
  String get keepItems;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @emptyCheckoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Add items to cart before proceeding to checkout.'**
  String get emptyCheckoutMessage;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'ORDER SUMMARY'**
  String get orderSummary;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @estDelivery.
  ///
  /// In en, this message translates to:
  /// **'Est. Delivery'**
  String get estDelivery;

  /// No description provided for @totalUpper.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalUpper;

  /// No description provided for @paymentMethodUpper.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethodUpper;

  /// No description provided for @itemsUpper.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get itemsUpper;

  /// No description provided for @defaultUpper.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultUpper;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @checkPaymentOpen.
  ///
  /// In en, this message translates to:
  /// **'Check / Reopen payment'**
  String get checkPaymentOpen;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get securePayment;

  /// No description provided for @expressShipping.
  ///
  /// In en, this message translates to:
  /// **'Express Shipping'**
  String get expressShipping;

  /// No description provided for @dayReturn7.
  ///
  /// In en, this message translates to:
  /// **'7-day Return'**
  String get dayReturn7;

  /// No description provided for @returnToCart.
  ///
  /// In en, this message translates to:
  /// **'Return to Cart'**
  String get returnToCart;

  /// No description provided for @checkoutEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your checkout is empty.'**
  String get checkoutEmptyTitle;

  /// No description provided for @successfullyOwned.
  ///
  /// In en, this message translates to:
  /// **'SUCCESSFULLY OWNED'**
  String get successfullyOwned;

  /// No description provided for @authenticScent.
  ///
  /// In en, this message translates to:
  /// **'AUTHENTIC SCENT'**
  String get authenticScent;

  /// No description provided for @molecularSignature.
  ///
  /// In en, this message translates to:
  /// **'MOLECULAR SIGNATURE'**
  String get molecularSignature;

  /// No description provided for @molecularSignatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique digital identifier for your olfactory profile.'**
  String get molecularSignatureDesc;

  /// No description provided for @fullStory.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT STORY'**
  String get fullStory;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'BASIC INFO'**
  String get basicInfo;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get nameHint;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'MORE DETAILS'**
  String get moreDetails;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @birthdayHint.
  ///
  /// In en, this message translates to:
  /// **'Select your birthday'**
  String get birthdayHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login.'**
  String get pleaseLogin;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get enterName;

  /// No description provided for @addressBook.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS BOOK'**
  String get addressBook;

  /// No description provided for @defaultAddressUpper.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT ADDRESS'**
  String get defaultAddressUpper;

  /// No description provided for @otherAddressesUpper.
  ///
  /// In en, this message translates to:
  /// **'OTHER ADDRESSES'**
  String get otherAddressesUpper;

  /// No description provided for @addNewAddressUpper.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW ADDRESS'**
  String get addNewAddressUpper;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get addressDeleted;

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetail;

  /// No description provided for @returnDetail.
  ///
  /// In en, this message translates to:
  /// **'RETURN DETAIL'**
  String get returnDetail;

  /// No description provided for @returnedProducts.
  ///
  /// In en, this message translates to:
  /// **'RETURNED PRODUCTS'**
  String get returnedProducts;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @evidenceImages.
  ///
  /// In en, this message translates to:
  /// **'EVIDENCE IMAGES'**
  String get evidenceImages;

  /// No description provided for @refundConfirmed.
  ///
  /// In en, this message translates to:
  /// **'REFUND CONFIRMED'**
  String get refundConfirmed;

  /// No description provided for @adminRefundNotice.
  ///
  /// In en, this message translates to:
  /// **'ADMIN HAS ISSUED YOUR REFUND'**
  String get adminRefundNotice;

  /// No description provided for @refundedAmount.
  ///
  /// In en, this message translates to:
  /// **'REFUNDED AMOUNT'**
  String get refundedAmount;

  /// No description provided for @timeUpper.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeUpper;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add new method'**
  String get addPaymentMethod;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get recipientName;

  /// No description provided for @recipientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient\'s full name'**
  String get recipientNameHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneHint;

  /// No description provided for @deliveryNote.
  ///
  /// In en, this message translates to:
  /// **'Delivery Note (Optional)'**
  String get deliveryNote;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @provinceCity.
  ///
  /// In en, this message translates to:
  /// **'Province / City'**
  String get provinceCity;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @ward.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get ward;

  /// No description provided for @specificAddress.
  ///
  /// In en, this message translates to:
  /// **'Specific Address'**
  String get specificAddress;

  /// No description provided for @specificAddressHint.
  ///
  /// In en, this message translates to:
  /// **'House number, street name, ward, district, city'**
  String get specificAddressHint;

  /// No description provided for @otherOptions.
  ///
  /// In en, this message translates to:
  /// **'Other Options'**
  String get otherOptions;

  /// No description provided for @ghnService.
  ///
  /// In en, this message translates to:
  /// **'GHN Service'**
  String get ghnService;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Deliver during office hours, call before arriving...'**
  String get noteHint;

  /// No description provided for @setDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setDefaultAddress;

  /// No description provided for @updateAddress.
  ///
  /// In en, this message translates to:
  /// **'Update Address'**
  String get updateAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get saveAddress;

  /// No description provided for @pickProvince.
  ///
  /// In en, this message translates to:
  /// **'Pick Province'**
  String get pickProvince;

  /// No description provided for @pickDistrict.
  ///
  /// In en, this message translates to:
  /// **'Pick District'**
  String get pickDistrict;

  /// No description provided for @pickWard.
  ///
  /// In en, this message translates to:
  /// **'Pick Ward'**
  String get pickWard;

  /// No description provided for @pickService.
  ///
  /// In en, this message translates to:
  /// **'Pick Shipment Service'**
  String get pickService;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @officeLabel.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get officeLabel;

  /// No description provided for @giftLabel.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get giftLabel;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get selectProvince;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectWard.
  ///
  /// In en, this message translates to:
  /// **'Select Ward'**
  String get selectWard;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressConfirm;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found'**
  String get noAddressesFound;

  /// No description provided for @addAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Add an address to start shopping'**
  String get addAddressHint;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @returnIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Return ID'**
  String get returnIdLabel;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get cancelRequestConfirm;

  /// No description provided for @cancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cancelled successfully'**
  String get cancelSuccess;

  /// No description provided for @cancelError.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling'**
  String get cancelError;

  /// No description provided for @confirmHandoverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Handover to courier confirmed'**
  String get confirmHandoverSuccess;

  /// No description provided for @confirmHandoverError.
  ///
  /// In en, this message translates to:
  /// **'Error confirming handover'**
  String get confirmHandoverError;

  /// No description provided for @refundBankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get refundBankLabel;

  /// No description provided for @refundAccountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get refundAccountNameLabel;

  /// No description provided for @refundAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get refundAccountNumberLabel;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @noReason.
  ///
  /// In en, this message translates to:
  /// **'No reason'**
  String get noReason;

  /// No description provided for @statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS'**
  String get statusSuccess;

  /// No description provided for @supportPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup Supported'**
  String get supportPickup;

  /// No description provided for @supportShowroomReturn.
  ///
  /// In en, this message translates to:
  /// **'Please return to Showroom and update tracking.'**
  String get supportShowroomReturn;

  /// No description provided for @aiScentDna.
  ///
  /// In en, this message translates to:
  /// **'AI Scent DNA'**
  String get aiScentDna;

  /// No description provided for @suggestionMode.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Mode'**
  String get suggestionMode;

  /// No description provided for @exploreNewScents.
  ///
  /// In en, this message translates to:
  /// **'Explore new olfactory layers'**
  String get exploreNewScents;

  /// No description provided for @preferredNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred Notes'**
  String get preferredNotesLabel;

  /// No description provided for @yourUniqueDna.
  ///
  /// In en, this message translates to:
  /// **'Your unique DNA'**
  String get yourUniqueDna;

  /// No description provided for @avoidedNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Avoided Notes'**
  String get avoidedNotesLabel;

  /// No description provided for @ingredientsToAvoid.
  ///
  /// In en, this message translates to:
  /// **'Ingredients you\'d like to avoid'**
  String get ingredientsToAvoid;

  /// No description provided for @saveDnaConfig.
  ///
  /// In en, this message translates to:
  /// **'SAVE DNA CONFIG'**
  String get saveDnaConfig;

  /// No description provided for @molecularAnalysis.
  ///
  /// In en, this message translates to:
  /// **'MOLECULAR ANALYSIS'**
  String get molecularAnalysis;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @daring.
  ///
  /// In en, this message translates to:
  /// **'Daring'**
  String get daring;

  /// No description provided for @aiSafeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI suggests exactly what you love.'**
  String get aiSafeSuggestion;

  /// No description provided for @aiBalancedSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI prioritizes your taste with some new notes.'**
  String get aiBalancedSuggestion;

  /// No description provided for @aiDaringSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI challenges your senses with breakout creations.'**
  String get aiDaringSuggestion;

  /// No description provided for @understandingYourDna.
  ///
  /// In en, this message translates to:
  /// **'UNDERSTANDING\nYOUR DNA'**
  String get understandingYourDna;

  /// No description provided for @dnaDescription.
  ///
  /// In en, this message translates to:
  /// **'AI Scent DNA is the key to personalizing your sense of smell, connecting instinctive preferences with the art of fragrance.'**
  String get dnaDescription;

  /// No description provided for @molecularRadar.
  ///
  /// In en, this message translates to:
  /// **'Molecular Radar'**
  String get molecularRadar;

  /// No description provided for @molecularRadarDesc.
  ///
  /// In en, this message translates to:
  /// **'5-dimensional analysis, visualizing every scent molecule that defines your identity.'**
  String get molecularRadarDesc;

  /// No description provided for @suggestionFocus.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Focus'**
  String get suggestionFocus;

  /// No description provided for @suggestionFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically filters unwanted ingredients and focuses on preferred DNA.'**
  String get suggestionFocusDesc;

  /// No description provided for @discoveryCurve.
  ///
  /// In en, this message translates to:
  /// **'Discovery Curve'**
  String get discoveryCurve;

  /// No description provided for @discoveryCurveDesc.
  ///
  /// In en, this message translates to:
  /// **'Control AI\'s breakout level, from safe steps to breakthrough experiences.'**
  String get discoveryCurveDesc;

  /// No description provided for @continueExploring.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE EXPLORING'**
  String get continueExploring;

  /// No description provided for @exploreNotes.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE NOTES'**
  String get exploreNotes;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotesHint;

  /// No description provided for @currentTrends.
  ///
  /// In en, this message translates to:
  /// **'CURRENT TRENDS'**
  String get currentTrends;

  /// No description provided for @addNewNote.
  ///
  /// In en, this message translates to:
  /// **'Add new note'**
  String get addNewNote;

  /// No description provided for @woody.
  ///
  /// In en, this message translates to:
  /// **'Woody'**
  String get woody;

  /// No description provided for @floral.
  ///
  /// In en, this message translates to:
  /// **'Floral'**
  String get floral;

  /// No description provided for @citrus.
  ///
  /// In en, this message translates to:
  /// **'Citrus'**
  String get citrus;

  /// No description provided for @spicy.
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get spicy;

  /// No description provided for @musky.
  ///
  /// In en, this message translates to:
  /// **'Musky'**
  String get musky;

  /// No description provided for @discoverYourScentSignature.
  ///
  /// In en, this message translates to:
  /// **'Let the Angel\nFind Your Signature'**
  String get discoverYourScentSignature;

  /// No description provided for @quizIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Begin an olfactory journey with the Perfume Angel to discover the scent that perfectly reflects your identity.'**
  String get quizIntroDescription;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'START NOW'**
  String get startNow;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Est: 2 mins'**
  String get estimatedTime;

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'STEP {current} / {total}'**
  String stepProgress(Object current, Object total);

  /// No description provided for @auraAnalysis.
  ///
  /// In en, this message translates to:
  /// **'THE ANGEL IS SENSING...'**
  String get auraAnalysis;

  /// No description provided for @personalizingScentExperience.
  ///
  /// In en, this message translates to:
  /// **'Guiding your soul to the realm of scents...'**
  String get personalizingScentExperience;

  /// No description provided for @processingOlfactoryData.
  ///
  /// In en, this message translates to:
  /// **'Understanding your heart\'s desires...'**
  String get processingOlfactoryData;

  /// No description provided for @matchingResonantNotes.
  ///
  /// In en, this message translates to:
  /// **'Seeking resonance from a million notes...'**
  String get matchingResonantNotes;

  /// No description provided for @identifyingPersonalSignature.
  ///
  /// In en, this message translates to:
  /// **'Sketching your unique scent signature...'**
  String get identifyingPersonalSignature;

  /// No description provided for @completingAuraAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Wrapping your unique fragrance gift...'**
  String get completingAuraAlgorithm;

  /// No description provided for @yourScentSignature.
  ///
  /// In en, this message translates to:
  /// **'The Angel\'s Gift'**
  String get yourScentSignature;

  /// No description provided for @resultsDescription.
  ///
  /// In en, this message translates to:
  /// **'From thousands of notes, the Angel has meticulously selected the most exquisite scents uniquely for your soul.'**
  String get resultsDescription;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No matching recommendations found.'**
  String get noRecommendations;

  /// No description provided for @retakeQuiz.
  ///
  /// In en, this message translates to:
  /// **'RETAKE'**
  String get retakeQuiz;

  /// No description provided for @exploreStore.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE STORE'**
  String get exploreStore;

  /// No description provided for @scentDetails.
  ///
  /// In en, this message translates to:
  /// **'SCENT DETAILS'**
  String get scentDetails;

  /// No description provided for @q1Text.
  ///
  /// In en, this message translates to:
  /// **'Who is this signature for?'**
  String get q1Text;

  /// No description provided for @q1Opt1.
  ///
  /// In en, this message translates to:
  /// **'Masculine'**
  String get q1Opt1;

  /// No description provided for @q1Opt2.
  ///
  /// In en, this message translates to:
  /// **'Feminine'**
  String get q1Opt2;

  /// No description provided for @q1Opt3.
  ///
  /// In en, this message translates to:
  /// **'Genderless'**
  String get q1Opt3;

  /// No description provided for @q2Text.
  ///
  /// In en, this message translates to:
  /// **'When will you use this scent?'**
  String get q2Text;

  /// No description provided for @q2Opt1.
  ///
  /// In en, this message translates to:
  /// **'Daily / Casual'**
  String get q2Opt1;

  /// No description provided for @q2Opt2.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get q2Opt2;

  /// No description provided for @q2Opt3.
  ///
  /// In en, this message translates to:
  /// **'Date Night'**
  String get q2Opt3;

  /// No description provided for @q2Opt4.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get q2Opt4;

  /// No description provided for @q2Opt5.
  ///
  /// In en, this message translates to:
  /// **'Special Events'**
  String get q2Opt5;

  /// No description provided for @q3Text.
  ///
  /// In en, this message translates to:
  /// **'What is your budget range?'**
  String get q3Text;

  /// No description provided for @q4Text.
  ///
  /// In en, this message translates to:
  /// **'What scent style do you prefer?'**
  String get q4Text;

  /// No description provided for @q4Opt1.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get q4Opt1;

  /// No description provided for @q4Opt2.
  ///
  /// In en, this message translates to:
  /// **'Floral'**
  String get q4Opt2;

  /// No description provided for @q4Opt3.
  ///
  /// In en, this message translates to:
  /// **'Woody'**
  String get q4Opt3;

  /// No description provided for @q4Opt4.
  ///
  /// In en, this message translates to:
  /// **'Oriental / Warm'**
  String get q4Opt4;

  /// No description provided for @q4Opt5.
  ///
  /// In en, this message translates to:
  /// **'Herbal'**
  String get q4Opt5;

  /// No description provided for @q5Text.
  ///
  /// In en, this message translates to:
  /// **'Expected longevity & sillage?'**
  String get q5Text;

  /// No description provided for @q5Opt1.
  ///
  /// In en, this message translates to:
  /// **'2-4h (Light)'**
  String get q5Opt1;

  /// No description provided for @q5Opt2.
  ///
  /// In en, this message translates to:
  /// **'4-6h (Moderate)'**
  String get q5Opt2;

  /// No description provided for @q5Opt3.
  ///
  /// In en, this message translates to:
  /// **'6-8h (Long)'**
  String get q5Opt3;

  /// No description provided for @q5Opt4.
  ///
  /// In en, this message translates to:
  /// **'8h+ (Extreme)'**
  String get q5Opt4;

  /// No description provided for @setupPreferredPayment.
  ///
  /// In en, this message translates to:
  /// **'Setup Preferred Payment'**
  String get setupPreferredPayment;

  /// No description provided for @paymentMethodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your default payment way. We focus on two smoothest options: COD and PayOS online.'**
  String get paymentMethodsDesc;

  /// No description provided for @paymentOptionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} payment options'**
  String paymentOptionsCount(Object count);

  /// No description provided for @currentPriority.
  ///
  /// In en, this message translates to:
  /// **'Current priority: {method}.'**
  String currentPriority(Object method);

  /// No description provided for @activateMethod.
  ///
  /// In en, this message translates to:
  /// **'Activate Method'**
  String get activateMethod;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get setDefault;

  /// No description provided for @confirmSettings.
  ///
  /// In en, this message translates to:
  /// **'Confirm Settings'**
  String get confirmSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @payosTitle.
  ///
  /// In en, this message translates to:
  /// **'Online via PayOS'**
  String get payosTitle;

  /// No description provided for @payosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open secure gateway for QR scan or fast transfer'**
  String get payosSubtitle;

  /// No description provided for @payosDetails.
  ///
  /// In en, this message translates to:
  /// **'Receive digital receipt instantly after payment.'**
  String get payosDetails;

  /// No description provided for @codTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash On Delivery (COD)'**
  String get codTitle;

  /// No description provided for @codSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inspect package then pay directly to courier'**
  String get codSubtitle;

  /// No description provided for @codDetails.
  ///
  /// In en, this message translates to:
  /// **'Suitable if you want to hold payment until items arrive.'**
  String get codDetails;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @noDefaultSet.
  ///
  /// In en, this message translates to:
  /// **'No default set'**
  String get noDefaultSet;

  /// No description provided for @setDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a method for faster checkout.'**
  String get setDefaultDesc;

  /// No description provided for @editPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method'**
  String get editPaymentMethod;

  /// No description provided for @editPayos.
  ///
  /// In en, this message translates to:
  /// **'Edit PayOS online'**
  String get editPayos;

  /// No description provided for @editCod.
  ///
  /// In en, this message translates to:
  /// **'Edit COD'**
  String get editCod;

  /// No description provided for @paymentEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize description, status visibility and priority in profile.'**
  String get paymentEditDesc;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get shortDescription;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status Label'**
  String get statusLabel;

  /// No description provided for @detailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Detailed Info'**
  String get detailedInfo;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Is Active'**
  String get isActive;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all config fields'**
  String get fillAllFields;

  /// No description provided for @payosNote.
  ///
  /// In en, this message translates to:
  /// **'PayOS is great for fast gateway, QR scanning or instant confirmation. COD should stay on as a fallback when needed.'**
  String get payosNote;

  /// No description provided for @loyaltyProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Program'**
  String get loyaltyProgramTitle;

  /// No description provided for @memberLabel.
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get memberLabel;

  /// No description provided for @accumulatedPoints.
  ///
  /// In en, this message translates to:
  /// **'ACCUMULATED POINTS'**
  String get accumulatedPoints;

  /// No description provided for @pointsToNextTier.
  ///
  /// In en, this message translates to:
  /// **'{count} points to next tier'**
  String pointsToNextTier(int count);

  /// No description provided for @redeemRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'REDEEM REWARDS'**
  String get redeemRewardsTitle;

  /// No description provided for @noRewardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No points-based rewards available for you yet.'**
  String get noRewardsAvailable;

  /// No description provided for @membershipTiersTitle.
  ///
  /// In en, this message translates to:
  /// **'MEMBERSHIP TIERS'**
  String get membershipTiersTitle;

  /// No description provided for @defaultTier.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultTier;

  /// No description provided for @howToStayTitle.
  ///
  /// In en, this message translates to:
  /// **'HOW TO EARN?'**
  String get howToStayTitle;

  /// No description provided for @howToStayDesc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate points through shopping and activities.'**
  String get howToStayDesc;

  /// No description provided for @howToEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'HOW TO EARN?'**
  String get howToEarnTitle;

  /// No description provided for @shoppingEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'SHOPPING BEAUTY'**
  String get shoppingEarnTitle;

  /// No description provided for @shoppingEarnDesc.
  ///
  /// In en, this message translates to:
  /// **'Every 10,000đ spent = 1 point'**
  String get shoppingEarnDesc;

  /// No description provided for @redeemEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'REDEEM BENEFITS'**
  String get redeemEarnTitle;

  /// No description provided for @redeemEarnDesc.
  ///
  /// In en, this message translates to:
  /// **'Use points (1 point = 500đ) for direct discount'**
  String get redeemEarnDesc;

  /// No description provided for @upgradeEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE CLASS'**
  String get upgradeEarnTitle;

  /// No description provided for @upgradeEarnDesc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate enough points to unlock elite privileges'**
  String get upgradeEarnDesc;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION HISTORY'**
  String get transactionHistoryTitle;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'Your journey hasn\'t started yet'**
  String get noTransactionsYet;

  /// No description provided for @orderEarnedPoints.
  ///
  /// In en, this message translates to:
  /// **'Earned points from order'**
  String get orderEarnedPoints;

  /// No description provided for @redeemedDiscount.
  ///
  /// In en, this message translates to:
  /// **'Redeemed for discount'**
  String get redeemedDiscount;

  /// No description provided for @returnedRefundPoints.
  ///
  /// In en, this message translates to:
  /// **'Refund points (Order cancelled)'**
  String get returnedRefundPoints;

  /// No description provided for @redeemNow.
  ///
  /// In en, this message translates to:
  /// **'REDEEM NOW'**
  String get redeemNow;

  /// No description provided for @claimNow.
  ///
  /// In en, this message translates to:
  /// **'CLAIM NOW'**
  String get claimNow;

  /// No description provided for @claimVoucherConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to claim this {code} voucher?'**
  String claimVoucherConfirm(String code);

  /// No description provided for @claimSuccess.
  ///
  /// In en, this message translates to:
  /// **'Claimed successfully! Code {code} is now in your wallet.'**
  String claimSuccess(String code);

  /// No description provided for @voucherDiscount.
  ///
  /// In en, this message translates to:
  /// **'VOUCHER DISCOUNT'**
  String get voucherDiscount;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until: {date}'**
  String validUntil(String date);

  /// No description provided for @paymentVnpayDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay with VNPay wallet'**
  String get paymentVnpayDesc;

  /// No description provided for @paymentMomoDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay with MoMo wallet'**
  String get paymentMomoDesc;

  /// No description provided for @paymentCodDesc.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get paymentCodDesc;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'HELLO!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I am the Perfume Angel, your companion in finding your \"destined scent\".'**
  String get welcomeSubtitle;

  /// No description provided for @aiScentDnaDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover Scent DNA'**
  String get aiScentDnaDiscover;

  /// No description provided for @aiScentDnaDiscoverSub.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze your preferences'**
  String get aiScentDnaDiscoverSub;

  /// No description provided for @giftConsultation.
  ///
  /// In en, this message translates to:
  /// **'Gift Consultation'**
  String get giftConsultation;

  /// No description provided for @giftConsultationSub.
  ///
  /// In en, this message translates to:
  /// **'Find the perfect gift for your loved ones'**
  String get giftConsultationSub;

  /// No description provided for @aiCrafting.
  ///
  /// In en, this message translates to:
  /// **'The Scent Deity is crafting...'**
  String get aiCrafting;

  /// No description provided for @aiMolecularProcessing.
  ///
  /// In en, this message translates to:
  /// **'Molecular processing...'**
  String get aiMolecularProcessing;

  /// No description provided for @promptAnalyzeDna.
  ///
  /// In en, this message translates to:
  /// **'Help me analyze my scent DNA'**
  String get promptAnalyzeDna;

  /// No description provided for @promptGiftSearch.
  ///
  /// In en, this message translates to:
  /// **'I want to find perfume as a gift'**
  String get promptGiftSearch;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Tell me what you are looking for...'**
  String get chatInputHint;

  /// No description provided for @chipSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise Me'**
  String get chipSurprise;

  /// No description provided for @chipSurprisePrompt.
  ///
  /// In en, this message translates to:
  /// **'Give me a surprise scent recommendation'**
  String get chipSurprisePrompt;

  /// No description provided for @chipUnder1m.
  ///
  /// In en, this message translates to:
  /// **'Under 1M'**
  String get chipUnder1m;

  /// No description provided for @chipUnder1mPrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest perfumes under 1 million VND'**
  String get chipUnder1mPrompt;

  /// No description provided for @chipNight.
  ///
  /// In en, this message translates to:
  /// **'Evening Scent'**
  String get chipNight;

  /// No description provided for @chipNightPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scent suitable for evening occasion'**
  String get chipNightPrompt;

  /// No description provided for @chipGift.
  ///
  /// In en, this message translates to:
  /// **'Gift Ideas'**
  String get chipGift;

  /// No description provided for @chipGiftPrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest perfumes for gifting'**
  String get chipGiftPrompt;

  /// No description provided for @chipCheaper.
  ///
  /// In en, this message translates to:
  /// **'More affordable'**
  String get chipCheaper;

  /// No description provided for @chipCheaperPrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest similar but more affordable options'**
  String get chipCheaperPrompt;

  /// No description provided for @chipSweeter.
  ///
  /// In en, this message translates to:
  /// **'Sweeter'**
  String get chipSweeter;

  /// No description provided for @chipSweeterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest a sweeter scent'**
  String get chipSweeterPrompt;

  /// No description provided for @chipOffice.
  ///
  /// In en, this message translates to:
  /// **'Office Wear'**
  String get chipOffice;

  /// No description provided for @chipOfficePrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest perfumes suitable for work'**
  String get chipOfficePrompt;

  /// No description provided for @chipMasculine.
  ///
  /// In en, this message translates to:
  /// **'More masculine'**
  String get chipMasculine;

  /// No description provided for @chipMasculinePrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest a more masculine perfume'**
  String get chipMasculinePrompt;

  /// No description provided for @chipFeminine.
  ///
  /// In en, this message translates to:
  /// **'More feminine'**
  String get chipFeminine;

  /// No description provided for @chipFemininePrompt.
  ///
  /// In en, this message translates to:
  /// **'Suggest a more feminine perfume'**
  String get chipFemininePrompt;

  /// No description provided for @paymentPayosDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan QR or bank transfer'**
  String get paymentPayosDesc;

  /// No description provided for @earnPoints.
  ///
  /// In en, this message translates to:
  /// **'Earn {points} reward points on this order'**
  String earnPoints(int points);

  /// No description provided for @homeAiBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask the Angel'**
  String get homeAiBannerTitle;

  /// No description provided for @homeAiBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Let the Angel guide you to your destined scent today.'**
  String get homeAiBannerDesc;

  /// No description provided for @askNow.
  ///
  /// In en, this message translates to:
  /// **'ASK NOW'**
  String get askNow;

  /// No description provided for @dnaMatch.
  ///
  /// In en, this message translates to:
  /// **'MATCH {percent}% WITH YOUR DNA'**
  String dnaMatch(int percent);

  /// No description provided for @productReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Review'**
  String get productReviewTitle;

  /// No description provided for @productCountHeader.
  ///
  /// In en, this message translates to:
  /// **'Product {current}/{total}'**
  String productCountHeader(int current, int total);

  /// No description provided for @pleaseSelectStars.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectStars;

  /// No description provided for @reviewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this product...'**
  String get reviewPlaceholder;

  /// No description provided for @addPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'Add photo ({count}/5)'**
  String addPhotoCount(int count);

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @alreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this product'**
  String get alreadyReviewed;

  /// No description provided for @reviewErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get reviewErrorOccurred;

  /// No description provided for @thankYouReview.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankYouReview;

  /// No description provided for @ratingVeryBad.
  ///
  /// In en, this message translates to:
  /// **'Very Bad'**
  String get ratingVeryBad;

  /// No description provided for @ratingBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get ratingBad;

  /// No description provided for @ratingNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get ratingNormal;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @selectStars.
  ///
  /// In en, this message translates to:
  /// **'Select stars'**
  String get selectStars;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStep;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'YES, CANCEL'**
  String get yesCancel;

  /// No description provided for @relatedOrder.
  ///
  /// In en, this message translates to:
  /// **'Related Order'**
  String get relatedOrder;

  /// No description provided for @redeemVoucherConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use {points} points to redeem this voucher?'**
  String redeemVoucherConfirm(int points);

  /// No description provided for @redeemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Redeemed successfully! Code {code} is now in your wallet.'**
  String redeemSuccess(String code);

  /// No description provided for @reverseLogistics.
  ///
  /// In en, this message translates to:
  /// **'REVERSE LOGISTICS'**
  String get reverseLogistics;

  /// No description provided for @auditTrail.
  ///
  /// In en, this message translates to:
  /// **'AUDIT TRAIL'**
  String get auditTrail;

  /// No description provided for @stockAdjustmentLogs.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustment Logs'**
  String get stockAdjustmentLogs;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @conversionRate.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get conversionRate;

  /// No description provided for @cancelRate.
  ///
  /// In en, this message translates to:
  /// **'Cancel Rate'**
  String get cancelRate;

  /// No description provided for @refundVolume.
  ///
  /// In en, this message translates to:
  /// **'Refund Volume'**
  String get refundVolume;

  /// No description provided for @grossRevenue.
  ///
  /// In en, this message translates to:
  /// **'GROSS REVENUE'**
  String get grossRevenue;

  /// No description provided for @transCount.
  ///
  /// In en, this message translates to:
  /// **'TRANS. COUNT'**
  String get transCount;

  /// No description provided for @aovEfficiency.
  ///
  /// In en, this message translates to:
  /// **'AOV / EFFICIENCY'**
  String get aovEfficiency;

  /// No description provided for @analyticsCommand.
  ///
  /// In en, this message translates to:
  /// **'ANALYTICS COMMAND'**
  String get analyticsCommand;

  /// No description provided for @globalNetwork.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL NETWORK'**
  String get globalNetwork;

  /// No description provided for @topPerformanceCollection.
  ///
  /// In en, this message translates to:
  /// **'TOP PERFORMANCE COLLECTION'**
  String get topPerformanceCollection;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'NO RECENT ACTIVITY'**
  String get noRecentActivity;

  /// No description provided for @noPendingReturns.
  ///
  /// In en, this message translates to:
  /// **'NO PENDING RETURNS FOUND'**
  String get noPendingReturns;

  /// No description provided for @terminateSession.
  ///
  /// In en, this message translates to:
  /// **'TERMINATE SESSION'**
  String get terminateSession;

  /// No description provided for @terminateSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from this terminal?'**
  String get terminateSessionConfirm;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'SCAN TO PAY'**
  String get scanToPay;

  /// No description provided for @loyaltyGateway.
  ///
  /// In en, this message translates to:
  /// **'LOYALTY GATEWAY'**
  String get loyaltyGateway;

  /// No description provided for @terminateRequest.
  ///
  /// In en, this message translates to:
  /// **'TERMINATE REQUEST'**
  String get terminateRequest;

  /// No description provided for @encryptionActive.
  ///
  /// In en, this message translates to:
  /// **'ENCRYPTION ACTIVE'**
  String get encryptionActive;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'CLIENT'**
  String get client;

  /// No description provided for @loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'LOYALTY POINTS'**
  String get loyaltyPoints;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get member;

  /// No description provided for @returnsHistory.
  ///
  /// In en, this message translates to:
  /// **'Returns History'**
  String get returnsHistory;

  /// No description provided for @allAteliers.
  ///
  /// In en, this message translates to:
  /// **'ALL ATELIERS'**
  String get allAteliers;

  /// No description provided for @chatStatusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get chatStatusActive;

  /// No description provided for @addToBagInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite to Bag'**
  String get addToBagInvite;

  /// No description provided for @chatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get chatHistoryTitle;

  /// No description provided for @newConsultationBtn.
  ///
  /// In en, this message translates to:
  /// **'NEW CONSULTATION'**
  String get newConsultationBtn;

  /// No description provided for @recentJourneysTitle.
  ///
  /// In en, this message translates to:
  /// **'RECENT JOURNEYS'**
  String get recentJourneysTitle;

  /// No description provided for @sinceLabel.
  ///
  /// In en, this message translates to:
  /// **'SINCE 2026'**
  String get sinceLabel;

  /// No description provided for @storyHeroSub.
  ///
  /// In en, this message translates to:
  /// **'The Intersection of'**
  String get storyHeroSub;

  /// No description provided for @storyHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Nature & Intellect'**
  String get storyHeroTitle;

  /// No description provided for @philosophyLabel.
  ///
  /// In en, this message translates to:
  /// **'OUR PHILOSOPHY'**
  String get philosophyLabel;

  /// No description provided for @philosophyQuote.
  ///
  /// In en, this message translates to:
  /// **'Scent is the most intense form of memory.'**
  String get philosophyQuote;

  /// No description provided for @philosophyDesc.
  ///
  /// In en, this message translates to:
  /// **'AURA was founded on a simple yet radical idea: that the ancient art of perfumery should be personal, precise, and profoundly intelligent.\n\nWe combined the sensitivity of world-class \"noses\" with the analytical power of advanced AI to bridge the gap between human emotion and chemical composition.'**
  String get philosophyDesc;

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'THE AURA METHOD'**
  String get methodLabel;

  /// No description provided for @methodSourcingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sourcing'**
  String get methodSourcingTitle;

  /// No description provided for @methodSourcingDesc.
  ///
  /// In en, this message translates to:
  /// **'We travel the globe to source the highest quality raw materials from sustainable estates.'**
  String get methodSourcingDesc;

  /// No description provided for @methodAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get methodAnalysisTitle;

  /// No description provided for @methodAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Our AI engine analyzes millions of sensory data points to understand human olfactory resonance.'**
  String get methodAnalysisDesc;

  /// No description provided for @methodCraftingTitle.
  ///
  /// In en, this message translates to:
  /// **'Crafting'**
  String get methodCraftingTitle;

  /// No description provided for @methodCraftingDesc.
  ///
  /// In en, this message translates to:
  /// **'Each bottle is finished by hand in our atelier, ensuring the human touch remains at our core.'**
  String get methodCraftingDesc;

  /// No description provided for @ctaStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Experience the Future\nof Fragrance.'**
  String get ctaStoryTitle;

  /// No description provided for @ctaStoryBtn.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER MY SCENT'**
  String get ctaStoryBtn;

  /// No description provided for @manageDeliveryPoints.
  ///
  /// In en, this message translates to:
  /// **'MANAGE DELIVERY POINTS'**
  String get manageDeliveryPoints;

  /// No description provided for @shippingAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'Store your delivery locations for the fastest and most convenient checkout process.'**
  String get shippingAddressDesc;

  /// No description provided for @savedAddressesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved address} other{{count} saved addresses}}'**
  String savedAddressesCount(int count);

  /// No description provided for @currentDefaultIs.
  ///
  /// In en, this message translates to:
  /// **'Current default is {label}'**
  String currentDefaultIs(String label);

  /// No description provided for @priorityRecipient.
  ///
  /// In en, this message translates to:
  /// **'Priority recipient: {name}'**
  String priorityRecipient(String name);

  /// No description provided for @canChangeBeforeCheckout.
  ///
  /// In en, this message translates to:
  /// **'. You can change it before checkout.'**
  String get canChangeBeforeCheckout;

  /// No description provided for @savedAddressesUpper.
  ///
  /// In en, this message translates to:
  /// **'SAVED ADDRESSES'**
  String get savedAddressesUpper;

  /// No description provided for @readyForDeliveryScenario.
  ///
  /// In en, this message translates to:
  /// **'Ready for any delivery scenario'**
  String get readyForDeliveryScenario;

  /// No description provided for @deliveryTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY TIPS'**
  String get deliveryTipsTitle;

  /// No description provided for @deliveryTipNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Set a default address to receive optimal shipping suggestions from Perfume GPT.'**
  String get deliveryTipNoAddress;

  /// No description provided for @deliveryTipWithAddress.
  ///
  /// In en, this message translates to:
  /// **'Perfume GPT will prioritize suggesting the best time slots and shipping methods for your {label}.'**
  String deliveryTipWithAddress(String label);

  /// No description provided for @addressFormTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addressFormTitleAdd;

  /// No description provided for @addressFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get addressFormTitleEdit;

  /// No description provided for @addressFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide accurate information to ensure your order is delivered to the right person at the right time.'**
  String get addressFormSubtitle;

  /// No description provided for @setAsDefaultAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'This address will be automatically selected when you proceed to checkout.'**
  String get setAsDefaultAddressDesc;

  /// No description provided for @errorRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get errorRequiredFields;

  /// No description provided for @defaultAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default address updated'**
  String get defaultAddressUpdated;

  /// No description provided for @addressAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'New address added successfully'**
  String get addressAddedSuccess;

  /// No description provided for @addressUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully'**
  String get addressUpdatedSuccess;

  /// No description provided for @addressDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted address {label}'**
  String addressDeletedSuccess(String label);

  /// No description provided for @notSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetLabel;

  /// No description provided for @noDefaultAddressYet.
  ///
  /// In en, this message translates to:
  /// **'No default address yet'**
  String get noDefaultAddressYet;

  /// No description provided for @payosNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'PayOS Note'**
  String get payosNoteTitle;

  /// No description provided for @paymentMethodsComboTitle.
  ///
  /// In en, this message translates to:
  /// **'PayOS & COD'**
  String get paymentMethodsComboTitle;

  /// No description provided for @scentNotes.
  ///
  /// In en, this message translates to:
  /// **'Scent Notes'**
  String get scentNotes;

  /// No description provided for @noNotesFound.
  ///
  /// In en, this message translates to:
  /// **'No scent notes found'**
  String get noNotesFound;

  /// No description provided for @technicalSpecs.
  ///
  /// In en, this message translates to:
  /// **'TECHNICAL SPECIFICATIONS'**
  String get technicalSpecs;

  /// No description provided for @longevityLabel.
  ///
  /// In en, this message translates to:
  /// **'Longevity'**
  String get longevityLabel;

  /// No description provided for @concentrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get concentrationLabel;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'HELP CENTER'**
  String get helpCenterTitle;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'HOW CAN WE HELP YOU?'**
  String get howCanWeHelp;

  /// No description provided for @searchIssueHint.
  ///
  /// In en, this message translates to:
  /// **'Search your issue...'**
  String get searchIssueHint;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FREQUENTLY ASKED QUESTIONS'**
  String get faqTitle;

  /// No description provided for @catOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get catOrders;

  /// No description provided for @catPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get catPayments;

  /// No description provided for @catShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get catShipping;

  /// No description provided for @catAiConsult.
  ///
  /// In en, this message translates to:
  /// **'AI Consulting'**
  String get catAiConsult;

  /// No description provided for @catAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get catAccount;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How to return products?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'You can send a return request within 7 days of receiving the items. Go to \"My Orders\", select the order, and press \"Request Return\".'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'How does the AI recommendation algorithm work?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Perfume GPT uses a neural system combined with data from 147 sensory points and your lifestyle to coordinate the perfect scent molecules for your identity.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'Does Perfume GPT ship internationally?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Currently we support shipping in Vietnam and Southeast Asian countries. We are expanding our global network soon.'**
  String get faq3Answer;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'CONTACT'**
  String get contactTitle;

  /// No description provided for @supportChannels.
  ///
  /// In en, this message translates to:
  /// **'ONLINE SUPPORT CHANNELS'**
  String get supportChannels;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @responseTime5m.
  ///
  /// In en, this message translates to:
  /// **'Response time ~ 5 mins'**
  String get responseTime5m;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send us an Email'**
  String get sendEmail;

  /// No description provided for @hotline247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support Hotline'**
  String get hotline247;

  /// No description provided for @freeHotline.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeHotline;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'SEND US A MESSAGE'**
  String get sendMessage;

  /// No description provided for @messageContent.
  ///
  /// In en, this message translates to:
  /// **'Message Content'**
  String get messageContent;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get sortPriceHigh;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get sortName;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'SORT BY'**
  String get sortBy;

  /// No description provided for @noVariantAvailable.
  ///
  /// In en, this message translates to:
  /// **'No variant available'**
  String get noVariantAvailable;

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @achWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achWelcomeTitle;

  /// No description provided for @achWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Join the PerfumeGPT fragrance community'**
  String get achWelcomeDesc;

  /// No description provided for @achExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scent Explorer'**
  String get achExplorerTitle;

  /// No description provided for @achExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your AI Scent Profile (Quiz)'**
  String get achExplorerDesc;

  /// No description provided for @achNoteMasterTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Master'**
  String get achNoteMasterTitle;

  /// No description provided for @achNoteMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover more than 5 characteristic notes'**
  String get achNoteMasterDesc;

  /// No description provided for @achShopperTitle.
  ///
  /// In en, this message translates to:
  /// **'Elite Shopper'**
  String get achShopperTitle;

  /// No description provided for @achShopperDesc.
  ///
  /// In en, this message translates to:
  /// **'Place your first order'**
  String get achShopperDesc;

  /// No description provided for @achReviewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Review King'**
  String get achReviewerTitle;

  /// No description provided for @achReviewerDesc.
  ///
  /// In en, this message translates to:
  /// **'Leave at least 3 detailed reviews'**
  String get achReviewerDesc;

  /// No description provided for @achievementsHeader.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENTS'**
  String get achievementsHeader;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address Label'**
  String get addressLabel;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get accountSettings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY VIEWED'**
  String get recentlyViewed;

  /// No description provided for @isHelpful.
  ///
  /// In en, this message translates to:
  /// **'WAS THIS INFORMATION HELPFUL?'**
  String get isHelpful;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @artOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Ordering Process & Tracking'**
  String get artOrdersTitle;

  /// No description provided for @artOrdersContent.
  ///
  /// In en, this message translates to:
  /// **'After choosing your favorite scent, you can place an order by following these steps:\n• Add product to cart.\n• Check quantity and volume.\n• Proceed to checkout and fill in address information.\nAll orders will be processed within 24h.'**
  String get artOrdersContent;

  /// No description provided for @artPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods & Security'**
  String get artPaymentsTitle;

  /// No description provided for @artPaymentsContent.
  ///
  /// In en, this message translates to:
  /// **'Perfume GPT currently supports 2 main payment methods to ensure safety and convenience:\n• Bank Transfer via PayOS (Supports all domestic banks via QR Code).\n• Cash on Delivery (COD).\nAll your transaction information is encrypted and securely protected via PayOS payment gateway.'**
  String get artPaymentsContent;

  /// No description provided for @artShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping Policy & Fees'**
  String get artShippingTitle;

  /// No description provided for @artShippingContent.
  ///
  /// In en, this message translates to:
  /// **'We partner with Giao Hàng Nhanh (GHN) to deliver products to you as quickly as possible:\n• Urban areas: 1-2 business days.\n• Suburbs/Other: 3-5 business days.\nShipping fees will be automatically calculated based on product weight and your delivery address via GHN system.'**
  String get artShippingContent;

  /// No description provided for @artAiTitle.
  ///
  /// In en, this message translates to:
  /// **'About Perfume GPT AI Consulting System'**
  String get artAiTitle;

  /// No description provided for @artAiContent.
  ///
  /// In en, this message translates to:
  /// **'Our AI system is not just a simple filter. It is the result of collaboration between fragrance experts and technology engineers:\n• 5-dimensional analysis: Essential, Style, Environment, Emotion, and Memory.\n• Continuous updates from actual customer data.\nAccuracy up to 98% for first-time use.'**
  String get artAiContent;

  /// No description provided for @artAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Management & Security'**
  String get artAccountTitle;

  /// No description provided for @artAccountContent.
  ///
  /// In en, this message translates to:
  /// **'To ensure benefits and accumulate reward points, you should maintain your account:\n• Update personal information in Profile.\n• Turn on 2-factor authentication for enhanced security.\nIf you forget your password, please select \"Forgot Password\" at the login screen to receive a recovery code.'**
  String get artAccountContent;
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
