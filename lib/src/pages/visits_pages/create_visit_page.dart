import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../classes/client.dart';

import '../../providers/login_provider.dart';
import '../../providers/create_visit_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/main_button.dart';
import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/create_visit_widgets/date_visit.dart';
import '../../widgets/general_widgets/snackbar_widget.dart';
import '../../widgets/create_visit_widgets/clients_multi_select.dart';

class CreateVisitPage extends StatefulWidget {

  final FetchData? oFetchData;

  const CreateVisitPage( { super.key, this.oFetchData } );

  @override
  State<CreateVisitPage> createState() => _CreateVisitPageState();

}

class _CreateVisitPageState extends State<CreateVisitPage> {

  final controller = TextEditingController();
  late final FetchData oFetchData;

  @override
  void initState() {
    super.initState();
    oFetchData = widget.oFetchData ?? FetchData();
    getClients();
  }
  
  getClients() async {

    final loginProvider = Provider.of<LoginProvider>( context, listen: false );
    final createVisitProvider = Provider.of<CreateVisitProvider>( context, listen: false );
    
    final lClients = await oFetchData.getAssignedClients( loginProvider.oUser!.sAccessToken!, loginProvider.oUser!.sId! );

    if (!mounted) return;

    createVisitProvider.setClients( lClients );

    final items = lClients.map((client) => MultiSelectItem<Client>( client, client.sName! )).toList();

    createVisitProvider.setItems( items );

  }
  
  createVisit() async {

    final createVisitProvider = Provider.of<CreateVisitProvider>( context, listen: false );
    final loginProvider = Provider.of<LoginProvider>( context, listen: false );

    if(  createVisitProvider.selectedDate != null && createVisitProvider.lSelectedClients.isNotEmpty ) {

      loginProvider.bLoading = true;

      final mVisit = {
        'date': DateFormat('dd-MM-yyyy').format( createVisitProvider.selectedDate! ),
        'clients': createVisitProvider.lSelectedClients.map( ( client ) => {'client_id': client.sClientId} ).toList()
      };

      bool bSuccess = await oFetchData.createVisit(
        loginProvider.oUser!.sAccessToken!,
        loginProvider.oUser!.sId!,
        mVisit
      );

      if ( bSuccess && mounted ) {

        ScaffoldMessenger.of(context).showSnackBar(
          snackBarWidget(
            sMessage: TextsUtil.of(context)!.getText( 'new_visit.success_visit' ),
            bError: false
          )
        );

        Navigator.pop( context, true );
        
      } else {

        if(!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          snackBarWidget( sMessage: TextsUtil.of(context)!.getText( 'new_visit.error_visit' ) )
        );

      }

      loginProvider.bLoading = false;

    } else {

      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget( sMessage: TextsUtil.of(context)!.getText( 'new_visit.empty_fields' ) )
      );

    }

  }

  @override
  Widget build( BuildContext context ) {

    return Scaffold(
      key: const Key('create_visit_page'),
      appBar: AppBar(
        title: PoppinsText(
          sText: TextsUtil.of(context)!.getText( 'new_visit.title' ),
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor,
          fontWeight: FontWeight.w500
        ),
        backgroundColor: ColorsApp.backgroundColor,
        scrolledUnderElevation: 0.0
      ),
      body: Column(
        children: [
          SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
          ClientsMultiSelect(),
          DateVisit(),
          SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
          MainButton(
            key: const Key('create_visit_button'),
            sLabel: TextsUtil.of(context)!.getText( 'new_visit.create_button' ),
            onPressed: createVisit
          )
        ]
      )
    );

  }
}