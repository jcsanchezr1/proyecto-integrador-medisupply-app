import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/visit.dart';

import '../../providers/login_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../../widgets/visits_widgets/date_filter.dart';
import '../../widgets/visits_widgets/visit_card.dart';
import '../../widgets/general_widgets/poppins_text.dart';

import 'create_visit_page.dart';

class VisitsPage extends StatefulWidget {

  final FetchData? fetchData;

  const VisitsPage( { super.key, this.fetchData } );

  @override
  State<VisitsPage> createState() => _VisitsPageState();

}

class _VisitsPageState extends State<VisitsPage> {

  List<Visit> lVisits = [];
  bool bIsLoading = false;

  getVisitsByDate( { String sDate = '' } ) async {

    setState( () => bIsLoading = true );

    final oFetchData = widget.fetchData ?? FetchData();
    final loginProvider = Provider.of<LoginProvider>( context, listen: false );

    try {
      lVisits = await oFetchData.getVisitsByDate(
        loginProvider.oUser!.sAccessToken!,
        loginProvider.oUser!.sId!,
        sDate
      );

      lVisits.sort((a, b) {
        final dateA = DateFormat('dd-MM-yyyy').parse(a.sDate);
        final dateB = DateFormat('dd-MM-yyyy').parse(b.sDate);
        return dateA.compareTo(dateB);
      });

    } catch (e) {
      lVisits = [];
    }

    if (mounted) {
      setState( () => bIsLoading = false );
    }

  }

  @override
  void initState() {
    super.initState();
    getVisitsByDate();
  }

  @override
  Widget build( BuildContext context ) => Scaffold(
    floatingActionButton: FloatingActionButton(
      backgroundColor: ColorsApp.backgroundColor,
      onPressed: () {
        Navigator.push(
          context,
          SlidePageRoute( page: CreateVisitPage() )
        ).then((bCreated) {
          if(bCreated != null && bCreated) {
            getVisitsByDate();
          }
        });
      },
      child: const Icon(
        Icons.add_rounded,
        color: ColorsApp.primaryColor,
        semanticLabel: 'Add Order'
      )
    ),
    body: Column(
      children: [
        DateFilter(
          onDateSelected: (selectedDate) {
            final formattedDate = selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate) : '';
            getVisitsByDate(sDate: formattedDate);
          }
        ),
        Expanded(
          child: bIsLoading ? Center(
            child: CircularProgressIndicator( color: ColorsApp.primaryColor )
          ) : lVisits.isEmpty ? Center(
            child: PoppinsText(
              sText: TextsUtil.of(context)?.getText( 'visits.no_visits' ) ?? 'No Visits Assigned',
              dFontSize: ResponsiveApp.dSize( 16.0 ),
              colorText: ColorsApp.textColor
            )
          ) : ListView.builder(
            itemCount: lVisits.length,
            itemBuilder: ( context, index ) => VisitCard(
              oVisit: lVisits[index],
              iIndex: index + 1
            )
          )
        )
      ]
    )
  );

}