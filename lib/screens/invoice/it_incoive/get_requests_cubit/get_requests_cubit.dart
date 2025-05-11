import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import 'package:graduation_project/models/request_model.dart';

part 'get_requests_state.dart';

class GetRequestsCubit extends Cubit<GetRequestsState> {
  GetRequestsCubit() : super(GetRequestsInitial());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getRequests(
      {String? year, String? department, String? type}) async {
    emit(GetRequestsLoading());

    try {
      Query query = firestore.collection('student_affairs_requests');

      if (type != null) {
        //if there is type, get requests of that type
        query = query.where('type', isEqualTo: type);
      } else {
        //if there is no type, get all requests except training
        // query = query.where('type', isNotEqualTo: 'Training');
      }

      if (department != null) {
        //if there is department, get requests of that department
        query = query.where('department', isEqualTo: department);
      }

      if (year != null) {
        //if there is year, get requests of that year
        query = query.where('year', isEqualTo: year);
      }
      //getting the documents
      final querySnapshot = await query.get();

      //transfrom each document to request
      final requests = querySnapshot.docs
          .map((request) => Request.fromJson(request))
          .toList();

      //emiting the requests loaded state with the requests
      emit(GetRequestsLoaded(requests));
    } catch (e) {
      emit(GetRequestsError(e.toString()));
    }
  }
}
