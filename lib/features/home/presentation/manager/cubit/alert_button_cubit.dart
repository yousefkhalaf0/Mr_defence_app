import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'alert_button_state.dart';

class AlertButtonCubit extends Cubit<AlertButtonState> {
  AlertButtonCubit() : super(AlertButtonInitial());
}
