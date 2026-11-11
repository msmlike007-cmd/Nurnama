import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

// ═════════════ Constants ═════════════
const kApp = 'নূরনামা';
const kAzan = bool.fromEnvironment('AZAN');
const kVersion = '2.1.0';
const kBuild = 3;
const green = Color(0xFF0B3D2E);
const green2 = Color(0xFF14604A);
const gold = Color(0xFFD4AF37);
const cream = Color(0xFFFFF8E7);
const linkFb = 'https://www.facebook.com/share/1E6ypLt8tZ/';
const linkIg = 'https://www.instagram.com/md.masum366';
const linkTg = 'https://t.me/MasumNoornama';

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

bool inBdAt(double la, double lo) => la >= 20.5 && la <= 26.7 && lo >= 88.0 && lo <= 92.8;

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

// ═════════════ Helpers ═════════════
String digits(Object o, String set) => o.toString().split('').map((c) {
      final i = '0123456789'.indexOf(c);
      return i < 0 ? c : set[i];
    }).join();
String bn(Object o) => digits(o, '০১২৩৪৫৬৭৮৯');
String ar(Object o) => digits(o, '٠١٢٣٤٥٦٧٨٩');

DateTime now0() => DateTime.now();
DateTime dOnly(DateTime t) => DateTime(t.year, t.month, t.day);
bool leap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
String dateKey(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
int daysBetween(DateTime a, DateTime b) => DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

Color cardC(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF1B2B25) : Colors.white;
Color mute(BuildContext c) => Theme.of(c).colorScheme.onSurface.withOpacity(.65);
Color pri(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0xFF7BD8B0) : green;

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

/// হিজরি → গ্রেগরিয়ান (কুয়েতি অ্যালগরিদম, নির্ভরযোগ্য)
DateTime hijriToG(int y, int m, int d, int adj) {
  final jd = (11 * y + 3) ~/ 30 +
      354 * y +
      30 * m -
      (m - 1) ~/ 2 +
      d +
      1948440 -
      385;
  final l = jd + 68569;
  final n = (4 * l) ~/ 146097;
  final l2 = l - (146097 * n + 3) ~/ 4;
  final i = (4000 * (l2 + 1)) ~/ 1461001;
  final l3 = l2 - (1461 * i) ~/ 4 + 31;
  final j = (80 * l3) ~/ 2447;
  final day = l3 - (2447 * j) ~/ 80;
  final l4 = j ~/ 11;
  final month = j + 2 - 12 * l4;
  final year = 100 * (n - 49) + i + l4;
  return DateTime(year, month, day).subtract(Duration(days: adj));
}

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
  final b = t.toLocal();
  final h = b.hour;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  final p = h < 4 ? 'রাত' : h < 6 ? 'ভোর' : h < 12 ? 'সকাল' : h < 15 ? 'দুপুর' : h < 17 ? 'বিকাল' : h < 19 ? 'সন্ধ্যা' : 'রাত';
  return '${bn(h12)}:${bn(b.minute.toString().padLeft(2, '0'))} $p';
}

class Day {
  final List<DateTime> five;
  final DateTime sunrise, nextFajr, asrHanafi, asrShafi;
  Day(this.five, this.sunrise, this.nextFajr, this.asrHanafi, this.asrShafi);
  DateTime get fajr => five[0];
  DateTime get sunset => five[3];
  DateTime endOf(int i) => i == 0 ? sunrise : i == 1 ? five[2] : i == 2 ? five[3] : i == 3 ? five[4] : nextFajr;
}

Day timesFor(DateTime d, AppState s) {
  final comp = DateComponents.from(d);
  final t = PrayerTimes(s.c, comp, s.params());
  final n = PrayerTimes(s.c, DateComponents.from(d.add(const Duration(days: 1))), s.params());
  final ah = PrayerTimes(s.c, comp, s.params(hanafiOverride: true));
  final asf = PrayerTimes(s.c, comp, s.params(hanafiOverride: false));
  DateTime l(DateTime x) => x.toLocal();
  return Day([l(t.fajr), l(t.dhuhr), l(t.asr), l(t.maghrib), l(t.isha)], l(t.sunrise), l(n.fajr), l(ah.asr), l(asf.asr));
}

Future<void> openUrl(String u) async {
  try {
    await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
  } catch (_) {}
}

void openPage(BuildContext ctx, String title, Widget page) =>
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: SafeArea(child: page))));

// ═════════════ Quran data (alquran.cloud, cached on phone) ═════════════
class QS {
  final List<String> ar, bn;
  QS(this.ar, this.bn);
}

class Api {
  static const base = 'https://api.alquran.cloud/v1';

  static Future<dynamic> _json(String url, String cache) async {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$cache');
    if (await f.exists()) {
      try {
        return jsonDecode(await f.readAsString());
      } catch (_) {}
    }
    final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 40));
    if (r.statusCode != 200) throw Exception('http ${r.statusCode}');
    final body = utf8.decode(r.bodyBytes);
    final j = jsonDecode(body);
    if (j['code'] != 200) throw Exception('api');
    await f.writeAsString(body);
    return j;
  }

  static Future<List<dynamic>> surahList() async => (await _json('$base/surah', 'surahs.json'))['data'] as List;

  static QS _pack(List data) {
    var a = <String>[], b = <String>[];
    for (final e in data) {
      final id = e['edition']['identifier'];
      final list = e['ayahs'] != null ? (e['ayahs'] as List).map((x) => x['text'] as String).toList() : [e['text'] as String];
      if (id == 'quran-uthmani') {
        a = list;
      } else {
        b = list;
      }
    }
    return QS(a, b);
  }

  static Future<QS> surah(int n) async {
    final j = await _json('$base/surah/$n/editions/quran-uthmani,bn.bengali', 's$n.json');
    return _pack(j['data'] as List);
  }

  static Future<QS> ayah(String ref) async {
    final j = await _json('$base/ayah/$ref/editions/quran-uthmani,bn.bengali', 'a_${ref.replaceAll(':', '_')}.json');
    return _pack(j['data'] as List);
  }
}

// ═════════════ Notifications ═════════════
@pragma('vm:entry-point')
Future<void> notifBg(NotificationResponse r) async => handleNotifAction(r);

Future<void> handleNotifAction(NotificationResponse r) async {
  try {
    final pl = r.payload ?? '';
    if (r.actionId == 'prayed' && pl.startsWith('trk|')) {
      final parts = pl.split('|');
      final i = int.parse(parts[1]);
      final k = parts[2];
      final sp = await SharedPreferences.getInstance();
      await sp.reload();
      final cur = (sp.getString('trk_$k') ?? '00000').split('');
      cur[i] = '1';
      await sp.setString('trk_$k', cur.join());
    }
  } catch (_) {}
}

class Notif {
  static final p = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    await p.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: handleNotifAction,
      onDidReceiveBackgroundNotificationResponse: notifBg,
    );
  }

  static AndroidFlutterLocalNotificationsPlugin? get _a =>
      p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static Future<void> ask() async {
    await _a?.requestNotificationsPermission();
  }

  static Future<bool> enabled() async => (await _a?.areNotificationsEnabled()) ?? true;

  static const _stop = AndroidNotificationAction('stop', 'বন্ধ করুন', cancelNotification: true, showsUserInterface: false);

  static AndroidNotificationSound _alarmSound() =>
      kAzan ? const RawResourceAndroidNotificationSound('azan') : const UriAndroidNotificationSound('content://settings/system/alarm_alert');

  static NotificationDetails azanDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          kAzan ? 'azan_v3' : 'azan_alarm_v3',
          'আজান',
          channelDescription: 'নামাজের ওয়াক্তে আজান',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: _alarmSound(),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: true,
          autoCancel: false,
          timeoutAfter: 300000,
          additionalFlags: kAzan ? null : Int32List.fromList(<int>[4]),
          actions: const [_stop],
        ),
      );

  static NotificationDetails customDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_alarm_v3',
          'আমার অ্যালার্ম',
          channelDescription: 'আপনার সেট করা অ্যালার্ম',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          ongoing: true,
          autoCancel: false,
          timeoutAfter: 300000,
          additionalFlags: Int32List.fromList(<int>[4]),
          actions: const [_stop],
        ),
      );

  static NotificationDetails prayedDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'remind_v3',
          'নামাজ রিমাইন্ডার',
          channelDescription: 'নামাজ পড়েছেন কিনা জানতে চাওয়া',
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('prayed', 'হ্যাঁ, পড়েছি', cancelNotification: true, showsUserInterface: false),
            AndroidNotificationAction('later', 'পরে', cancelNotification: true, showsUserInterface: false),
          ],
        ),
      );

  static Future<bool> _at(int id, String title, String body, DateTime when, NotificationDetails d, {String? payload}) async {
    final z = tz.TZDateTime.from(when, tz.UTC);
    for (final mode in [AndroidScheduleMode.alarmClock, AndroidScheduleMode.exactAllowWhileIdle, AndroidScheduleMode.inexactAllowWhileIdle]) {
      try {
        await p.zonedSchedule(id, title, body, z, d,
            payload: payload,
            androidScheduleMode: mode,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
        return true;
      } catch (_) {}
    }
    return false;
  }

  static Future<void> schedule(AppState s) async {
    await p.cancelAll();
    final now = DateTime.now();
    final base = dOnly(now);
    for (var d = 0; d < 10; d++) {
      final day = base.add(Duration(days: d));
      final t = timesFor(day, s);
      for (var i = 0; i < 5; i++) {
        if (s.on[i] && t.five[i].isAfter(now)) {
          await _at(100 + d * 10 + i, 'আজান - ${prayers[i]}', '${prayers[i]} নামাজের ওয়াক্ত হয়েছে', t.five[i], azanDetails());
        }
        if (s.remind && s.name.isNotEmpty) {
          final w = t.five[i].add(const Duration(minutes: 15));
          if (w.isAfter(now)) {
            await _at(6000 + d * 10 + i, 'নামাজের খোঁজ', '${s.addr}, ${prayers[i]} নামাজ পড়েছেন তো?', w, prayedDetails(),
                payload: 'trk|$i|${dateKey(day)}');
          }
        }
      }
      for (var c = 0; c < s.customs.length; c++) {
        final a = s.customs[c];
        if (a['on'] != true) continue;
        final w = DateTime(day.year, day.month, day.day, a['h'] as int, a['m'] as int);
        if (w.isAfter(now)) await _at(8000 + c * 10 + d, '${a['l']}', 'আপনার অ্যালার্ম', w, customDetails());
      }
    }
  }

  static Future<bool> test() => _at(9999, 'আজান পরীক্ষা', 'এটি একটি পরীক্ষামূলক আজান', DateTime.now().add(const Duration(seconds: 10)), azanDetails());
}

// ═════════════ State ═════════════
class AppState extends ChangeNotifier {
  double lat = 23.81, lon = 90.41;
  String place = 'ঢাকা';
  List<bool> on = List.filled(5, true);
  int adj = 0, themeMode = 0;
  bool hanafi = true, remind = true, loaded = false;
  String method = 'auto', name = '', title = 'ভাই', note = '', lastPopup = '';
  double arSize = 26;
  List<Map<String, dynamic>> customs = [];
  Map<String, dynamic>? update;
  late SharedPreferences sp;

  Coordinates get c => Coordinates(lat, lon);
  String get addr => title.isEmpty ? name : '$name $title';

  CalculationParameters params({bool? hanafiOverride}) {
    CalculationMethod m;
    switch (method) {
      case 'karachi':
        m = CalculationMethod.karachi;
        break;
      case 'mwl':
        m = CalculationMethod.muslim_world_league;
        break;
      case 'umm':
        m = CalculationMethod.umm_al_qura;
        break;
      case 'egypt':
        m = CalculationMethod.egyptian;
        break;
      default:
        m = inBdAt(lat, lon) ? CalculationMethod.karachi : CalculationMethod.muslim_world_league;
    }
    final p = m.getParameters();
    p.madhab = (hanafiOverride ?? hanafi) ? Madhab.hanafi : Madhab.shafi;
    return p;
  }

  Future<void> load() async {
    sp = await SharedPreferences.getInstance();
    adj = sp.getInt('adj') ?? 0;
    themeMode = sp.getInt('theme') ?? 0;
    hanafi = sp.getBool('hanafi') ?? true;
    remind = sp.getBool('remind') ?? true;
    method = sp.getString('method') ?? 'auto';
    name = sp.getString('name') ?? '';
    title = sp.getString('title') ?? 'ভাই';
    lastPopup = sp.getString('popup') ?? '';
    arSize = sp.getDouble('arSize') ?? 26;
    final cj = sp.getString('customs');
    if (cj != null) {
      try {
        customs = (jsonDecode(cj) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }
    final s = sp.getString('on');
    if (s != null && s.length == 5) on = s.split('').map((e) => e == '1').toList();
    if (sp.containsKey('lat')) {
      lat = sp.getDouble('lat')!;
      lon = sp.getDouble('lon')!;
      place = sp.getString('place') ?? place;
    }
    loaded = true;
    notifyListeners();
    if (!sp.containsKey('lat')) await gps();
  }

  Future<String> _label(double la, double lo) async {
    try {
      final r = await http
          .get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&zoom=14&accept-language=bn&lat=$la&lon=$lo'),
              headers: {'User-Agent': 'NurNama/2.0 (Android prayer times app)'})
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        final a = (jsonDecode(utf8.decode(r.bodyBytes))['address'] ?? {}) as Map;
        final parts = <String>[];
        for (final k in ['suburb', 'neighbourhood', 'village', 'town', 'city', 'municipality', 'county', 'state_district']) {
          final v = (a[k] ?? '').toString().trim();
          if (v.isNotEmpty && !parts.contains(v)) parts.add(v);
        }
        final out = parts.take(3).toList();
        final cn = (a['country'] ?? '').toString().trim();
        if (cn.isNotEmpty && !inBdAt(la, lo)) out.add(cn);
        if (out.isNotEmpty) return out.join(', ');
      }
    } catch (_) {}
    if (inBdAt(la, lo)) return nearest(la, lo).n;
    return '${la.toStringAsFixed(2)}, ${lo.toStringAsFixed(2)}';
  }

  Future<void> gps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        note = 'ফোনের লোকেশন (GPS) চালু করুন';
        notifyListeners();
        return;
      }
      v
