import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/client.dart';

import '../../providers/login_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/clients_widgets/client_card.dart';
import '../../widgets/general_widgets/poppins_text.dart';

class ClientsPage extends StatefulWidget {

  const ClientsPage( { super.key, this.fetchData } );

  final FetchData? fetchData;

  @override
  State<ClientsPage> createState() => _ClientsPageState();

}

class _ClientsPageState extends State<ClientsPage> {

  List<Client> lClients = [];
  bool bIsLoading = true;

  getClientsByVendor() async {

    final oFetchData = widget.fetchData ?? FetchData();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    try {
      lClients = await oFetchData.getAssignedClients(
        loginProvider.oUser!.sAccessToken!,
        loginProvider.oUser!.sId!
      );

      lClients.sort( ( a, b ) => b.sName!.compareTo( a.sName! ) );

    } catch (e) {
      lClients = [];
    }

    if (mounted) {
      setState( () => bIsLoading = false );
    }

  }

  @override
  void initState() {
    super.initState();
    getClientsByVendor();
  }

  @override
  Widget build( BuildContext context ) => bIsLoading ? Center(
    child: CircularProgressIndicator( color: ColorsApp.primaryColor )
  ) : lClients.isEmpty ? Center(
    child: PoppinsText(
      sText: TextsUtil.of(context)?.getText( 'clients.no_clients' ) ?? 'No Clients Assigned',
      dFontSize: ResponsiveApp.dSize( 16.0 ),
      colorText: ColorsApp.textColor
    )
  ): ListView.builder(
    itemCount: lClients.length,
    itemBuilder: ( context, index ) => ClientCard( oClient: lClients[index] )
  );

}