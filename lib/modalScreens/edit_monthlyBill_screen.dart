import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/Provider/dark_them.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/functions/AlertButtonFunction.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flash_chat/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditMonthlyBillScreen extends StatefulWidget {
  final Function addBill;
  final QueryDocumentSnapshot userMonthlyBillList;
  final QueryDocumentSnapshot userInfo;

  EditMonthlyBillScreen(this.addBill, this.userMonthlyBillList, this.userInfo);

  @override
  _EditMonthlyBillScreenState createState() => _EditMonthlyBillScreenState();
}

class _EditMonthlyBillScreenState extends State<EditMonthlyBillScreen> {
  String billName;
  String billCost;
  double currentTotalMonthlyBills;
  double currentTotalIncome;
  final _fireStore = FirebaseFirestore.instance;
  String dropdownValue;

  bool billNameEnabled = false;
  bool billNameEnabled2 = true;

  bool billCostEnabled = false;
  bool billCostEnabled2 = true;

  bool billIconEnabled = false;

  bool dateChanged = false;

  int picker;

  DateTime selectedDate = DateTime.now();
  DateTime dateToday = DateTime.now();
  String formattedDate;

  SharedPreferences preferences;


  String updatedTotalMonthlyBillCost;
  String updateMonthlyIncome;
  String updatedBillIcon;

  bool pickerChanged = false;

  bool checkNullorSpace() {
    if (billName != null &&
        billName != '' &&
        billCost != null &&
        billCost != '') {
      return true;
    } else {
      return false;
    }
  }

  String currentLang = "ar";

  void getCurrentLanguage() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentLang = preferences.getString('language');
    });

  }

  @override
  void initState() {
    getCurrentLanguage();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    Map<String, String> arabicCategory = {
      'Rent': "إيجار",
      'Water': "فاتورة المياة",
      'Internet': "فاتورة الانترنت",
      'Phone': "فاتورة الجوال",
      'Electricity': "فاتورة الكهرباء",
      'Installment': "قسط",
      'Subscription':"اشتراك شهري"
    };

    Map<String, String> arabicToEnglish = {
      "إيجار": 'Rent',
      "فاتورة المياة": 'Water',
      "فاتورة الانترنت": 'Internet',
      "فاتورة الجوال": 'Phone',
      "فاتورة الكهرباء": 'Electricity',
      "قسط": 'Installment',
      "اشتراك شهري": "Subscription"
    };

    Map<String, int> monthlyBillCategoryInt = {
      'Rent': 0,
      'Water': 1,
      'Internet': 2,
      'Phone': 3,
      'Electricity': 4,
      'Installment': 5,
      'Subscription': 6,
    };

    Map<int, String> monthlyBillCategoryString = {
      0: 'Rent',
      1: 'Water',
      2: 'Internet',
      3: 'Phone',
      4: 'Electricity',
      5: 'Installment',
      6: "Subscription"
    };

    Map<int, String> arabicMonthlyBillCategoryString = {
      0: 'إيجار',
      1: 'فاتورة المياة',
      2: 'فاتورة الأنترنت',
      3: 'فاتورة الجوال',
      4: 'فاتورة الكهرب',
      5: 'قسط',
      6: "اشتراك شهري"
    };

    if (pickerChanged == false) {
      picker =
          monthlyBillCategoryInt[widget.userMonthlyBillList.get('billIcon')];
    }

    final themChange = Provider.of<DarkThemProvider>(context);

    bool shouldDelete = false;
    bool isEnabled = false;

    Timestamp currentBillDate = widget.userMonthlyBillList.get('billDate');
    DateTime billDate = DateTime.parse(currentBillDate.toDate().toString());
    String billDateForrmated = DateFormat('yyyy-MM-dd').format(billDate);

    void showCupertionPicker() {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              child: CupertinoPicker(
                  backgroundColor: CupertinoColors.white,
                  itemExtent: 32,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      picker = value;
                      pickerChanged = true;
                    });
                  },
                  children: [
                    Text('Rent'),
                    Text('Water'),
                    Text('Internet'),
                    Text('Phone'),
                    Text('Electricity'),
                    Text('Installment'),
                    Text("Subscription")
                  ]),
            );
          });
    }

    void showArabicCupertionPicker() {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              child: CupertinoPicker(
                  backgroundColor: CupertinoColors.white,
                  itemExtent: 32,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      picker = value;
                      pickerChanged = true;
                    });
                  },
                  children: [
                    Text('إيجار'),
                    Text('فاتورة المياه'),
                    Text('فاتورة الأنترنت'),
                    Text('فاتورة الجوال'),
                    Text('فاتورة الكهرب'),
                    Text('قسط'),
                    Text("اشتراك شهري")
                  ]),
            );
          });
    }
    DateTime currentDay = DateTime.now();
    _selectDate(BuildContext context) async {
      int lastDay = DateTime(currentDay.year,currentDay.month+1,0).day;
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(DateTime.now().year,DateTime.now().month),
        lastDate: DateTime(DateTime.now().year,DateTime.now().month, lastDay ),
      );
      if (picked != null && picked != selectedDate)
        setState(() {
          selectedDate = picked;
          formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
          dateChanged = true;
        });
    }

    if (billIconEnabled == false) {
      dropdownValue = currentLang == 'ar' ? arabicCategory[widget.userMonthlyBillList.get('billIcon')] : widget.userMonthlyBillList.get('billIcon');
    }

    void editMonthlyBill(){
      if (billName == null) {
        billName = widget.userMonthlyBillList.get('billName');
      }
      if (billCost == null) {
        billCost = widget.userMonthlyBillList.get('billCost');
      }
      if (updateMonthlyIncome == null) {
        updateMonthlyIncome = widget.userInfo.get('userBudget');
      }
      if (updatedTotalMonthlyBillCost == null) {
        updatedTotalMonthlyBillCost =
            widget.userInfo.get('totalMonthlyBillCost');
      }

      if (Platform.isIOS) {
        widget.userMonthlyBillList.reference.update(
            {'billIcon': monthlyBillCategoryString[picker]});
      }
      if (Platform.isAndroid) {
        if (dropdownValue == null) {
          if(currentLang == 'ar')
            dropdownValue = arabicToEnglish[widget.userMonthlyBillList.get('billIcon')];
          else
            dropdownValue =
                widget.userMonthlyBillList.get('billIcon');
        }
      }

      if (dateChanged) {
        widget.userMonthlyBillList.reference
            .update({'billDate': selectedDate});
      }

      widget.userMonthlyBillList.reference
          .update({'billName': billName});
      if(double.tryParse(billCost) != null && double.parse(billCost) > 0)
        widget.userMonthlyBillList.reference
            .update({'billCost': billCost});
      widget.userInfo.reference
          .update({'userBudget': updateMonthlyIncome});
      widget.userInfo.reference.update({
        'totalMonthlyBillCost': updatedTotalMonthlyBillCost
      });

      if (Platform.isAndroid){
        if(currentLang == 'ar'){
          widget.userMonthlyBillList.reference
              .update({'billIcon': arabicToEnglish[dropdownValue]});
        }
        else
          widget.userMonthlyBillList.reference
              .update({'billIcon': dropdownValue});
      }

      if(double.tryParse(billCost) != null && double.parse(billCost) > 0)
        Navigator.pop(context);
      else
        showIOSGeneralAlert(context, "${S.of(context).rightNumber}");
    }

    return Scaffold(
      backgroundColor: themChange.getDarkTheme() ? Colors.grey.shade800 : null,
      body: SingleChildScrollView(
        child: Container(
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )),
            child: Column(
              children: [
                Text(
                  '${S.of(context).editMonthlyBill}',
                  style: TextStyle(
                      color: Color(0xff01937C),
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 50, right: 50, top: 20, bottom: 20),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: billNameEnabled
                          ? TextField(
                              onSubmitted: (value) {
                                setState(() {
                                  billNameEnabled = false;
                                  billNameEnabled2 = false;
                                  if (billName == null) {
                                    billName = widget.userMonthlyBillList
                                        .get('billName');
                                  }
                                });
                              },
                              maxLength: 10,
                              textAlign: TextAlign.center,
                              autofocus: true,
                              onChanged: (text) {
                                setState(() {
                                  billName = text;
                                });
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: widget.userMonthlyBillList
                                      .get('billName'),
                                  counter: Offstage()),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text(
                                    billNameEnabled2
                                        ? widget.userMonthlyBillList
                                            .get('billName')
                                        : billName,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        billNameEnabled = true;
                                      });
                                    },
                                    icon: Icon(Icons.edit),
                                  )
                                ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: billCostEnabled
                          ? TextField(
                              onSubmitted: (value) {
                                setState(() {
                                  if(double.parse(billCost) > 0) {
                                    double oldCost = double.parse(widget
                                        .userMonthlyBillList
                                        .get('billCost'));
                                    double updatedCost = double.parse(billCost);
                                    double differenceBetweenCosts =
                                        updatedCost - oldCost;

                                    double currentTotalBudget = double.parse(
                                        widget.userInfo.get('userBudget'));
                                    double updatedTotalBudget =
                                        currentTotalBudget -
                                            differenceBetweenCosts;
                                    updateMonthlyIncome =
                                        updatedTotalBudget.toString();

                                    double currentTotalMonthlyBill = double
                                        .parse(
                                        widget.userInfo
                                            .get('totalMonthlyBillCost'));
                                    double updatedTotalMonthlyBill =
                                        currentTotalMonthlyBill +
                                            differenceBetweenCosts;
                                    updatedTotalMonthlyBillCost =
                                        updatedTotalMonthlyBill.toString();

                                    billCostEnabled = false;
                                    billCostEnabled2 = false;
                                    if (billCost == null) {
                                      billCost = widget.userMonthlyBillList
                                          .get('billCost');
                                    }
                                  }
                                });
                              },
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              autofocus: true,
                              keyboardType:
                                  TextInputType.numberWithOptions(signed: true,decimal: true),
                              onChanged: (text) {
                                setState(() {
                                  billCost = text;
                                });
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: widget.userMonthlyBillList
                                      .get('billCost'),
                                  counter: Offstage()),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text(
                                    billCostEnabled2
                                        ? widget.userMonthlyBillList
                                            .get('billCost')
                                        : billCost,
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        billCostEnabled = true;
                                      });
                                    },
                                    icon: Icon(Icons.edit),
                                  )
                                ]),
                    ),
                    Platform.isIOS
                        ? Container(
                            child: FlatButton(
                                onPressed: () {
                                  currentLang == 'ar'? showArabicCupertionPicker():
                                  showCupertionPicker();
                                },
                                child: currentLang == 'ar' ? Text(
                                    '${arabicMonthlyBillCategoryString[picker]}') : Text(
                                    '${monthlyBillCategoryString[picker]}')),
                          )
                        : currentLang == 'ar' ?  DropdownButton(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 10,
                      style: const TextStyle(color: Colors.grey),
                      underline: Container(
                        height: 1,
                        color: Color(0xff01937C),
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                          billIconEnabled = true;
                        });
                      },
                      items: <String>[
                        "إيجار",
                        "فاتورة المياة",
                        "فاتورة الانترنت",
                        "فاتورة الجوال",
                        "فاتورة الكهرباء",
                        "قسط",
                        "اشتراك شهري"
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ) : DropdownButton(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 10,
                            style: const TextStyle(color: Colors.grey),
                            underline: Container(
                              height: 1,
                              color: Color(0xff01937C),
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                billIconEnabled = true;
                              });
                            },
                            items: <String>[
                              'Rent',
                              'Water',
                              'Internet',
                              'Phone',
                              'Electricity',
                              'Installment',
                              "Subscription"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                  ]),
                ),
                Container(
                  width: 150,
                  child: TextButton(
                    onPressed: () => _selectDate(context),
                    child: Row(children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.grey,
                      ),
                      Text(
                        formattedDate == null
                            ? ' $billDateForrmated'
                            : ' $formattedDate',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ]),
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.grey)))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      Platform.isIOS
                          ? showIOSDeleteMonthlyBillsAlert(
                              context,
                              widget.userInfo,
                              widget.userMonthlyBillList,
                              shouldDelete)
                          : showAlertDialogForMonthlyBill(context, shouldDelete,
                              widget.userInfo, widget.userMonthlyBillList);
                    },
                    child: Text(
                      '${S.of(context).delete}',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ))),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {
                     editMonthlyBill();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${S.of(context).update}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xff01937C)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ))),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
