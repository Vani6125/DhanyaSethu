import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../widgets/custom_drawer.dart';

class DiseaseScreen extends StatefulWidget {
  @override
  _DiseaseScreen createState() => _DiseaseScreen();
}

class _DiseaseScreen extends State<DiseaseScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
      // Already on this screen
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/soil');
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  File? _image;
  String? _prediction;
  double? _confidence;
  bool _loading = false;
  String? _errorMessage;

  final picker = ImagePicker();

  // Minimum confidence threshold for predictions
  static const double MIN_CONFIDENCE = 0.6; // 60% confidence minimum

  final Map<String, String> remedies = {
    "Bacterial Leaf Blight Disease or Bacterial Blight Disease":
    "Use copper-based bactericides. Avoid water logging. Use resistant varieties.",
    "Bacterial Leaf Streak Disease":
    "Apply copper fungicides and avoid overhead irrigation.",
    "Brown Spot Disease":
    "Apply fungicides like Mancozeb. Improve soil fertility and use disease-free seeds.",
    "Dirty Panicle Disease":
    "Improve drainage, avoid excess nitrogen, and use clean seed stock.",
    "Grassy Stunt Disease":
    "Control brown planthopper insects. Remove infected plants and weeds.",
    "Narrow Brown Spot Disease":
    "Use balanced fertilization. Apply appropriate fungicides during early infection.",
    "Rice Blast Disease":
    "Apply Tricyclazole. Avoid high nitrogen levels. Use resistant varieties.",
    "Rice Ragged Stunt Disease":
    "Control green leafhoppers and remove infected plants promptly.",
    "Rice Tungro Disease or Yellow Orange Leaf Disease":
    "Use virus-free seedlings. Control leafhoppers and remove infected plants.",
    "Sheath blight Disease":
    "Apply validamycin or propiconazole. Maintain good field hygiene.",
    "No disease detected":
    "Your crop looks healthy! Keep monitoring regularly.",
    "Healthy":
    "Your rice plant looks healthy! Continue with regular care and monitoring."
  };

  // Valid rice disease classes that the model can predict
  final Set<String> validRiceDiseases = {
    "Bacterial Leaf Blight Disease or Bacterial Blight Disease",
    "Bacterial Leaf Streak Disease",
    "Brown Spot Disease",
    "Dirty Panicle Disease",
    "Grassy Stunt Disease",
    "Narrow Brown Spot Disease",
    "Rice Blast Disease",
    "Rice Ragged Stunt Disease",
    "Rice Tungro Disease or Yellow Orange Leaf Disease",
    "Sheath blight Disease",
    "No disease detected",
    "Healthy"
  };

  Future<void> requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
      Permission.mediaLibrary,
    ].request();
  }

  Future<void> pickFromCamera() async {
    await requestPermissions();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _prediction = null;
      _confidence = null;
      _errorMessage = null;
      setState(() {});
      await uploadToRoboflow(_image!);
    }
  }

  Future<void> pickFromGallery() async {
    await requestPermissions();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _prediction = null;
      _confidence = null;
      _errorMessage = null;
      setState(() {});
      await uploadToRoboflow(_image!);
    }
  }

  bool _isValidRicePrediction(String prediction, double confidence) {
    // Check if prediction is in our valid diseases list
    if (!validRiceDiseases.contains(prediction)) {
      return false;
    }

    // Check if confidence meets minimum threshold
    if (confidence < MIN_CONFIDENCE) {
      return false;
    }

    return true;
  }

  String _normalizeHealthyPrediction(String prediction) {
    // Normalize different healthy predictions to a consistent format
    final lowerPrediction = prediction.toLowerCase();
    if (lowerPrediction.contains('healthy') ||
        lowerPrediction.contains('no disease') ||
        lowerPrediction == 'normal') {
      return "Healthy";
    }
    return prediction;
  }

  Future<void> uploadToRoboflow(File imageFile) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final apiKey = 'xxxzNj7cVdJVEi0NUZtw'; // Replace with your actual key
    final modelId = 'rice-disease-vahwz/4';

    // Use classify endpoint for classification models
    final url = Uri.parse(
        'https://classify.roboflow.com/$modelId?api_key=$apiKey');

    try {
      // Read image as bytes and encode to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Send POST request with base64 image
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: base64Image,
      );

      print("🔍 Status Code: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("✅ Decoded response: $decoded");

        setState(() {
          if (decoded['predictions'] != null && decoded['predictions'].isNotEmpty) {
            final topPrediction = decoded['predictions'][0];
            final predictedClass = topPrediction['class'] ?? 'Unknown';
            final confidence = topPrediction['confidence']?.toDouble() ?? 0.0;

            print("🎯 Predicted class: $predictedClass");
            print("📊 Confidence: ${(confidence * 100).toStringAsFixed(1)}%");

            // Normalize healthy predictions
            final normalizedPrediction = _normalizeHealthyPrediction(predictedClass);

            // Validate prediction
            if (_isValidRicePrediction(normalizedPrediction, confidence)) {
              _prediction = normalizedPrediction;
              _confidence = confidence;
              _errorMessage = null;
            } else {
              _prediction = null;
              _confidence = null;

              if (confidence < MIN_CONFIDENCE) {
                _errorMessage = "Low confidence prediction (${(confidence * 100).toStringAsFixed(1)}%). Please try with a clearer image of the rice plant with better lighting.";
              } else {
                _errorMessage = "This doesn't appear to be a rice plant image. Please upload a clear photo of rice plant leaves, stems, or panicles.";
              }
            }
          } else {
            _prediction = null;
            _confidence = null;
            _errorMessage = "No predictions found. Please try with a clearer image of a rice plant.";
          }
          _loading = false;
        });
      } else {
        print("❌ Prediction failed with code ${response.statusCode}");
        print("❌ Error body: ${response.body}");

        // Try to parse error message
        String errorMessage = 'Prediction failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // If JSON parsing fails, use default message
        }

        setState(() {
          _prediction = null;
          _confidence = null;
          _errorMessage = errorMessage;
          _loading = false;
        });
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      setState(() {
        _prediction = null;
        _confidence = null;
        _errorMessage = 'Network error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Color _getDiseaseColor(String disease) {
    if (disease.toLowerCase().contains('blight')) {
      return Colors.red.shade600;
    } else if (disease.toLowerCase().contains('spot')) {
      return Colors.orange.shade600;
    } else if (disease.toLowerCase().contains('blast')) {
      return Colors.purple.shade600;
    } else if (disease.toLowerCase().contains('tungro') || disease.toLowerCase().contains('yellow')) {
      return Colors.amber.shade600;
    } else if (disease.toLowerCase().contains('stunt')) {
      return Colors.brown.shade600;
    } else if (disease.toLowerCase().contains('healthy') || disease.toLowerCase().contains('no disease')) {
      return Colors.green.shade600;
    } else {
      return Colors.blue.shade600;
    }
  }

  IconData _getDiseaseIcon(String disease) {
    if (disease.toLowerCase().contains('blight')) {
      return Icons.warning_amber;
    } else if (disease.toLowerCase().contains('spot')) {
      return Icons.error_outline;
    } else if (disease.toLowerCase().contains('blast')) {
      return Icons.dangerous;
    } else if (disease.toLowerCase().contains('tungro') || disease.toLowerCase().contains('yellow')) {
      return Icons.wb_sunny;
    } else if (disease.toLowerCase().contains('stunt')) {
      return Icons.height;
    } else if (disease.toLowerCase().contains('healthy') || disease.toLowerCase().contains('no disease')) {
      return Icons.check_circle_outline;
    } else {
      return Icons.bug_report;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? remedy = _prediction != null ? remedies[_prediction!] : null;

    return Scaffold(
      appBar:  AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Text('Rice Disease Detector',style: TextStyle(color: Colors.white),),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Image Display Section
              _image != null
                  ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _image!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No image selected",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Results Section
              _loading
                  ? Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Analyzing your rice plant...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
                  : _errorMessage != null
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Error",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : _prediction != null
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Analysis Results",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:Border(
                          left: BorderSide(
                            color: _getDiseaseColor(_prediction!),
                            width: 4,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getDiseaseIcon(_prediction!),
                                color: _getDiseaseColor(_prediction!),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _prediction!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getDiseaseColor(_prediction!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_confidence != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.speed,
                                  color: Colors.grey.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (remedy != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getDiseaseColor(_prediction!).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _prediction!.toLowerCase().contains('healthy') || _prediction!.toLowerCase().contains('no disease')
                                        ? Icons.tips_and_updates
                                        : Icons.healing,
                                    color: _getDiseaseColor(_prediction!),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      remedy,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ready to Analyze",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Capture or upload a rice plant photo to detect diseases",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickFromCamera,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        "Take Photo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickFromGallery,
                      icon: const Icon(Icons.photo_library, color: Colors.deepPurple),
                      label: const Text(
                        "Gallery",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
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