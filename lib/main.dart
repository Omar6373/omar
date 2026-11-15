import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

const orange = Color(0xffff792d);
const ownerUid = '0tIk0W8QrJZLYwORAwGyrZHhndC2';
const ownerEmail = 'omarayad83@gmail.com';
const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const appId = String.fromEnvironment('FIREBASE_APP_ID');
const senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const bucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: apiKey, appId: appId, messagingSenderId: senderId,
      projectId: projectId, storageBucket: bucket,
    ));
  }
  runApp(const App());
}
class App extends StatelessWidget {
  const App({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'OMAR STORE',
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(primary: orange, surface: Color(0xff1a1a1a)),
    ),
    home: const Directionality(textDirection: TextDirection.rtl, child: Splash()),
  );
}
class Splash extends StatefulWidget {
  const Splash({super.key});
  @override State<Splash> createState() => _SplashState();
}
class _SplashState extends State<Splash> {
  VideoPlayerController? _video;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startIntro();
  }

  Future<void> _startIntro() async {
    try {
      final controller = VideoPlayerController.asset('assets/intro.mp4');
      _video = controller;
      await controller.initialize();
      if (!mounted) return;
      controller.addListener(() {
        if (!_finished &&
            controller.value.isInitialized &&
            controller.value.position >= controller.value.duration &&
            controller.value.duration > Duration.zero) {
          _goToCatalog();
        }
      });
      setState(() {});
      await controller.play();
    } catch (_) {
      _goToCatalog();
    }
  }

  void _goToCatalog() {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl, child: Welcome()),
    ));
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: _video != null && _video!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _video!.value.aspectRatio,
            child: VideoPlayer(_video!),
          )
        : const SizedBox.shrink(),
    ),
  );
}

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override State<Welcome> createState() => _WelcomeState();
}
class _WelcomeState extends State<Welcome> {
  final AudioPlayer _player = AudioPlayer();
  bool _entering = false;
  Future<void> _enter() async {
    if (_entering) return;
    setState(() => _entering = true);
    try {
      await _player.play(AssetSource('sounds/enter.wav'));
      await Future<void>.delayed(const Duration(milliseconds: 550));
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl, child: Catalog())));
  }
  @override void dispose() {
    _player.dispose();
    super.dispose();
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(fit: StackFit.expand, children: [
      Image.asset(
        'assets/welcome.png',
        fit: BoxFit.fill,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xff090909), Color(0xff2a1000), Colors.black])),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('OS', style: TextStyle(color: orange, fontSize: 92, fontWeight: FontWeight.w900)),
            Text('OMAR STORE', style: TextStyle(color: orange, fontSize: 36, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('برامج مدفوعة + ألعاب مدفوعة', style: TextStyle(color: Colors.white, fontSize: 22)),
            SizedBox(height: 12),
            Text('و العديد من المحتويات المميزة', style: TextStyle(color: Colors.white70, fontSize: 18)),
            SizedBox(height: 90),
            Icon(Icons.android, color: orange, size: 100),
          ])),
        ),
      Positioned(
        left: 0, right: 0, bottom: 0, height: MediaQuery.sizeOf(context).height * .29,
        child: Semantics(
          button: true, label: 'اضغط للدخول',
          child: Material(color: Colors.transparent, child: InkWell(
            onTap: _enter,
            child: const SizedBox.expand(),
          )),
        ),
      ),
    ]),
  );
}

class Catalog extends StatefulWidget {
  const Catalog({super.key});
  @override State<Catalog> createState() => _CatalogState();
}
class _CatalogState extends State<Catalog> {
  String type = 'game', query = '';
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.black,
      title: const Text('OMAR STORE', style: TextStyle(color: orange, fontWeight: FontWeight.bold)),
      actions: [IconButton(icon: const Icon(Icons.admin_panel_settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Admin())))],
    ),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        SegmentedButton<String>(segments: const [
          ButtonSegment(value: 'game', label: Text('الألعاب'), icon: Icon(Icons.sports_esports)),
          ButtonSegment(value: 'app', label: Text('البرامج'), icon: Icon(Icons.apps)),
        ], selected: {type}, onSelectionChanged: (v) => setState(() => type = v.first)),
        const SizedBox(height: 14),
        TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث عن لعبة أو برنامج', border: OutlineInputBorder()), onChanged: (v) => setState(() => query = v.toLowerCase())),
      ])),
      Expanded(child: Firebase.apps.isEmpty
        ? const Center(child: Text('يجب ربط Firebase لعرض المنشورات'))
        : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('posts').where('type', isEqualTo: type).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('تعذر تحميل المنشورات'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final posts = snapshot.data!.docs.where((d) => (d.data()['title'] ?? '').toString().toLowerCase().contains(query)).toList();
            if (posts.isEmpty) return const Center(child: Text('ماكو إضافات حالياً'));
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .72, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemBuilder: (context, index) {
                final d = posts[index].data();
                return Card(clipBehavior: Clip.antiAlias, child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Directionality(textDirection: TextDirection.rtl, child: Details(data: d)))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: cover(d['imageUrl']?.toString() ?? '', d['imageBase64']?.toString())),
                    Padding(padding: const EdgeInsets.all(10), child: Text(d['title']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
                    const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10), child: Text('عرض التفاصيل', style: TextStyle(color: orange))),
                  ]),
                ));
              },
            );
          },
        )),
    ]),
  );
}
Widget cover(String url, [String? imageBase64]) {
  if (imageBase64 != null && imageBase64.isNotEmpty) {
    try {
      return Image.memory(base64Decode(imageBase64), fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)));
    } catch (_) {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
  return url.isEmpty
    ? const Center(child: Icon(Icons.sports_esports, color: orange, size: 55))
    : Image.network(url, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)));
}
class Details extends StatelessWidget {
  final Map<String, dynamic> data;
  const Details({super.key, required this.data});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(data['title']?.toString() ?? 'التفاصيل')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      SizedBox(height: 230, child: cover(data['imageUrl']?.toString() ?? '', data['imageBase64']?.toString())),
      const SizedBox(height: 20),
      Text(data['title']?.toString() ?? '', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      Text(data['description']?.toString() ?? ''),
      const SizedBox(height: 22),
      FilledButton.icon(icon: const Icon(Icons.download), label: const Text('تحميل'), onPressed: () async {
        final raw = data['url']?.toString() ?? '';
        final uri = Uri.tryParse(raw);
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح رابط التحميل')));
          }
        }
      }),
    ]),
  );
}
class Admin extends StatefulWidget {
  const Admin({super.key});
  @override State<Admin> createState() => _AdminState();
}
class _AdminState extends State<Admin> {
  final password = TextEditingController();
  final title = TextEditingController(), description = TextEditingController(), url = TextEditingController();
  String type = 'game';
  XFile? picked;
  bool busy = false;
  @override void dispose() {
    for (final c in [password, title, description, url]) { c.dispose(); }
    super.dispose();
  }
  Future<void> login() async {
    setState(() => busy = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: ownerEmail, password: password.text);
      if (FirebaseAuth.instance.currentUser?.uid != ownerUid || FirebaseAuth.instance.currentUser?.email?.toLowerCase() != ownerEmail) {
        await FirebaseAuth.instance.signOut();
        throw Exception('هذا الحساب غير مخول بالإدارة');
      }
      if (mounted) setState(() {});
    } catch (e) { notify(e.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  void notify(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  Future<void> publish() async {
    if (title.text.trim().isEmpty || !url.text.trim().startsWith('https://')) {
      notify('اكتب الاسم ورابط HTTPS صحيح'); return;
    }
    setState(() => busy = true);
    try {
      String imageBase64 = '';
      if (picked != null) {
        final bytes = await picked!.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded == null) throw Exception('تعذر قراءة صورة الغلاف');
        final resized = img.copyResize(decoded, width: 400);
        final jpeg = Uint8List.fromList(img.encodeJpg(resized, quality: 60));
        if (jpeg.length > 240000) throw Exception('حجم الغلاف كبير، اختر صورة أصغر');
        imageBase64 = base64Encode(jpeg);
      }
      await FirebaseFirestore.instance.collection('posts').add({
        'title': title.text.trim(), 'description': description.text.trim(),
        'url': url.text.trim(), 'type': type, 'imageBase64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });
      title.clear(); description.clear(); url.clear();
      setState(() => picked = null);
      notify('تم النشر');
    } catch (e) { notify('فشل النشر: $e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) return const Scaffold(body: Center(child: Text('يجب إعداد Firebase أولاً')));
    final authorized = FirebaseAuth.instance.currentUser?.uid == ownerUid && FirebaseAuth.instance.currentUser?.email?.toLowerCase() == ownerEmail && ownerUid.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الإدارة')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        if (!authorized) ...[
          const ListTile(title: Text('حساب المالك'), subtitle: Text(ownerEmail)),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
          const SizedBox(height: 12),
          FilledButton(onPressed: busy ? null : login, child: const Text('دخول المالك')),
        ] else ...[
          SegmentedButton<String>(segments: const [ButtonSegment(value: 'game', label: Text('لعبة')), ButtonSegment(value: 'app', label: Text('برنامج'))], selected: {type}, onSelectionChanged: (v) => setState(() => type = v.first)),
          TextField(controller: title, decoration: const InputDecoration(labelText: 'الاسم')),
          TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف')),
          TextField(controller: url, decoration: const InputDecoration(labelText: 'رابط التحميل')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () async {
            final image = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (image != null) setState(() => picked = image);
          }, icon: const Icon(Icons.image), label: Text(picked == null ? 'اختيار صورة' : picked!.name)),
          FilledButton(onPressed: busy ? null : publish, child: const Text('نشر')),
          const Divider(height: 36),
          const Text('المنشورات الحالية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(children: snapshot.data!.docs.map((doc) => ListTile(
                title: Text(doc.data()['title']?.toString() ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                  await doc.reference.delete();
                }),
                onTap: () {
                  title.text = doc.data()['title']?.toString() ?? '';
                  description.text = doc.data()['description']?.toString() ?? '';
                  url.text = doc.data()['url']?.toString() ?? '';
                  type = doc.data()['type']?.toString() ?? 'game';
                  notify('للتعديل: غيّر الحقول ثم انشر نسخة جديدة، واحذف القديمة');
                  setState(() {});
                },
              )).toList());
            },
          ),
          TextButton(onPressed: () async { await FirebaseAuth.instance.signOut(); if (mounted) setState(() {}); }, child: const Text('تسجيل خروج')),
        ],
      ]),
    );
  }
}
