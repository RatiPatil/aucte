import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FhirPreviewScreen extends StatefulWidget {
  const FhirPreviewScreen({super.key, this.fhirJson, this.title});

  final String? fhirJson;
  final String? title;

  @override
  State<FhirPreviewScreen> createState() => _FhirPreviewScreenState();
}

class _FhirPreviewScreenState extends State<FhirPreviewScreen> {
  String _jsonContent = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_jsonContent.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('fhirJson')) {
        _jsonContent = args['fhirJson'] as String;
      } else if (widget.fhirJson != null) {
        _jsonContent = widget.fhirJson!;
      } else {
        _jsonContent = '''{
  "resourceType": "Bundle",
  "id": "auc-bundle-demo",
  "type": "document",
  "meta": {
    "profile": ["https://aucte.ayush.gov.in/fhir/StructureDefinition/aucte-clinical-document"]
  },
  "entry": []
}''';
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _jsonContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('FHIR R4 Bundle JSON copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title ?? 'FHIR R4 Bundle Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: _copyToClipboard,
            tooltip: 'Copy JSON',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Code Header info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FHIR R4',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Interoperable Clinical Resource Bundle',
                      style: AppTextStyles.labelMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ),

            // Dark JSON Syntax viewer
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.codeBackground,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _jsonContent,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      color: AppColors.codeText,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'FHIR R4 Bundle record saved locally.',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Save Record'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
