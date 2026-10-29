import 'package:fpdart/fpdart.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../entities/dashboard_snapshot.dart';

abstract class HomeRepository {
  Future<Either<AppException, DashboardSnapshot>> getDashboardSnapshot();
}
