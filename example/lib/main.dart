import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_fincode/flutter_fincode.dart';
import 'package:flutter_fincode/models/fincode_card_details.dart';
import 'package:flutter_fincode/models/fincode_card_info_result.dart';
import 'package:flutter_fincode/models/fincode_credit_card.dart';
import 'package:flutter_fincode/models/fincode_register_card_result.dart';
import 'package:flutter_fincode_example/loading_button.dart';

const String customerId = 'c_Ux3mjHkYROq44oNZyS-3aA';
const String orderId = 'o_bVAeocUHTZSHXNHWAYqxzg';
const String accessId = 'a_Ettwoxt6SxKAfSoI6FeIEQ';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final List<FincodeCreditCard> cardList = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initData() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      FlutterFincode.publishableKey = 'm_test_NmQzMWQ5ZDQtYzM3My00ZTZiLWI1MzEtZmY2N2U4YTlhOTJlYWE0ZmI5OTQtNDZlMi00ZmY0LWE2MWQtN2RhMTY3NjJmZmMwc18yNDAyMDU5MzA1Ng';
      FlutterFincode.tenantShopId = 's_24020521229';
      platformVersion = await FlutterFincode.instance.getPlatformVersion() ?? 'Unknown platform version';
      FincodeCardInfoResult result = await FlutterFincode.instance.cardInfoList(customerId);
      if (result.success) {
        cardList.clear();
        cardList.addAll(result.data ?? []);
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> getCardList() async {
    FincodeCardInfoResult result = await FlutterFincode.instance.cardInfoList(customerId);
    if (result.success) {
      cardList.clear();
      cardList.addAll(result.data ?? []);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Fincode example'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Card List: ',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Visibility(
                  visible: cardList.isEmpty,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No card found',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ),
                for (final FincodeCreditCard card in cardList)
                  Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text('${card.brand}  ${card.cardNo}'),
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      children: [
                        Text('Card ID: ${card.id}'),
                        Text('Expire: ${card.expire}'),
                        Text('Holder Name: ${card.holderName}'),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          label: const Text('Copy Card ID'),
                          icon: const Icon(Icons.paste_outlined),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: card.id));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Card ID copied to clipboard'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Add Card:',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                CardInfoForm(onAdded: getCardList),
                const SizedBox(height: 10),
                Text('Running on: $_platformVersion\n'),
                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final dynamic response =
                  await FlutterFincode.instance.showPaymentSheet();
              if (!mounted) return;
              showAlert(context, response);
            },
            tooltip: 'Make Payment',
            child: const Icon(Icons.shopping_bag),
          )),
    );
  }

  void showAlert(BuildContext context, dynamic response) {
    final bool success = response['status'] == 'success';
    final String message;
    if (success) {
      message = 'Execution successful!\n ID: ${response['id']}';
    } else {
      message = 'code: ${response['code']}\nmessage: ${response['message']}';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CardInfoForm extends StatefulWidget {
  const CardInfoForm({super.key, this.onAdded});

  final VoidCallback? onAdded;

  @override
  State<CardInfoForm> createState() => _CardInfoFormState();
}

class _CardInfoFormState extends State<CardInfoForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _securityCodeController = TextEditingController();

  final bool canEdit = true;

  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration(labelText: 'Cardholder Name'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: _inputDecoration(labelText: 'Card Number'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            validator: (value) {
              if (value == null || value.isEmpty || value.length != 16) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryDateController,
                  decoration: _inputDecoration(labelText: 'Expiry Date (YY/MM)'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('') ||
                        value.length != 4) {
                      return 'Please enter a valid expiry date';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _securityCodeController,
                  decoration: _inputDecoration(labelText: 'Security Code'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return 'Please enter a valid code';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            width: double.infinity,
            height: 48,
            child: LoadingButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final FormState formState = _formKey.currentState as FormState;
                if (!formState.validate()) return;
                // Implement submission logic
                if (kDebugMode) {
                  print("Submitting card info...");
                  print("Name: ${_nameController.text}");
                  print("Card Number: ${_cardNumberController.text}");
                  print("Expiry Date: ${_expiryDateController.text}");
                  print("Security Code: ${_securityCodeController.text}");
                }
                FincodeCardDetails card = FincodeCardDetails(
                  customerId: customerId,
                  holderName: _nameController.text,
                  cardNo: _cardNumberController.text,
                  expire: _expiryDateController.text,
                  securityCode: _securityCodeController.text,
                );
                final FincodeRegisterCardResult result = await FlutterFincode.instance.registerCard(card);
                if (result.success) {
                  _nameController.clear();
                  _cardNumberController.clear();
                  _expiryDateController.clear();
                  _securityCodeController.clear();
                  widget.onAdded?.call();
                }
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(result.success ? 'Success' : 'Error'),
                      content: Text(result.message ?? ''),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String labelText}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 14, color: colorScheme.outline),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.surfaceVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}