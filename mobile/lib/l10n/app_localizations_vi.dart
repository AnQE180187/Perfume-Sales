// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Perfume GPT';

  @override
  String get atelierDeParfum => 'XƯỞNG NƯỚC HOA';

  @override
  String get welcomeBack => 'Chào mừng trở lại';

  @override
  String get emailAddress => 'ĐỊA CHỈ EMAIL';

  @override
  String get password => 'MẬT KHẨU';

  @override
  String get forgotPassword => 'QUÊN MẬT KHẨU?';

  @override
  String get login => 'ĐĂNG NHẬP';

  @override
  String get dontHaveAccount => 'BẠN CHƯA CÓ TÀI KHOẢN? ';

  @override
  String get createAccount => 'TẠO TÀI KHOẢN';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get error => 'Lỗi';

  @override
  String get paid => 'Đã thanh toán';

  @override
  String get pending => 'Chờ thanh toán';

  @override
  String get cancelled => 'Đã hủy';

  @override
  String get cancelUpper => 'HỦY BỎ';

  @override
  String get paymentMethodTitle => 'Phương thức thanh toán';

  @override
  String get noPaymentMethods => 'Chưa có phương thức thanh toán khả dụng.';

  @override
  String get paymentMethodSubtitle =>
      'Chọn phương thức mặc định cho đơn hàng tiếp theo';

  @override
  String get recommended => 'Đề xuất';

  @override
  String get standby => 'Dự phòng';

  @override
  String get payosNoteLong =>
      'PayOS cho phép quét QR hoặc chuyển khoản tức thì. COD phù hợp khi bạn muốn kiểm tra hàng trước khi thanh toán.';

  @override
  String get returnReasonExample => 'Ví dụ: Sản phẩm bị rò rỉ khi nhận hàng...';

  @override
  String get userCancelled => 'Người dùng đã hủy';

  @override
  String get posOutOfStock => 'Hết hàng';

  @override
  String posLowStockWarning(int count) {
    return 'Chỉ còn $count';
  }

  @override
  String posStockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get orderConfirmError => 'Không thể xác nhận đơn hàng';

  @override
  String get missingPaymentLink =>
      'Đơn đã tạo nhưng chưa có link thanh toán. Thử lại.';

  @override
  String get unableOpenPayment =>
      'Không thể mở trang thanh toán. Nhấn nút để thử lại.';

  @override
  String get paymentInstructions =>
      'Hoàn tất thanh toán trên browser, sau đó quay lại và nhấn kiểm tra.';

  @override
  String get april => 'Tháng 4';

  @override
  String get staffHome => 'Trang chủ';

  @override
  String get inventory => 'Kho hàng';

  @override
  String get pos => 'POS';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String get salesReport => 'Báo cáo bán hàng';

  @override
  String get totalRevenue => 'Tổng doanh thu';

  @override
  String get totalOrdersLabel => 'Tổng đơn';

  @override
  String get paidLabel => 'Đã TT';

  @override
  String get avgPerOrder => 'TB/đơn';

  @override
  String get pendingProcess => 'Chờ xác nhận';

  @override
  String get paymentRate => 'Tỷ lệ TT';

  @override
  String get topBestSellers => 'Top sản phẩm bán chạy';

  @override
  String get noOrdersYet => 'Chưa có đơn hàng nào';

  @override
  String get unableLoadData => 'Không thể tải dữ liệu';

  @override
  String totalOrdersCount(Object count) {
    return '$count đơn';
  }

  @override
  String get searchOrdersHint => 'Tìm mã đơn, SĐT, tên khách...';

  @override
  String get statusCancelled => 'Đã hủy';

  @override
  String get statusPaid => 'Đã thanh toán';

  @override
  String get statusPendingPayment => 'Chờ thanh toán';

  @override
  String get statusProcessing => 'Đang xử lý';

  @override
  String get statusPending => 'Chờ xác nhận';

  @override
  String get confirmReturnTitle => 'Xác nhận trả hàng';

  @override
  String confirmReturnDesc(Object code) {
    return 'Tạo yêu cầu trả hàng & hoàn tiền cho đơn $code?';
  }

  @override
  String get returnRefundLabel => 'Trả hàng / Hoàn tiền';

  @override
  String get returnSuccess => 'Đã tạo trả hàng & hoàn tiền thành công';

  @override
  String get returnError => 'Không thể xử lý trả hàng';

  @override
  String get reasonCustomerReturnCounter => 'Khách trả hàng tại quầy';

  @override
  String get ordersHistoryLabel => 'Đơn hàng';

  @override
  String get profileLabel => 'Cá nhân';

  @override
  String itemCount(int count) {
    return '$count sản phẩm';
  }

  @override
  String get repay => 'Thanh toán lại';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get guest => 'Khách';

  @override
  String get subtotal => 'Tạm tính';

  @override
  String get discount => 'Giảm giá';

  @override
  String get total => 'Tổng cộng';

  @override
  String get success => 'Thành công';

  @override
  String get no => 'Không';

  @override
  String get confirmCancelOrderTitle => 'Xác nhận hủy đơn';

  @override
  String confirmCancelOrderDesc(Object code) {
    return 'Bạn có chắc muốn hủy đơn $code? Thao tác này không thể hoàn tác.';
  }

  @override
  String cancelOrderSuccess(Object code) {
    return 'Đã hủy đơn $code';
  }

  @override
  String get cancelOrderError => 'Lỗi hủy đơn';

  @override
  String get or => 'HOẶC';

  @override
  String get google => 'GOOGLE';

  @override
  String get facebook => 'FACEBOOK';

  @override
  String get joinTheAtelier => 'Gia nhập Xưởng';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get phoneOptional => 'SỐ ĐIỆN THOẠI (KHÔNG BẮT BUỘC)';

  @override
  String get agreeToTerms => 'TÔI ĐỒNG Ý VỚI ĐIỀU KHOẢN VÀ CHÍNH SÁCH BẢO MẬT';

  @override
  String get registrationSuccessful =>
      'ĐĂNG KÝ THÀNH CÔNG. VUI LÒNG XÁC THỰC EMAIL.';

  @override
  String get pleaseFillFields => 'VUI LÒNG ĐIỀN ĐỦ THÔNG TIN';

  @override
  String get pleaseAcceptTerms => 'VUI LÒNG CHẤP NHẬN ĐIỀU KHOẢN';

  @override
  String get dnaSuccessTitle => 'KHO LƯU TRỮ DNA ĐÃ ĐƯỢC THIẾT LẬP';

  @override
  String get dnaSuccessMessage =>
      'Hệ thống đã ghi nhận thành công hồ sơ khứu giác của bạn.';

  @override
  String get dnaSuccessSubmessage =>
      'Thiên thần sẽ dẫn lối bạn khám phá những mùi hương độc bản phản ánh đúng bản sắc của riêng mình.';

  @override
  String get exploreNow => 'KHÁM PHÁ NGAY';

  @override
  String avoidedNotesWarning(Object notes) {
    return '(Tuy nhiên, có chứa nốt hương bạn muốn tránh: $notes)';
  }

  @override
  String avoidedNotesNotice(Object notes) {
    return 'Lưu ý: Có nốt hương bạn muốn tránh ($notes)';
  }

  @override
  String get dnaMatchDescription1 => 'Sản phẩm này vô cùng tương thích với ';

  @override
  String get dnaMatchDescription2 => ' mà bạn đặc biệt yêu thích.';

  @override
  String get dnaMatchScore => 'Chỉ số phù hợp DNA:';

  @override
  String get excellentScore => 'TUYỆT VỜI';

  @override
  String get unisex => 'Phi giới tính';

  @override
  String get accessDenied => 'TRUY CẬP BỊ TỪ CHỐI';

  @override
  String get pleaseProvideCredentials => 'VUI LÒNG CUNG CẤP THÔNG TIN';

  @override
  String get dnaScent => 'TẠO MÙI HƯƠNG DNA CỦA BẠN';

  @override
  String get onboarding1Title => 'NGHỆ THUẬT MÙI HƯƠNG';

  @override
  String get onboarding1Subtitle =>
      'Khám phá bản sắc nước hoa độc bản của bạn thông qua bộ sưu tập do AI tuyển chọn.';

  @override
  String get onboarding2Title => 'TUYỂN CHỌN THÔNG MINH';

  @override
  String get onboarding2Subtitle =>
      'AI phân tích hàng ngàn nốt hương để tìm ra sự hòa quyện hoàn hảo dành riêng cho bạn.';

  @override
  String get onboarding3Title => 'SỰ SANG TRỌNG VĨNH CỬU';

  @override
  String get onboarding3Subtitle =>
      'Trải nghiệm tương lai của nước hoa, được chế tác với sự xuất sắc truyền thống.';

  @override
  String get next => 'TIẾP THEO';

  @override
  String get and => 'và';

  @override
  String get more => 'khác';

  @override
  String get beginJourney => 'BẮT ĐẦU HÀNH TRÌNH';

  @override
  String get neuralArchitect => 'KIẾN TRÚC SƯ THẦN KINH';

  @override
  String get describeVision => 'MÔ TẢ Ý TƯỞNG CỦA BẠN...';

  @override
  String get welcomeMessage =>
      'Chào mừng bạn đến với Xưởng. Tôi là Kiến trúc sư Thần kinh của bạn. Hãy cho tôi biết, bạn muốn khám phá bối cảnh cảm xúc nào thông qua mùi hương hôm nay?';

  @override
  String get yourProfile => 'HỒ SƠ CỦA BẠN';

  @override
  String get atelierMember => 'THÀNH VIÊN XƯỞNG';

  @override
  String get theAtelier => 'XƯỞNG SÁNG TÁC';

  @override
  String get acquisitionHistory => 'LỊCH SỬ SỞ HỮU';

  @override
  String get curatedCollection => 'BỘ SƯU TẬP TUYỂN CHỌN';

  @override
  String get neuralDnaArchive => 'KHO LƯU TRỮ DNA THẦN KINH';

  @override
  String get system => 'HỆ THỐNG';

  @override
  String get appearance => 'GIAO DIỆN';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get concierge => 'DỊCH VỤ HỖ TRỢ';

  @override
  String get disconnectSession => 'ĐĂNG XUẤT';

  @override
  String get luminaAtelier => 'PERFUME GPT';

  @override
  String get intensity => 'ĐỘ ĐẬM ĐẶC';

  @override
  String get neuralInsight => 'THÔNG TIN THẦN KINH';

  @override
  String get scentProfile => 'CẤU TRÚC MÙI HƯƠNG';

  @override
  String get theStory => 'CÂU CHUYỆN';

  @override
  String get storyHeader => 'Câu chuyện phía sau mùi hương';

  @override
  String get storyInspiration => 'NGUỒN CẢM HỨNG';

  @override
  String get storyCraftsmanship => 'NGHỆ THUẬT CHẾ TÁC';

  @override
  String get backToProductStory => 'QUAY LẠI SẢN PHẨM';

  @override
  String get discoverNotesStory => 'KHÁM PHÁ TẦNG HƯƠNG';

  @override
  String get acquireScent => 'SỞ HỮU MÙI HƯƠNG';

  @override
  String get topNotes => 'HƯƠNG ĐẦU';

  @override
  String get heartNotes => 'HƯƠNG GIỮA';

  @override
  String get baseNotes => 'HƯƠNG CUỐI';

  @override
  String get orderAtelier => 'XÁC NHẬN ĐƠN HÀNG';

  @override
  String get yourSelection => 'LỰA CHỌN CỦA BẠN';

  @override
  String get shippingAtelier => 'GIAO HÀNG';

  @override
  String get change => 'THAY ĐỔI';

  @override
  String get paymentMethod => 'PHƯƠNG THỨC THANH TOÁN';

  @override
  String get priorityShipping => 'GIAO HÀNG ƯU TIÊN';

  @override
  String get complimentary => 'MIỄN PHÍ';

  @override
  String get totalAcquisition => 'TỔNG THANH TOÁN';

  @override
  String get confirmOrder => 'XÁC NHẬN ĐẶT HÀNG';

  @override
  String get acquisitionComplete => 'SỞ HỮU THÀNH CÔNG';

  @override
  String get orderCodified => 'THÔNG TIN ĐƠN HÀNG ĐÃ ĐƯỢC GHI NHẬN';

  @override
  String get traceOrder => 'THEO DÕI';

  @override
  String get returnToAtelier => 'QUAY LẠI XƯỞNG';

  @override
  String get shoppingCart => 'GIỎ HÀNG';

  @override
  String get yourCartEmpty => 'GIỎ HÀNG TRỐNG';

  @override
  String get discoverCollection => 'Khám phá bộ sưu tập tuyển chọn';

  @override
  String get exploreCollection => 'KHÁM PHÁ BỘ SƯU TẬP';

  @override
  String get promoCode => 'MÃ KHUYẾN MÃI';

  @override
  String get availableVouchers => 'Mã giảm giá khả dụng';

  @override
  String get close => 'ĐÓNG';

  @override
  String minOrderRequired(String amount) {
    return 'Tối thiểu $amountđ';
  }

  @override
  String get apply => 'ÁP DỤNG';

  @override
  String get proceedCheckout => 'TIẾN HÀNH THANH TOÁN';

  @override
  String get discountApplied => 'giảm giá đã áp dụng';

  @override
  String get invalidPromoCode => 'Mã khuyến mãi không hợp lệ';

  @override
  String get orderHistory => 'LỊCH SỬ ĐƠN HÀNG';

  @override
  String get orderHistoryAppear => 'Lịch sử đơn hàng sẽ xuất hiện tại đây';

  @override
  String get startShopping => 'BẮT ĐẦU MUA SẮM';

  @override
  String get orderDetails => 'CHI TIẾT ĐƠN HÀNG';

  @override
  String get orderNumber => 'MÃ ĐƠN HÀNG';

  @override
  String get orderDate => 'NGÀY ĐẶT HÀNG';

  @override
  String get orderTimeline => 'TIẾN TRÌNH ĐƠN HÀNG';

  @override
  String get trackingInformation => 'THÔNG TIN VẬN CHUYỂN';

  @override
  String get trackingNumber => 'Mã vận đơn';

  @override
  String get trackShipment => 'THEO DÕI VẬN CHUYỂN';

  @override
  String get items => 'SẢN PHẨM';

  @override
  String get shippingAddress => 'ĐỊA CHỈ GIAO HÀNG';

  @override
  String get shippingFee => 'Phí vận chuyển';

  @override
  String get free => 'Miễn phí';

  @override
  String get reorder => 'ĐẶT LẠI';

  @override
  String get cancelOrder => 'HỦY ĐƠN HÀNG';

  @override
  String get cancelOrderConfirm => 'Bạn có chắc muốn hủy đơn hàng này?';

  @override
  String get yesCancelOrder => 'CÓ, HỦY ĐƠN';

  @override
  String get orderCancelled => 'Đơn hàng đã hủy';

  @override
  String get orderPlacedSuccess => 'Đặt hàng thành công';

  @override
  String get failedToReorder => 'Đặt lại thất bại';

  @override
  String get failedToCancel => 'Hủy đơn thất bại';

  @override
  String get failedLoadOrders => 'Tải đơn hàng thất bại';

  @override
  String get failedLoadOrder => 'Tải chi tiết đơn hàng thất bại';

  @override
  String get retry => 'Thử lại';

  @override
  String get moreItems => 'sản phẩm khác';

  @override
  String get qty => 'SL';

  @override
  String get orderNumberCopied => 'Đã sao chép mã đơn hàng';

  @override
  String get orderStatusPending => 'Chờ xác nhận';

  @override
  String get orderStatusConfirmed => 'Đã xác nhận';

  @override
  String get orderStatusProcessing => 'Đang xử lý';

  @override
  String get orderStatusShipped => 'Đã giao vận';

  @override
  String get orderStatusOutForDelivery => 'Đang giao hàng';

  @override
  String get orderStatusDelivered => 'Đã giao hàng';

  @override
  String get orderStatusCancelled => 'Đã hủy';

  @override
  String get wishlistTitle => 'Yêu thích';

  @override
  String get wishlistEmptyTitle => 'DANH SÁCH YÊU THÍCH TRỐNG';

  @override
  String get wishlistEmptySubtitle =>
      'Danh sách yêu thích đang chờ mùi hương bạn thật sự yêu.';

  @override
  String get exploreFragrances => 'KHÁM PHÁ NƯỚC HOA';

  @override
  String get orderStatusRefunded => 'Đã hoàn tiền';

  @override
  String get orderDescPending =>
      'Thiên thần đang tiếp nhận yêu cầu khứu giác của bạn';

  @override
  String get orderDescConfirmed =>
      'Nghệ nhân đang bắt đầu chuẩn bị những tinh hoa';

  @override
  String get orderDescProcessing =>
      'Mùi hương của bạn đang được đóng gói một cách tỉ mỉ';

  @override
  String get orderDescShipped =>
      'Hành trình hương thơm đang trên đường tới bạn';

  @override
  String get orderDescOutForDelivery =>
      'Mùi hương đặc bản sẽ chạm ngõ nhà bạn hôm nay';

  @override
  String get orderDescDelivered =>
      'Chúc mừng bạn đã sở hữu dấu ấn mùi hương mới';

  @override
  String get orderDescCancelled => 'Đơn hàng đã được hủy bỏ khỏi hệ thống';

  @override
  String get orderDescRefunded =>
      'Tiền hoàn đã được chuyển vào tài khoản của bạn';

  @override
  String get payment => 'THANH TOÁN';

  @override
  String get selectPaymentMethod => 'CHỌN PHƯƠNG THỨC THANH TOÁN';

  @override
  String get vnpay => 'VNPay';

  @override
  String get momo => 'Momo';

  @override
  String get cod => 'Thanh toán khi nhận hàng';

  @override
  String get payNow => 'THANH TOÁN NGAY';

  @override
  String get processingPayment => 'Đang xử lý thanh toán...';

  @override
  String get paymentSuccess => 'Thanh toán thành công';

  @override
  String get paymentFailed => 'Thanh toán thất bại';

  @override
  String get paymentCancelled => 'Đã hủy thanh toán';

  @override
  String get paymentMethodPayos => 'Cổng PayOS';

  @override
  String get paymentMethodPayosDesc => 'Quét mã QR hoặc chuyển khoản ngân hàng';

  @override
  String get paymentMethodCod => 'Thanh toán khi nhận hàng (COD)';

  @override
  String get paymentMethodCodDesc => 'Thanh toán khi nhận sản phẩm';

  @override
  String get paymentMethodVnpay => 'Ví VNPay';

  @override
  String get paymentMethodMomo => 'Ví MoMo';

  @override
  String get paymentStatusPending => 'Chờ thanh toán';

  @override
  String get paymentStatusProcessing => 'Đang xử lý';

  @override
  String get paymentStatusSuccess => 'Thành công';

  @override
  String get paymentStatusFailed => 'Thanh toán thất bại';

  @override
  String get paymentStatusCancelled => 'Đã hủy';

  @override
  String get paymentStatusRefunded => 'Đã hoàn tiền';

  @override
  String get notSelected => 'Chưa chọn';

  @override
  String get exclusiveOffer => 'ƯU ĐÃI ĐẶC QUYỀN';

  @override
  String get taxVat => 'Thuế (VAT)';

  @override
  String get incTaxLabel => 'Đã bao gồm các loại thuế';

  @override
  String get totalAmountUpper => 'TỔNG THANH TOÁN';

  @override
  String get productValue => 'Giá trị sản phẩm';

  @override
  String get addShippingAddress => 'Thêm địa chỉ giao hàng';

  @override
  String get defaultLabel => 'Mặc định';

  @override
  String get selectShippingAddress => 'Chọn địa chỉ giao hàng';

  @override
  String get syncAccountDesc =>
      'Danh sách này được đồng bộ trực tiếp từ tài khoản của bạn.';

  @override
  String get noAddressFound =>
      'Bạn chưa có địa chỉ. Hãy thêm địa chỉ trước khi đặt hàng.';

  @override
  String get manageAddresses => 'Quản lý địa chỉ';

  @override
  String get openAddressManager => 'Mở màn quản lý địa chỉ';

  @override
  String get searchFragrance => 'TÌM KIẾM HƯƠNG THƠM...';

  @override
  String get personalizedSelection => 'LỰA CHỌN DÀNH RIÊNG CHO BẠN';

  @override
  String get tailoredRecommendations => 'GỢI Ý PHÙ HỢP VỚI BẠN';

  @override
  String get viewCollection => 'Xem tất cả';

  @override
  String get eauDeParfum => 'NƯỚC HOA EAU DE PARFUM';

  @override
  String get rating => 'đánh giá';

  @override
  String get noReviews => 'Chưa có đánh giá';

  @override
  String get viewReviews => 'Xem review';

  @override
  String get addToCart => 'THÊM VÀO GIỎ HÀNG';

  @override
  String get variantNotFound => 'Không tìm thấy phiên bản sản phẩm phù hợp.';

  @override
  String get addedToCart => 'Đã thêm vào giỏ hàng';

  @override
  String get viewCart => 'Xem giỏ';

  @override
  String get failedAddToCart => 'Không thể thêm vào giỏ';

  @override
  String get notifications => 'Thông báo';

  @override
  String get notificationSettings => 'Cài đặt thông báo';

  @override
  String get notificationSubtitle =>
      'Theo dõi đơn hàng, ưu đãi riêng và hoạt động tài khoản.';

  @override
  String get noNotifications => 'Không có thông báo nào';

  @override
  String get markAllRead => 'Đánh dấu đã đọc';

  @override
  String get readAll => 'Đọc hết';

  @override
  String get allNotificationsRead => 'Bạn đã đọc hết thông báo';

  @override
  String unreadNotifications(int count) {
    return 'Bạn có $count thông báo chưa đọc';
  }

  @override
  String get updateNotifications => 'Hãy cập nhật ngay những ưu đãi mới nhất';

  @override
  String get orderUpdates => 'Cập nhật đơn hàng';

  @override
  String get orderUpdatesSub => 'Giao hàng, chuẩn bị đơn và thanh toán';

  @override
  String get offersAndGifts => 'Ưu đãi và quà tặng';

  @override
  String get offersAndGiftsSub =>
      'Ưu đãi thành viên, gói giới hạn và mã giảm giá';

  @override
  String get accountActivity => 'Hoạt động tài khoản';

  @override
  String get accountActivitySub => 'Thông báo hàng về và bảo mật tài khoản';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get all => 'Tất cả';

  @override
  String get filterUnread => 'Chưa đọc';

  @override
  String get filterOrders => 'Đơn hàng';

  @override
  String get filterOffers => 'Ưu đãi';

  @override
  String get filterAccount => 'Tài khoản';

  @override
  String get latest => 'MỚI NHẤT';

  @override
  String get older => 'TRƯỚC ĐÓ';

  @override
  String get paymentSummary => 'TÓM TẮT THANH TOÁN';

  @override
  String get totalAmount => 'Tổng số tiền';

  @override
  String get shippingAddressUpper => 'ĐỊA CHỈ GIAO HÀNG';

  @override
  String get contactSupport => 'LIÊN HỆ HỖ TRỢ';

  @override
  String get returnRequest => 'Trả hàng / Hoàn tiền';

  @override
  String get supportContactMessage => 'Bộ phận hỗ trợ sẽ liên hệ bạn sớm nhất.';

  @override
  String get trackOrderUpper => 'THEO DÕI ĐƠN HÀNG';

  @override
  String get buyNow => 'MUA NGAY';

  @override
  String get freeReturns => 'Đổi trả miễn phí trong 7 ngày';

  @override
  String get checkingPayment => 'Đang kiểm tra...';

  @override
  String get unavailable => 'Không khả dụng';

  @override
  String get placedOn => 'Đặt ngày';

  @override
  String get ordersActive => 'Đang xử lý';

  @override
  String get ordersCompleted => 'Hoàn thành';

  @override
  String get ordersReturns => 'Hoàn trả';

  @override
  String get ordersCancelled => 'Đã hủy';

  @override
  String get paymentStatusPaid => 'Hoàn tất thanh toán';

  @override
  String get returnRequestTitle => 'Yêu cầu trả hàng';

  @override
  String get selectReturnItems => 'Chọn sản phẩm cần trả';

  @override
  String get returnReason => 'Lý do trả hàng';

  @override
  String get returnReasonHint => 'Mô tả chi tiết tình trạng sản phẩm...';

  @override
  String get refundInfo => 'Thông tin nhận hoàn tiền';

  @override
  String get bankName => 'Ngân hàng / Ví điện tử';

  @override
  String get bankNameHint => 'VD: MB Bank, Momo...';

  @override
  String get accountNumber => 'Số tài khoản / Số điện thoại';

  @override
  String get accountName => 'Chủ tài khoản';

  @override
  String get accountNameHint => 'NGUYEN VAN A';

  @override
  String get evidenceTitle => 'Chứng cứ thực tế';

  @override
  String get photoEvidence => 'Hình ảnh (Ít nhất 3 ảnh)';

  @override
  String get videoEvidence => 'Video (3s - 60s)';

  @override
  String get addPhoto => 'Thêm ảnh';

  @override
  String get addVideo => 'Thêm video';

  @override
  String get submitReturn => 'Gửi yêu cầu trả hàng';

  @override
  String get errorSelectItems => 'Vui lòng chọn sản phẩm cần trả';

  @override
  String get errorReason => 'Vui lòng nhập lý do trả hàng';

  @override
  String get errorBankInfo => 'Vui lòng nhập đầy đủ thông tin thanh toán';

  @override
  String get errorPhotoCount => 'Vui lòng cung cấp ít nhất 3 hình ảnh';

  @override
  String get errorVideoMissing => 'Vui lòng cung cấp 1 video minh chứng';

  @override
  String get returnPolicyNote =>
      'Lưu ý: Sản phẩm phải còn nguyên tem mác và chưa qua sử dụng.';

  @override
  String get reasonDamaged => 'Hàng hư hỏng / Chai/lọ bị vỡ';

  @override
  String get reasonWrongItem => 'Gửi sai sản phẩm';

  @override
  String get reasonScentPreference => 'Mùi hương không phù hợp với sở thích';

  @override
  String get reasonColorMismatch => 'Màu/sắc tố không đúng như mong đợi';

  @override
  String get reasonExpired => 'Sản phẩm gần hết hạn sử dụng';

  @override
  String get reasonQualityNotAsExpected => 'Chất lượng không như kỳ vọng';

  @override
  String get reasonChangeOfMind => 'Thay đổi ý định không muốn mua';

  @override
  String get returnCategoryStoreFault =>
      'Lỗi của Cửa Hàng (Hoàn toàn bộ + phí ship)';

  @override
  String get returnCategoryOther =>
      'Lý Do Khác (Hoàn sản phẩm, không hoàn phí ship)';

  @override
  String get returnProcessNotice =>
      'Yêu cầu của bạn sẽ được xử lý trong vòng 24-48h';

  @override
  String get returnRequestSuccess => 'Gửi yêu cầu thành công';

  @override
  String get returnSuccessSubtitle => 'Yêu cầu của bạn đang được xem xét';

  @override
  String get viewReturnDetails => 'Xem chi tiết yêu cầu';

  @override
  String get returnToHome => 'Quay lại trang chủ';

  @override
  String get returnStatusRequested => 'Yêu cầu mới';

  @override
  String get returnStatusReviewing => 'Đang xem xét';

  @override
  String get returnStatusApproved => 'Đã chấp nhận';

  @override
  String get returnStatusReturning => 'Đang gửi hàng';

  @override
  String get returnStatusReceived => 'Đã nhận hàng';

  @override
  String get returnStatusRefunding => 'Đang hoàn tiền';

  @override
  String get returnStatusCompleted => 'Đã hoàn tất';

  @override
  String get returnStatusRejected => 'Bị từ chối';

  @override
  String get returnStatusRejectedAfterReturn => 'Bị từ chối khi nhận hàng';

  @override
  String get returnStatusCancelled => 'Đã hủy';

  @override
  String get returnStep1 => 'Chọn sản phẩm';

  @override
  String get returnStep2 => 'Chi tiết';

  @override
  String get returnStep3 => 'Minh chứng';

  @override
  String get returnNext => 'Tiếp tục';

  @override
  String get returnBack => 'Quay lại';

  @override
  String get returnGuidanceTitle => 'Hướng dẫn trả hàng';

  @override
  String get returnGuidanceStep1 => 'Chọn các sản phẩm bạn muốn hoàn trả';

  @override
  String get returnGuidanceStep2 => 'Cung cấp lý do và tài khoản nhận tiền';

  @override
  String get returnGuidanceStep3 =>
      'Tải lên ít nhất 3 ảnh và 1 video minh chứng rõ nét';

  @override
  String get returnEvidenceTip1 => 'Chụp rõ các mặt của sản phẩm';

  @override
  String get returnEvidenceTip2 => 'Quay video khui hàng hoặc lỗi';

  @override
  String get shipmentTitle => 'Thông tin vận chuyển';

  @override
  String get ghnPickupNotice => 'GHN sẽ đến lấy hàng tại địa chỉ của bạn';

  @override
  String get ghnPickupDesc => 'Vui lòng bàn giao gói hàng cho bưu tá';

  @override
  String get trackMovement => 'Theo dõi lộ trình vận chuyển';

  @override
  String get confirmHandover => 'Xác nhận đã gửi hàng';

  @override
  String get submitShipment => 'Gửi thông tin vận chuyển';

  @override
  String get refundNoticeTitle => 'ĐANG XỬ LÝ HOÀN TIỀN';

  @override
  String get refundNoticeDesc =>
      'Chúng tôi đã nhận được sản phẩm trả lại. Bộ phận tài chính sẽ tiến hành lệnh hoàn tiền vào tài khoản của bạn trong vòng 24 giờ làm việc.';

  @override
  String get refundSuccessTitle => 'HOÀN TIỀN THÀNH CÔNG';

  @override
  String get refundSuccessSub => 'ADMIN ĐÃ CHUYỂN KHOẢN VÀO TÀI KHOẢN CỦA BẠN';

  @override
  String get refundAmountLabel => 'SỐ TIỀN ĐÃ HOÀN';

  @override
  String get refundTimeLabel => 'THỜI GIAN';

  @override
  String get receiptImageHeader => 'HÌNH ẢNH HÓA ĐƠN CHUYỂN KHOẢN';

  @override
  String get resetDna => 'Thiết lập lại DNA';

  @override
  String get resetDnaConfirm =>
      'Bạn có chắc chắn muốn thiết lập lại toàn bộ sở thích mùi hương về mặc định không?';

  @override
  String get dnaResetSuccess => 'Cấu hình DNA đã được thiết lập lại';

  @override
  String get reset => 'Làm mới';

  @override
  String get settings => 'Cài đặt';

  @override
  String get appSettings => 'THÔNG TIN ỨNG DỤNG';

  @override
  String get support => 'HỖ TRỢ';

  @override
  String get legal => 'PHÁP LÝ';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get helpCenter => 'Trung tâm trợ giúp';

  @override
  String get contactUs => 'Liên hệ với chúng tôi';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get termsOfService => 'Điều khoản sử dụng';

  @override
  String get version => 'Phiên bản';

  @override
  String get scentClub => 'Câu lạc bộ Mùi hương';

  @override
  String get fragranceLibrary => 'Thư viện nước hoa';

  @override
  String get boutiques => 'Hệ thống cửa hàng';

  @override
  String get scentQuiz => 'Quiz AI';

  @override
  String get exclusiveCollection => 'Bộ sưu tập độc quyền';

  @override
  String get journal => 'Tạp chí';

  @override
  String get ingredientsDictionary => 'Từ điển thành phần';

  @override
  String get giftService => 'Dịch vụ quà tặng';

  @override
  String get brandStory => 'Câu chuyện thương hiệu';

  @override
  String get brand => 'Thương hiệu';

  @override
  String get supportConcierge => 'Hỗ trợ tư vấn';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get searchHint => 'Tìm kiếm mùi hương...';

  @override
  String get memberPlatinum => 'THÀNH VIÊN BẠCH KIM';

  @override
  String get memberGold => 'THÀNH VIÊN VÀNG';

  @override
  String get memberSilver => 'THÀNH VIÊN BẠC';

  @override
  String get memberStandard => 'THÀNH VIÊN';

  @override
  String get loyaltyProgram => 'Khách hàng thân thiết';

  @override
  String get loading => 'Đang tải...';

  @override
  String get startPoints => 'Bắt đầu tích điểm ngay';

  @override
  String get scentProfileSoon => 'Hồ sơ mùi hương chi tiết sẽ sớm có mặt';

  @override
  String get loginToViewProfile => 'Vui lòng đăng nhập để xem hồ sơ của bạn';

  @override
  String get pointsLabel => 'điểm';

  @override
  String get tierLabel => 'Hạng';

  @override
  String get logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get errorLoadingProfile => 'Lỗi khi tải hồ sơ';

  @override
  String get accountManagement => 'QUẢN LÝ TÀI KHOẢN';

  @override
  String get myOrders => 'Đơn hàng của tôi';

  @override
  String get shippingAddresses => 'Địa chỉ nhận hàng';

  @override
  String get paymentAndCards => 'Thanh toán & Thẻ';

  @override
  String get aiScentPreferences => 'Tùy chọn mùi hương AI';

  @override
  String get searchExploreHint => 'Tìm thương hiệu, nốt hương hoặc cảm xúc...';

  @override
  String get topRated => 'ĐÁNH GIÁ CAO';

  @override
  String get navHome => 'TRANG CHỦ';

  @override
  String get navExplore => 'KHÁM PHÁ';

  @override
  String get navAlerts => 'THÔNG BÁO';

  @override
  String get navProfile => 'CÁ NHÂN';

  @override
  String get scentFamily => 'Dòng hương';

  @override
  String get usageOccasion => 'Dịp sử dụng';

  @override
  String get priceRange => 'Khoảng giá';

  @override
  String get featuredScents => 'Hương thơm nổi bật';

  @override
  String get searchResults => 'Kết quả tìm kiếm';

  @override
  String get productsFound => 'sản phẩm';

  @override
  String get clearFilter => 'Xóa lọc';

  @override
  String get noProductsFound => 'Không tìm thấy sản phẩm phù hợp';

  @override
  String get searchExploreHintHome =>
      'Tìm thương hiệu, nốt hương hoặc cảm xúc...';

  @override
  String get headlineElevate => 'Nâng tầm ';

  @override
  String get headlineSignature => 'dấu ấn';

  @override
  String get headlineUniqueScent => '\nhương riêng của bạn';

  @override
  String get aiScentSignature => 'AI SCENT SIGNATURE';

  @override
  String get uniqueScentSignature => 'Dấu ấn mùi hương riêng biệt';

  @override
  String get exploreCta => 'KHÁM PHÁ';

  @override
  String get aiSelection => 'AI TUYỂN CHỌN';

  @override
  String get myProfile => 'HỒ SƠ CỦA TÔI';

  @override
  String get cart => 'Giỏ hàng';

  @override
  String get allProducts => 'TẤT CẢ SẢN PHẨM';

  @override
  String get trackOrderCta => 'Theo dõi đơn';

  @override
  String get viewOffers => 'Xem ưu đãi';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String get viewReview => 'Đánh giá';

  @override
  String get categoryOrders => 'ĐƠN HÀNG';

  @override
  String get categoryOffers => 'ƯU ĐÃI';

  @override
  String get categoryAccount => 'TÀI KHOẢN';

  @override
  String get returnCode => 'Mã trả hàng';

  @override
  String get returnDetails => 'Chi tiết trả hàng';

  @override
  String get review => 'Đánh giá';

  @override
  String get reviewed => 'Đã đánh giá';

  @override
  String get listedPrice => 'GIÁ NIÊM YẾT';

  @override
  String get selectSize => 'Chọn dung tích';

  @override
  String get aiScentAnalysis => 'Phân tích mùi hương AI';

  @override
  String get scentStructure => 'Cấu trúc mùi hương';

  @override
  String get viewAll => 'XEM TẤT CẢ';

  @override
  String get topNotesDesc => 'Tươi sáng và nhẹ nhàng';

  @override
  String get heartNotesDesc => 'Đậm đà và đa tầng';

  @override
  String get baseNotesDesc => 'Sâu lắng và bền lâu';

  @override
  String get readMore => 'Đọc thêm';

  @override
  String get readMoreUpper => 'ĐỌC THÊM';

  @override
  String get readLess => 'Thu gọn';

  @override
  String readTime(int count) {
    return '$count PHÚT ĐỌC';
  }

  @override
  String get aiScentAnalysisDesc1 =>
      'Chúng tôi đề xuất sản phẩm này dựa trên sự yêu thích của bạn với nốt hương ';

  @override
  String get aiScentAnalysisDesc2 =>
      '. Sự kết hợp hoàn hảo giữa các tầng hương này sẽ mang lại trải nghiệm tinh tế, thanh tao và lưu hương bền lâu trên làn da bạn.';

  @override
  String get perfumeGptInsight => 'GÓC NHÌN PERFUMEGPT';

  @override
  String get noAiSummary => 'Chưa có tổng hợp AI cho sản phẩm này.';

  @override
  String get noReviewsYet => 'Chưa có đánh giá nào cho sản phẩm này.';

  @override
  String get allReviews => 'Tất cả đánh giá';

  @override
  String get withImages => 'Có hình ảnh';

  @override
  String get havePromoCode => 'Bạn có mã khuyến mãi?';

  @override
  String get notCalculated => 'Chưa tính';

  @override
  String get estSubtotal => 'TỔNG TIỀN TẠM TÍNH';

  @override
  String get shippingFeeNotice => 'Phí vận chuyển sẽ được tính tại bước sau';

  @override
  String get goToCheckout => 'ĐI ĐẾN THANH TOÁN';

  @override
  String get architectureOfScent => 'Kiến trúc mùi hương';

  @override
  String get architectureOfScentDesc =>
      'Hành trình xuyên qua các tầng hương, khám phá những nốt hương độc bản được chế tác công phu.';

  @override
  String get heart => 'Hương giữa';

  @override
  String get base => 'Hương cuối';

  @override
  String get top => 'Hương đầu';

  @override
  String get bestValue => 'TIẾT KIỆM NHẤT';

  @override
  String get trialSize => 'DÙNG THỬ';

  @override
  String get informationPending => 'Thông tin đang cập nhật...';

  @override
  String get verifiedBuyer => 'Người mua xác thực';

  @override
  String get failedLoadReviews => 'Không thể tải đánh giá';

  @override
  String verifiedReviewsCount(int count) {
    return '$count đánh giá đã xác thực';
  }

  @override
  String peopleFoundHelpful(int count) {
    return '$count người thấy hữu ích';
  }

  @override
  String get helpful => 'Hữu ích';

  @override
  String get report => 'Báo cáo';

  @override
  String get reportReasonHint => 'Lý do bạn báo cáo đánh giá này?';

  @override
  String get reportSuccess => 'Đã gửi báo cáo thành công';

  @override
  String get helpfulSuccess => 'Cảm ơn bạn đã phản hồi';

  @override
  String yearsAgo(int count) {
    return '$count năm trước';
  }

  @override
  String monthsAgo(int count) {
    return '$count tháng trước';
  }

  @override
  String weeksAgo(int count) {
    return '$count tuần trước';
  }

  @override
  String daysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String hoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String get justNow => 'Vừa xong';

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get memberDiscount => 'Giảm giá hội viên';

  @override
  String get pleaseSelectItems => 'HÃY CHỌN SẢN PHẨM';

  @override
  String discountAppliedWithPercent(int percent) {
    return 'Giảm $percent% đã được áp dụng';
  }

  @override
  String get removeCode => 'Xóa mã';

  @override
  String get enterPromoCode => 'Nhập mã giảm giá';

  @override
  String get availablePromoCodes => 'MÃ KHUYẾN MÃI CÓ SẴN';

  @override
  String get useCode => 'DÙNG';

  @override
  String get clearCartConfirm => 'Xóa toàn bộ giỏ hàng?';

  @override
  String get clearCartSubtitle =>
      'Thao tác này sẽ xóa tất cả sản phẩm bạn đã chọn.';

  @override
  String get keepItems => 'Giữ lại sản phẩm';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get emptyCheckoutMessage =>
      'Hãy thêm sản phẩm vào giỏ hàng trước khi tiến hành thanh toán.';

  @override
  String get orderSummary => 'TÓM TẮT ĐƠN HÀNG';

  @override
  String get products => 'Sản phẩm';

  @override
  String get estDelivery => 'Dự kiến nhận hàng';

  @override
  String get totalUpper => 'TỔNG';

  @override
  String get paymentMethodUpper => 'PHƯƠNG THỨC THANH TOÁN';

  @override
  String get itemsUpper => 'SẢN PHẨM';

  @override
  String get defaultUpper => 'MẶC ĐỊNH';

  @override
  String get placeOrder => 'Đặt hàng';

  @override
  String get checkPaymentOpen => 'Kiểm tra / mở lại thanh toán';

  @override
  String get securePayment => 'Thanh toán bảo mật';

  @override
  String get expressShipping => 'Giao hàng hỏa tốc';

  @override
  String get dayReturn7 => '7 ngày hoàn trả';

  @override
  String get returnToCart => 'Quay lại giỏ hàng';

  @override
  String get checkoutEmptyTitle => 'Trang thanh toán của bạn đang trống.';

  @override
  String get successfullyOwned => 'SỞ HỮU THÀNH CÔNG';

  @override
  String get authenticScent => 'MÙI HƯƠNG NGUYÊN BẢN';

  @override
  String get molecularSignature => 'CHỮ KÝ PHÂN TỬ';

  @override
  String get molecularSignatureDesc =>
      'Mã định danh kỹ thuật số duy nhất cho hồ sơ mùi hương của bạn.';

  @override
  String get orderIdLabel => 'MÃ ĐƠN HÀNG';

  @override
  String get estDeliveryDate => 'DỰ KIẾN GIAO HÀNG';

  @override
  String get orderConfirmationNotice =>
      'Đơn hàng của bạn sẽ được xác nhận trong vòng 24 giờ tới.';

  @override
  String get fullStory => 'CÂU CHUYỆY SẢN PHẨM';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String minutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get basicInfo => 'THÔNG TIN CƠ BẢN';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get nameHint => 'Họ và tên của bạn';

  @override
  String get moreDetails => 'CHI TIẾT THÊM';

  @override
  String get gender => 'GIỚI TÍNH';

  @override
  String get male => 'Nam';

  @override
  String get female => 'Nữ';

  @override
  String get other => 'Khác';

  @override
  String get birthday => 'Ngày sinh nhật';

  @override
  String get birthdayHint => 'Chọn ngày sinh của bạn';

  @override
  String get saveChanges => 'LƯU THAY ĐỔI';

  @override
  String get profileUpdated => 'Hồ sơ đã được cập nhật thành công';

  @override
  String get updateFailed => 'Cập nhật thất bại';

  @override
  String get pleaseLogin => 'Vui lòng đăng nhập.';

  @override
  String get enterName => 'Vui lòng nhập tên';

  @override
  String get addressBook => 'SỔ ĐỊA CHỈ';

  @override
  String get defaultAddressUpper => 'ĐỊA CHỈ MẶC ĐỊNH';

  @override
  String get otherAddressesUpper => 'ĐỊA CHỈ KHÁC';

  @override
  String get addNewAddressUpper => 'THÊM ĐỊA CHỈ MỚI';

  @override
  String get addressDeleted => 'Đã xóa địa chỉ thành công';

  @override
  String get orderDetail => 'Chi tiết đơn hàng';

  @override
  String get returnDetail => 'CHI TIẾT TRẢ HÀNG';

  @override
  String get returnedProducts => 'SẢN PHẨM TRẢ';

  @override
  String get quantity => 'Số lượng';

  @override
  String get evidenceImages => 'HÌNH ẢNH MINH CHỨNG';

  @override
  String get refundConfirmed => 'HOÀN TIỀN ĐÃ XÁC NHẬN';

  @override
  String get adminRefundNotice => 'ADMIN ĐÃ CHUYỂN TIỀN HOÀN CHO BẠN';

  @override
  String get refundedAmount => 'SỐ TIỀN HOÀN';

  @override
  String get timeUpper => 'THỜI GIAN';

  @override
  String get paymentMethods => 'Phương thức thanh toán';

  @override
  String get addPaymentMethod => 'Thêm phương thức mới';

  @override
  String get editAddress => 'Chỉnh sửa địa chỉ';

  @override
  String get addNewAddress => 'Thêm địa chỉ mới';

  @override
  String get category => 'Phân loại';

  @override
  String get recipientName => 'Thông tin cá nhân';

  @override
  String get recipientNameHint => 'Nhập họ và tên người nhận';

  @override
  String get phone => 'Số điện thoại';

  @override
  String get phoneHint => 'Nhập số điện thoại';

  @override
  String get deliveryNote => 'Ghi chú giao hàng (Tùy chọn)';

  @override
  String get location => 'Vị trí';

  @override
  String get provinceCity => 'Tỉnh / Thành phố';

  @override
  String get district => 'Quận / Huyện';

  @override
  String get ward => 'Phường / Xã';

  @override
  String get specificAddress => 'Địa chỉ cụ thể';

  @override
  String get specificAddressHint =>
      'Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố';

  @override
  String get otherOptions => 'Tùy chọn khác';

  @override
  String get ghnService => 'Dịch vụ GHN';

  @override
  String get noteHint => 'Ví dụ: Giao giờ hành chính, gọi trước khi đến...';

  @override
  String get setDefaultAddress => 'Đặt làm địa chỉ mặc định';

  @override
  String get updateAddress => 'Cập nhật địa chỉ';

  @override
  String get saveAddress => 'Lưu địa chỉ';

  @override
  String get pickProvince => 'Chọn Tỉnh / Thành phố';

  @override
  String get pickDistrict => 'Chọn Quận / Huyện';

  @override
  String get pickWard => 'Chọn Phường / Xã';

  @override
  String get pickService => 'Chọn dịch vụ vận chuyển';

  @override
  String get homeLabel => 'Nhà riêng';

  @override
  String get officeLabel => 'Văn phòng';

  @override
  String get giftLabel => 'Quà tặng';

  @override
  String get hotelLabel => 'Khách sạn';

  @override
  String get schoolLabel => 'Trường học';

  @override
  String get cafeLabel => 'Cửa hàng';

  @override
  String get otherLabel => 'Khác';

  @override
  String get selectProvince => 'Chọn Tỉnh / Thành phố';

  @override
  String get selectDistrict => 'Chọn Quận / Huyện';

  @override
  String get selectWard => 'Chọn Phường / Xã';

  @override
  String get deleteAddress => 'Xóa địa chỉ';

  @override
  String get deleteAddressConfirm => 'Bạn có chắc chắn muốn xóa địa chỉ này?';

  @override
  String get noAddressesFound => 'Chưa có địa chỉ nào';

  @override
  String get addAddressHint => 'Hãy thêm địa chỉ để bắt đầu mua sắm';

  @override
  String get delete => 'Xóa';

  @override
  String get returnIdLabel => 'Mã trả hàng';

  @override
  String get cancelRequest => 'Hủy yêu cầu';

  @override
  String get cancelRequestConfirm =>
      'Bạn có chắc chắn muốn hủy yêu cầu trả hàng này?';

  @override
  String get cancelSuccess => 'Đã hủy yêu cầu thành công';

  @override
  String get cancelError => 'Lỗi khi hủy';

  @override
  String get confirmHandoverSuccess => 'Đã xác nhận bàn giao hàng cho shipper';

  @override
  String get confirmHandoverError => 'Lỗi khi xác nhận bàn giao';

  @override
  String get refundBankLabel => 'Ngân hàng';

  @override
  String get refundAccountNameLabel => 'Chủ tài khoản';

  @override
  String get refundAccountNumberLabel => 'Số tài khoản';

  @override
  String get reasonLabel => 'Lý do';

  @override
  String get noReason => 'Không có';

  @override
  String get statusSuccess => 'THÀNH CÔNG';

  @override
  String get supportPickup => 'Hỗ trợ Pickup';

  @override
  String get supportShowroomReturn =>
      'Vui lòng gửi hàng về Showroom và cập nhật mã vận đơn.';

  @override
  String get returnShopPaysShipping => 'Phí vận chuyển sẽ do Shop chi trả.';

  @override
  String get returnCustomerPaysShipping =>
      'Quý khách vui lòng thanh toán phí ship cho bưu tá.';

  @override
  String get returnShippingResponsibility => 'Trách nhiệm phí vận chuyển';

  @override
  String get returnShippingFeeCustomerRejected =>
      'Khách hàng thanh toán phí ship gửi trả khi nhận hàng';

  @override
  String get returnRejectedRequestLabel => 'Phản hồi về yêu cầu trả hàng';

  @override
  String get returnRejectedReasonCompromised =>
      'Rất tiếc, sản phẩm hoàn trả không còn nguyên seal hoặc đã bị hư hại/sử dụng. Theo chính sách của hệ thống, PerfumeGPT sẽ gửi trả lại sản phẩm này cho quý khách. Chi phí vận chuyển lượt gửi trả sẽ do người mua thanh toán khi nhận hàng.';

  @override
  String get shopEvidenceLabel => 'Bằng chứng từ cửa hàng';

  @override
  String get returnSendingBackToCustomer => 'Hàng đang gửi trả lại bạn';

  @override
  String get returnPreparingToSendBack =>
      'Đội ngũ PerfumeGPT đang chuẩn bị đóng gói và gửi trả lại sản phẩm cho quý khách. Vui lòng theo dõi trạng thái tiếp theo.';

  @override
  String get aiScentDna => 'AI Scent DNA';

  @override
  String get suggestionMode => 'Chế độ gợi ý';

  @override
  String get exploreNewScents => 'Khám phá những tầng hương mới';

  @override
  String get preferredNotesLabel => 'Nốt hương ưu tiên';

  @override
  String get yourUniqueDna => 'DNA đặc trưng của bạn';

  @override
  String get avoidedNotesLabel => 'Danh sách loại trừ';

  @override
  String get ingredientsToAvoid => 'Những thành phần bạn muốn tránh';

  @override
  String get saveDnaConfig => 'LƯU CẤU HÌNH DNA';

  @override
  String get molecularAnalysis => 'PHÂN TÍCH PHÂN TỬ';

  @override
  String get classic => 'Cổ điển';

  @override
  String get daring => 'Phá cách';

  @override
  String get aiSafeSuggestion =>
      'AI chỉ gợi ý chính xác những gì bạn yêu thích.';

  @override
  String get aiBalancedSuggestion =>
      'AI sẽ ưu tiên gu của bạn nhưng có thêm các nốt hương mới lạ.';

  @override
  String get aiDaringSuggestion =>
      'AI sẽ thử thách khứu giác bạn với các sáng tạo đột phá.';

  @override
  String get understandingYourDna => 'THẤU HIỂU\nDNA CỦA BẠN';

  @override
  String get dnaDescription =>
      'AI Scent DNA là chìa khóa mở ra cánh cổng cá nhân hóa khứu giác, kết nối sở thích bản năng với nghệ thuật chế tác hương thơm.';

  @override
  String get molecularRadar => 'Radar Phân Tử';

  @override
  String get molecularRadarDesc =>
      'Hệ thống phân tích 5 chiều, trực quan hóa từng phân tử mùi hương cấu thành nên bản sắc của bạn.';

  @override
  String get suggestionFocus => 'Tập Trung Gợi Ý';

  @override
  String get suggestionFocusDesc =>
      'Hệ thống tự động thanh lọc các thành phần không mong muốn và tập trung vào DNA yêu thích.';

  @override
  String get discoveryCurve => 'Đường Cong Khám Phá';

  @override
  String get discoveryCurveDesc =>
      'Kiểm soát mức độ bứt phá của AI, từ những bước chân an toàn đến những trải nghiệm hương liệu đột phá.';

  @override
  String get continueExploring => 'TIẾT KIỆM KHÁM PHÁ';

  @override
  String get exploreNotes => 'KHÁM PHÁ NỐT HƯƠNG';

  @override
  String get searchNotesHint => 'Tìm kiếm nốt hương...';

  @override
  String get currentTrends => 'XU HƯỚNG HIỆN TẠI';

  @override
  String get addNewNote => 'Thêm nốt mới';

  @override
  String get woody => 'Gỗ';

  @override
  String get floral => 'Hoa';

  @override
  String get citrus => 'Cam chanh';

  @override
  String get spicy => 'Gia vị';

  @override
  String get musky => 'Xạ hương';

  @override
  String get discoverYourScentSignature =>
      'Hãy để Thiên thần\ntìm thấy Signature của bạn';

  @override
  String get quizIntroDescription =>
      'Bắt đầu hành trình khứu giác cùng Thiên thần nước hoa để tìm ra mùi hương phản ánh đúng bản sắc của bạn.';

  @override
  String get startNow => 'BẮT ĐẦU NGAY';

  @override
  String get estimatedTime => 'Ước tính: 2 phút';

  @override
  String stepProgress(Object current, Object total) {
    return 'BƯỚC $current / $total';
  }

  @override
  String get auraAnalysis => 'THIÊN THẦN ĐANG CẢM NHẬN...';

  @override
  String get personalizingScentExperience =>
      'Dẫn lối tâm hồn bạn đến với miền hương vị...';

  @override
  String get processingOlfactoryData => 'Đang thấu hiểu tâm tư của bạn...';

  @override
  String get matchingResonantNotes =>
      'Tìm kiếm sự cộng hưởng từ triệu nốt hương...';

  @override
  String get identifyingPersonalSignature =>
      'Phác họa chữ ký mùi hương độc bản...';

  @override
  String get completingAuraAlgorithm =>
      'Gói ghém món quà hương thơm riêng biệt...';

  @override
  String get yourScentSignature => 'Món quà của Thiên thần';

  @override
  String get resultsDescription =>
      'Giữa hàng vạn nốt hương, Thiên thần đã chọn lọc ra những mùi hương tuyệt mỹ nhất dành riêng cho tâm hồn bạn.';

  @override
  String get noRecommendations => 'Không tìm thấy đề xuất phù hợp.';

  @override
  String get retakeQuiz => 'LÀM LẠI';

  @override
  String get exploreStore => 'KHÁM PHÁ CỬA HÀNG';

  @override
  String get scentDetails => 'CHI TIẾT MÙI HƯƠNG';

  @override
  String get q1Text => 'Dấu ấn này dành cho ai?';

  @override
  String get q1Opt1 => 'Nam tính';

  @override
  String get q1Opt2 => 'Nữ tính';

  @override
  String get q1Opt3 => 'Phi giới tính';

  @override
  String get q2Text => 'Bạn sẽ sử dụng mùi hương này khi nào?';

  @override
  String get q2Opt1 => 'Hàng ngày';

  @override
  String get q2Opt2 => 'Công sở';

  @override
  String get q2Opt3 => 'Hẹn hò';

  @override
  String get q2Opt4 => 'Tiệc tùng';

  @override
  String get q2Opt5 => 'Sự kiện đặc biệt';

  @override
  String get q3Text => 'Mức ngân sách bạn dự định đầu tư?';

  @override
  String get q4Text => 'Bạn yêu thích phong cách mùi hương nào?';

  @override
  String get q4Opt1 => 'Tươi mát';

  @override
  String get q4Opt2 => 'Hoa cỏ';

  @override
  String get q4Opt3 => 'Gỗ';

  @override
  String get q4Opt4 => 'Phương đông';

  @override
  String get q4Opt5 => 'Thảo mộc';

  @override
  String get q5Text => 'Bạn kỳ vọng độ bám tỏa trong bao lâu?';

  @override
  String get q5Opt1 => '2-4h (Nhẹ)';

  @override
  String get q5Opt2 => '4-6h (Vừa)';

  @override
  String get q5Opt3 => '6-8h (Bền)';

  @override
  String get q5Opt4 => '8h+ (Cực lâu)';

  @override
  String get setupPreferredPayment => 'Thiết lập thanh toán ưu tiên';

  @override
  String get paymentMethodsDesc =>
      'Chọn cách thanh toán mặc định cho đơn hàng tiếp theo. Tập trung vào hai lựa chọn gọn nhất: COD và PayOS online.';

  @override
  String paymentOptionsCount(Object count) {
    return '$count lựa chọn thanh toán';
  }

  @override
  String currentPriority(Object method) {
    return 'Ưu tiên hiện tại: $method.';
  }

  @override
  String get activateMethod => 'Kích hoạt phương thức';

  @override
  String get setDefault => 'Đặt mặc định';

  @override
  String get confirmSettings => 'Xác nhận thiết lập';

  @override
  String get settingsSaved => 'Thiết lập đã được lưu';

  @override
  String get payosTitle => 'Thanh toán online qua PayOS';

  @override
  String get payosSubtitle =>
      'Mở cổng thanh toán bảo mật để quét QR hoặc chuyển khoản nhanh';

  @override
  String get payosDetails =>
      'Nhận biên nhận điện tử ngay sau khi hoàn tất thanh toán.';

  @override
  String get codTitle => 'Thanh toán khi nhận hàng (COD)';

  @override
  String get codSubtitle =>
      'Kiểm tra gói hàng rồi thanh toán trực tiếp cho đơn vị giao hàng';

  @override
  String get codDetails =>
      'Phù hợp khi bạn muốn giữ thanh toán đến lúc hàng giao tận nơi.';

  @override
  String get active => 'Đang bật';

  @override
  String get noDefaultSet => 'Chưa thiết lập';

  @override
  String get setDefaultDesc =>
      'Hãy chọn một phương thức để checkout nhanh hơn.';

  @override
  String get editPaymentMethod => 'Sửa phương thức thanh toán';

  @override
  String get editPayos => 'Chỉnh sửa PayOS online';

  @override
  String get editCod => 'Chỉnh sửa COD';

  @override
  String get paymentEditDesc =>
      'Tùy chỉnh mô tả, trạng thái hiển thị và mức ưu tiên trong hồ sơ.';

  @override
  String get shortDescription => 'Mô tả ngắn';

  @override
  String get statusLabel => 'Nhãn trạng thái';

  @override
  String get detailedInfo => 'Thông tin chi tiết';

  @override
  String get setAsDefault => 'Đặt làm mặc định';

  @override
  String get isActive => 'Đang kích hoạt';

  @override
  String get fillAllFields => 'Vui lòng điền đủ thông tin cấu hình';

  @override
  String get payosNote =>
      'PayOS phù hợp khi bạn muốn mở cổng thanh toán nhanh, quét QR ngân hàng hoặc nhận xác nhận tức thì. COD vẫn nên giữ bật như một phương án dự phòng khi cần.';

  @override
  String get loyaltyProgramTitle => 'Khách hàng thân thiết';

  @override
  String get memberLabel => 'THÀNH VIÊN';

  @override
  String get accumulatedPoints => 'ĐIỂM TÍCH LŨY';

  @override
  String pointsToNextTier(int count) {
    return '$count điểm để lên hạng';
  }

  @override
  String get redeemRewardsTitle => 'ĐỔI ƯU ĐÃI';

  @override
  String get noRewardsAvailable =>
      'Hiện chưa có ưu đãi đổi điểm nào dành cho bạn.';

  @override
  String get membershipTiersTitle => 'CẤP HẠNG THÀNH VIÊN';

  @override
  String get defaultTier => 'Mặc định';

  @override
  String get howToStayTitle => 'LÀM SAO ĐỂ TÍCH ĐIỂM?';

  @override
  String get howToStayDesc => 'Tích lũy điểm thông qua mua sắm và hoạt động.';

  @override
  String get howToEarnTitle => 'LÀM SAO ĐỂ TÍCH ĐIỂM?';

  @override
  String get shoppingEarnTitle => 'MUA SẮM LÀM ĐẸP';

  @override
  String get shoppingEarnDesc =>
      'Cứ 10.000đ chi tiêu = 1 điểm tích lũy tinh chất';

  @override
  String get redeemEarnTitle => 'VIVU ƯU ĐÃI';

  @override
  String get redeemEarnDesc =>
      'Sử dụng điểm (1 điểm = 500đ) để khấu trừ trực tiếp';

  @override
  String get upgradeEarnTitle => 'NÂNG TẦM ĐẲNG CẤP';

  @override
  String get upgradeEarnDesc =>
      'Tích lũy đủ điểm để mở khóa các đặc quyền thượng lưu';

  @override
  String get transactionHistoryTitle => 'LỊCH SỬ GIAO DỊCH';

  @override
  String get noTransactionsYet => 'Hành trình của bạn chưa bắt đầu';

  @override
  String get orderEarnedPoints => 'Tích điểm từ đơn hàng';

  @override
  String get redeemedDiscount => 'Khấu trừ khi thanh toán';

  @override
  String get returnedRefundPoints => 'Hoàn trả điểm (Từ chối đơn)';

  @override
  String get redeemNow => 'ĐỔI NGAY';

  @override
  String get claimNow => 'NHẬN NGAY';

  @override
  String claimVoucherConfirm(String code) {
    return 'Bạn có muốn nhận mã giảm giá $code này không?';
  }

  @override
  String claimSuccess(String code) {
    return 'Nhận thành công! Mã $code đã có trong ví của bạn.';
  }

  @override
  String get voucherDiscount => 'VOUCHER GIẢM';

  @override
  String validUntil(String date) {
    return 'Hết hạn: $date';
  }

  @override
  String get paymentVnpayDesc => 'Thanh toán bằng ví điện tử VNPay';

  @override
  String get paymentMomoDesc => 'Thanh toán bằng ví điện tử MoMo';

  @override
  String get paymentCodDesc => 'Thanh toán khi nhận hàng';

  @override
  String get quizHistoryTitle => 'Lịch sử khảo sát AI';

  @override
  String get noQuizHistory => 'Bạn chưa có lịch sử khảo sát nào.';

  @override
  String get quizHistorySubtitle =>
      'Xem lại các gợi ý mùi hương AI đã dành cho bạn.';

  @override
  String quizResultDate(String date) {
    return 'Khảo sát ngày $date';
  }

  @override
  String get welcomeTitle => 'CHÀO BẠN!';

  @override
  String get welcomeSubtitle =>
      'Tôi là Thiên thần Nước hoa, người đồng hành giúp bạn tìm thấy \"mùi hương định mệnh\".';

  @override
  String get aiScentDnaDiscover => 'Khám phá DNA mùi hương';

  @override
  String get aiScentDnaDiscoverSub => 'AI sẽ phân tích sở thích của bạn';

  @override
  String get giftConsultation => 'Tư vấn quà tặng';

  @override
  String get giftConsultationSub => 'Tìm món quà hoàn hảo cho người thân';

  @override
  String get aiCrafting => 'Thần hương đang pha chế...';

  @override
  String get aiMolecularProcessing => 'Molecular processing...';

  @override
  String get promptAnalyzeDna => 'Hãy giúp tôi phân tích DNA mùi hương của tôi';

  @override
  String get promptGiftSearch => 'Tôi muốn tìm mua nước hoa làm quà tặng';

  @override
  String get chatInputHint => 'Nhắn nhủ điều bạn đang tìm kiếm...';

  @override
  String get chipSurprise => 'Gợi ý bất ngờ';

  @override
  String get chipSurprisePrompt => 'Gợi ý cho tôi một mùi hương bất ngờ';

  @override
  String get chipUnder1m => 'Dưới 1 triệu';

  @override
  String get chipUnder1mPrompt => 'Gợi ý nước hoa dưới 1 triệu đồng';

  @override
  String get chipNight => 'Hương buổi tối';

  @override
  String get chipNightPrompt => 'Mùi hương phù hợp cho buổi tối';

  @override
  String get chipGift => 'Quà tặng';

  @override
  String get chipGiftPrompt => 'Gợi ý nước hoa làm quà tặng';

  @override
  String get chipCheaper => 'Rẻ hơn';

  @override
  String get chipCheaperPrompt => 'Gợi ý tương tự nhưng rẻ hơn';

  @override
  String get chipSweeter => 'Ngọt hơn';

  @override
  String get chipSweeterPrompt => 'Gợi ý mùi hương ngọt hơn';

  @override
  String get chipOffice => 'Đi làm';

  @override
  String get chipOfficePrompt => 'Gợi ý nước hoa phù hợp đi làm';

  @override
  String get chipMasculine => 'Nam tính hơn';

  @override
  String get chipMasculinePrompt => 'Gợi ý nước hoa nam tính hơn';

  @override
  String get chipFeminine => 'Nữ tính hơn';

  @override
  String get chipFemininePrompt => 'Gợi ý nước hoa nữ tính hơn';

  @override
  String get paymentPayosDesc => 'Quét mã QR hoặc chuyển khoản ngân hàng';

  @override
  String earnPoints(int points) {
    return 'Tích lũy $points điểm khi mua sản phẩm này';
  }

  @override
  String get homeAiBannerTitle => 'Hỏi ý kiến Thiên thần';

  @override
  String get homeAiBannerDesc =>
      'Hãy để Thiên thần dẫn lối bạn đến với mùi hương định mệnh hôm nay.';

  @override
  String get askNow => 'HỎI NGAY';

  @override
  String dnaMatch(int percent) {
    return 'ĐỘ TƯƠNG THÍCH DNA: $percent%';
  }

  @override
  String get productReviewTitle => 'Đánh giá sản phẩm';

  @override
  String productCountHeader(int current, int total) {
    return 'Sản phẩm $current/$total';
  }

  @override
  String get pleaseSelectStars => 'Vui lòng chọn số sao';

  @override
  String get reviewPlaceholder => 'Chia sẻ trải nghiệm của bạn về sản phẩm...';

  @override
  String addPhotoCount(int count) {
    return 'Thêm hình ảnh ($count/5)';
  }

  @override
  String get submitReview => 'Gửi đánh giá';

  @override
  String get alreadyReviewed => 'Bạn đã đánh giá sản phẩm này rồi';

  @override
  String get reviewErrorOccurred => 'Có lỗi xảy ra, vui lòng thử lại';

  @override
  String get thankYouReview => 'Cảm ơn bạn đã đánh giá!';

  @override
  String get ratingVeryBad => 'Rất tệ';

  @override
  String get ratingBad => 'Tệ';

  @override
  String get ratingNormal => 'Bình thường';

  @override
  String get ratingGood => 'Tốt';

  @override
  String get ratingExcellent => 'Tuyệt vời';

  @override
  String get selectStars => 'Chọn số sao';

  @override
  String get nextStep => 'Tiếp theo';

  @override
  String get yesCancel => 'CÓ, HỦY';

  @override
  String get relatedOrder => 'Đơn hàng liên quan';

  @override
  String redeemVoucherConfirm(int points) {
    return 'Sử dụng $points điểm để đổi voucher này?';
  }

  @override
  String redeemSuccess(String code) {
    return 'Đổi thành công! Mã $code đã có trong ví của bạn.';
  }

  @override
  String get reverseLogistics => 'LOGISTICS NGƯỢC';

  @override
  String get auditTrail => 'NHẬT KÝ KIỂM TRA';

  @override
  String get stockAdjustmentLogs => 'Lịch sử điều chỉnh kho';

  @override
  String get recentActivity => 'Hoạt động gần đây';

  @override
  String get conversionRate => 'Tỷ lệ chuyển đổi';

  @override
  String get cancelRate => 'Tỷ lệ hủy';

  @override
  String get refundVolume => 'Lượng hoàn tiền';

  @override
  String get grossRevenue => 'DOANH THU GỘP';

  @override
  String get transCount => 'SỐ GIAO DỊCH';

  @override
  String get aovEfficiency => 'AOV / HIỆU SUẤT';

  @override
  String get analyticsCommand => 'PHÂN TÍCH DỮ LIỆU';

  @override
  String get globalNetwork => 'TOÀN HỆ THỐNG';

  @override
  String get topPerformanceCollection => 'Top sản phẩm bán chạy';

  @override
  String get noRecentActivity => 'KHÔNG CÓ HOẠT ĐỘNG GẦN ĐÂY';

  @override
  String get noPendingReturns => 'KHÔNG TÌM THẤY YÊU CẦU HOÀN TRẢ';

  @override
  String get terminateSession => 'CHẤM DỨT PHIÊN';

  @override
  String get terminateSessionConfirm =>
      'Bạn có chắc chắn muốn đăng xuất khỏi nhà ga này?';

  @override
  String get scanToPay => 'QUÉT ĐỂ THANH TOÁN';

  @override
  String get loyaltyGateway => 'CỔNG THÀNH VIÊN';

  @override
  String get terminateRequest => 'CHẤM DỨT YÊU CẦU';

  @override
  String get encryptionActive => 'MÃ HÓA ĐANG HOẠT ĐỘNG';

  @override
  String get client => 'KHÁCH HÀNG';

  @override
  String get loyaltyPoints => 'ĐIỂM THÀNH VIÊN';

  @override
  String get member => 'THÀNH VIÊN';

  @override
  String get returnsHistory => 'Lịch sử trả hàng';

  @override
  String get allAteliers => 'TẤT CẢ CỨA HÀNG';

  @override
  String get chatStatusActive => 'ĐANG HOẠT ĐỘNG';

  @override
  String get addToBagInvite => 'Thêm vào giỏ';

  @override
  String get chatHistoryTitle => 'Lịch sử';

  @override
  String get newConsultationBtn => 'ĐOẠN CHAT MỚI';

  @override
  String get recentJourneysTitle => 'GẦN ĐÂY';

  @override
  String get sinceLabel => 'TỪ NĂM 2026';

  @override
  String get storyHeroSub => 'Sự Giao Thoa Giữa';

  @override
  String get storyHeroTitle => 'Tự Nhiên & Trí Tuệ';

  @override
  String get philosophyLabel => 'TRIẾT LÝ CỦA CHÚNG TÔI';

  @override
  String get philosophyQuote => 'Mùi hương là dạng ký ức mãnh liệt nhất.';

  @override
  String get philosophyDesc =>
      'AURA được thành lập dựa trên một ý tưởng đơn giản nhưng mang tính cách mạng: nghệ thuật chế tác nước hoa cổ xưa nên mang tính cá nhân, chính xác và thông minh sâu sắc.\n\nChúng tôi kết hợp sự nhạy bén của các chuyên gia điều hương hàng đầu thế giới với sức mạnh phân tích của AI tiên tiến để thu hẹp khoảng cách giữa cảm xúc con người và thành phần hóa học.';

  @override
  String get methodLabel => 'PHƯƠNG PHÁP AURA';

  @override
  String get methodSourcingTitle => 'Nguồn cung ứng';

  @override
  String get methodSourcingDesc =>
      'Chúng tôi đi khắp thế giới để tìm nguồn nguyên liệu thô chất lượng cao nhất từ các trang trại bền vững.';

  @override
  String get methodAnalysisTitle => 'Phân tích';

  @override
  String get methodAnalysisDesc =>
      'Công cụ AI của chúng tôi phân tích hàng triệu điểm dữ liệu cảm giác để thấu hiểu sự cộng hưởng khứu giác của con người.';

  @override
  String get methodCraftingTitle => 'Chế tác';

  @override
  String get methodCraftingDesc =>
      'Mỗi chai nước hoa đều được hoàn thiện thủ công tại xưởng, đảm bảo giá trị con người luôn là cốt lõi của chúng tôi.';

  @override
  String get ctaStoryTitle => 'Trải Nghiệm Tương Lai\nCủa Nước Hoa.';

  @override
  String get ctaStoryBtn => 'KHÁM PHÁ MÙI HƯƠNG CỦA TÔI';

  @override
  String get manageDeliveryPoints => 'Quản lý điểm nhận hàng';

  @override
  String get shippingAddressDesc =>
      'Chọn địa chỉ mặc định cho các đơn hàng tiếp theo, đồng thời lưu riêng địa chỉ quà tặng hoặc văn phòng để thanh toán nhanh hơn.';

  @override
  String savedAddressesCount(int count) {
    return '$count địa chỉ đã lưu';
  }

  @override
  String currentDefaultIs(String label) {
    return 'Địa chỉ mặc định hiện tại là $label.';
  }

  @override
  String priorityRecipient(String name) {
    return 'Người nhận ưu tiên: $name.';
  }

  @override
  String get canChangeBeforeCheckout =>
      'Bạn có thể đổi nhanh địa chỉ nhận ngay trước khi thanh toán.';

  @override
  String get savedAddressesUpper => 'ĐỊA CHỈ ĐÃ LƯU';

  @override
  String get readyForDeliveryScenario => 'Sẵn sàng cho mọi kịch bản giao hàng';

  @override
  String get deliveryTipsTitle => 'Gợi ý giao hàng mượt hơn';

  @override
  String get deliveryTipNoAddress =>
      'Hãy tạo địa chỉ đầu tiên để checkout có thể tự động điền thông tin nhận hàng.';

  @override
  String deliveryTipWithAddress(String label) {
    return 'Địa chỉ mặc định hiện tại là $label. Nếu đây là địa chỉ công ty, hãy luôn điền người nhận và ghi chú quầy lễ tân để shipper giao thuận lợi hơn.';
  }

  @override
  String get addressFormTitleAdd => 'Thêm địa chỉ giao hàng';

  @override
  String get addressFormTitleEdit => 'Chỉnh sửa địa chỉ';

  @override
  String get addressFormSubtitle =>
      'Lưu thông tin nhận hàng để checkout nhanh và chính xác hơn.';

  @override
  String get setAsDefaultAddressDesc =>
      'Địa chỉ này sẽ được ưu tiên điền sẵn ở bước thanh toán.';

  @override
  String get errorRequiredFields => 'Vui lòng điền đủ thông tin bắt buộc';

  @override
  String get defaultAddressUpdated => 'Đã cập nhật địa chỉ mặc định';

  @override
  String get addressAddedSuccess => 'Đã thêm địa chỉ giao hàng mới';

  @override
  String get addressUpdatedSuccess => 'Đã cập nhật địa chỉ giao hàng';

  @override
  String addressDeletedSuccess(String label) {
    return 'Đã xóa địa chỉ $label';
  }

  @override
  String get notSetLabel => 'Chưa thiết lập';

  @override
  String get noDefaultAddressYet => 'Chưa có địa chỉ mặc định';

  @override
  String get payosNoteTitle => 'Ghi chú PayOS';

  @override
  String get paymentMethodsComboTitle => 'PayOS & COD';

  @override
  String get scentNotes => 'Nốt hương';

  @override
  String get noNotesFound => 'Không tìm thấy nốt hương nào';

  @override
  String get technicalSpecs => 'THÔNG SỐ KỸ THUẬT';

  @override
  String get longevityLabel => 'Độ lưu hương';

  @override
  String get concentrationLabel => 'Nồng độ';

  @override
  String get updating => 'Đang cập nhật...';

  @override
  String get seeMore => 'Xem thêm';

  @override
  String get seeLess => 'Thu gọn';

  @override
  String get helpCenterTitle => 'TRUNG TÂM TRỢ GIÚP';

  @override
  String get howCanWeHelp => 'CHÚNG TÔI CÓ THỂ GIÚP GÌ CHO BẠN?';

  @override
  String get searchIssueHint => 'Tìm kiếm vấn đề của bạn...';

  @override
  String get faqTitle => 'CÂU HỎI THƯỜNG GẶP';

  @override
  String get catOrders => 'Đơn hàng';

  @override
  String get catPayments => 'Thanh toán';

  @override
  String get catShipping => 'Vận chuyển';

  @override
  String get catAiConsult => 'AI Tư vấn';

  @override
  String get catAccount => 'Tài khoản';

  @override
  String get faq1Question => 'Làm thế nào để đổi trả sản phẩm?';

  @override
  String get faq1Answer =>
      'Bạn có thể gửi yêu cầu đổi trả trong vòng 7 ngày kể từ khi nhận hàng. Vui lòng vào mục \"Đơn hàng của tôi\", chọn đơn hàng cần đổi trả và nhấn \"Yêu cầu hoàn trả\".';

  @override
  String get faq2Question => 'Thuật toán AI gợi ý mùi hương hoạt động ra sao?';

  @override
  String get faq2Answer =>
      'Perfume GPT sử dụng hệ thống thần kinh nhân tạo kết hợp với dữ liệu về 147 điểm cảm quan và lối sống của bạn để phối hợp các phân tử mùi hương phù hợp nhất với bản sắc riêng của bạn.';

  @override
  String get faq3Question => 'Perfume GPT có giao hàng quốc tế không?';

  @override
  String get faq3Answer =>
      'Hiện tại chúng tôi hỗ trợ giao hàng tại Việt Nam và các quốc gia khu vực Đông Nam Á. Chúng tôi đang mở rộng mạng lưới giao hàng toàn cầu trong thời gian tới.';

  @override
  String get contactTitle => 'LIÊN HỆ';

  @override
  String get supportChannels => 'KÊNH HỖ TRỢ TRỰC TUYẾN';

  @override
  String get liveChat => 'Trò chuyện trực tiếp';

  @override
  String get responseTime5m => 'Thời gian phản hồi ~ 5 phút';

  @override
  String get sendEmail => 'Gửi Email cho chúng tôi';

  @override
  String get hotline247 => 'Hotline hỗ trợ 24/7';

  @override
  String get freeHotline => 'Miễn phí';

  @override
  String get sendMessage => 'GỬI LỜI NHẮN CHO CHÚNG TÔI';

  @override
  String get messageContent => 'Nội dung tin nhắn';

  @override
  String get sendRequest => 'Gửi yêu cầu';

  @override
  String get sortNewest => 'Mới nhất';

  @override
  String get sortPriceLow => 'Giá tăng';

  @override
  String get sortPriceHigh => 'Giá giảm';

  @override
  String get sortName => 'Tên A-Z';

  @override
  String get sortBy => 'SẮP XẾP THEO';

  @override
  String get noVariantAvailable => 'Sản phẩm chưa có phiên bản';

  @override
  String get removedFromWishlist => 'Đã xóa khỏi yêu thích';

  @override
  String get undo => 'HOÀN TÁC';

  @override
  String get remove => 'Xóa';

  @override
  String itemsCount(int count) {
    return '$count sản phẩm';
  }

  @override
  String get achWelcomeTitle => 'Bước Chân Đầu';

  @override
  String get achWelcomeDesc => 'Tham gia cộng đồng yêu nước hoa PerfumeGPT';

  @override
  String get achExplorerTitle => 'Nhà Thám Hiểm';

  @override
  String get achExplorerDesc => 'Hoàn thành hồ sơ mùi hương AI (Quiz)';

  @override
  String get achNoteMasterTitle => 'Bậc Thầy Nốt Hương';

  @override
  String get achNoteMasterDesc => 'Khám phá hơn 5 nốt hương đặc trưng';

  @override
  String get achShopperTitle => 'Người Mua Tinh Hoa';

  @override
  String get achShopperDesc => 'Thực hiện đơn hàng đầu tiên của bạn';

  @override
  String get achReviewerTitle => 'Vua Đánh Giá';

  @override
  String get achReviewerDesc => 'Để lại ít nhất 3 đánh giá chi tiết';

  @override
  String get achievementsHeader => 'THÀNH TỰU ĐÃ ĐẠT';

  @override
  String get addressLabel => 'Nhãn địa chỉ';

  @override
  String get email => 'Email';

  @override
  String get subject => 'Chủ đề';

  @override
  String get message => 'Tin nhắn';

  @override
  String get settingsTitle => 'CÀI ĐẶT';

  @override
  String get accountSettings => 'THIẾT LẬP TÀI KHOẢN';

  @override
  String get security => 'Bảo mật';

  @override
  String get aboutUs => 'Về chúng tôi';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get deleteAccountConfirm =>
      'Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa tài khoản?';

  @override
  String get recentlyViewed => 'SẢN PHẨM VỪA XEM';

  @override
  String get isHelpful => 'THÔNG TIN NÀY CÓ HỮU ÍCH KHÔNG?';

  @override
  String get yes => 'Có';

  @override
  String get help => 'Trợ giúp';

  @override
  String get artOrdersTitle => 'Quy trình đặt hàng & Theo dõi';

  @override
  String get artOrdersContent =>
      'Sau khi chọn được mùi hương ưng ý, bạn có thể thực hiện đặt hàng theo các bước sau:\n• Thêm sản phẩm vào giỏ hàng.\n• Kiểm tra lại số lượng và dung tích.\n• Tiến hành thanh toán và điền thông tin địa chỉ.\nMọi đơn hàng sẽ được xử lý trong vòng 24h.';

  @override
  String get artPaymentsTitle => 'Phương thức thanh toán & Bảo mật';

  @override
  String get artPaymentsContent =>
      'Perfume GPT hiện hỗ trợ 2 phương thức thanh toán chính để đảm bảo tính an toàn và tiện lợi:\n• Chuyển khoản qua PayOS (Hỗ trợ tất cả ngân hàng nội địa qua QR Code).\n• Thanh toán khi nhận hàng (COD).\nMọi thông tin giao dịch của bạn đều được mã hóa và bảo mật tuyệt đối qua cổng thanh toán PayOS.';

  @override
  String get artShippingTitle => 'Chính sách vận chuyển & Phí';

  @override
  String get artShippingContent =>
      'Chúng tôi hợp tác cùng đơn vị vận chuyển Giao Hàng Nhanh (GHN) để mang sản phẩm đến tay bạn nhanh nhất có thể:\n• Nội thành: 1-2 ngày làm việc.\n• Ngoại thành: 3-5 ngày làm việc.\nPhí vận chuyển sẽ được tự động tính toán dựa trên khối lượng sản phẩm và địa chỉ nhận hàng của bạn qua hệ thống GHN.';

  @override
  String get artAiTitle => 'Về hệ thống tư vấn AI của Perfume GPT';

  @override
  String get artAiContent =>
      'Hệ thống AI của chúng tôi không chỉ là một bộ lọc đơn giản. Nó là kết quả của sự hợp tác giữa các chuyên gia mùi hương và kỹ sư công nghệ:\n• Phân tích 5 chiều: Cần thiết, Phong cách, Môi trường, Cảm xúc và Ký ức.\n• Cập nhật liên tục từ dữ liệu khách hàng thực tế.\nĐộ chính xác lên đến 98% cho lần đầu tiên sử dụng.';

  @override
  String get artAccountTitle => 'Quản lý tài khoản & Bảo mật';

  @override
  String get artAccountContent =>
      'Để đảm bảo quyền lợi và tích lũy điểm thưởng, bạn nên duy trì tài khoản của mình:\n• Cập nhật thông tin cá nhân trong mục Hồ sơ.\n• Bật xác thực 2 lớp để tăng cường bảo mật.\nNếu quên mật khẩu, vui lòng chọn \"Quên mật khẩu\" tại màn hình đăng nhập để nhận mã khôi phục.';
}
