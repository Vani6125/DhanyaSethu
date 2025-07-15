import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/custom_drawer.dart';

class SoilReportDashboardScreen extends StatefulWidget {
  @override
  _SoilReportDashboardScreenState createState() =>
      _SoilReportDashboardScreenState();
}

class _SoilReportDashboardScreenState extends State<SoilReportDashboardScreen>
    with TickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 2;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/disease');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final Map<String, double> soilData = {
    'Nitrogen': 0.0,
    'Phosphorus': 0.0,
    'Potassium': 0.0,
    'pH': 0.0,
    'OrganicCarbon': 0.0,
  };

  final Map<String, Map<String, double>> optimalRanges = {
    'Nitrogen': {'min': 150, 'max': 300, 'critical': 100},
    'Phosphorus': {'min': 25, 'max': 50, 'critical': 15},
    'Potassium': {'min': 150, 'max': 300, 'critical': 100},
    'pH': {'min': 6.0, 'max': 7.5, 'critical': 5.5},
    'OrganicCarbon': {'min': 0.5, 'max': 2.0, 'critical': 0.3},
  };

  Map<String, String> remedies = {};

  Map<String, String> getRemedies(Map<String, double> data) {
    Map<String, String> result = {};

    if (data['Nitrogen']! < 150) {
      result['Nitrogen'] =
      'Apply urea (46-0-0) at 100-150 kg/ha or ammonium sulfate. Use green manure crops like dhaincha or incorporate compost at 5-10 tons/ha.';
    }
    if (data['Phosphorus']! < 25) {
      result['Phosphorus'] =
      'Apply DAP (18-46-0) at 100-150 kg/ha or Single Super Phosphate. Use well-decomposed farmyard manure at 10-15 tons/ha.';
    }
    if (data['Potassium']! < 150) {
      result['Potassium'] =
      'Use Muriate of Potash (MOP) at 60-100 kg/ha. Incorporate crop residues and apply wood ash for organic potassium.';
    }
    if (data['pH']! < 5.5) {
      result['pH'] =
      'Soil is acidic. Apply agricultural lime at 1-2 tons/ha. Grow pH-tolerant crops like millets, tea, or blueberries.';
    } else if (data['pH']! > 8) {
      result['pH'] =
      'Soil is alkaline. Use gypsum at 2-4 tons/ha and add organic matter. Consider sulfur application at 200-400 kg/ha.';
    }
    if (data['OrganicCarbon']! < 0.5) {
      result['Organic Carbon'] =
      'Add compost at 5-10 tons/ha, green manure, or farmyard manure regularly. Practice crop rotation with legumes.';
    }

    return result;
  }

  String getHealthStatus(String nutrient, double value) {
    final ranges = optimalRanges[nutrient]!;
    if (value >= ranges['min']! && value <= ranges['max']!) {
      return 'Optimal';
    } else if (value >= ranges['critical']! && value < ranges['min']!) {
      return 'Low';
    } else if (value < ranges['critical']!) {
      return 'Critical';
    } else {
      return 'High';
    }
  }

  Color getHealthColor(String nutrient, double value) {
    final status = getHealthStatus(nutrient, value);
    switch (status) {
      case 'Optimal':
        return Colors.green;
      case 'Low':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        remedies = getRemedies(soilData);
      });
      _animationController.forward();
    }
  }

  Widget _buildTextField(String label) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: '$label value',
          prefixIcon: Icon(_getIconForNutrient(label), color: Colors.deepPurple[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.deepPurple[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter $label value';
          if (double.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
        onSaved: (value) {
          soilData[label] = double.parse(value!);
        },
      ),
    );
  }

  IconData _getIconForNutrient(String nutrient) {
    switch (nutrient) {
      case 'Nitrogen':
        return Icons.grass;
      case 'Phosphorus':
        return Icons.scatter_plot;
      case 'Potassium':
        return Icons.spa;
      case 'pH':
        return Icons.water_drop;
      case 'OrganicCarbon':
        return Icons.eco;
      default:
        return Icons.science;
    }
  }

  Widget _buildNutrientCard(String nutrient, double value) {
    final status = getHealthStatus(nutrient, value);
    final color = getHealthColor(nutrient, value);
    final ranges = optimalRanges[nutrient]!;
    final progress = value / ranges['max']!;

    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getIconForNutrient(nutrient), color: color),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nutrient,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Value: ${value.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: Colors.grey[300],
              color: color,
              minHeight: 8,
            ),
            SizedBox(height: 8),
            Text(
              'Optimal range: ${ranges['min']!.toStringAsFixed(1)} - ${ranges['max']!.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (soilData.values.every((value) => value == 0.0)) {
      return Container();
    }

    List<PieChartSectionData> sections = [];
    int index = 0;

    soilData.forEach((nutrient, value) {
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: getHealthColor(nutrient, value),
            value: value,
            title: nutrient,
            radius: 100,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      index++;
    });

    return Container(
      height: 350,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Soil Composition Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Text('Soil Report Dashboard',style: TextStyle(color: Colors.white),),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[500]!, Colors.deepPurple[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
        drawer: CustomDrawer(
          user: FirebaseAuth.instance.currentUser,
          context: context,
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.green[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Soil Parameters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Provide your soil test results for personalized recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: soilData.keys
                              .map((key) => _buildTextField(key))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.analytics, color: Colors.white),
                          label: Text(
                            "Generate Analysis",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              if (remedies.isNotEmpty) ...[
                _buildPieChart(),
                SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple[500]!, Colors.deepPurple[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Soil Health Analysis",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...soilData.entries.map((entry) =>
                          _buildNutrientCard(entry.key, entry.value)
                      ).toList(),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[700]!, Colors.orange[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Personalized Recommendations",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...remedies.entries.map((entry) => Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.orange[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getIconForNutrient(entry.key),
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ] else
                Container(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Welcome to Soil Analysis",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Enter your soil test values above to get personalized recommendations for better crop yields",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

    bottomNavigationBar: Container(
    decoration: BoxDecoration(
    boxShadow: [
    BoxShadow(
    color: Colors.deepPurple.withOpacity(0.1),
    blurRadius: 10,
    spreadRadius: 2,
    ),
    ],
    border: Border(
    top: BorderSide(
    color: Colors.deepPurple.withOpacity(0.1),
    width: 1,
    ),
    ),
    ),
    child: BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
    selectedItemColor: Colors.deepPurple,
    unselectedItemColor: Colors.grey[700],
    backgroundColor: Colors.white,
    elevation: 10,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    type: BottomNavigationBarType.fixed,
    items: [
    BottomNavigationBarItem(
    icon: Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: _selectedIndex == 0
    ? Colors.deepPurple.withOpacity(0.2)
        : Colors.transparent,
    ),
    child: const Icon(Icons.biotech),
    ),
    label: 'Disease',
    ),
    BottomNavigationBarItem(
    icon: Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: _selectedIndex == 1
    ? Colors.deepPurple.withOpacity(0.2)
        : Colors.transparent,
    ),
    child: const Icon(Icons.home),
    ),
    label: 'Home',
    ),
    BottomNavigationBarItem(
    icon: Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: _selectedIndex == 2
    ? Colors.deepPurple.withOpacity(0.2)
        : Colors.transparent,
    ),
    child: const Icon(Icons.science),
    ),
    label: 'Soil',
    ),
    ],
    ),
    )
    );
  }
}