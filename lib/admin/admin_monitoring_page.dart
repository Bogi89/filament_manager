import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminMonitoringPage extends StatefulWidget {
  const AdminMonitoringPage({super.key});

  @override
  State<AdminMonitoringPage> createState() => _AdminMonitoringPageState();
}

class _AdminMonitoringPageState extends State<AdminMonitoringPage> {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadMonitoringData();
  }

  Future<void> _loadMonitoringData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'Du musst mit deinem FilaLog-Administratorkonto angemeldet sein.',
        );
      }

      final callable = _functions.httpsCallable('getMonitoringOverview');
      final result = await callable.call();

      if (!mounted) {
        return;
      }

      final rawData = result.data;

      if (rawData is! Map) {
        throw Exception('Ungültige Antwort der Monitoring-Funktion.');
      }

      setState(() {
        _data = Map<String, dynamic>.from(rawData);
        _isLoading = false;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }

      var message = 'Monitoring-Daten konnten nicht geladen werden.';

      if (error.code == 'permission-denied') {
        message = 'Dieses Konto hat keinen Zugriff auf das Monitoring.';
      } else if (error.code == 'unauthenticated') {
        message = 'Du musst mit deinem Administratorkonto angemeldet sein.';
      }

      setState(() {
        _error = message;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  Map<String, dynamic> _mapValue(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  List<Map<String, dynamic>> _mapListValue(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _formatDateTime(dynamic value) {
    if (value == null) {
      return '–';
    }

    final dateTime = DateTime.tryParse(value.toString());

    if (dateTime == null) {
      return '–';
    }

    final localDateTime = dateTime.toLocal();

    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year.toString();
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FilaLog Monitoring'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadMonitoringData,
            tooltip: 'Aktualisieren',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadMonitoringData,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data ?? <String, dynamic>{};

    final registrations = _mapValue(data['registrations']);
    final guests = _mapValue(data['guests']);
    final guestPlatforms = _mapValue(guests['platforms']);

    final premium = _mapValue(data['premium']);
    final conversion = _mapValue(premium['conversion']);
    final paddle = _mapValue(premium['paddle']);
    final googlePlay = _mapValue(premium['googlePlay']);

    final paddleToday = _mapValue(paddle['today']);
    final paddleLast7Days = _mapValue(paddle['last7Days']);
    final paddleLast30Days = _mapValue(paddle['last30Days']);

    final googlePlayToday = _mapValue(googlePlay['today']);
    final googlePlayLast7Days = _mapValue(googlePlay['last7Days']);
    final googlePlayLast30Days = _mapValue(googlePlay['last30Days']);

    final recentRegistrations = _mapListValue(registrations['recent']);
    final recentPurchases = _mapListValue(data['recentPurchases']);

    return RefreshIndicator(
      onRefresh: _loadMonitoringData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Text('Übersicht', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Stand: ${data['generatedAt'] ?? '–'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          _MonitoringSection(
            title: 'Nutzer',
            children: [
              _MonitoringValue(
                label: 'Registrierte Konten gesamt',
                value: _intValue(registrations['total']),
              ),
              _MonitoringValue(
                label: 'Neue Konten heute',
                value: _intValue(registrations['today']),
              ),
              _MonitoringValue(
                label: 'Neue Konten – letzte 7 Tage',
                value: _intValue(registrations['last7Days']),
              ),
              _MonitoringValue(
                label: 'Neue Konten – letzte 30 Tage',
                value: _intValue(registrations['last30Days']),
              ),
              _MonitoringValue(
                label: 'Registrierte Nutzer mit Filamentbestand',
                value: _intValue(registrations['withFilaments']),
              ),
              _MonitoringValue(
                label: 'Aktive registrierte Nutzer heute',
                value: _intValue(registrations['activeToday']),
              ),
              _MonitoringValue(
                label: 'Aktive registrierte Nutzer – letzte 7 Tage',
                value: _intValue(registrations['active7Days']),
              ),
              _MonitoringValue(
                label: 'Aktive registrierte Nutzer – letzte 30 Tage',
                value: _intValue(registrations['active30Days']),
              ),
              _MonitoringValue(
                label: 'Gestartete Testphasen',
                value: _intValue(data['trials']),
              ),
              _MonitoringValue(
                label: 'Eindeutige Gast-Installationen gesamt',
                value: _intValue(guests['unique']),
              ),
              _MonitoringValue(
                label: 'Neue Gäste heute',
                value: _intValue(guests['today']),
              ),
              _MonitoringValue(
                label: 'Neue Gäste – letzte 7 Tage',
                value: _intValue(guests['last7Days']),
              ),
              _MonitoringValue(
                label: 'Neue Gäste – letzte 30 Tage',
                value: _intValue(guests['last30Days']),
              ),
              _MonitoringValue(
                label: 'Gastmodus gestartet gesamt',
                value: _intValue(guests['starts']),
              ),
              _MonitoringValue(
                label: 'Gast-App-Starts gesamt',
                value: _intValue(guests['appStarts']),
              ),
              _MonitoringValue(
                label: 'Aktive Gäste heute',
                value: _intValue(guests['activeToday']),
              ),
              _MonitoringValue(
                label: 'Aktive Gäste – letzte 7 Tage',
                value: _intValue(guests['active7Days']),
              ),
              _MonitoringValue(
                label: 'Aktive Gäste – letzte 30 Tage',
                value: _intValue(guests['active30Days']),
              ),
              _MonitoringValue(
                label: 'Gast-Installationen Android',
                value: _intValue(guestPlatforms['android']),
              ),
              _MonitoringValue(
                label: 'Gast-Installationen Web',
                value: _intValue(guestPlatforms['web']),
              ),
              _MonitoringValue(
                label: 'Gast-Installationen andere Plattformen',
                value: _intValue(guestPlatforms['other']),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonitoringSection(
            title: 'Letzte Registrierungen',
            children: recentRegistrations.isEmpty
                ? [const Text('Noch keine Registrierungen vorhanden.')]
                : recentRegistrations.map((registration) {
                    final uid = registration['uid']?.toString() ?? '–';
                    final createdAt = _formatDateTime(
                      registration['createdAt'],
                    );

                    return _MonitoringDetailValue(label: uid, value: createdAt);
                  }).toList(),
          ),
          const SizedBox(height: 16),
          _MonitoringSection(
            title: 'Premium',
            children: [
              _MonitoringValue(
                label: 'Premium-Zugänge gesamt',
                value: _intValue(premium['active']),
              ),
              _MonitoringValue(
                label: 'Manuell / kostenlos freigeschaltet',
                value: _intValue(premium['manual']),
              ),
              _MonitoringValue(
                label: 'Aktive bezahlte Zugänge',
                value: _intValue(premium['paid']),
              ),
              _MonitoringPercentValue(
                label: 'Conversion Registrierung → bezahlt',
                value: _doubleValue(conversion['registrationToPaidPercent']),
              ),
              _MonitoringPercentValue(
                label: 'Conversion Testphase → bezahlt',
                value: _doubleValue(conversion['trialToPaidPercent']),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonitoringSection(
            title: 'Paddle – Web',
            children: [
              _MonitoringValue(
                label: 'Live-Konten',
                value: _intValue(paddle['live']),
              ),
              _MonitoringValue(
                label: 'Aktive Abos',
                value: _intValue(paddle['active']),
              ),
              _MonitoringValue(
                label: 'Kündigung vorgemerkt',
                value: _intValue(paddle['scheduledCancel']),
              ),
              _MonitoringValue(
                label: 'Gekündigt',
                value: _intValue(paddle['canceled']),
              ),
              _MonitoringValue(
                label: 'Pausiert',
                value: _intValue(paddle['paused']),
              ),
              _MonitoringValue(
                label: 'Sandbox-Konten',
                value: _intValue(paddle['sandbox']),
              ),
              _MonitoringValue(
                label: 'Erfolgreiche Käufe gesamt',
                value: _intValue(paddle['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz gesamt',
                cents: _intValue(paddle['revenueCents']),
              ),
              _MonitoringValue(
                label: 'Käufe heute',
                value: _intValue(paddleToday['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz heute',
                cents: _intValue(paddleToday['revenueCents']),
              ),
              _MonitoringValue(
                label: 'Käufe – letzte 7 Tage',
                value: _intValue(paddleLast7Days['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz – letzte 7 Tage',
                cents: _intValue(paddleLast7Days['revenueCents']),
              ),
              _MonitoringValue(
                label: 'Käufe – letzte 30 Tage',
                value: _intValue(paddleLast30Days['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz – letzte 30 Tage',
                cents: _intValue(paddleLast30Days['revenueCents']),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonitoringSection(
            title: 'Google Play – Android',
            children: [
              _MonitoringValue(
                label: 'Aktive Abos gesamt',
                value: _intValue(googlePlay['total']),
              ),
              _MonitoringValue(
                label: 'Aktive Monatsabos',
                value: _intValue(googlePlay['monthly']),
              ),
              _MonitoringValue(
                label: 'Aktive Jahresabos',
                value: _intValue(googlePlay['yearly']),
              ),
              _MonitoringValue(
                label: 'Erfasste Käufe gesamt',
                value: _intValue(googlePlay['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Erfasster Umsatz gesamt',
                cents: _intValue(googlePlay['revenueCents']),
              ),
              _MonitoringValue(
                label: 'Käufe heute',
                value: _intValue(googlePlayToday['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz heute',
                cents: _intValue(googlePlayToday['revenueCents']),
              ),
              _MonitoringValue(
                label: 'Käufe – letzte 7 Tage',
                value: _intValue(googlePlayLast7Days['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz – letzte 7 Tage',
                cents: _intValue(googlePlayLast7Days['revenueCents']),
              ),
              _MonitoringValue(
                label: 'Käufe – letzte 30 Tage',
                value: _intValue(googlePlayLast30Days['purchases']),
              ),
              _MonitoringMoneyValue(
                label: 'Umsatz – letzte 30 Tage',
                cents: _intValue(googlePlayLast30Days['revenueCents']),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonitoringSection(
            title: 'Letzte Käufe',
            children: recentPurchases.isEmpty
                ? [const Text('Noch keine Käufe erfasst.')]
                : recentPurchases.map((purchase) {
                    final provider = purchase['provider']?.toString() ?? '–';
                    final plan = purchase['plan']?.toString() ?? '–';
                    final purchasedAt = _formatDateTime(
                      purchase['purchasedAt'],
                    );
                    final amount = _intValue(purchase['amount']);
                    final formattedAmount = (amount / 100)
                        .toStringAsFixed(2)
                        .replaceAll('.', ',');

                    return _MonitoringDetailValue(
                      label: '$provider · $plan · $formattedAmount €',
                      value: purchasedAt,
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MonitoringSection extends StatelessWidget {
  const _MonitoringSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MonitoringDetailValue extends StatelessWidget {
  const _MonitoringDetailValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringMoneyValue extends StatelessWidget {
  const _MonitoringMoneyValue({required this.label, required this.cents});

  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final euros = cents / 100;
    final formattedValue = euros.toStringAsFixed(2).replaceAll('.', ',');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Text(
            '$formattedValue €',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _MonitoringPercentValue extends StatelessWidget {
  const _MonitoringPercentValue({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Text(
            '${value.toStringAsFixed(1)} %',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _MonitoringValue extends StatelessWidget {
  const _MonitoringValue({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
