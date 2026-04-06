import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/tr_text.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  Map<String, bool> selectedContacts = {};
  bool selectAll = false;
  bool isLoading = true; // 🔹 Loading state

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    setState(() {
      isLoading = true;
    });

    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );

    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final list = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );

    contacts = list;

    for (var c in contacts) {
      selectedContacts[c.id!] = false;
    }

    filteredContacts = contacts;

    setState(() {
      isLoading = false;
    });
  }

  void searchContacts(String value) {
    filteredContacts = contacts
        .where(
          (c) =>
              (c.displayName ?? "").toLowerCase().contains(value.toLowerCase()),
        )
        .toList();

    setState(() {});
  }

  void toggleSelectAll(bool value) {
    selectAll = value;

    for (var key in selectedContacts.keys) {
      selectedContacts[key] = value;
    }

    setState(() {});
  }

  void toggleSingle(String id, bool value) {
    selectedContacts[id] = value;

    // Update selectAll if needed
    selectAll = !selectedContacts.values.contains(false);

    setState(() {});
  }

  void navigateToPreview() {
    final selected = contacts
        .where((c) => selectedContacts[c.id!] == true)
        .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select contacts")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewContactsScreen(selectedContacts: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'contact'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// SEARCH BAR
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Contact",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: searchContacts,
            ),

            /// SELECT ALL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TrText("select_all_contacts"),
                Checkbox(
                  value: selectAll,
                  onChanged: (v) {
                    toggleSelectAll(v!);
                  },
                  checkColor: Colors.white,
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),

            /// CONTACT LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredContacts.isEmpty
                  ? const Center(child: Text("No contacts found"))
                  : ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final id = contact.id!;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(206, 230, 254, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 28,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            title: Text(contact.displayName ?? "No Name"),
                            subtitle: contact.phones.isNotEmpty
                                ? Text(contact.phones.first.number)
                                : const Text("No Number"),
                            trailing: Checkbox(
                              value: selectedContacts[id] ?? false,
                              onChanged: (v) {
                                toggleSingle(id, v!);
                              },
                              checkColor: Colors.white,
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            /// NEXT BUTTON
            CustomButton(text: 'preview', onPressed: navigateToPreview),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Preview screen
class PreviewContactsScreen extends StatefulWidget {
  final List<Contact> selectedContacts;

  const PreviewContactsScreen({super.key, required this.selectedContacts});

  @override
  State<PreviewContactsScreen> createState() => _PreviewContactsScreenState();
}

class _PreviewContactsScreenState extends State<PreviewContactsScreen> {
  bool _isPrinting = false;

  /// Build PDF with all selected contacts
Future<Uint8List> buildContactsPdf() async {
  final pdf = pw.Document();
  final contacts = widget.selectedContacts;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return [
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: contacts.map((contact) {
              return pw.Container(
                width: (PdfPageFormat.a4.availableWidth - 40) / 3,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      contact.displayName ?? "No Name",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    if (contact.phones.isNotEmpty)
                      pw.Text(
                        contact.phones.first.number,
                        style: const pw.TextStyle(fontSize: 10),
                      )
                    else
                      pw.Text(
                        "No Number",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}
  /// Print selected contacts
 Future<void> printContacts() async {
  try {
    final pdfBytes = await buildContactsPdf();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TrText("printer_not_available")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "preview_contacts",
        actions: [
          IconButton(
           onPressed: _isPrinting
    ? null
    : () async {
        final adsProvider = context.read<AdsProvider>();

        /// ✅ 1. Show Ad FIRST
        await adsProvider.showAdInterstitial();

        if (!mounted) return;

        /// ✅ 2. Show Loader
        setState(() => _isPrinting = true);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Container(
            color: Colors.black.withOpacity(0.3), // 👈 premium feel
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );

        /// ✅ 3. Small delay (VERY IMPORTANT)
        // await Future.delayed(const Duration(milliseconds: 100));

        try {
          /// ✅ 4. Start Printing
          await printContacts();
        } finally {
          /// ✅ 5. Close Loader
          if (mounted) {
            Navigator.pop(context); // close dialog
            setState(() => _isPrinting = false);
          }
        }
      },
            icon: Icon(Icons.print, size: 28, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: widget.selectedContacts.isEmpty
            ? const Center(child: Text("No contacts selected"))
            : ListView.builder(
                itemCount: widget.selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = widget.selectedContacts[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(206, 230, 254, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      title: Text(contact.displayName ?? "No Name"),
                      subtitle: contact.phones.isNotEmpty
                          ? Text(contact.phones.first.number)
                          : const Text("No Number"),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
