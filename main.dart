import 'dart:async';
import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ───────────── Constants ─────────────
const kApp = 'নূরনামা';
const kDev = 'মাসুম';
const kAzan = bool.fromEnvironment('AZAN');
const green = Color(0xFF0B3D2E);
const green2 = Color(0xFF14604A);
const gold = Color(0xFFD4AF37);
const cream = Color(0xFFFFF8E7);

const prayers = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];
const prayerIcons = [Icons.wb_twilight, Icons.wb_sunny, Icons.wb_sunny_outlined, Icons.nightlight_round, Icons.bedtime];
const bnMonths = ['বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'];
const hijriBn = ['মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ'];
const hijriAr = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
const enMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const wdBn = ['রবিবার', 'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার'];

class Dist {
  final String n;
  final double la, lo;
  const Dist(this.n, this.la, this.lo);
}

const dists = [
  Dist('ঢাকা', 23.81, 90.41), Dist('গাজীপুর', 23.99, 90.42), Dist('নারায়ণগঞ্জ', 23.63, 90.50), Dist('নরসিংদী', 23.92, 90.72),
  Dist('মানিকগঞ্জ', 23.86, 90.00), Dist('মুন্সিগঞ্জ', 23.55, 90.53), Dist('টাঙ্গাইল', 24.25, 89.92), Dist('কিশোরগঞ্জ', 24.43, 90.78),
  Dist('ফরিদপুর', 23.61, 89.84), Dist('রাজবাড়ী', 23.76, 89.64), Dist('গোপালগঞ্জ', 23.01, 89.83), Dist('মাদারীপুর', 23.17, 90.20),
  Dist('শরীয়তপুর', 23.22, 90.35), Dist('চট্টগ্রাম', 22.36, 91.78), Dist('কক্সবাজার', 21.43, 92.01), Dist('কুমিল্লা', 23.46, 91.18),
  Dist('ব্রাহ্মণবাড়িয়া', 23.96, 91.11), Dist('চাঁদপুর', 23.23, 90.66), Dist('ফেনী', 23.02, 91.40), Dist('লক্ষ্মীপুর', 22.94, 90.84),
  Dist('নোয়াখালী', 22.82, 91.10), Dist('খাগড়াছড়ি', 23.12, 91.98), Dist('রাঙামাটি', 22.65, 92.17), Dist('বান্দরবান', 22.20, 92.22),
  Dist('সিলেট', 24.90, 91.87), Dist('মৌলভীবাজার', 24.48, 91.77), Dist('হবিগঞ্জ', 24.37, 91.42), Dist('সুনামগঞ্জ', 25.07, 91.40),
  Dist('রাজশাহী', 24.37, 88.60), Dist('বগুড়া', 24.85, 89.37), Dist('পাবনা', 24.00, 89.23), Dist('সিরাজগঞ্জ', 24.45, 89.70),
  Dist('নাটোর', 24.42, 89.00), Dist('নওগাঁ', 24.80, 88.94), Dist('চাঁপাইনবাবগঞ্জ', 24.60, 88.28), Dist('জয়পুরহাট', 25.10, 89.02),
  Dist('খুলনা', 22.82, 89.55), Dist('যশোর', 23.17, 89.21), Dist('সাতক্ষীরা', 22.72, 89.07), Dist('বাগেরহাট', 22.65, 89.79),
  Dist('নড়াইল', 23.17, 89.50), Dist('মাগুরা', 23.49, 89.42), Dist('ঝিনাইদহ', 23.54, 89.17), Dist('কুষ্টিয়া', 23.90, 89.12),
  Dist('চুয়াডাঙ্গা', 23.64, 88.84), Dist('মেহেরপুর', 23.76, 88.63), Dist('বরিশাল', 22.70, 90.37), Dist('ভোলা', 22.69, 90.65),
  Dist('পটুয়াখালী', 22.36, 90.33), Dist('পিরোজপুর', 22.58, 89.97), Dist('ঝালকাঠি', 22.64, 90.20), Dist('বরগুনা', 22.15, 90.12),
  Dist('রংপুর', 25.75, 89.25), Dist('দিনাজপুর', 25.63, 88.64), Dist('কুড়িগ্রাম', 25.81, 89.64), Dist('গাইবান্ধা', 25.33, 89.53),
  Dist('নীলফামারী', 25.93, 88.86), Dist('লালমনিরহাট', 25.99, 89.45), Dist('ঠাকুরগাঁও', 26.03, 88.46), Dist('পঞ্চগড়', 26.34, 88.55),
  Dist('ময়মনসিংহ', 24.75, 90.41), Dist('জামালপুর', 24.92, 89.94), Dist('শেরপুর', 25.02, 90.02), Dist('নেত্রকোণা', 24.87, 90.73),
];

Dist nearest(double la, double lo) {
  var best = dists.first;
  var bd = double.infinity;
  for (final d in dists) {
    final x = (d.la - la) * (d.la - la) + (d.lo - lo) * (d.lo - lo);
    if (x < bd) {
      bd = x;
      best = d;
    }
  }
  return best;
}

// ───────────── Helpers ─────────────
String digits(Object o, String set) => o.toString().split('').map((c) {
      final i = '0123456789'.indexOf(c);
      return i < 0 ? c : set[i];
    }).join();
String bn(Object o) => digits(o, '০১২৩৪৫৬৭৮৯');
String ar(Object o) => digits(o, '٠١٢٣٤٥٦٧٨٩');

DateTime bdNow() => DateTime.now().toUtc().add(const Duration(hours: 6));
DateTime dOnly(DateTime t) => DateTime(t.year, t.month, t.day);
bool leap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

class BnDate {
  final int y, m, d;
  BnDate(this.y, this.m, this.d);
}

/// বাংলাদেশের সংশোধিত বাংলা সন (১৪ এপ্রিল = ১ বৈশাখ)
BnDate toBangla(DateTime g) {
  final day = DateTime.utc(g.year, g.month, g.day);
  var gy = g.year;
  var start = DateTime.utc(gy, 4, 14);
  if (day.isBefore(start)) {
    gy--;
    start = DateTime.utc(gy, 4, 14);
  }
  var diff = day.difference(start).inDays;
  final lens = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, leap(gy + 1) ? 30 : 29, 30];
  var m = 0;
  while (m < 11 && diff >= lens[m]) {
    diff -= lens[m];
    m++;
  }
  return BnDate(gy - 593, m, diff + 1);
}

HijriCalendar hijri(DateTime g, int adj) => HijriCalendar.fromDate(dOnly(g).add(Duration(days: adj)));
String enStr(DateTime g) => '${g.day} ${enMonths[g.month - 1]} ${g.year}';
String bnStr(DateTime g) {
  final b = toBangla(g);
  return '${bn(b.d)} ${bnMonths[b.m]} ${bn(b.y)} বঙ্গাব্দ';
}

String hiBn(DateTime g, int adj) {
  final h = hijri(g, adj);
  return '${bn(h.hDay)} ${hijriBn[h.hMonth - 1]} ${bn(h.hYear)} হিজরি';
}

String hiAr(DateTime g, int adj) {
  final h = hijri(g, adj);
  return '${ar(h.hDay)} ${hijriAr[h.hMonth - 1]} ${ar(h.hYear)} هـ';
}

String fmt(DateTime t) {
  final b = t.toUtc().add(const Duration(hours: 6));
  final h = b.hour;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  final p = h < 4 ? 'রাত' : h < 6 ? 'ভোর' : h < 12 ? 'সকাল' : h < 15 ? 'দুপুর' : h < 17 ? 'বিকাল' : h < 19 ? 'সন্ধ্যা' : 'রাত';
  return '${bn(h12)}:${bn(b.minute.toString().padLeft(2, '0'))} $p';
}

class Day {
  final List<DateTime> five; // ফজর, যোহর, আসর, মাগরিব, এশা
  final DateTime sunrise;
  Day(this.five, this.sunrise);
  DateTime get fajr => five[0];
  DateTime get sunset => five[3];
}

Day timesFor(DateTime d, Coordinates c) {
  final p = CalculationMethod.karachi.getParameters();
  p.madhab = Madhab.hanafi;
  final t = PrayerTimes(c, DateComponents.from(d), p);
  DateTime l(DateTime x) => x.toLocal();
  return Day([l(t.fajr), l(t.dhuhr), l(t.asr), l(t.maghrib), l(t.isha)], l(t.sunrise));
}

// ───────────── Notifications ─────────────
class Notif {
  static final p = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    await p.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
  }

  static Future<void> ask() async {
    final a = p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await a?.requestNotificationsPermission();
    await a?.requestExactAlarmsPermission();
  }

  static NotificationDetails details() => NotificationDetails(
        android: AndroidNotificationDetails(
          kAzan ? 'azan_v1' : 'azan_default_v1',
          'আজান',
          channelDescription: 'নামাজের ওয়াক্তে আজান',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: kAzan ? const RawResourceAndroidNotificationSound('azan') : null,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
        ),
      );

  static Future<void> _at(int id, String title, String body, DateTime when) async {
    final z = tz.TZDateTime.from(when, tz.local);
    for (final mode in [AndroidScheduleMode.exactAllowWhileIdle, AndroidScheduleMode.inexactAllowWhileIdle]) {
      try {
        await p.zonedSchedule(id, title, body, z, details(),
            androidScheduleMode: mode, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
        return;
      } catch (_) {}
    }
  }

  static Future<void> schedule(Coordinates c, List<bool> on) async {
    await p.cancelAll();
    final now = DateTime.now();
    final base = dOnly(bdNow());
    var id = 1;
    for (var d = 0; d < 10; d++) {
      final t = timesFor(base.add(Duration(days: d)), c);
      for (var i = 0; i < 5; i++) {
        id++;
        if (!on[i] || !t.five[i].isAfter(now)) continue;
        await _at(id, 'আজান - ${prayers[i]}', '${prayers[i]} নামাজের ওয়াক্ত হয়েছে', t.five[i]);
      }
    }
  }

  static Future<void> test() => _at(9999, 'আজান পরীক্ষা', 'এটি একটি পরীক্ষামূলক আজান', DateTime.now().add(const Duration(seconds: 10)));
}

// ───────────── State ─────────────
class AppState extends ChangeNotifier {
  double lat = 23.81, lon = 90.41;
  String place = 'ঢাকা';
  List<bool> on = List.filled(5, true);
  int adj = 0;
  String note = '';
  late SharedPreferences sp;
  Coordinates get c => Coordinates(lat, lon);

  Future<void> load() async {
    sp = await SharedPreferences.getInstance();
    adj = sp.getInt('adj') ?? 0;
    final s = sp.getString('on');
    if (s != null && s.length == 5) on = s.split('').map((e) => e == '1').toList();
    if (sp.containsKey('lat')) {
      lat = sp.getDouble('lat')!;
      lon = sp.getDouble('lon')!;
      place = sp.getString('place') ?? place;
      notifyListeners();
    } else {
      await gps();
    }
    await Notif.ask();
    await Notif.schedule(c, on);
  }

  Future<void> gps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        note = 'ফোনের লোকেশন (GPS) চালু করুন';
        notifyListeners();
        return;
      }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        note = 'লোকেশনের অনুমতি দিন, অথবা সেটিংসে জেলা বেছে নিন';
        notifyListeners();
        return;
      }
      final pos = desiredAccuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 25));
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 25)));
      if (pos.latitude < 20.5 || pos.latitude > 26.7 || pos.longitude < 88.0 || pos.longitude > 92.8) {
        note = 'আপনি বাংলাদেশের বাইরে আছেন, সেটিংসে জেলা বেছে নিন';
        notifyListeners();
        return;
      }
      note = '';
      await setLoc(pos.latitude, pos.longitude, nearest(pos.latitude, pos.longitude).n);
    } catch (_) {
      note = 'লোকেশন পাওয়া যায়নি, সেটিংসে জেলা বেছে নিন';
      notifyListeners();
    }
  }

  Future<void> setLoc(double la, double lo, String name) async {
    lat = la;
    lon = lo;
    place = name;
    await sp.setDouble('lat', la);
    await sp.setDouble('lon', lo);
    await sp.setString('place', name);
    notifyListeners();
    await Notif.schedule(c, on);
  }

  Future<void> toggle(int i) async {
    on[i] = !on[i];
    await sp.setString('on', on.map((e) => e ? '1' : '0').join());
    notifyListeners();
    await Notif.schedule(c, on);
  }

  Future<void> setAdj(int v) async {
    adj = v.clamp(-2, 2);
    await sp.setInt('adj', adj);
    notifyListeners();
  }
}

// ───────────── App ─────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notif.init();
  final s = AppState();
  runApp(App(s));
  s.load();
}

class App extends StatelessWidget {
  final AppState s;
  const App(this.s, {super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: kApp,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: green, primary: green, secondary: gold),
          scaffoldBackgroundColor: cream,
        ),
        home: Shell(s),
      );
}

class Shell extends StatefulWidget {
  final AppState s;
  const Shell(this.s, {super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.s,
        builder: (_, __) {
          final s = widget.s;
          return Scaffold(
            body: SafeArea(child: IndexedStack(index: i, children: [HomePage(s), CalPage(s), RamPage(s), SetPage(s)])),
            bottomNavigationBar: NavigationBar(
              selectedIndex: i,
              onDestinationSelected: (v) => setState(() => i = v),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.access_time), label: 'নামাজ'),
                NavigationDestination(icon: Icon(Icons.calendar_month), label: 'ক্যালেন্ডার'),
                NavigationDestination(icon: Icon(Icons.nights_stay), label: 'রমজান'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'সেটিংস'),
              ],
            ),
          );
        },
      );
}

// ───────────── Logo ─────────────
class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _LogoPainter()));
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size z) {
    final s = z.width;
    c.drawCircle(Offset(s / 2, s / 2), s / 2,
        Paint()..shader = const RadialGradient(colors: [green2, green]).createShader(Rect.fromLTWH(0, 0, s, s)));
    final g = Paint()..color = gold;
    final a = Path()..addOval(Rect.fromCircle(center: Offset(.5 * s, .36 * s), radius: .22 * s));
    final b = Path()..addOval(Rect.fromCircle(center: Offset(.57 * s, .32 * s), radius: .19 * s));
    c.drawPath(Path.combine(PathOperation.difference, a, b), g);
    final d = Path()
      ..moveTo(.30 * s, .80 * s)
      ..quadraticBezierTo(.30 * s, .62 * s, .5 * s, .60 * s)
      ..quadraticBezierTo(.70 * s, .62 * s, .70 * s, .80 * s)
      ..close();
    c.drawPath(d, g);
    c.drawRect(Rect.fromLTRB(.28 * s, .80 * s, .72 * s, .84 * s), g);
    final st = Path();
    for (var i = 0; i < 10; i++) {
      final r = (i % 2 == 0 ? .05 : .02) * s;
      final ang = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(.60 * s + r * math.cos(ang), .30 * s + r * math.sin(ang));
      i == 0 ? st.moveTo(p.dx, p.dy) : st.lineTo(p.dx, p.dy);
    }
    c.drawPath(st..close(), g);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ───────────── Home ─────────────
class HomePage extends StatefulWidget {
  final AppState s;
  const HomePage(this.s, {super.key});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  Widget row(IconData i, String a, String b) => ListTile(
        dense: true,
        leading: Icon(i, color: green2),
        title: Text(a),
        trailing: Text(b, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final now = DateTime.now();
    final today = dOnly(bdNow());
    final tt = timesFor(today, s.c);
    DateTime? nx;
    var ni = 0;
    for (var i = 0; i < 5; i++) {
      if (tt.five[i].isAfter(now)) {
        nx = tt.five[i];
        ni = i;
        break;
      }
    }
    nx ??= timesFor(today.add(const Duration(days: 1)), s.c).five[0];
    final left = nx.difference(now);
    String two(int n) => bn(n.toString().padLeft(2, '0'));
    final cd = '${two(left.inHours)}:${two(left.inMinutes % 60)}:${two(left.inSeconds % 60)}';
    const w = TextStyle(color: Colors.white);
    const w7 = TextStyle(color: Colors.white70, fontSize: 14);

    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [green, green2]), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Logo(size: 44),
            const SizedBox(width: 10),
            const Text(kApp, style: TextStyle(color: gold, fontSize: 26, fontWeight: FontWeight.w700)),
            const Spacer(),
            const Icon(Icons.location_on, color: gold, size: 16),
            Text(s.place, style: w),
          ]),
          const SizedBox(height: 14),
          Text('${wdBn[today.weekday % 7]}, ${enStr(today)}', style: w.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(bnStr(today), style: w7),
          Text(hiBn(today, s.adj), style: w7),
          Text(hiAr(today, s.adj), style: w7, textDirection: TextDirection.rtl),
        ]),
      ),
      if (s.note.isNotEmpty)
        Card(color: Colors.orange.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Text(s.note))),
      Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('পরবর্তী ওয়াক্ত: ${prayers[ni]}', style: const TextStyle(fontSize: 16)),
            Text(fmt(nx), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: green)),
            const SizedBox(height: 4),
            Text(cd, style: const TextStyle(fontSize: 22, color: Color(0xFF9A7B0A), fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      Card(
        child: Column(children: [
          for (var i = 0; i < 5; i++)
            ListTile(
              tileColor: i == ni ? gold.withOpacity(.15) : null,
              leading: Icon(prayerIcons[i], color: green2),
              title: Text(prayers[i], style: const TextStyle(fontSize: 17)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(fmt(tt.five[i]), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                IconButton(
                  tooltip: 'আজান অ্যালার্ম',
                  icon: Icon(s.on[i] ? Icons.notifications_active : Icons.notifications_off,
                      color: s.on[i] ? green : Colors.grey),
                  onPressed: () => s.toggle(i),
                ),
              ]),
            ),
        ]),
      ),
      Card(
        margin: const EdgeInsets.only(top: 10),
        child: Column(children: [
          row(Icons.wb_twilight, 'সূর্যোদয়', fmt(tt.sunrise)),
          row(Icons.wb_sunny, 'সূর্যাস্ত', fmt(tt.sunset)),
          row(Icons.free_breakfast, 'সেহরির শেষ সময়', fmt(tt.fajr)),
          row(Icons.restaurant, 'ইফতারের সময়', fmt(tt.five[3])),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text('গণনা: করাচি পদ্ধতি, হানাফি আসর। স্থানীয় ক্যালেন্ডারের সাথে ১-২ মিনিট পার্থক্য হতে পারে।',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    ]);
  }
}

// ───────────── Calendar ─────────────
class CalPage extends StatefulWidget {
  final AppState s;
  const CalPage(this.s, {super.key});
  @override
  State<CalPage> createState() => _CalState();
}

class _CalState extends State<CalPage> {
  late DateTime month = DateTime(bdNow().year, bdNow().month, 1);
  late DateTime sel = dOnly(bdNow());

  void go(int d) => setState(() => month = DateTime(month.year, month.month + d, 1));

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final today = dOnly(bdNow());
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final last = DateTime(month.year, month.month, days);
    final lead = month.weekday % 7;
    final b1 = toBangla(month), b2 = toBangla(last);
    final h1 = hijri(month, s.adj), h2 = hijri(last, s.adj);
    final bnR = b1.m == b2.m ? bnMonths[b1.m] : '${bnMonths[b1.m]} – ${bnMonths[b2.m]}';
    final hiR = h1.hMonth == h2.hMonth ? hijriBn[h1.hMonth - 1] : '${hijriBn[h1.hMonth - 1]} – ${hijriBn[h2.hMonth - 1]}';
    final arR = h1.hMonth == h2.hMonth ? hijriAr[h1.hMonth - 1] : '${hijriAr[h1.hMonth - 1]} – ${hijriAr[h2.hMonth - 1]}';

    Widget cell(int d) {
      final g = DateTime(month.year, month.month, d);
      final isT = g == today, isS = g == sel, fri = g.weekday == 5;
      final h = hijri(g, s.adj);
      return InkWell(
        onTap: () => setState(() => sel = g),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: isS ? green : isT ? gold.withOpacity(.35) : Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$d',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isS ? Colors.white : fri ? Colors.red.shade700 : Colors.black87)),
            Text(bn(toBangla(g).d), style: TextStyle(fontSize: 11, color: isS ? Colors.white70 : green2)),
            Text(bn(h.hDay), style: TextStyle(fontSize: 11, color: isS ? gold : Colors.brown)),
          ]),
        ),
      );
    }

    final tt = timesFor(sel, s.c);
    return ListView(padding: const EdgeInsets.all(12), children: [
      Row(children: [
        IconButton(onPressed: () => go(-1), icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Column(children: [
            Text('${enMonths[month.month - 1]} ${month.year}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text('বাংলা: $bnR ${bn(b1.y)}', style: const TextStyle(color: green2)),
            Text('হিজরি: $hiR ${bn(h1.hYear)}', style: const TextStyle(color: Colors.brown)),
            Text('$arR ${ar(h1.hYear)}', style: const TextStyle(color: Colors.brown), textDirection: TextDirection.rtl),
          ]),
        ),
        IconButton(onPressed: () => go(1), icon: const Icon(Icons.chevron_right)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        for (final d in ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি'])
          Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)))),
      ]),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: .72,
        children: [for (var i = 0; i < lead; i++) const SizedBox(), for (var d = 1; d <= days; d++) cell(d)],
      ),
      const Text('  ● বড়: ইংরেজি   ● সবুজ: বাংলা   ● বাদামি: হিজরি', style: TextStyle(fontSize: 11, color: Colors.black54)),
      Card(
        margin: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${wdBn[sel.weekday % 7]}, ${enStr(sel)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(bnStr(sel)),
            Text(hiBn(sel, s.adj)),
            Text(hiAr(sel, s.adj), textDirection: TextDirection.rtl),
            const Divider(),
            for (var i = 0; i < 5; i++) Text('${prayers[i]}: ${fmt(tt.five[i])}'),
            Text('সূর্যোদয়: ${fmt(tt.sunrise)}'),
          ]),
        ),
      ),
    ]);
  }
}

// ───────────── Ramadan ─────────────
class RamPage extends StatelessWidget {
  final AppState s;
  const RamPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final today = dOnly(bdNow());
    DateTime g(int y, int m) {
      final x = HijriCalendar.now().hijriToGregorian(y, m, 1);
      return DateTime(x.year, x.month, x.day).subtract(Duration(days: s.adj));
    }

    var hy = hijri(today, s.adj).hYear;
    var st = g(hy, 9), en = g(hy, 10);
    if (!today.isBefore(en)) {
      hy++;
      st = g(hy, 9);
      en = g(hy, 10);
    }
    final n = DateTime.utc(en.year, en.month, en.day).difference(DateTime.utc(st.year, st.month, st.day)).inDays;
    final toStart = DateTime.utc(st.year, st.month, st.day).difference(DateTime.utc(today.year, today.month, today.day)).inDays;

    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [green, green2]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          Text('রমজান ${bn(hy)} হিজরি', style: const TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('প্রথম রোজা: ${bn(st.day)} ${enMonths[st.month - 1]} ${bn(st.year)} (${wdBn[st.weekday % 7]})',
              style: const TextStyle(color: Colors.white)),
          Text(toStart > 0 ? 'আর ${bn(toStart)} দিন বাকি' : 'রমজান চলছে', style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(children: [
          SizedBox(width: 44, child: Text('রোজা', style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(flex: 3, child: Text('তারিখ', style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(flex: 2, child: Text('সেহরি শেষ', style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(flex: 2, child: Text('ইফতার', style: TextStyle(fontWeight: FontWeight.w700))),
        ]),
      ),
      for (var i = 0; i < n; i++)
        Builder(builder: (_) {
          final d = st.add(Duration(days: i));
          final t = timesFor(d, s.c);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: d == today ? gold.withOpacity(.3) : Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              SizedBox(width: 44, child: Text(bn(i + 1), style: const TextStyle(fontWeight: FontWeight.w700))),
              Expanded(flex: 3, child: Text('${wdBn[d.weekday % 7]}\n${d.day} ${enMonths[d.month - 1].substring(0, 3)}', style: const TextStyle(fontSize: 12))),
              Expanded(flex: 2, child: Text(fmt(t.fajr), style: const TextStyle(fontSize: 13))),
              Expanded(flex: 2, child: Text(fmt(t.five[3]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            ]),
          );
        }),
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text('চাঁদ দেখা সাপেক্ষে তারিখ ১ দিন আগে-পরে হতে পারে। সেটিংসে হিজরি তারিখ সমন্বয় করা যায়।',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    ]);
  }
}

// ───────────── Settings ─────────────
class SetPage extends StatelessWidget {
  final AppState s;
  const SetPage(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(12), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('লোকেশন (বাংলাদেশ)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text('বর্তমান: ${s.place}'),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: s.gps, icon: const Icon(Icons.my_location), label: const Text('GPS থেকে লোকেশন নিন')),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: dists.any((d) => d.n == s.place) ? s.place : null,
              hint: const Text('অথবা জেলা বেছে নিন'),
              items: [for (final d in dists) DropdownMenuItem(value: d.n, child: Text(d.n))],
              onChanged: (v) {
                final d = dists.firstWhere((x) => x.n == v);
                s.setLoc(d.la, d.lo, d.n);
              },
            ),
          ]),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('আজান অ্যালার্ম', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(kAzan ? 'আজানের শব্দ: অ্যাপে যুক্ত' : 'আজানের শব্দ: ফোনের ডিফল্ট অ্যালার্ম সাউন্ড (azan.mp3 যুক্ত করলে আজান বাজবে)',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton(onPressed: Notif.ask, child: const Text('অনুমতি দিন')),
              OutlinedButton(onPressed: Notif.test, child: const Text('১০ সেকেন্ড পর পরীক্ষা')),
            ]),
            const Text('\nঅ্যালার্মের জন্য ব্যাটারি সেভার থেকে অ্যাপটি বাদ দিন।', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Expanded(child: Text('হিজরি তারিখ সমন্বয় (দিন)', style: TextStyle(fontWeight: FontWeight.w700))),
            IconButton(onPressed: () => s.setAdj(s.adj - 1), icon: const Icon(Icons.remove_circle_outline)),
            Text(bn(s.adj), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(onPressed: () => s.setAdj(s.adj + 1), icon: const Icon(Icons.add_circle_outline)),
          ]),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            const Logo(size: 80),
            const SizedBox(height: 8),
            const Text(kApp, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: green)),
            const Text('সংস্করণ ১.০.০'),
            const SizedBox(height: 6),
            const Text('ডেভেলপার: $kDev', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    ]);
  }
}
