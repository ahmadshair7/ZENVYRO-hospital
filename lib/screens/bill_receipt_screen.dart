import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/pharmacy_bill_model.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class BillReceiptScreen extends StatefulWidget {
  final PharmacyBill bill;

  const BillReceiptScreen({super.key, required this.bill});

  @override
  State<BillReceiptScreen> createState() => _BillReceiptScreenState();
}

class _BillReceiptScreenState extends State<BillReceiptScreen> {
  late PharmacyBill _currentBill;

  @override
  void initState() {
    super.initState();
    _currentBill = widget.bill;
  }

  void _showEditDialog() {
    final List<Map<String, dynamic>> items = _currentBill.medicines.map((m) => {
      'name': m.name,
      'type': m.type,
      'quantity': m.quantity,
      'price': m.totalPrice,
      'qtyController': TextEditingController(text: m.quantity.toString()),
      'priceController': TextEditingController(text: m.totalPrice.toStringAsFixed(0)),
    }).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double total = 0;
          for (var item in items) {
            final price = double.tryParse(item['priceController'].text) ?? 0.0;
            total += price;
          }

          return AlertDialog(
            title: Text('Edit Bill: ${_currentBill.patientName}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: item['type'],
                                  items: ['Tablet', 'Capsule', 'Injection', 'Syrup', 'Drops', 'Ointment', 'Other'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                                  onChanged: (v) => setDialogState(() => item['type'] = v!),
                                  decoration: const InputDecoration(labelText: 'Type', contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: item['qtyController'],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Qty', contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                  onChanged: (_) => setDialogState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: item['priceController'],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Price', contentPadding: EdgeInsets.symmetric(horizontal: 8), prefixText: 'Rs.'),
                                  onChanged: (_) => setDialogState(() {}),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GRAND TOTAL:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        Text('Rs. ${total.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF00A859))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () async {
                  final updatedMeds = items.map((i) {
                    final qty = int.tryParse(i['qtyController'].text) ?? 1;
                    final price = double.tryParse(i['priceController'].text) ?? 0.0;
                    return DispensedMedicine(
                      name: i['name'],
                      type: i['type'],
                      quantity: qty,
                      pricePerUnit: price,
                      totalPrice: price,
                    );
                  }).toList();

                  final updatedBill = PharmacyBill(
                    id: _currentBill.id,
                    patientId: _currentBill.patientId,
                    patientName: _currentBill.patientName,
                    patientAge: _currentBill.patientAge,
                    patientMobile: _currentBill.patientMobile,
                    source: _currentBill.source,
                    medicines: updatedMeds,
                    date: _currentBill.date,
                    grandTotal: total,
                  );

                  await StorageService.updatePharmacyBill(updatedBill);
                  
                  if (mounted) {
                    setState(() {
                      _currentBill = updatedBill;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bill updated successfully'), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A859), foregroundColor: Colors.white),
                child: const Text('UPDATE BILL'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('BILL RECEIPT'),
        backgroundColor: const Color(0xFF00A859),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: _showEditDialog,
            tooltip: 'Edit Bill',
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () => PdfService.printReceipt(_currentBill),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildReceiptCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: Text('EDIT BILL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00A859),
                      side: const BorderSide(color: Color(0xFF00A859)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => PdfService.printReceipt(_currentBill),
                    icon: const Icon(Icons.print_rounded),
                    label: Text('PRINT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A859),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECEIPT', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF00A859))),
              Text('#${_currentBill.id.substring(0, 8).toUpperCase()}', style: GoogleFonts.outfit(color: Colors.grey)),
            ],
          ),
          const Divider(height: 32),
          Text(_currentBill.patientName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Age: ${_currentBill.patientAge} • ${_currentBill.patientMobile}', style: GoogleFonts.outfit(color: Colors.grey)),
          Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(_currentBill.date)}', style: GoogleFonts.outfit(color: Colors.grey)),
          const SizedBox(height: 24),
          Text('DISPENSED MEDICINES', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1)),
          const SizedBox(height: 16),
          ..._currentBill.medicines.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF00A859).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.medication_rounded, color: Color(0xFF00A859), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      Text('${m.type} • Qty: ${m.quantity}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('Rs. ${m.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GRAND TOTAL', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Rs. ${_currentBill.grandTotal.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF00A859))),
            ],
          ),
        ],
      ),
    );
  }
}
