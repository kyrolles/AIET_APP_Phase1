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
  final List<String> statusList = ['No Status', 'Pending'];
  String? currentDepartment;
  String? currentYear;
  String? currentType;

  void _refreshRequests() {
    BlocProvider.of<GetRequestsCubit>(context).getRequests(
      department: currentDepartment,
      year: currentYear,
      type: currentType,
      statusList: statusList,
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshRequests();
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
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10, top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: const Color(0XFFFAFAFA),
            ),
            child: FilterWidget(
              statusList: statusList,
              initialDepartment: currentDepartment,
              initialYear: currentYear,
              initialType: currentType,
              onFilterChanged: (department, year, type) {
                currentDepartment = department;
                currentYear = year;
                currentType = type;
                _refreshRequests();
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<GetRequestsCubit, GetRequestsState>(
              builder: (context, state) {
                if (state is GetRequestsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is GetRequestsLoaded) {
                  return ListContainer(
                    title: 'Requests',
                    emptyMessage: 'No requests found',
                    listOfWidgets: showRequestsList(state.requests),
                  );
                }
                if (state is GetRequestsError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                }
                return const SizedBox();
              },
            ),
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
                    builder: (context) => const ItArchiveScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> showRequestsList(List<Request> requests) {
    return requests
        .map((request) => RequestContainer(
              request: request,
              onStatusChanged: () {
                _refreshRequests();
              },
            ))
        .toList();
  }
}
