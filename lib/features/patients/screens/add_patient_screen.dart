import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/patient_model.dart';
import '../repositories/local_patient_repository.dart';
import '../repositories/patient_repository.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _mobileController = TextEditingController();
  final _abhaController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  String _gender = 'Male';
  String? _bloodGroup = 'O+';
  DateTime _dateOfBirth = DateTime(1995, 1, 1);
  bool _isSaving = false;
  bool _isFetchingLocation = false;
  bool _isSearchingDisease = false;
  Timer? _debounce;
  String _lastDiseaseQuery = '';
  List<String> _cachedDiseases = [];

  final List<String> _genders = const ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _diseaseController.dispose();
    _aadhaarController.dispose();
    _mobileController.dispose();
    _abhaController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<Iterable<String>> _searchDiseases(TextEditingValue textEditingValue) async {
    final query = textEditingValue.text.trim();
    if (query.length < 2) return const Iterable<String>.empty();
    if (query == _lastDiseaseQuery) return _cachedDiseases;

    final completer = Completer<Iterable<String>>();
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      _lastDiseaseQuery = query;
      setState(() => _isSearchingDisease = true);
      try {
        final response = await http.get(Uri.parse('https://clinicaltables.nlm.nih.gov/api/conditions/v3/search?terms=$query&df=term&maxList=10'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is List && data.length >= 4) {
            final items = data[3] as List;
            _cachedDiseases = items.map((e) => (e as List)[0].toString()).toList();
            completer.complete(_cachedDiseases);
          } else {
             completer.complete([]);
          }
        } else {
          completer.complete([]);
        }
      } catch (e) {
        completer.complete([]);
      } finally {
        if (mounted) setState(() => _isSearchingDisease = false);
      }
    });

    return completer.future;
  }

  Future<void> _fetchPincodeData(String pincode) async {
    if (pincode.length != 6) return;
    
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final firstResult = data[0];
          if (firstResult['Status'] == 'Success') {
            final postOffice = firstResult['PostOffice'][0];
            setState(() {
              _stateController.text = postOffice['State'] ?? '';
              _districtController.text = postOffice['District'] ?? '';
              _talukaController.text = postOffice['Block'] ?? postOffice['Division'] ?? '';
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid PIN Code. Please enter a valid 6-digit Indian PIN Code.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to fetch location details. Please try again or enter the details manually.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _savePatient() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted fields before saving.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final firstName = _firstNameController.text.trim();
    final middleName = _middleNameController.text.trim();
    final surname = _surnameController.text.trim();

    if (firstName.isEmpty || middleName.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First Name, Middle Name and Surname are required.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final generatedId = 'PAT-${const Uuid().v4().substring(0, 6).toUpperCase()}';
      
      final patient = PatientModel(
        id: generatedId,
        fullName: '$firstName $middleName $surname'.trim().replaceAll(RegExp(r'\s+'), ' '),
        firstName: firstName,
        middleName: middleName,
        surname: surname,
        diseaseName: _diseaseController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim().isNotEmpty ? _aadhaarController.text.trim() : null,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        mobile: _mobileController.text.trim(),
        abhaNumber: _abhaController.text.trim().isNotEmpty
            ? _abhaController.text.trim()
            : null,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        taluka: _talukaController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        country: _countryController.text.trim(),
        bloodGroup: _bloodGroup,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final PatientRepository patientRepo = LocalPatientRepository.instance;
      await patientRepo.addPatient(patient);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Patient Created'),
            content: Text('The patient has been successfully created with ID: $generatedId'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.patientDetail, arguments: patient);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save patient. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dobText =
        "${_dateOfBirth.day}/${_dateOfBirth.month}/${_dateOfBirth.year}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Patient Demographics',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Fields
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'e.g. Sunita',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter first name';
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'Enter valid alphabetic name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                
                TextFormField(
                  controller: _middleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Middle Name *',
                    hintText: 'e.g. Kumar',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter middle name';
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'Enter valid alphabetic name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    labelText: 'Surname / Last Name *',
                    hintText: 'e.g. Devi',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter surname';
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'Enter valid alphabetic name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Gender Segmented Selection
                Text(
                  'Gender *',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: _genders.map((g) {
                    final selected = _gender == g;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _gender = g;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primarySoft
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              g,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Date of birth
                InkWell(
                  onTap: _selectDateOfBirth,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth *',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dobText, style: AppTextStyles.bodyLarge),
                        const Icon(
                          Icons.edit_calendar_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Mobile
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: '10-digit mobile number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Enter valid 10-digit mobile'
                      : null,
                ),
                const SizedBox(height: 14),

                // Disease Name
                Autocomplete<String>(
                  optionsBuilder: _searchDiseases,
                  onSelected: (String selection) {
                    _diseaseController.text = selection;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    // Sync controller so validation works
                    textEditingController.addListener(() {
                      _diseaseController.text = textEditingController.text;
                    });
                    
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Disease Name *',
                        hintText: 'e.g. Diabetes (Type 2 letters to search)',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        suffixIcon: _isSearchingDisease
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter disease name'
                          : null,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final String option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(option),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Aadhaar Number (Optional)
                TextFormField(
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Aadhaar Number (Optional)',
                    hintText: '12-digit Aadhaar',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      if (!RegExp(r'^\d{12}$').hasMatch(v.trim())) {
                        return 'Please enter a valid 12-digit Aadhaar number.';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ABHA Number (Optional)
                TextFormField(
                  controller: _abhaController,
                  decoration: const InputDecoration(
                    labelText: 'ABHA Number (Optional)',
                    hintText: 'e.g. 91-8842-1092-3841',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                    helperText:
                        'Real ABHA verification will be added in production',
                  ),
                ),
                const SizedBox(height: 14),

                // Blood Group
                DropdownButtonFormField<String>(
                  initialValue: _bloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items: _bloodGroups.map((bg) {
                    return DropdownMenuItem(value: bg, child: Text(bg));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _bloodGroup = val;
                    });
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  'Patient Address',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Country
                TextFormField(
                  controller: _countryController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Country *',
                    prefixIcon: Icon(Icons.public_outlined),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 14),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Full Address *',
                    hintText: 'House No., Near Landmark, Main Road',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter full address';
                    if (!RegExp(r'^[a-zA-Z0-9\s,\-/\.#]+$').hasMatch(v.trim())) {
                      return 'Enter valid address characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // PIN Code
                TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'PIN Code *',
                    hintText: 'e.g. 413304',
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                    suffixIcon: _isFetchingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (value.trim().length == 6) {
                      _fetchPincodeData(value.trim());
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter PIN Code';
                    if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                      return 'Please enter a valid 6-digit PIN Code.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // State & District
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State *',
                          hintText: 'Maharashtra',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter state' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(
                          labelText: 'District *',
                          hintText: 'Solapur',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter district' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Taluka & Village
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _talukaController,
                        decoration: const InputDecoration(
                          labelText: 'Taluka / Sub-District',
                          hintText: 'Pandharpur',
                          prefixIcon: Icon(Icons.my_location_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Village / City *',
                          hintText: 'Bhose',
                          prefixIcon: Icon(Icons.holiday_village_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter village/city' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Save Patient Record',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
