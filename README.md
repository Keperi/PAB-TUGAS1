# PEMOGRAMAN APLIKASI BERGERAK TUGAS 1
<p>Aplikasi Shopping Cart ini adalah aplikasi belanja sederhana berbasis Flutter yang menampilkan daftar produk elektronik. User dapat mencari produk, menyaring berdasarkan kategori, menambahkan produk ke keranjang belanja, lalu melanjutkan ke halaman checkout untuk menyelesaikan pembelian.</p>
<p>Aplikasi ini dibangun menggunakan konsep State Management dengan package provider, sehingga perubahan data seperti penambahan item ke keranjang langsung tercermin di seluruh bagian aplikasi secara real-time tanpa perlu reload halaman.</p>

## pubspec.yaml
```dart
name: tugas_flutterpart5
description: "A new Flutter project."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.11.0

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```
<p>Ini adalah file konfigurasi utama dari sebuah project Flutter. Setiap project Flutter pasti punya file ini, fungsinya seperti daftar kebutuhan project — mulai dari identitas aplikasi, versi Dart yang dipakai, sampai library-library tambahan yang digunakan.</p>
<p>Di dalam file ini ada beberapa bagian utama. Pertama ada identitas project yang berisi nama, deskripsi, dan versi aplikasi. Lalu ada environment yang menentukan versi Dart SDK yang kompatibel. Ada juga dependencies yaitu daftar library yang dibutuhkan saat aplikasi berjalan, di project ini ada provider untuk state management dan intl untuk format mata uang Rupiah. Selain itu ada dev dependencies yang berisi library yang hanya dipakai saat proses development dan tidak ikut terbawa ke aplikasi final. Terakhir ada Flutter config yang mengaktifkan Material Design icons dan mendaftarkan font custom Poppins yang dipakai di seluruh aplikasi.</p>

## currency_formatter.dart
```dart
import 'package:intl/intl.dart';

final _formatter = NumberFormat('#,###', 'id_ID');

/// Mengubah angka menjadi format Rupiah, contoh: 15000000 → "Rp 15.000.000"
String formatRupiah(double amount) {
  return 'Rp ${_formatter.format(amount.toInt())}';
}
```
<p>Ini adalah file utilitas yang tugasnya cuma satu — mengubah angka biasa menjadi format harga Rupiah yang enak dibaca. File ini dibuat terpisah supaya kalau suatu saat ada perubahan format harga, cukup ubah di satu tempat ini saja, tidak perlu ubah satu-satu di setiap halaman.</p>
<p>Di dalamnya ada dua hal. Pertama ada objek NumberFormat dari package intl yang dikonfigurasi untuk menggunakan format angka Indonesia, jadi pemisah ribuannya pakai titik bukan koma, contohnya 15000000 jadi 15.000.000. Kedua ada fungsi formatRupiah() yang menerima angka dan mengembalikan string siap tampil ke layar, contohnya formatRupiah(15000000) menghasilkan "Rp 15.000.000". Fungsi ini dipakai di product_list_page.dart dan cart_page.dart untuk menampilkan semua harga di aplikasi.</p>

## product.dart
```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String emoji;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
  });
}
```
<p>Ini adalah file model yang merepresentasikan data sebuah produk di dalam aplikasi. Di Flutter, model seperti ini biasanya dibuat terpisah supaya struktur datanya jelas dan bisa dipakai di mana saja.</p>
<p>Di dalamnya hanya ada satu class yaitu Product yang berisi beberapa properti — id sebagai pengenal unik tiap produk, name untuk nama produk, price untuk harga, emoji sebagai gambar sederhana pengganti foto produk, dan description untuk deskripsi singkat. Semua properti ini bersifat final artinya datanya tidak bisa diubah setelah produk dibuat. File ini dipakai di hampir semua bagian aplikasi, mulai dari menampilkan daftar produk sampai menyimpan data produk di dalam keranjang belanja.</p>

## cart_item.dart
```dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
```
<p>
  Ini adalah file model yang merepresentasikan sebuah item yang ada di dalam keranjang belanja. Berbeda dengan product.dart yang hanya menyimpan data produk, file ini menyimpan data produk sekaligus berapa banyak produk tersebut ditambahkan ke keranjang.
</p>
<p>
  Di dalamnya ada satu class yaitu CartItem yang berisi dua properti utama — product yang menyimpan data produk aslinya, dan quantity yang menyimpan jumlah produk tersebut di keranjang. Selain itu ada satu getter bernama totalPrice yang secara otomatis menghitung harga total dengan mengalikan harga produk dengan jumlahnya. Jadi misalnya kamu tambah Laptop Gaming sebanyak 3, maka totalPrice akan otomatis menghitung 15.000.000 x 3 = 45.000.000. File ini dipakai di cart_model.dart untuk menyimpan dan mengelola semua item yang ada di keranjang.
</p>

## cart_model.dart
```dart
// lib/models/cart_model.dart
import 'package:flutter/foundation.dart';
import 'product.dart';
import 'cart_item.dart';

class CartModel extends ChangeNotifier {
  // Private state - Map for O(1) lookup
  final Map<String, CartItem> _items = {};

  // Getters
  Map<String, CartItem> get items => _items;

  List<CartItem> get itemsList => _items.values.toList();

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isEmpty => _items.isEmpty;

  // Methods
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Product already in cart, increase quantity
      _items[product.id]!.quantity++;
    } else {
      // New product, add to cart
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners(); // ← Notify UI!
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      // If quantity becomes 0, remove item
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```
<p>
   Ini adalah file yang mengatur semua logika keranjang belanja. Di Flutter, file seperti ini disebut sebagai state management — artinya dia yang bertanggung jawab menyimpan data keranjang dan memberitahu UI untuk update tampilannya setiap kali ada perubahan.
</p>
<p>
  Di dalamnya ada satu class yaitu CartModel yang extends ChangeNotifier. ChangeNotifier ini yang membuat semua widget yang mendengarkan CartModel bisa otomatis update tampilannya saat data berubah. Data keranjangnya disimpan dalam bentuk Map dengan id produk sebagai key-nya, tujuannya supaya pencarian produk di keranjang bisa dilakukan dengan cepat.
</p>
<p>
  Di dalamnya juga ada beberapa method yang bisa dipanggil dari halaman manapun — addItem() untuk menambah produk ke keranjang, removeItem() untuk menghapus produk, increaseQuantity() dan decreaseQuantity() untuk mengubah jumlah produk, dan clear() untuk mengosongkan seluruh keranjang. Selain method, ada juga beberapa getter seperti totalPrice untuk menghitung total harga dan totalQuantity untuk menghitung total jumlah item di keranjang.
</p>

## main.dart
```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'pages/product_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProductListPage(),
    );
  }
}
```
<p>
  Ini adalah titik awal dari aplikasi Flutter. Setiap aplikasi Flutter pasti punya file ini, dan dia yang pertama kali dijalankan saat aplikasi dibuka.
Di dalamnya ada fungsi main() yang merupakan fungsi utama 
</p>
<p>
  Di dalamnya ada fungsi main() yang merupakan fungsi utama yang dijalankan pertama kali. Di dalam fungsi ini aplikasi dibungkus dengan ChangeNotifierProvider dari package provider, tujuannya supaya CartModel bisa diakses dari halaman manapun di dalam aplikasi tanpa perlu dikirim manual satu-satu antar halaman.
</p>
<p>
  Selain itu ada class MyApp yang berisi konfigurasi dasar aplikasi seperti tema warna, font yang dipakai yaitu Poppins, dan halaman pertama yang ditampilkan saat aplikasi dibuka yaitu ProductListPage. Singkatnya file ini adalah tempat dimana semua bagian aplikasi dirakit dan dijalankan bersama.
</p>

## product_list_page.dart
```dart
// lib/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import '../utils/currency_formatter.dart';
import 'cart_page.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  // Tampilkan bottom sheet untuk pilih quantity sebelum masuk cart
  void _showAddToCartSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddToCartSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy products
    final products = [
      Product(
        id: '1',
        name: 'Laptop Gaming',
        price: 15000000,
        emoji: '💻',
        description: 'Laptop gaming performa tinggi',
      ),
      Product(
        id: '2',
        name: 'Smartphone Pro',
        price: 8000000,
        emoji: '📱',
        description: 'Smartphone flagship terbaru',
      ),
      Product(
        id: '3',
        name: 'Wireless Headphones',
        price: 1500000,
        emoji: '🎧',
        description: 'Headphones noise-cancelling',
      ),
      Product(
        id: '4',
        name: 'Smart Watch',
        price: 3000000,
        emoji: '⌚',
        description: 'Smartwatch dengan health tracking',
      ),
      Product(
        id: '5',
        name: 'Camera DSLR',
        price: 12000000,
        emoji: '📷',
        description: 'Kamera DSLR profesional',
      ),
      Product(
        id: '6',
        name: 'Tablet Pro',
        price: 7000000,
        emoji: '📟',
        description: 'Tablet untuk produktivitas',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Cart badge
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.totalQuantity > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 3,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.deepPurple.shade50,
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(product.price),
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          // Sekarang buka bottom sheet dulu
                          onPressed: () => _showAddToCartSheet(context, product),
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Bottom Sheet ──────────────────────────────────────────────────────────────
// StatefulWidget karena perlu menyimpan state quantity sementara di sheet ini

class _AddToCartSheet extends StatefulWidget {
  final Product product;
  const _AddToCartSheet({required this.product});

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  int _quantity = 1;

  void _increase() => setState(() => _quantity++);
  void _decrease() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _addToCart() {
    final cart = context.read<CartModel>();

    // Tambahkan sebanyak _quantity kali
    for (int i = 0; i < _quantity; i++) {
      cart.addItem(widget.product);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_quantity}x ${widget.product.name} ditambahkan ke cart!',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final subtotal = product.price * _quantity;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Produk info: emoji + nama + harga satuan
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(product.emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatRupiah(product.price)} / item',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Label + quantity controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  // Tombol kurang
                  _CircleButton(
                    icon: Icons.remove,
                    onTap: _decrease,
                    enabled: _quantity > 1,
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Tombol tambah
                  _CircleButton(
                    icon: Icons.add,
                    onTap: _increase,
                    enabled: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider tipis
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),

          // Subtotal + tombol Done
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    formatRupiah(subtotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Tombol bulat untuk +/-
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? Colors.blue : Colors.grey[200],
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }
}
```
<p>
  Ini adalah halaman utama yang pertama kali dilihat user saat membuka aplikasi. Di sini ditampilkan semua daftar produk yang tersedia dalam bentuk grid dua kolom.
</p>
<p>
  Di dalamnya ada beberapa bagian. Pertama ada daftar produk yang berisi enam produk dummy lengkap dengan nama, harga, emoji, dan deskripsinya. Lalu ada AppBar di bagian atas yang menampilkan ikon keranjang belanja beserta badge merah yang menunjukkan total jumlah item yang sudah ditambahkan ke keranjang. Badge ini otomatis update setiap kali ada produk yang ditambahkan.
</p>
<p>
  Di bagian body ada GridView yang menampilkan semua produk dalam bentuk card. Setiap card berisi emoji produk, nama, harga yang sudah diformat menggunakan formatRupiah(), dan tombol Add. Yang membedakan dari versi sebelumnya, tombol Add sekarang tidak langsung memasukkan produk ke keranjang — melainkan membuka bottom sheet terlebih dahulu. Di dalam bottom sheet tersebut user bisa memilih berapa jumlah produk yang ingin ditambahkan, melihat subtotal harga secara langsung, lalu menekan tombol Add to Cart untuk memasukkan ke keranjang.
</p>

## cart_page.dart
```dart
// lib/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../utils/currency_formatter.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // Clear cart button
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Cart?'),
                            content: const Text('Remove all items from cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CartModel>().clear();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.itemsList.length,
                  itemBuilder: (context, index) {
                    // FIX: ambil product dari snapshot stabil, bukan cartItem langsung
                    // supaya tidak stale saat quantity berubah
                    final product = cart.itemsList[index].product;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Product emoji
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatRupiah(product.price), // FIX: format dengan pemisah ribuan
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // FIX: Quantity controls dibungkus Consumer tersendiri
                                  // agar quantity & subtotal reactive saat +/- ditekan
                                  Consumer<CartModel>(
                                    builder: (context, cart, _) {
                                      final cartItem = cart.items[product.id];
                                      if (cartItem == null) return const SizedBox.shrink();
                                      return Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              cart.decreaseQuantity(product.id);
                                            },
                                            icon: const Icon(Icons.remove_circle_outline),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              cart.increaseQuantity(product.id);
                                            },
                                            icon: const Icon(Icons.add_circle_outline),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Remove button & subtotal
                            // FIX: subtotal juga dibungkus Consumer agar reactive
                            Consumer<CartModel>(
                              builder: (context, cart, _) {
                                final cartItem = cart.items[product.id];
                                if (cartItem == null) return const SizedBox.shrink();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        cart.removeItem(product.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${product.name} removed'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                    Text(
                                      formatRupiah(cartItem.totalPrice), // FIX: format dengan pemisah ribuan
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total price bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formatRupiah(cart.totalPrice), // FIX: format dengan pemisah ribuan
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Checkout'),
                              content: Text(
                                'Total: ${formatRupiah(cart.totalPrice)}\nItems: ${cart.totalQuantity}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    cart.clear();
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order placed!')),
                                    );
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```
<p>
  Ini adalah halaman keranjang belanja yang bisa diakses dengan menekan ikon keranjang di AppBar halaman utama. Di sini user bisa melihat semua produk yang sudah ditambahkan, mengubah jumlahnya, menghapusnya, dan melakukan checkout.
</p>
<p>
  Di dalamnya ada beberapa bagian. Pertama ada AppBar yang menampilkan jumlah total item di keranjang dan tombol hapus semua item di pojok kanan. Kalau keranjang kosong, halaman ini akan menampilkan tampilan khusus empty state dengan tombol untuk kembali ke halaman produk.
</p>
<p>
  Di bagian body ada ListView yang menampilkan semua item di keranjang. Setiap item menampilkan emoji produk, nama, harga satuan, tombol plus minus untuk mengubah jumlah, subtotal harga per item, dan tombol hapus. Bagian quantity controls dan subtotal dibungkus dengan Consumer tersendiri supaya angkanya langsung update secara real-time saat tombol plus minus ditekan tanpa perlu reload halaman.
</p>
<p>
  Di bagian bawah ada total bar yang menampilkan total keseluruhan harga dan tombol Checkout. Saat tombol Checkout ditekan akan muncul dialog konfirmasi yang menampilkan ringkasan pesanan, dan jika dikonfirmasi maka keranjang akan dikosongkan dan user kembali ke halaman utama.
</p>

# DOKUMENTASI PROGRAM
<img width="407" height="864" alt="image" src="https://github.com/user-attachments/assets/df196514-2360-473c-9c13-4a2be4040c4b" />
<img width="407" height="864" alt="image" src="https://github.com/user-attachments/assets/bf5e649d-7aa3-4042-b6fb-4bc5eb38f0b2" />
<img width="407" height="864" alt="image" src="https://github.com/user-attachments/assets/247d5d27-2a7f-40b2-bc86-6e4c085cd24a" />
