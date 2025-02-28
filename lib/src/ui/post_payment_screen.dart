import 'package:flutter/material.dart';

class PostPaymentScreen extends StatelessWidget {
  final bool successful;
  const PostPaymentScreen({super.key, required this.successful});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width:  double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          spacing: 8,
          children: [
            Icon(successful?Icons.verified:Icons.error,color: successful?Colors.green:Colors.red,size: 45,),
          Text(successful?"Transaction Successful":"Transaction Failed",style: TextStyle(color: Colors.black87,fontSize: 21),),
        ],),
      ),
    );
  }
}
