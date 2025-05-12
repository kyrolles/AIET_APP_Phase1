import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import 'package:graduation_project/models/request_model.dart';

part 'get_requests_state.dart';

class GetRequestsCubit extends Cubit<GetRequestsState> {
  GetRequestsCubit() : super(GetRequestsInitial());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getRequests({
    String? year,
    String? department,
    String? type,
    required List<String> statusList,
  }) async {
    emit(GetRequestsLoading());

    try {
      Query query = firestore
          .collection('student_affairs_requests')
          .orderBy('created_at', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (department != null) {
        query = query.where('department', isEqualTo: department);
      }

      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }

      final querySnapshot = await query.get();
      final requests = querySnapshot.docs
          .map((doc) => Request.fromJson(doc))
          .where((request) =>
              statusList.contains(request.status) &&
              (request.type == 'Proof of enrollment' ||
                  request.type == 'Grades Report' ||
                  request.type == 'Curriculum Content' ||
                  request.type == 'Tuition Fees'))
          .toList();

      emit(GetRequestsLoaded(requests));
    } catch (e) {
      emit(GetRequestsError(e.toString()));
    }
  }
}
