import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_invoice_request_contanier.dart';
import '../../../components/my_app_bar.dart';
import 'get_requests_cubit/get_requests_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItArchiveScreen extends StatelessWidget {
  const ItArchiveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: MyAppBar(
        title:
            localizations?.studentAffairsArchive ?? 'Student Affairs Archive',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: BlocProvider(
        create: (context) =>
            GetRequestsCubit()..getRequests(statusList: ['Done', 'Rejected']),
        child: BlocBuilder<GetRequestsCubit, GetRequestsState>(
          builder: (context, state) {
            if (state is GetRequestsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetRequestsError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is GetRequestsLoaded) {
              return ListContainer(
                title: localizations?.requests ?? 'Requests',
                listOfWidgets: state.requests
                    .map((request) => RequestContainer(
                          request: request,
                          onStatusChanged: () {
                            // Refresh the requests list
                            context
                                .read<GetRequestsCubit>()
                                .getRequests(statusList: ['Done', 'Rejected']);
                          },
                        ))
                    .toList(),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
