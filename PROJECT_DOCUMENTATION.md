# Flutter Medicine Store - Tài Liệu Dự Án

## 📋 Mục Lục

1. [Tổng Quan Dự Án](#tổng-quan-dự-án)
2. [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
3. [Chi Tiết Từng File](#chi-tiết-từng-file)
4. [Hướng Dẫn Kết Nối Firestore](#hướng-dẫn-kết-nối-firestore)
5. [Câu Hỏi Vấn Đáp về Firestore](#câu-hỏi-vấn-đáp-về-firestore)

---

## 📱 Tổng Quan Dự Án

**Flutter Medicine Store** là một ứng dụng bán thuốc tây được xây dựng bằng Flutter, sử dụng Firebase làm backend. Ứng dụng hỗ trợ:

- ✅ Đăng ký/Đăng nhập người dùng
- ✅ Quản lý thuốc (CRUD) cho admin
- ✅ Tìm kiếm và lọc thuốc theo danh mục
- ✅ Giỏ hàng và thanh toán
- ✅ Lịch sử đơn hàng
- ✅ Duyệt đơn hàng cho admin

---

## 📁 Cấu Trúc Thư Mục

```
FlutterMedicine/
├── lib/
│   ├── main.dart                    # Entry point của ứng dụng
│   ├── firebase_options.dart        # Cấu hình Firebase cho các platform
│   ├── models/                      # Data models
│   │   ├── medicine.dart
│   │   ├── user_model.dart
│   │   ├── cart_item.dart
│   │   └── order.dart
│   ├── services/                    # Business logic và API calls
│   │   ├── auth_service.dart
│   │   ├── medicine_service.dart
│   │   ├── cart_service.dart
│   │   └── order_service.dart
│   ├── screens/                     # UI Screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── admin/
│   │   │   ├── admin_panel_screen.dart
│   │   │   ├── add_medicine_screen.dart
│   │   │   ├── edit_medicine_screen.dart
│   │   │   └── pending_orders_screen.dart
│   │   └── cart/
│   │       ├── cart_screen.dart
│   │       ├── checkout_screen.dart
│   │       └── order_history_screen.dart
│   ├── widgets/                     # Reusable widgets
│   │   ├── medicine_card.dart
│   │   └── loading_indicator.dart
│   └── utils/                       # Utilities và constants
│       └── constants.dart
├── scripts/
│   └── seed_data.dart               # Script để seed dữ liệu mẫu
├── firestore.rules                  # Firestore security rules
├── pubspec.yaml                     # Dependencies và cấu hình
└── README.md
```

---

## 📄 Chi Tiết Từng File

### 🔧 Configuration Files

#### `pubspec.yaml`
**Mô tả**: File quản lý dependencies và cấu hình của Flutter project.

**Dependencies chính**:
- `firebase_core: ^3.6.0` - Firebase core package
- `firebase_auth: ^5.3.1` - Firebase Authentication
- `cloud_firestore: ^5.4.4` - Cloud Firestore database
- `provider: ^6.1.1` - State management
- `intl: ^0.19.0` - Internationalization (formatting dates, currency)

**Cách sử dụng**: Chạy `flutter pub get` để cài đặt dependencies.

---

#### `lib/firebase_options.dart`
**Mô tả**: Chứa cấu hình Firebase cho các platform (Web, Android, iOS).

**Nội dung chính**:
- `DefaultFirebaseOptions` class với các phương thức:
  - `currentPlatform` - Tự động chọn platform hiện tại
  - `web` - Cấu hình cho web
  - `android` - Cấu hình cho Android

**Cách tạo**: Chạy `flutterfire configure` hoặc tạo thủ công từ `google-services.json`.

---

#### `firestore.rules`
**Mô tả**: Định nghĩa security rules cho Firestore collections.

**Các rules chính**:
- **Users collection**: Users chỉ có thể đọc/cập nhật dữ liệu của chính họ
- **Medicines collection**: Tất cả authenticated users có thể đọc, chỉ admin có thể write
- **Orders collection**: Users đọc orders của mình, admin đọc tất cả và có thể cập nhật status

**Quan trọng**: Phải publish rules này lên Firebase Console để có hiệu lực.

---

### 🎯 Entry Point

#### `lib/main.dart`
**Mô tả**: Entry point của ứng dụng, khởi tạo Firebase và setup Provider.

**Chức năng chính**:
1. Khởi tạo Firebase với `Firebase.initializeApp()`
2. Setup `MultiProvider` với các services:
   - `AuthService` - Quản lý authentication
   - `MedicineService` - Quản lý medicines
   - `CartService` - Quản lý giỏ hàng (ChangeNotifier)
   - `OrderService` - Quản lý orders
3. `AuthWrapper` - Điều hướng giữa Login và Home dựa trên auth state

**Flow**:
```
App Start → Firebase Init → Provider Setup → AuthWrapper → Login/Home
```

---

### 📦 Models

#### `lib/models/medicine.dart`
**Mô tả**: Data model cho Medicine (Thuốc).

**Properties**:
- `id` - Document ID từ Firestore
- `name` - Tên thuốc
- `price` - Giá
- `description` - Mô tả
- `category` - Danh mục
- `stock` - Số lượng tồn kho
- `manufacturer` - Nhà sản xuất
- `imageUrl` - URL hình ảnh
- `createdAt`, `updatedAt` - Timestamps

**Methods**:
- `toMap()` - Convert sang Map để lưu Firestore
- `fromMap()` - Factory constructor từ Firestore data

---

#### `lib/models/user_model.dart`
**Mô tả**: Data model cho User.

**Properties**:
- `id` - User ID (Firebase Auth UID)
- `email` - Email
- `displayName` - Tên hiển thị
- `role` - Vai trò ('admin' hoặc 'user')
- `createdAt`, `updatedAt` - Timestamps

---

#### `lib/models/cart_item.dart`
**Mô tả**: Data model cho item trong giỏ hàng.

**Properties**:
- `medicine` - Medicine object
- `quantity` - Số lượng

**Methods**:
- `totalPrice` - Getter tính tổng giá (price * quantity)

---

#### `lib/models/order.dart`
**Mô tả**: Data model cho Order (Đơn hàng).

**Classes**:
1. **MedicineOrder**:
   - `id` - Order ID
   - `userId` - User ID của người đặt
   - `items` - List<OrderItem>
   - `totalAmount` - Tổng tiền
   - `status` - Trạng thái ('pending', 'processing', 'completed', 'cancelled')
   - `shippingInfo` - ShippingInfo object
   - `createdAt`, `updatedAt` - Timestamps

2. **OrderItem**:
   - `medicineId`, `medicineName`, `price`, `quantity`
   - `subtotal` - Getter tính subtotal

3. **ShippingInfo**:
   - `fullName`, `phone`, `address`, `notes`

---

### 🔌 Services

#### `lib/services/auth_service.dart`
**Mô tả**: Service xử lý authentication và user management.

**Methods**:
- `register(String email, String password, String name)` - Đăng ký user mới
- `login(String email, String password)` - Đăng nhập
- `logout()` - Đăng xuất
- `getCurrentUser()` - Lấy thông tin user hiện tại
- `isAdmin()` - Kiểm tra user có phải admin không
- `authStateChanges` - Stream theo dõi auth state

**Firestore Collections sử dụng**:
- `users` - Lưu thông tin user

---

#### `lib/services/medicine_service.dart`
**Mô tả**: Service xử lý CRUD operations cho medicines.

**Methods**:
- `getAllMedicines()` - Stream tất cả medicines
- `getMedicineById(String id)` - Lấy medicine theo ID
- `getMedicinesByCategory(String category)` - Lọc theo danh mục
- `searchMedicines(String query)` - Tìm kiếm theo tên
- `addMedicine(Medicine medicine)` - Thêm medicine mới
- `updateMedicine(Medicine medicine)` - Cập nhật medicine
- `deleteMedicine(String id)` - Xóa medicine
- `seedSampleData()` - Seed dữ liệu mẫu

**Firestore Collections sử dụng**:
- `medicines` - Collection chứa medicines

**Lưu ý**: Query với `where` và `orderBy` cùng lúc cần composite index. Code đã xử lý bằng cách sort client-side.

---

#### `lib/services/cart_service.dart`
**Mô tả**: Service quản lý giỏ hàng (sử dụng ChangeNotifier).

**Properties**:
- `items` - List<CartItem>
- `totalAmount` - Getter tính tổng tiền

**Methods**:
- `addToCart(Medicine medicine, int quantity)` - Thêm vào giỏ
- `removeFromCart(String medicineId)` - Xóa khỏi giỏ
- `updateQuantity(String medicineId, int quantity)` - Cập nhật số lượng
- `clearCart()` - Xóa tất cả

**State Management**: Sử dụng `ChangeNotifier` để notify listeners khi cart thay đổi.

---

#### `lib/services/order_service.dart`
**Mô tả**: Service xử lý orders.

**Methods**:
- `createOrder(MedicineOrder order)` - Tạo order mới
- `getUserOrders(String userId)` - Stream orders của user
- `getPendingOrders()` - Stream tất cả pending orders (cho admin)
- `getOrderById(String orderId)` - Lấy order theo ID
- `updateOrderStatus(String orderId, String status)` - Cập nhật status

**Firestore Collections sử dụng**:
- `orders` - Collection chứa orders

---

### 🖥️ Screens

#### Authentication Screens

##### `lib/screens/auth/login_screen.dart`
**Mô tả**: Màn hình đăng nhập.

**Features**:
- Form validation
- Email và password input
- Link đến Register screen
- Error handling và hiển thị thông báo

---

##### `lib/screens/auth/register_screen.dart`
**Mô tả**: Màn hình đăng ký.

**Features**:
- Form với validation:
  - Name (required)
  - Email (required, email format)
  - Password (required, min 6 characters)
  - Confirm Password (must match)
- Tự động tạo user document trong Firestore với role 'user'
- Link đến Login screen

---

#### Home Screen

##### `lib/screens/home/home_screen.dart`
**Mô tả**: Màn hình chính hiển thị danh sách medicines.

**Features**:
- Search bar để tìm kiếm medicines
- Filter dropdown theo category
- List medicines với MedicineCard widget
- Floating Action Button cho Cart
- Icon button cho Order History
- "Admin Panel" button (chỉ hiện với admin)

**Navigation**:
- Cart Screen
- Order History Screen
- Admin Panel (nếu là admin)

---

#### Admin Screens

##### `lib/screens/admin/admin_panel_screen.dart`
**Mô tả**: Màn hình quản lý medicines cho admin.

**Features**:
- List tất cả medicines
- Edit và Delete buttons cho mỗi medicine
- "Add Medicine" floating button
- "Seed Data" button (icon refresh)
- "Pending Orders" button (icon shopping bag)

**Actions**:
- Navigate to Add/Edit Medicine screens
- Navigate to Pending Orders screen
- Delete medicine với confirmation dialog
- Seed sample data với confirmation dialog

---

##### `lib/screens/admin/add_medicine_screen.dart`
**Mô tả**: Form thêm medicine mới.

**Fields**:
- Name, Price, Description, Category, Stock, Manufacturer, Image URL

**Validation**: Tất cả fields đều required (trừ Image URL).

---

##### `lib/screens/admin/edit_medicine_screen.dart`
**Mô tả**: Form chỉnh sửa medicine.

**Tương tự Add Medicine Screen**, nhưng pre-fill data từ medicine hiện tại.

---

##### `lib/screens/admin/pending_orders_screen.dart`
**Mô tả**: Màn hình duyệt đơn hàng pending cho admin.

**Features**:
- List tất cả orders có status 'pending'
- Expandable cards hiển thị chi tiết:
  - Order items
  - Shipping information
- Action buttons:
  - **Approve** - Chuyển status sang 'processing'
  - **Reject** - Chuyển status sang 'cancelled'

**Real-time**: Sử dụng Stream để tự động cập nhật khi có order mới.

---

#### Cart Screens

##### `lib/screens/cart/cart_screen.dart`
**Mô tả**: Màn hình giỏ hàng.

**Features**:
- Hiển thị items trong cart
- Tăng/giảm số lượng
- Xóa item
- Hiển thị tổng tiền
- "Checkout" button

**Navigation**: Checkout Screen

---

##### `lib/screens/cart/checkout_screen.dart`
**Mô tả**: Màn hình thanh toán.

**Features**:
- Order summary
- Shipping information form:
  - Full Name, Phone, Address, Notes
- Payment method selection (simulated):
  - Cash on Delivery
  - Credit Card (simulated)
- "Place Order" button

**Flow**:
1. Validate form
2. Tạo Order object
3. Save vào Firestore
4. Clear cart
5. Show success dialog
6. Navigate to Order History hoặc Home

---

##### `lib/screens/cart/order_history_screen.dart`
**Mô tả**: Màn hình lịch sử đơn hàng.

**Features**:
- List tất cả orders của user hiện tại
- Sắp xếp theo ngày (mới nhất trước)
- Expandable cards hiển thị:
  - Order items
  - Shipping information
  - Status với màu sắc:
    - Pending: Orange
    - Processing: Blue
    - Completed: Green
    - Cancelled: Red

**Real-time**: Tự động cập nhật khi có thay đổi.

---

### 🧩 Widgets

#### `lib/widgets/medicine_card.dart`
**Mô tả**: Reusable widget hiển thị medicine trong card format.

**Features**:
- Hiển thị: Name, Category, Price, Stock
- "Add to Cart" button
- Navigate to detail (nếu cần)

---

#### `lib/widgets/loading_indicator.dart`
**Mô tả**: Loading indicator widget với message.

**Usage**: Hiển thị khi đang load data.

---

### 🛠️ Utils

#### `lib/utils/constants.dart`
**Mô tả**: Chứa các constants của ứng dụng.

**Constants**:
- Collection names: `medicinesCollection`, `usersCollection`
- User roles: `roleAdmin`, `roleUser`
- Medicine categories list

---

### 📜 Scripts

#### `scripts/seed_data.dart`
**Mô tả**: Standalone Dart script để seed dữ liệu mẫu vào Firestore.

**Cách chạy**:
```bash
dart run scripts/seed_data.dart
```

**Lưu ý**: Script này là pure Dart (không dùng Flutter), sử dụng `DefaultFirebaseOptions.web` để initialize Firebase.

---

## 🔥 Hướng Dẫn Kết Nối Firestore

### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Nhập tên project (ví dụ: "Medicine Store")
4. Chọn Google Analytics (optional)
5. Click "Create project"

### Bước 2: Thêm App vào Firebase Project

#### Cho Web:
1. Trong Firebase Console, click icon Web (`</>`)
2. Đăng ký app với nickname (ví dụ: "medicine-web")
3. Copy cấu hình Firebase (sẽ có dạng):
```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "..."
};
```

#### Cho Android:
1. Click icon Android
2. Đăng ký app với package name (ví dụ: `com.example.flutter_medicine`)
3. Download `google-services.json`
4. Đặt file vào `android/app/google-services.json`

### Bước 3: Cài Đặt Firebase CLI (Optional)

```bash
npm install -g firebase-tools
firebase login
```

### Bước 4: Cấu Hình Firebase trong Flutter

#### Cách 1: Sử dụng FlutterFire CLI (Recommended)

```bash
# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình Firebase
flutterfire configure
```

Lệnh này sẽ:
- Tự động tạo `lib/firebase_options.dart`
- Cấu hình cho các platform bạn chọn

#### Cách 2: Tạo Thủ Công

1. Tạo file `lib/firebase_options.dart`
2. Copy cấu hình từ Firebase Console vào file:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
```

### Bước 5: Khởi Tạo Firebase trong App

Trong `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### Bước 6: Cấu Hình Firestore Security Rules

1. Trong Firebase Console, vào **Firestore Database** → **Rules**
2. Copy nội dung từ file `firestore.rules` trong project
3. Paste vào Firebase Console
4. Click **Publish**

**Lưu ý quan trọng**: Rules phải được publish mới có hiệu lực!

### Bước 7: Tạo Firestore Collections

Firestore sẽ tự động tạo collections khi bạn thêm documents đầu tiên. Hoặc bạn có thể tạo thủ công:

1. Vào **Firestore Database** → **Data**
2. Click **Start collection**
3. Tạo các collections:
   - `medicines`
   - `users`
   - `orders`

### Bước 8: Seed Dữ Liệu Mẫu (Optional)

```bash
dart run scripts/seed_data.dart
```

### Bước 9: Kiểm Tra Kết Nối

1. Chạy app: `flutter run`
2. Thử đăng ký user mới
3. Kiểm tra Firestore Console xem có document mới không

---

## ❓ Câu Hỏi Vấn Đáp về Firestore

### 🔹 Câu Hỏi Cơ Bản

**Q1: Firestore là gì?**
A: Firestore là NoSQL database của Google, cho phép lưu trữ và đồng bộ dữ liệu real-time. Nó sử dụng collections và documents để tổ chức dữ liệu.

**Q2: Sự khác biệt giữa Firestore và Realtime Database?**
A:
- **Firestore**: NoSQL document database, có query phức tạp hơn, tốt cho mobile/web apps
- **Realtime Database**: JSON database, real-time sync tốt hơn, tốt cho gaming apps

**Q3: Firestore có miễn phí không?**
A: Có, Firestore có free tier với giới hạn:
- 50K reads/day
- 20K writes/day
- 20K deletes/day
- 1GB storage

---

### 🔹 Cấu Trúc Dữ Liệu

**Q4: Firestore tổ chức dữ liệu như thế nào?**
A: Firestore sử dụng cấu trúc phân cấp:
```
Collection → Document → Subcollection → Document → ...
```

Ví dụ:
```
medicines (collection)
  └── medicine1 (document)
      ├── name: "Paracetamol"
      ├── price: 15000
      └── orders (subcollection - optional)
          └── order1 (document)
```

**Q5: Document trong Firestore có giới hạn kích thước không?**
A: Có, mỗi document tối đa **1MB**. Nếu dữ liệu lớn hơn, nên chia nhỏ hoặc dùng Cloud Storage.

**Q6: Có thể lưu arrays và nested objects không?**
A: Có, Firestore hỗ trợ:
- Arrays: `[1, 2, 3]`
- Maps/Nested objects: `{key: {nested: value}}`
- Timestamps, booleans, numbers, strings, null

---

### 🔹 Queries và Indexes

**Q7: Làm sao để query dữ liệu trong Firestore?**
A: Sử dụng các methods:
```dart
// Simple query
firestore.collection('medicines')
  .where('category', isEqualTo: 'Kháng sinh')
  .get();

// With ordering
firestore.collection('medicines')
  .where('price', isGreaterThan: 10000)
  .orderBy('price')
  .limit(10)
  .get();

// Real-time stream
firestore.collection('medicines')
  .snapshots()
  .listen((snapshot) {
    // Handle updates
  });
```

**Q8: Khi nào cần composite index?**
A: Khi query sử dụng nhiều điều kiện cùng lúc:
- `where()` + `orderBy()` trên các fields khác nhau
- Nhiều `where()` trên các fields khác nhau

Firebase sẽ tự động tạo link để tạo index khi gặp lỗi.

**Q9: Làm sao tránh cần composite index?**
A: Có 2 cách:
1. **Sort client-side**: Fetch data rồi sort trong code
   ```dart
   // Thay vì:
   .where('category', isEqualTo: 'Kháng sinh')
   .orderBy('createdAt', descending: true)
   
   // Làm:
   .where('category', isEqualTo: 'Kháng sinh')
   // Rồi sort trong code
   ```

2. **Sử dụng single field queries**: Chỉ dùng `where` hoặc `orderBy` một lần

**Q10: Có thể query với nhiều điều kiện `where` không?**
A: Có, nhưng có giới hạn:
- Tối đa 1 `where` với `!=`, `<`, `<=`, `>`, `>=`
- Các `where` khác phải dùng `==` hoặc `in`
- Tất cả `where` phải cùng một field hoặc có composite index

---

### 🔹 Security Rules

**Q11: Security Rules là gì?**
A: Security Rules định nghĩa ai có thể đọc/ghi dữ liệu trong Firestore. Chúng chạy trên server, không thể bị bypass từ client.

**Q12: Cấu trúc Security Rules như thế nào?**
A:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /collection/{document} {
      allow read: if condition;
      allow write: if condition;
      // hoặc
      allow create, update, delete: if condition;
    }
  }
}
```

**Q13: Các helper functions thường dùng trong Rules?**
A:
- `request.auth != null` - User đã đăng nhập
- `request.auth.uid` - User ID
- `resource.data.field` - Dữ liệu hiện tại trong document
- `request.resource.data.field` - Dữ liệu mới khi write
- `get(/path/to/doc)` - Đọc document khác để check

**Q14: Làm sao check user role trong Rules?**
A: Đọc user document:
```javascript
function isAdmin() {
  return request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid))
           .data.role == 'admin';
}
```

**Q15: Rules có ảnh hưởng đến performance không?**
A: Có, nhưng rất nhỏ. Rules chạy trên server, mỗi read/write sẽ check rules. Nên giữ rules đơn giản và tránh đọc quá nhiều documents khác.

---

### 🔹 Real-time Updates

**Q16: Làm sao lắng nghe thay đổi real-time?**
A: Sử dụng `.snapshots()` thay vì `.get()`:
```dart
firestore.collection('medicines')
  .snapshots()
  .listen((snapshot) {
    snapshot.docChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        // Document mới được thêm
      } else if (change.type == DocumentChangeType.modified) {
        // Document được cập nhật
      } else if (change.type == DocumentChangeType.removed) {
        // Document bị xóa
      }
    });
  });
```

**Q17: StreamBuilder trong Flutter hoạt động như thế nào với Firestore?**
A: `StreamBuilder` tự động rebuild UI khi Stream emit data mới:
```dart
StreamBuilder<List<Medicine>>(
  stream: medicineService.getAllMedicines(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView(...);
    }
    return CircularProgressIndicator();
  },
)
```

---

### 🔹 Transactions và Batch Writes

**Q18: Khi nào dùng Transaction?**
A: Khi cần đảm bảo atomic operations (hoặc tất cả thành công, hoặc tất cả fail):
```dart
await firestore.runTransaction((transaction) async {
  final doc = await transaction.get(ref);
  final newStock = doc.data()!['stock'] - 1;
  transaction.update(ref, {'stock': newStock});
});
```

**Q19: Batch Write là gì?**
A: Cho phép thực hiện nhiều operations cùng lúc (tối đa 500):
```dart
final batch = firestore.batch();
batch.set(ref1, data1);
batch.update(ref2, data2);
batch.delete(ref3);
await batch.commit();
```

---

### 🔹 Best Practices

**Q20: Nên tổ chức collections như thế nào?**
A:
- **Flat structure**: Tốt cho queries đơn giản
  ```
  medicines/
  users/
  orders/
  ```
- **Nested structure**: Tốt cho dữ liệu liên quan chặt chẽ
  ```
  users/{userId}/orders/{orderId}
  ```

**Q21: Có nên lưu arrays lớn trong document không?**
A: Không, nếu array > 1000 items hoặc thay đổi thường xuyên. Nên tách thành subcollection.

**Q22: Làm sao paginate dữ liệu?**
A: Sử dụng `startAfter()` và `limit()`:
```dart
final lastDoc = snapshot.docs.last;
final nextPage = firestore.collection('medicines')
  .orderBy('createdAt')
  .startAfterDocument(lastDoc)
  .limit(20)
  .get();
```

**Q23: Có nên dùng offline persistence không?**
A: Có, Firestore tự động cache data. Enable trong code:
```dart
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

### 🔹 Troubleshooting

**Q24: Lỗi "Missing or insufficient permissions" là gì?**
A: Security Rules không cho phép operation này. Kiểm tra:
1. Rules đã được publish chưa?
2. User có đủ quyền không?
3. Điều kiện trong rules có đúng không?

**Q25: Lỗi "The query requires an index" là gì?**
A: Query cần composite index. Click vào link trong error để tạo index tự động, hoặc vào Firebase Console → Firestore → Indexes.

**Q26: Tại sao query chậm?**
A: Có thể do:
- Thiếu index
- Query quá phức tạp
- Dữ liệu quá lớn
- Network chậm

**Q27: Làm sao debug Security Rules?**
A: Sử dụng Rules Playground trong Firebase Console để test rules với mock data.

**Q28: Có thể backup Firestore data không?**
A: Có, sử dụng:
- Firebase Console → Firestore → Export
- Hoặc `gcloud firestore export`

---

### 🔹 Integration với Flutter

**Q29: Package nào cần cài để dùng Firestore trong Flutter?**
A:
```yaml
dependencies:
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4
```

**Q30: Có cần khởi tạo Firebase trước khi dùng Firestore không?**
A: Có, phải gọi `Firebase.initializeApp()` trước:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Q31: Làm sao convert Firestore Timestamp sang DateTime?**
A:
```dart
final timestamp = doc.data()['createdAt'] as Timestamp;
final dateTime = timestamp.toDate();
```

**Q32: Làm sao convert DateTime sang Firestore Timestamp?**
A:
```dart
// Tự động convert khi save
await ref.set({
  'createdAt': DateTime.now(),
});

// Hoặc explicit
await ref.set({
  'createdAt': Timestamp.fromDate(DateTime.now()),
});
```

---

## 📚 Tài Liệu Tham Khảo

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Queries](https://firebase.google.com/docs/firestore/query-data/queries)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

## 🎯 Kết Luận

Tài liệu này cung cấp overview toàn diện về cấu trúc project và cách kết nối Firestore. Nếu có thắc mắc, hãy tham khảo phần Câu Hỏi Vấn Đáp hoặc tài liệu chính thức của Firebase.

**Chúc bạn code vui vẻ! 🚀**

