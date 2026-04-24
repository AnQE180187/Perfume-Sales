import Layout from "@/components/layout";
import CartPage from "@/pages/cart";
import PaymentResultPage from "@/pages/cart/payment-result";
import ProductListPage from "@/pages/catalog/product-list";
import CatalogPage from "@/pages/catalog/index";
import CategoryListPage from "@/pages/catalog/category-list";
import ProductDetailPage from "@/pages/catalog/product-detail";
import HomePage from "@/pages/home";
import ProfilePage from "@/pages/profile";
import SearchPage from "@/pages/search";
import AiChatPage from "@/pages/ai-chat";
import AiQuizPage from "@/pages/ai-quiz";
import OrdersPage from "@/pages/profile/orders";
import OrderDetailPage from "@/pages/profile/order-detail";
import EditProfilePage from "@/pages/profile/edit";
import AddressesPage from "@/pages/profile/addresses";
import VouchersPage from "@/pages/profile/vouchers";
import FavoritesPage from "@/pages/profile/favorites";
import ReturnsPage from "@/pages/profile/returns";
import ReturnDetailPage from "@/pages/profile/return-detail";
import CreateReturnPage from "@/pages/profile/create-return";
import LoginPage from "@/pages/login";
import { createBrowserRouter } from "react-router-dom";
import { getBasePath } from "@/utils/zma";

const router = createBrowserRouter(
  [
    {
      path: "/login",
      element: <LoginPage />
    },
    {
      path: "/",
      element: <Layout />,
      children: [
        {
          path: "/",
          element: <HomePage />,
          handle: {
            logo: true,
          },
        },
        {
          path: "/categories",
          element: <CategoryListPage />,
          handle: {
            title: "Danh mục sản phẩm",
            back: false,
          },
        },
        {
          path: "/cart",
          element: <CartPage />,
          handle: {
            title: "Giỏ hàng",
          },
        },
        {
          path: "/payment/result",
          element: <PaymentResultPage />,
          handle: {
            title: "Kết quả thanh toán",
          },
        },
        {
          path: "/payment/payos/return",
          element: <PaymentResultPage />,
          handle: {
            title: "Kết quả thanh toán",
          },
        },
        {
          path: "/payment/payos/cancel",
          element: <PaymentResultPage />,
          handle: {
            title: "Kết quả thanh toán",
          },
        },
        {
          path: "/profile",
          element: <ProfilePage />,
          handle: {
            logo: true,
          },
        },
        {
          path: "/flash-sales",
          element: <ProductListPage />,
          handle: {
            title: "Bộ sưu tập nước hoa",
          },
        },
        {
          path: "/catalog",
          element: <CatalogPage />,
          handle: {
            title: "Bộ sưu tập nước hoa",
            back: false,
          },
        },
        {
          path: "/category/:id",
          element: <ProductListPage />,
          handle: {
            title: ({ categories, params }) =>
              categories.find((c) => c.id === Number(params.id))?.name,
          },
        },
        {
          path: "/product/:id",
          element: <ProductDetailPage />,
          handle: {
            scrollRestoration: 0, // when user selects another product in related products, scroll to the top of the page
          },
        },
        {
          path: "/search",
          element: <SearchPage />,
          handle: {
            title: "Tìm kiếm",
          },
        },
        {
          path: "/ai-chat",
          element: <AiChatPage />,
          handle: {
            title: "Trợ Lý AI",
          },
        },
        {
          path: "/ai-quiz",
          element: <AiQuizPage />,
          handle: {
            title: "Tìm Mùi Hương",
          },
        },
        {
          path: "/orders",
          element: <OrdersPage />,
          handle: {
            title: "Đơn hàng của tôi",
          },
        },
        {
          path: "/orders/:id",
          element: <OrderDetailPage />,
          handle: {
            title: "Chi tiết đơn hàng",
          },
        },
        {
          path: "/orders/:id/return",
          element: <CreateReturnPage />,
          handle: {
            title: "Yêu cầu trả hàng",
          },
        },
        {
          path: "/returns",
          element: <ReturnsPage />,
          handle: {
            title: "Đơn trả hàng",
          },
        },
        {
          path: "/returns/:id",
          element: <ReturnDetailPage />,
          handle: {
            title: "Chi tiết trả hàng",
          },
        },
        {
          path: "/profile/edit",
          element: <EditProfilePage />,
          handle: { title: "Chỉnh sửa hồ sơ" }
        },
        {
          path: "/profile/addresses",
          element: <AddressesPage />,
          handle: { title: "Địa chỉ nhận hàng" }
        },
        {
          path: "/profile/vouchers",
          element: <VouchersPage />,
          handle: { title: "Kho Voucher" }
        },
        {
          path: "/profile/favorites",
          element: <FavoritesPage />,
          handle: { title: "Sản phẩm yêu thích" }
        },
      ],
    },
  ],
  { basename: getBasePath() }
);

export default router;
