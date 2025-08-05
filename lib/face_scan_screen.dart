import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class StyleSuggestion {
  final String category;
  final List<String> suggestions;
  final String reasoning;
  final IconData icon;
  final Color color;

  StyleSuggestion({
    required this.category,
    required this.suggestions,
    required this.reasoning,
    required this.icon,
    required this.color,
  });
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  File? _imageFile;
  List<StyleSuggestion> _suggestions = [];
  bool _isAnalyzing = false;
  String _errorMessage = '';
  String _analysisStatus = '';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _isAnalyzing = true;
          _errorMessage = '';
          _suggestions.clear();
          _analysisStatus = 'Detecting facial features...';
        });
        await _analyzeFace(picked.path);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
        _isAnalyzing = false;
        _analysisStatus = '';
      });
    }
  }

  Future<void> _analyzeFace(String path) async {
    try {
      setState(() {
        _analysisStatus = 'Processing facial landmarks...';
      });

      final inputImage = InputImage.fromFilePath(path);
      final options = FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
      );
      final faceDetector = FaceDetector(options: options);

      setState(() {
        _analysisStatus = 'Analyzing face structure...';
      });

      final faces = await faceDetector.processImage(inputImage);

      await faceDetector.close();

      if (faces.isEmpty) {
        setState(() {
          _errorMessage =
              'No face detected in the image. Please try with a clearer photo showing your face.';
          _isAnalyzing = false;
          _analysisStatus = '';
        });
        return;
      }

      setState(() {
        _analysisStatus = 'Generating style recommendations...';
      });

      // Add a small delay for better UX
      await Future.delayed(Duration(milliseconds: 500));

      final face = faces.first;
      final suggestions = _generateSuggestions(face);

      setState(() {
        _suggestions = suggestions;
        _isAnalyzing = false;
        _analysisStatus = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error analyzing face: $e';
        _isAnalyzing = false;
        _analysisStatus = '';
      });
    }
  }

  List<StyleSuggestion> _generateSuggestions(Face face) {
    List<StyleSuggestion> suggestions = [];

    // Face shape analysis
    final faceShape = _analyzeFaceShape(face);
    suggestions.add(_getHaircutSuggestions(faceShape));

    // Beard analysis
    final beardAnalysis = _analyzeBeardPotential(face);
    suggestions.add(beardAnalysis);

    // Eye analysis for glasses suggestions
    final eyeAnalysis = _analyzeEyeFeatures(face);
    suggestions.add(eyeAnalysis);

    return suggestions;
  }

  String _analyzeFaceShape(Face face) {
    final boundingBox = face.boundingBox;
    final width = boundingBox.width;
    final height = boundingBox.height;
    final ratio = height / width;

    if (ratio > 1.3) return 'Long';
    if (ratio < 1.1) return 'Wide';
    if (width > height * 0.9 && width < height * 1.1) return 'Square';
    return 'Oval';
  }

  StyleSuggestion _getHaircutSuggestions(String faceShape) {
    Map<String, List<String>> haircutMap = {
      'Long': ['Side-swept fringe', 'Layered cut', 'Pompadour', 'Quiff'],
      'Wide': ['High fade', 'Buzz cut', 'Crew cut', 'Short sides long top'],
      'Square': ['Textured crop', 'Side part', 'Undercut', 'Slicked back'],
      'Oval': ['Classic taper', 'Modern quiff', 'Fade', 'Any style works!'],
    };

    return StyleSuggestion(
      category: 'Haircut Recommendations',
      suggestions: haircutMap[faceShape] ?? ['Classic cut', 'Fade', 'Trim'],
      reasoning: 'Perfect styles for your $faceShape face shape',
      icon: Icons.content_cut,
      color: Color(0xff1E2676),
    );
  }

  StyleSuggestion _analyzeBeardPotential(Face face) {
    final landmarks = face.landmarks;
    final boundingBox = face.boundingBox;

    // Check jawline strength and chin prominence
    final bottomMouth = landmarks[FaceLandmarkType.bottomMouth]?.position;
    final chinBottom = boundingBox.bottom;

    bool strongJawline = false;
    if (bottomMouth != null) {
      final chinLength = chinBottom - bottomMouth.y;
      strongJawline = chinLength > 25;
    }

    List<String> beardSuggestions;
    String reasoning;

    if (strongJawline) {
      beardSuggestions = ['Full beard', 'Goatee', 'Van Dyke', 'Circle beard'];
      reasoning = 'Your strong jawline can support various beard styles';
    } else {
      beardSuggestions = [
        'Light stubble',
        'Clean shave',
        'Soul patch',
        'Mustache',
      ];
      reasoning = 'Lighter facial hair complements your facial structure';
    }

    return StyleSuggestion(
      category: 'Facial Hair Options',
      suggestions: beardSuggestions,
      reasoning: reasoning,
      icon: Icons.face_retouching_natural,
      color: Colors.orange,
    );
  }

  StyleSuggestion _analyzeEyeFeatures(Face face) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    List<String> glassesSuggestions = [
      'Rectangular frames',
      'Round frames',
      'Aviator style',
      'Wayfarers',
    ];

    String reasoning = 'Based on your eye spacing and face proportions';

    if (leftEye != null && rightEye != null) {
      final eyeDistance = (rightEye.position.x - leftEye.position.x).abs();
      if (eyeDistance > 60) {
        glassesSuggestions = [
          'Wide frames',
          'Oversized glasses',
          'Cat-eye frames',
        ];
        reasoning = 'Wide-set eyes look great with broader frame styles';
      } else if (eyeDistance < 45) {
        glassesSuggestions = [
          'Narrow frames',
          'Small round glasses',
          'Slim rectangles',
        ];
        reasoning = 'Close-set eyes are complemented by sleeker frame designs';
      }
    }

    return StyleSuggestion(
      category: 'Eyewear Suggestions',
      suggestions: glassesSuggestions,
      reasoning: reasoning,
      icon: Icons.visibility,
      color: Colors.green,
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xff1E2676),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  subtitle: 'Take a new photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                SizedBox(height: 8.h),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  title: 'Gallery',
                  subtitle: 'Choose from gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Color(0xff1E2676).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: Color(0xff1E2676), size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1E2676),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff1E2676),
        foregroundColor: Colors.white,
        title: Text(
          'Smart Mirror',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image upload section
            Container(
              height: 320.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Color(0xff1E2676).withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child:
                  _imageFile != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Stack(
                          children: [
                            Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            if (_isAnalyzing)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xff1E2676),
                                              ),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        _analysisStatus,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Color(0xff1E2676).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.face_retouching_natural,
                              size: 64.sp,
                              color: Color(0xff1E2676),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Upload Your Photo',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1E2676),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Get AI-powered style recommendations\nbased on your facial features',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
            ),

            SizedBox(height: 20.h),

            // Upload button
            Container(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _showImageSourceDialog,
                icon: Icon(
                  _isAnalyzing ? Icons.hourglass_empty : Icons.camera_alt,
                  size: 20.sp,
                ),
                label: Text(
                  _isAnalyzing ? 'Analyzing Photo...' : 'Upload Photo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff1E2676),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Suggestions display
            if (_suggestions.isNotEmpty) ...[
              Text(
                'Your Style Recommendations',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1E2676),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            ..._suggestions
                .map(
                  (suggestion) => Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: suggestion.color.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: suggestion.color.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.r),
                              topRight: Radius.circular(10.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: suggestion.color,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  suggestion.icon,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suggestion.category,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: suggestion.color,
                                      ),
                                    ),
                                    Text(
                                      suggestion.reasoning,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: suggestion.color.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommended Styles',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children:
                                    suggestion.suggestions
                                        .map(
                                          (style) => Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 14.w,
                                              vertical: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: suggestion.color
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              border: Border.all(
                                                color: suggestion.color
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              style,
                                              style: TextStyle(
                                                color: suggestion.color,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            if (_suggestions.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Color(0xff1E2676).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Color(0xff1E2676).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xff1E2676),
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'These recommendations are based on AI analysis of your facial features. Consult with a professional stylist for personalized advice.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xff1E2676),
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
    );
  }
}
