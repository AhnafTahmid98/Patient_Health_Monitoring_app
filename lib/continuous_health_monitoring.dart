import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';

class ContinuousHealthMonitoring extends StatefulWidget {
  const ContinuousHealthMonitoring({super.key});

  @override
  State<ContinuousHealthMonitoring> createState() => _ContinuousHealthMonitoringState();
}

class _ContinuousHealthMonitoringState extends State<ContinuousHealthMonitoring> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.79.194:8765'),
  );

  String bpm = "Waiting for BPM data...";
  String temperature = "Waiting for Temperature data...";
  String stress = "Waiting for Stress data...";

  List<double> bpmData = [];
  List<double> temperatureData = [];
  List<String> stressData = [];

  bool isMonitoring = false;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startDataListener();
  }

  void _startDataListener() {
    channel.stream.listen((data) {
      if (!isMonitoring || isDisposed) return;

      try {
        final parsedData = jsonDecode(data);
        setState(() {
          if (parsedData.containsKey('BPM')) {
            bpm = parsedData['BPM'].toStringAsFixed(1);
            bpmData.add(parsedData['BPM']);
            if (bpmData.length > 20) {
              bpmData.removeAt(0);
            }
          }
          if (parsedData.containsKey('Temperature')) {
            temperature = parsedData['Temperature'].toStringAsFixed(1) + " °C";
            temperatureData.add(parsedData['Temperature']);
            if (temperatureData.length > 20) {
              temperatureData.removeAt(0);
            }
          }
          if (parsedData.containsKey('Stress')) {
            stress = parsedData['Stress'];
            stressData.add(stress);
            if (stressData.length > 20) {
              stressData.removeAt(0);
            }
          }
        });
      } catch (e) {
        setState(() {
          bpm = temperature = stress = "Error receiving data";
        });
      }
    }, onError: (error) {
      if (!isDisposed) {
        setState(() {
          bpm = temperature = stress = "Connection error";
        });
      }
    }, onDone: () {
      if (!isDisposed) {
        setState(() {
          bpm = temperature = stress = "Connection closed";
        });
      }
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    if (isMonitoring) {
      _stopMonitoring();
    }
    channel.sink.close();
    super.dispose();
  }

  void _startMonitoring() {
    if (!isDisposed) {
      channel.sink.add(jsonEncode({"command": "START_MONITORING", "page": "Continuous"}));
      setState(() {
        isMonitoring = true;
        bpm = "Starting measurement...";
        temperature = "Starting measurement...";
        stress = "Starting measurement...";
      });
    }
  }

  void _stopMonitoring() {
    if (!isDisposed) {
      channel.sink.add(jsonEncode({"command": "STOP_MONITORING", "page": "Continuous"}));
      setState(() {
        isMonitoring = false;
      });
    }
  }

  double mapStressLevel(String level) {
    switch (level) {
      case "Relaxed":
        return 1.0;
      case "Normal":
        return 2.0;
      case "Elevated":
        return 3.0;
      case "High":
        return 4.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('ContinuousHealthMonitoringPage'),
      appBar: AppBar(
        title: Text('Continuous Health Monitor'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Display current values for each parameter
            Text('Current BPM:', style: TextStyle(fontSize: 20)),
            Text(bpm, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 20),
            Text('Current Temperature:', style: TextStyle(fontSize: 20)),
            Text(temperature, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange)),
            SizedBox(height: 20),
            Text('Current Stress Level:', style: TextStyle(fontSize: 20)),
            Text(stress, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),

            SizedBox(height: 20),

            // Legend for the graph
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Legend(color: Colors.red, text: 'BPM'),
                SizedBox(width: 10),
                Legend(color: Colors.orangeAccent, text: 'Temperature'),
                SizedBox(width: 10),
                Legend(color: Colors.blue, text: 'Stress Level'),
              ],
            ),
            SizedBox(height: 10),

            // Unified graph for BPM, Temperature, and Stress with tooltips
            Text('Health Data History', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Container(
              height: 250,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value <= 50) {
                            return Text('${value.toInt()}');
                          }
                          switch (value.toInt()) {
                            case 1:
                              return Text('Relaxed');
                            case 2:
                              return Text('Normal');
                            case 3:
                              return Text('Elevated');
                            case 4:
                              return Text('High');
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Display time intervals on the X-axis
                          return Text('${value.toInt()} sec');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: bpmData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      showingIndicators: List.generate(bpmData.length, (index) => index),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: temperatureData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Colors.orangeAccent,
                      barWidth: 2,
                      showingIndicators: List.generate(temperatureData.length, (index) => index),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: stressData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), mapStressLevel(e.value))).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      showingIndicators: List.generate(stressData.length, (index) => index),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    // Configure tooltips
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          String label;
                          if (spot.bar.color == Colors.red) {
                            label = 'BPM: ${spot.y.toStringAsFixed(1)}';
                          } else if (spot.bar.color == Colors.orangeAccent) {
                            label = 'Temperature: ${spot.y.toStringAsFixed(1)} °C';
                          } else {
                            label = 'Stress: ${spot.y.toStringAsFixed(1)}';
                          }
                          return LineTooltipItem(label, TextStyle(color: spot.bar.color));
                        }).toList();
                      },
                    ),
                  ),
                  // Set the Y-axis ranges to match each metric's expected values
                  minY: 0,
                  maxY: 200, // Default range for BPM, also covering temperature up to 65
                ),
              ),
            ),

            SizedBox(height: 20),

            // Control buttons
            ElevatedButton(
              onPressed: isMonitoring ? null : _startMonitoring,
              child: Text('Start Measuring'),
            ),
            ElevatedButton(
              onPressed: isMonitoring ? _stopMonitoring : null,
              child: Text('Stop Measuring'),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Legend widget to include Key parameter
class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}
