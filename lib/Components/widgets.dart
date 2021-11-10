import 'package:flash_chat/modalScreens/edit_monthlyBill_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/modalScreens/edit_expense_screen.dart';
import 'package:flash_chat/functions/AlertButtonFunction.dart';



class RowTextWithTotal extends StatelessWidget {
  //this widget for the planning ahead and last Month Expense
  final String text;
  final String totalAmount;
  final Function onPress;
  final QueryDocumentSnapshot userInfo;

  RowTextWithTotal({this.text,this.totalAmount,this.onPress,this.userInfo});


  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlatButton(
            child: HomeScreenTextWidget(
              text: "$text",
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              padding: 10,
            ),
            onPressed: onPress,
          ),


          HomeScreenTextWidget(
            text: "$totalAmount SAR",
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.grey,
            padding: 20,
          ),
        ]);
  }
}

class HomeScreenTextWidget extends StatelessWidget {
  //this widget for the text in the green box.
  HomeScreenTextWidget(
      {this.text, this.fontSize, this.fontWeight, this.color, this.padding});

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding,right: padding,left: padding),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

class monthlyBillBubble extends StatelessWidget {
  //this widget for the squares which contains monthly bills
  monthlyBillBubble(this.billName, this.billCost, this.billDate,this.billIcon, this.userMonthlyBillList,this.userInfo);

  final String billName;
  final String billCost;
  final Timestamp billDate;
  final IconData billIcon;
  final QueryDocumentSnapshot userMonthlyBillList;
  final QueryDocumentSnapshot userInfo;


  @override
  Widget build(BuildContext context) {
    DateTime todayDate = DateTime.now();
    int daysLeft = billDate.toDate().difference(todayDate).inDays;

    //if the date is tomorrow the function count it as 0 days so i added 1 day manually
    if(!billDate.toDate().difference(todayDate).isNegative && daysLeft == 0){
      daysLeft = 1;
    }

      // if the date is today
    if(billDate.toDate().day == DateTime.now().day && billDate.toDate().month == DateTime.now().month){
      daysLeft = 0;
    }

    // if the date is yesterday or more the function will make the bill to the next month
    if(billDate.toDate().difference(todayDate).isNegative && daysLeft != 0){
      DateTime newDate = DateTime(todayDate.year,todayDate.month+1,todayDate.day);
      daysLeft = newDate.difference(billDate.toDate()).inDays;
      userMonthlyBillList.reference.update({'billDate': newDate});
    }
    bool shouldDelete = false;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(

        children: [
          Material(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            elevation: 5,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: (){

                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) =>
                          EditMonthlyBillScreen((taskTitle) {
                            Navigator.pop(context);
                          },
                              userMonthlyBillList,
                              userInfo
                          ));


                },
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 5,bottom: 10),
                        child: Row(

                          children:[

                            monthlyBubbleTextStyle(
                            firstText: "", secondText: "$billName ", padding: 0, fontSize: 25, color: Colors.black,
                          ),

                           Icon(billIcon,
                           size: 25,
                             color: Colors.grey,
                           ),


                            

                          ]
                        ),
                      ),
                      

                      
                      monthlyBubbleTextStyle(
                        firstText: "Cost: ",
                        secondText: "$billCost SAR",
                        padding: 1,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                      monthlyBubbleTextStyle(
                        firstText: "$daysLeft Days left",
                        secondText: '',
                        fontSize: 15,
                        padding: 1,
                        color: Colors.black,
                      ),


                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class monthlyBubbleTextStyle extends StatelessWidget {

  final String firstText;
  final String secondText;
  final double padding;
  final Color color;
  final double fontSize;



  monthlyBubbleTextStyle({this.firstText,this.secondText,this.padding,this.fontSize,this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.only(bottom: padding , right:padding ,),
      child: Row(
          children:[
            Text(firstText,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold
              ),

            ),
            Text("$secondText",
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: color
              ),
            ),
          ]
      ),
    );
  }
}

class ExpensesBubble extends StatelessWidget {

  final String expenseName;
  final String expenseTotal;
  final IconData expenseIcon;
  final String expenseDate;
  final String expenseTime;
  final bool isLast;
  final QueryDocumentSnapshot userExpenseList;
  final QueryDocumentSnapshot userInfoList;



  ExpensesBubble({this.expenseIcon,this.expenseName,this.expenseTotal,this.isLast,this.expenseTime,this.expenseDate,this.userExpenseList, this.userInfoList});

  @override
  Widget build(BuildContext context) {

    bool shouldDelete = false;

    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: Colors.black12
            ),
          ),
        ),
        child: Material(
          borderRadius: BorderRadius.only(
            topLeft: isLast? Radius.circular(10) : Radius.circular(0),
            topRight: isLast? Radius.circular(10) : Radius.circular(0),
          ),
          elevation: 0,
          color: Colors.white,

          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(

              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(expenseIcon,
                    size: 30,
                    color: Colors.purple,
                  ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(userExpenseList.get('expenseName') == null ? expenseName :userExpenseList.get('expenseName'),
                        style: TextStyle(
                            fontSize: 25
                        ),),
                      Text('$expenseDate $expenseTime',
                        style: TextStyle(
                            fontSize: 12
                        ),),

                    ]
                ),

                Expanded(
                  child: Column(

                    children: [

                      IconButton(onPressed:
                          () {

                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) =>
                                EditExpenseScreen((taskTitle) {
                                  Navigator.pop(context);
                                },
                                    userExpenseList,
                                    userInfoList
                                ));

                      },
                        icon: Icon(Icons.edit),
                        iconSize: 25,

                      ),
                      IconButton(onPressed: (){

                       showAlertDialogForExpense(context, shouldDelete, userInfoList, userExpenseList);

                      }, icon: Icon(Icons.delete),
                        iconSize: 25,),

                    ],
                  ),
                ),

                Text(expenseTotal,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.right,
                ),

              ],
            ),
          ),

        ),
      ),
    );
  }
}



