import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/screens/invoice/it_incoive/get_requests_cubit/get_requests_cubit.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_archive.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_invoice_request_contanier.dart';
import '../../../components/my_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'filter_widget.dart';

class ItInvoiceScreen extends StatefulWidget {
  const ItInvoiceScreen({super.key});

  @override
  State<ItInvoiceScreen> createState() => _ItInvoiceScreenState();
}

class _ItInvoiceScreenState extends State<ItInvoiceScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<GetRequestsCubit>(context).getRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: 'Student Affairs',
          onpressed: () {
            Navigator.pop(context);
          },
        ),
        body: Column(
          children: [
            FilterWidget(
              onFilterChanged: (department, year, type) {
                BlocProvider.of<GetRequestsCubit>(context).getRequests(
                  department: department,
                  year: year,
                  type: type,
                );
              },
            ),
            BlocBuilder<GetRequestsCubit, GetRequestsState>(
              builder: (context, state) {
                if (state is GetRequestsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is GetRequestsLoaded) {
                  return ListContainer(
                    title: 'Requests',
                    listOfWidgets: showRequestsList(state.requests),
                  );
                }
                if (state is GetRequestsError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  return const Center(
                      child: Text('Use filters to load documents.'));
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: KButton(
                backgroundColor: Colors.black38,
                text: 'Archive',
                height: 62,
                svgPath: 'assets/project_image/Pin.svg',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ItArchiveScreen();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  List<Widget> showRequestsList(List<Request> requests) {
    List<Widget> listOfRequests = [];
    for (var i = 0; i < requests.length; i++) {
      if (requests[i].status == 'No Status' ||
          requests[i].status == 'Pending') {
        listOfRequests.add(RequestContainer(request: requests[i]));
      }
    }
    return listOfRequests;
  }
}
