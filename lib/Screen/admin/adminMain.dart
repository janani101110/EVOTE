import 'package:evote/Screen/admin/adminAdmin.dart';
import 'package:evote/Screen/admin/adminCandidate.dart';
import 'package:evote/Screen/admin/adminDashboard.dart';
import 'package:evote/Screen/admin/adminDivision.dart';
import 'package:evote/Screen/admin/adminResults.dart';
import 'package:evote/Screen/admin/adminVoters.dart';
import 'package:evote/widget/adminSidenav.dart';
import 'package:evote/widget/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Adminmain extends StatefulWidget {
  const Adminmain({super.key});

  @override
  State<Adminmain> createState() => _AdminmainState();
}

class _AdminmainState extends State<Adminmain> {
 String selectPage = 'Dashboard';

  Widget getSelectedScreen(){
    switch (selectPage){
      case 'Candidates':
      return Admincandidate();
       
      case 'Divisions':
        return AdminDivision();
      case 'Voters':
        return Adminvoters();
      case 'Admins':
        return AdminAdmins();
      case 'Results':
        return Adminresults();
      default:
        return Admindashboard();
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Navbar(),
          Expanded(child: Row(
            children: [
              Adminsidenav(onItemSelected: (item){
                setState(() {
                  selectPage = item;
                });
              },),
              Expanded(child: Container(
                color: const Color(0xFFF4F6F8),
                padding: EdgeInsets.all(16.0),
                child: getSelectedScreen(),
              ))
            ],
          ))
        ]
      ),
    );
  }
}