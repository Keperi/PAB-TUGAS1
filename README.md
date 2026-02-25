# PEMOGRAMAN APLIKASI BERGERAK TUGAS 1
1. Nama: Fikri Abiyyu Rahman
2. NIM: 2409116063

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
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
    required this.category,
  });
}
```
<p>Ini adalah file model yang merepresentasikan data sebuah produk di dalam aplikasi. Di Flutter, model seperti ini biasanya dibuat terpisah supaya struktur datanya jelas dan bisa dipakai di mana saja.</p>
<p>Di dalamnya hanya ada satu class yaitu Product yang berisi beberapa properti — id sebagai pengenal unik tiap produk, name untuk nama produk, price untuk harga, emoji sebagai gambar sederhana pengganti foto produk, category untuk filter dan description untuk deskripsi singkat. Semua properti ini bersifat final artinya datanya tidak bisa diubah setelah produk dibuat. File ini dipakai di hampir semua bagian aplikasi, mulai dari menampilkan daftar produk sampai menyimpan data produk di dalam keranjang belanja.</p>

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
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFE63946)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Clear Cart?',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            content:
                                const Text('Remove all items from cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel',
                                    style: TextStyle(color: Colors.grey[600])),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CartModel>().clear();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear',
                                    style:
                                        TextStyle(color: Color(0xFFE63946))),
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
                  const Text('🛒', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    child: const Text('Continue Shopping',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.itemsList.length,
                  itemBuilder: (context, index) {
                    final product = cart.itemsList[index].product;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF0F4FF),
                                    Color(0xFFE8F0FE)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(product.emoji,
                                    style: const TextStyle(fontSize: 36)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatRupiah(product.price),
                                    style: const TextStyle(
                                      color: Color(0xFF2ECC71),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Consumer<CartModel>(
                                    builder: (context, cart, _) {
                                      final cartItem =
                                          cart.items[product.id];
                                      if (cartItem == null)
                                        return const SizedBox.shrink();
                                      return Row(
                                        children: [
                                          _QtyButton(
                                            icon: Icons.remove,
                                            onTap: () => cart
                                                .decreaseQuantity(product.id),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _QtyButton(
                                            icon: Icons.add,
                                            onTap: () => cart
                                                .increaseQuantity(product.id),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Consumer<CartModel>(
                              builder: (context, cart, _) {
                                final cartItem = cart.items[product.id];
                                if (cartItem == null)
                                  return const SizedBox.shrink();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        cart.removeItem(product.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${product.name} removed'),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor:
                                                const Color(0xFF1A1A2E),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete_outline,
                                          color: Color(0xFFE63946), size: 20),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatRupiah(cartItem.totalPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A2E),
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

              // ── Bottom Bar ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${cart.totalQuantity} item(s)',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500])),
                              Text(
                                formatRupiah(cart.totalPrice),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CheckoutPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: const Row(
                                children: [
                                  Text('Checkout',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800)),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1A1A2E)),
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

## checkout_page.dart
```dart
// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../utils/currency_formatter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'bank_transfer';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _placeOrder(CartModel cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Show success
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SuccessDialog(
        name: _nameController.text,
        total: cart.totalPrice,
        itemCount: cart.totalQuantity,
        onDone: () {
          cart.clear();
          Navigator.of(ctx).pop();
          // Pop checkout + cart pages back to product list
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, _) {
        const double shippingCost = 25000;
        final double tax = cart.totalPrice * 0.11;
        final double grandTotal = cart.totalPrice + shippingCost + tax;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Color(0xFF1A1A2E)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Checkout',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.4,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Order Summary ───────────────────────────────────────
                _SectionCard(
                  title: 'Order Summary',
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: [
                      ...cart.itemsList.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F4FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(item.product.emoji,
                                        style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                      Text(
                                          '${formatRupiah(item.product.price)} × ${item.quantity}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500])),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatRupiah(item.totalPrice),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      _PriceLine(
                          label: 'Subtotal',
                          value: formatRupiah(cart.totalPrice)),
                      const SizedBox(height: 6),
                      _PriceLine(
                          label: 'Shipping',
                          value: formatRupiah(shippingCost)),
                      const SizedBox(height: 6),
                      _PriceLine(
                          label: 'Tax (11%)',
                          value: formatRupiah(tax)),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                          Text(
                            formatRupiah(grandTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Shipping Info ───────────────────────────────────────
                _SectionCard(
                  title: 'Shipping Information',
                  icon: Icons.local_shipping_outlined,
                  child: Column(
                    children: [
                      _FormField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              controller: _phoneController,
                              label: 'Phone',
                              hint: '08xx-xxxx-xxxx',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.trim().length < 9
                                  ? 'Enter valid phone'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FormField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v != null && v.contains('@')
                                      ? null
                                      : 'Enter valid email',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        controller: _addressController,
                        label: 'Street Address',
                        hint: 'Jl. Contoh No. 123',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Address is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _FormField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'Jakarta',
                              icon: Icons.location_city_outlined,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FormField(
                              controller: _postalController,
                              label: 'Postal Code',
                              hint: '12345',
                              icon: Icons.markunread_mailbox_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (v) =>
                                  v != null && v.length >= 5
                                      ? null
                                      : 'Invalid',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        controller: _notesController,
                        label: 'Delivery Notes (optional)',
                        hint: 'Leave at door, ring twice...',
                        icon: Icons.note_alt_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Payment Method ──────────────────────────────────────
                _SectionCard(
                  title: 'Payment Method',
                  icon: Icons.payment_outlined,
                  child: Column(
                    children: [
                      _PaymentOption(
                        value: 'bank_transfer',
                        groupValue: _paymentMethod,
                        label: 'Bank Transfer',
                        subtitle: 'BCA, Mandiri, BNI, BRI',
                        emoji: '🏦',
                        onChanged: (v) =>
                            setState(() => _paymentMethod = v!),
                      ),
                      _PaymentOption(
                        value: 'e_wallet',
                        groupValue: _paymentMethod,
                        label: 'E-Wallet',
                        subtitle: 'GoPay, OVO, Dana, ShopeePay',
                        emoji: '📲',
                        onChanged: (v) =>
                            setState(() => _paymentMethod = v!),
                      ),
                      _PaymentOption(
                        value: 'cod',
                        groupValue: _paymentMethod,
                        label: 'Cash on Delivery',
                        subtitle: 'Pay when your order arrives',
                        emoji: '💵',
                        onChanged: (v) =>
                            setState(() => _paymentMethod = v!),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Place Order Button ──────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isProcessing ? null : () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      disabledBackgroundColor:
                          const Color(0xFF1A1A2E).withOpacity(0.6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Place Order · ${formatRupiah(grandTotal)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(icon, size: 16, color: const Color(0xFF5B6AF6)),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, size: 18, color: Colors.grey[400]),
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
        hintStyle:
            TextStyle(fontSize: 13, color: Colors.grey[300]),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5B6AF6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE63946)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE63946), width: 1.5),
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;

  const _PriceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final String subtitle;
  final String emoji;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEEF0FF)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B6AF6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: selected
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey[700])),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF5B6AF6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success Dialog ─────────────────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final String name;
  final double total;
  final int itemCount;
  final VoidCallback onDone;

  const _SuccessDialog({
    required this.name,
    required this.total,
    required this.itemCount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you, ${name.split(' ').first}! 🎉',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Items', value: '$itemCount item(s)'),
                  const SizedBox(height: 8),
                  _SummaryRow(
                      label: 'Total', value: formatRupiah(total)),
                  const SizedBox(height: 8),
                  _SummaryRow(
                      label: 'Estimated Delivery',
                      value: '3–5 business days'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Shopping',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
```
<p>
  Di halaman ini user akan dapat menampilkan grid produk lengkap dengan fitur search dan filter kategori.
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

// ── Data ─────────────────────────────────────────────────────────────────────
final List<Product> kProducts = [
  Product(
    id: '1',
    name: 'Laptop Gaming',
    price: 15000000,
    emoji: '💻',
    description: 'Laptop gaming performa tinggi',
    category: 'Electronics',
  ),
  Product(
    id: '2',
    name: 'Smartphone Pro',
    price: 8000000,
    emoji: '📱',
    description: 'Smartphone flagship terbaru',
    category: 'Electronics',
  ),
  Product(
    id: '3',
    name: 'Wireless Headphones',
    price: 1500000,
    emoji: '🎧',
    description: 'Headphones noise-cancelling',
    category: 'Audio',
  ),
  Product(
    id: '4',
    name: 'Smart Watch',
    price: 3000000,
    emoji: '⌚',
    description: 'Smartwatch dengan health tracking',
    category: 'Wearables',
  ),
  Product(
    id: '5',
    name: 'Camera DSLR',
    price: 12000000,
    emoji: '📷',
    description: 'Kamera DSLR profesional',
    category: 'Photography',
  ),
  Product(
    id: '6',
    name: 'Tablet Pro',
    price: 7000000,
    emoji: '📟',
    description: 'Tablet untuk produktivitas',
    category: 'Electronics',
  ),
  Product(
    id: '7',
    name: 'Bluetooth Speaker',
    price: 800000,
    emoji: '🔊',
    description: 'Speaker portabel tahan air',
    category: 'Audio',
  ),
  Product(
    id: '8',
    name: 'Fitness Band',
    price: 500000,
    emoji: '🏃',
    description: 'Pelacak aktivitas harian',
    category: 'Wearables',
  ),
  Product(
    id: '9',
    name: 'Drone Camera',
    price: 9500000,
    emoji: '🚁',
    description: 'Drone dengan kamera 4K',
    category: 'Photography',
  ),
];

const List<String> kCategories = [
  'All',
  'Electronics',
  'Audio',
  'Wearables',
  'Photography',
];

// ── Page ──────────────────────────────────────────────────────────────────────
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return kProducts.where((p) {
      final matchSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

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
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Shop',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFF1A1A2E)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
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
                          color: Color(0xFFE63946),
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
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
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.grey[400],
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = kCategories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1A1A2E)
                            : const Color(0xFFF0F0F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Product grid ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔍',
                            style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No products found',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return _ProductCard(
                        product: product,
                        onAddToCart: () =>
                            _showAddToCartSheet(context, product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF0F4FF),
                    const Color(0xFFE8F0FE),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(product.emoji,
                        style: const TextStyle(fontSize: 56)),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B6AF6),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(product.price),
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 14),
                        SizedBox(width: 4),
                        Text('Add',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Sheet ──────────────────────────────────────────────────────────────
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
    for (int i = 0; i < _quantity; i++) {
      cart.addItem(widget.product);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_quantity}x ${widget.product.name} added to cart!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0F4FF), Color(0xFFE8F0FE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      Text(product.emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${formatRupiah(product.price)} / item',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5B6AF6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  _CircleButton(
                      icon: Icons.remove, onTap: _decrease, enabled: _quantity > 1),
                  SizedBox(
                    width: 48,
                    child: Text('$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _CircleButton(
                      icon: Icons.add, onTap: _increase, enabled: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500])),
                  Text(
                    formatRupiah(subtotal),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Cart',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _CircleButton(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFF1A1A2E) : Colors.grey[200],
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? Colors.white : Colors.grey[400]),
      ),
    );
  }
}
```
<p>
  Pada halaman ini akan memunculkan tombol Checkout dari halaman keranjang. Halaman ini terdiri dari 3 bagian yaitu Order Summary (Ringkasan Pesanan), Shipping Information (Form Pengiriman), Payment Method (Metode Pembayaran).
</p>


# DOKUMENTASI PROGRAM
<img width="1080" height="2280" alt="Screenshot_1772008861" src="https://github.com/user-attachments/assets/fea5741f-72f3-4216-9da7-0683abd349ef" />
<img width="1080" height="2280" alt="Screenshot_1772008913" src="https://github.com/user-attachments/assets/756a0501-2041-44b1-8012-11b2d9a0f7b8" />
<img width="1080" height="2280" alt="Screenshot_1772008919" src="https://github.com/user-attachments/assets/ebf9c4bd-2e95-4c67-be04-4ae311917698" />
<img width="1080" height="2280" alt="Screenshot_1772008926" src="https://github.com/user-attachments/assets/8910875b-a6f0-4486-8317-6ca7706f5567" />
<img width="1080" height="2280" alt="Screenshot_1772008946" src="https://github.com/user-attachments/assets/6e43f13f-82fa-48ca-b8e9-2da6e007e561" />

