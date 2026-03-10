import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/models/language_model.dart';
import 'package:smart_scanner/providers/language_provider.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/screens/onboarding_screen.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class SelectLanguageScreen extends StatefulWidget {
  final bool fromSettings;
  const SelectLanguageScreen({super.key, this.fromSettings = false});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  final GetStorage _storage = GetStorage();
  String? selectedCode;
  bool isLoading = false;

  String searchText = "";

  @override
  void initState() {
    super.initState();

    final provider = context.read<LanguageProvider>();
    selectedCode = provider.languageCode;
  }

  Future<void> _applyLanguage() async {
    if (selectedCode == null) return;

    setState(() => isLoading = true);

    _storage.write('languageCode', selectedCode);

    context.read<LanguageProvider>().changeLanguage(selectedCode!);
    await context.read<TranslatorProvider>().loadLanguage(selectedCode!);

    // mark language selected
    _storage.write('hasSelectedLanguage', true);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (widget.fromSettings) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final translator = context.watch<TranslatorProvider>();

    final filteredLanguages = appLanguages
        .where(
          (lang) => lang.name.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: translator.tr("search_language"),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredLanguages.isEmpty
                      ? const Center(
                          child: TrText(
                            "no_language_found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredLanguages.length,
                          itemBuilder: (context, index) {
                            final lang = filteredLanguages[index];
                            bool selected = selectedCode == lang.code;

                            return ListTile(
                              title: Text(lang.name),
                              trailing: selected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedCode = lang.code;
                                });
                              },
                            );
                          },
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CustomButton(
                    onPressed: isLoading ? null : _applyLanguage,
                    text: translator.tr(
                      widget.fromSettings ? "change" : "done",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
