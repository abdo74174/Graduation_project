import 'package:dio/dio.dart';
import 'dart:async';

class ProductDescriptionService {
  final Dio _dio = Dio();
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  // Store API keys
  static const List<String> _apiKeys = [
    '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',
  ];

  int _currentKeyIndex = 0;
  DateTime? _lastRequestTime;
  Map<String, int> _requestCounts = {};
  Map<String, DateTime> _windowStartTimes = {};
  // Cache for recent descriptions
  final Map<String, String> _descriptionCache = {};
  // Debounce timer
  DateTime? _lastCallTime;
  static const _debounceDuration = Duration(seconds: 2);

  // Rate limiting constants
  static const _minRequestInterval = Duration(seconds: 5);
  static const _maxRequestsPerMinute = 20;
  static const _rateLimitWindowDuration = Duration(minutes: 1);
  // ignore: unused_field
  static const _maxRetriesOnRateLimit = 2;

  void _resetRateLimitWindow(String apiKey) {
    _requestCounts[apiKey] = 0;
    _windowStartTimes[apiKey] = DateTime.now();
  }

  bool _isRateLimited(String apiKey) {
    final now = DateTime.now();
    if (!_windowStartTimes.containsKey(apiKey)) {
      _resetRateLimitWindow(apiKey);
      return false;
    }

    final windowStart = _windowStartTimes[apiKey]!;
    if (now.difference(windowStart) >= _rateLimitWindowDuration) {
      _resetRateLimitWindow(apiKey);
      return false;
    }

    return (_requestCounts[apiKey] ?? 0) >= _maxRequestsPerMinute;
  }

  void _incrementRequestCount(String apiKey) {
    _requestCounts[apiKey] = (_requestCounts[apiKey] ?? 0) + 1;
  }

  // Validate category and subcategory compatibility
  bool _isValidSubCategory(String category, String? subCategory) {
    if (subCategory == null) return true;
    final categoryLower = category.toLowerCase();
    final subCategoryLower = subCategory.toLowerCase();

    final validSubCategories = {
      'blood pressure monitors': ['arm monitors', 'wrist monitors'],
      'stethoscopes': ['acoustic', 'electronic'],
      'surgical instruments': ['scalpels', 'forceps', 'retractors'],
      'diagnostic equipment': ['ultrasound', 'x-ray', 'ecg'],
      'medical supplies': ['bandages', 'syringes', 'gloves'],
      'rehabilitation equipment': ['wheelchairs', 'crutches', 'braces'],
      'monitoring devices': ['pulse oximeters', 'heart rate monitors'],
      'medical furniture': ['hospital beds', 'examination tables'],
    };

    final validSubs = validSubCategories[categoryLower] ?? [];
    return validSubs.contains(subCategoryLower) || subCategoryLower.isEmpty;
  }

  // Normalize product name to fix common typos
  String _normalizeProductName(String productName) {
    final normalized = productName.toLowerCase();
    if (normalized.contains('presure')) {
      return productName.replaceAll(
          RegExp(r'presure', caseSensitive: false), 'Pressure');
    }
    return productName;
  }

  // Generate cache key
  String _generateCacheKey(
      String productName, String category, String? subCategory) {
    return '$productName|$category|${subCategory ?? ''}';
  }

  // Expanded default descriptions for medical categories
  final Map<String, String> _defaultDescriptions = {
    'Blood Pressure Monitors': '''
State-of-the-art blood pressure monitoring system featuring oscillometric measurement technology and advanced motion artifact elimination. 
Delivers clinically validated accuracy (±3 mmHg) with dual-sensor technology for systolic, diastolic, and pulse readings. 
Includes advanced features: irregular heartbeat detection, multi-user memory (up to 120 readings), averaging function, and hypertension risk indicator. 
LCD display with backlight shows systolic/diastolic pressure, pulse rate, date/time, and battery status. 
Compliant with international standards (ISO 81060-2:2018) for professional medical use.
''',
    'Stethoscopes': '''
Premium diagnostic stethoscope with patented dual-frequency membrane (20-200Hz/100-500Hz) for superior acoustics. 
Features precision-crafted stainless steel chest piece with proprietary tunable diaphragm technology. 
Dual-lumen tubing eliminates external noise interference while anatomically designed ear tips ensure perfect sealing. 
Includes pediatric diaphragm adapter and latex-free components. 
Meets AAMI/ANSI/ISO 13485:2016 standards for professional diagnostic instruments.
''',
    'Surgical Instruments': '''
Medical-grade surgical instruments crafted from martensitic stainless steel (ASTM F899-12b compliant) with precision-engineered tips. 
Features tungsten carbide inserts for superior cutting performance and extended durability. 
Ergonomic handles with textured grip pattern ensure precise control during delicate procedures. 
Autoclavable up to 137°C (279°F), corrosion-resistant, and laser-tested for alignment. 
Meets stringent ISO 7153-1:2016 standards for surgical instruments.
''',
    'Diagnostic Equipment': '''
Advanced diagnostic system incorporating multi-parameter monitoring with high-resolution digital imaging (1920x1080p). 
Features real-time data processing with < 250ms latency and automated calibration system. 
Supports multiple diagnostic protocols with integrated AI-assisted analysis and interpretation. 
Includes secure data encryption (AES-256) and DICOM 3.0 compatibility for seamless integration. 
Certified to IEC 60601-1 standards for medical electrical equipment.
''',
    'Medical Supplies': '''
Premium medical supplies manufactured in ISO Class 7 cleanroom environments meeting USP <797> standards. 
Features medical-grade materials with biocompatibility testing (ISO 10993) and strict quality control. 
Sterilized using validated processes (ISO 11137) with lot-specific documentation and traceability. 
Includes tamper-evident packaging and clear usage instructions. 
Complies with FDA 21 CFR Part 820 quality system regulations.
''',
    'Rehabilitation Equipment': '''
Professional rehabilitation system designed with variable resistance technology (0-100kg) and precision load cells. 
Features anatomically optimized support structures with high-density foam (45-50 ILD) and antimicrobial upholstery. 
Includes digital angle measurement (±0.5° accuracy) and automated progress tracking. 
Supports multiple therapy protocols with adjustable settings for different rehabilitation stages. 
Certified to EN 957 standards for professional therapy equipment.
''',
    'Monitoring Devices': '''
High-precision patient monitoring system with multi-parameter capability (ECG, SpO2, NIBP, Temp, Resp). 
Features medical-grade sensors with 24-bit ADC resolution and advanced signal processing. 
Supports continuous monitoring with customizable alarm thresholds and trend analysis. 
Includes wireless connectivity (IEEE 802.11 a/b/g/n) and 48-hour data storage. 
Compliant with IEC 60601-1-8 for alarm systems in medical equipment.
''',
    'Medical Furniture': '''
Hospital-grade furniture constructed with antimicrobial powder-coated steel frame (load capacity: 250kg). 
Features high-density foam padding (ASTM D3574) with fluid-resistant, antimicrobial vinyl covering. 
Includes electric actuators with emergency battery backup and position memory settings. 
Supports Trendelenburg/reverse positions with smooth, quiet operation (<45dB). 
Meets IEC 60601-2-52 standards for medical beds and accessories.
''',
    'default': '''
Professional medical device engineered to meet international healthcare standards (ISO 13485:2016). 
Features precision components with documented quality control and performance validation. 
Includes comprehensive documentation, calibration certificates, and maintenance guidelines. 
Supports integration with standard medical protocols and workflows. 
Compliant with relevant FDA and CE marking requirements for medical devices.
'''
  };

  Future<String> generateDescription({
    required String productName,
    required String category,
    String? subCategory,
  }) async {
    // Normalize product name
    final normalizedProductName = _normalizeProductName(productName);

    // Check cache
    final cacheKey =
        _generateCacheKey(normalizedProductName, category, subCategory);
    if (_descriptionCache.containsKey(cacheKey)) {
      print('✅ Retrieved description from cache for $normalizedProductName');
      return _descriptionCache[cacheKey]!;
    }

    // Validate subcategory
    if (!_isValidSubCategory(category, subCategory)) {
      print(
          '⚠️ Invalid subcategory "$subCategory" for category "$category". Ignoring subcategory.');
      subCategory = null;
    }

    // Debounce check
    final now = DateTime.now();
    if (_lastCallTime != null &&
        now.difference(_lastCallTime!) < _debounceDuration) {
      print(
          '⏳ Debouncing: Too soon to make another API call. Using default description.');
      return _getDefaultDescription(category);
    }
    _lastCallTime = now;

    final String prompt = '''
Generate a professional and engaging product description for a medical product with the following details:
- Product Name: $normalizedProductName
- Category: $category${subCategory != null ? '\n- Subcategory: $subCategory' : ''}

Requirements:
- Length: 50-100 words
- Tone: Professional and informative
- Include: Key features, benefits, and target users
- Focus: Medical/healthcare context
- Highlight: Quality, safety, and reliability
- Format: Direct description without introductory phrases

Example style:
"Advanced surgical instrument featuring precision-engineered stainless steel construction. Delivers exceptional accuracy and control during procedures. Ergonomic design ensures comfortable handling during extended use. Meets rigorous medical standards for safety and reliability. Ideal for professional healthcare settings."
''';

    try {
      print(
          '🤖 Attempting to generate AI description for $normalizedProductName');
      print('📝 Category: $category');
      if (subCategory != null) print('📝 Subcategory: $subCategory');

      // Try each API key
      for (int keyAttempt = 0; keyAttempt < _apiKeys.length; keyAttempt++) {
        final currentKey = _apiKeys[_currentKeyIndex];

        // Check local rate limiting
        if (_isRateLimited(currentKey)) {
          print(
              '⏳ Local rate limit reached for API key ${_currentKeyIndex + 1}, rotating to next key...');
          _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
          continue;
        }

        // Enforce minimum interval between uproducts
        if (_lastRequestTime != null) {
          final timeSinceLastRequest =
              DateTime.now().difference(_lastRequestTime!);
          if (timeSinceLastRequest < _minRequestInterval) {
            await Future.delayed(_minRequestInterval - timeSinceLastRequest);
          }
        }

        // Try up to 3 times with exponential backoff for the current key
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            print(
                '🔑 Trying API key ${_currentKeyIndex + 1}, attempt ${attempt + 1} at ${DateTime.now().toIso8601String()}');

            final response = await _dio.post(
              _baseUrl,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $currentKey',
                  'HTTP-Referer':
                      'https://yourapp.com', // Required by OpenRouter
                  'X-Title': 'MedBridge', // Can be your app name
                },
                validateStatus: (status) => status! < 500,
              ),
              data: {
                "model": "mistralai/mistral-7b-instruct",
                "messages": [
                  {
                    "role": "system",
                    "content":
                        "You are a professional medical product description writer. Create concise, accurate, and engaging descriptions that highlight key features and benefits while maintaining medical accuracy."
                  },
                  {"role": "user", "content": prompt}
                ],
                "temperature": 0.7,
                "max_tokens": 150,
                "presence_penalty": 0.1,
                "frequency_penalty": 0.1,
              },
            );

            _lastRequestTime = DateTime.now();
            _incrementRequestCount(currentKey);
            print('📡 API Response Status: ${response.statusCode}');

            if (response.statusCode == 200) {
              final description =
                  response.data['choices'][0]['message']['content'].trim();
              print('✅ Successfully generated AI description');
              _descriptionCache[cacheKey] = description; // Cache the result
              return description;
            } else if (response.statusCode == 429) {
              print(
                  '⏳ Rate limit hit for current API key (attempt ${attempt + 1})');
              if (attempt < 2) {
                // Exponential backoff: 10s, 20s
                final delaySeconds = 10 * (attempt + 1);
                print('⏳ Waiting $delaySeconds seconds before retrying...');
                await Future.delayed(Duration(seconds: delaySeconds));
                continue;
              } else {
                print(
                    '⏳ Max retries reached for rate limit, rotating to next key...');
                _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
                break;
              }
            } else {
              print('❌ API error: ${response.statusCode}');
              print('❌ Error details: ${response.data}');
              break;
            }
          } catch (e) {
            print('❌ Attempt ${attempt + 1} failed: $e');
            if (attempt < 2) {
              await Future.delayed(Duration(seconds: (attempt + 1) * 2));
              continue;
            }
          }
        }
      }

      print('⚠️ All API attempts failed, using default description');
      final defaultDescription = _getDefaultDescription(category);
      _descriptionCache[cacheKey] = defaultDescription; // Cache default
      return defaultDescription;
    } catch (e) {
      print('❌ Error generating description: $e');
      final defaultDescription = _getDefaultDescription(category);
      _descriptionCache[cacheKey] = defaultDescription; // Cache default
      return defaultDescription;
    }
  }

  String _getDefaultDescription(String category) {
    print('📝 Using default description for category: $category');

    // Try to find an exact match first
    String? description = _defaultDescriptions[category];

    // If no exact match, try to find a partial match
    if (description == null) {
      final categoryLower = category.toLowerCase();
      for (var entry in _defaultDescriptions.entries) {
        if (categoryLower.contains(entry.key.toLowerCase())) {
          description = entry.value;
          break;
        }
      }
    }

    // If still no match, use default
    return (description ?? _defaultDescriptions['default']!).trim();
  }
}
