import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:app/features/home/data/emergency_type_data_model.dart';
part 'emergency_state.dart';

class EmergencyCubit extends Cubit<EmergencyState> {
  EmergencyCubit() : super(EmergencyState());
  void selectEmergency(EmergencyType? type) {
    if (state.selectedEmergency != type) {
      emit(state.copyWith(selectedEmergency: type));
    }
  }

  void changePage(int index) {
    if (state.currentPageIndex != index) {
      emit(state.copyWith(currentPageIndex: index));
    }
  }

  void clearSelectedEmergency() {
    if (state.selectedEmergency != null) {
      emit(
        EmergencyState(
          selectedEmergency: null,
          currentPageIndex: state.currentPageIndex,
        ),
      );
    }
  }
}

class EmergencyState {
  final EmergencyType? selectedEmergency;
  final int currentPageIndex;

  EmergencyState({this.selectedEmergency, this.currentPageIndex = 0});

  EmergencyState copyWith({
    EmergencyType? selectedEmergency,
    int? currentPageIndex,
  }) {
    return EmergencyState(
      selectedEmergency: selectedEmergency ?? this.selectedEmergency,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmergencyState &&
        other.selectedEmergency == selectedEmergency &&
        other.currentPageIndex == currentPageIndex;
  }

  @override
  int get hashCode => selectedEmergency.hashCode ^ currentPageIndex.hashCode;
}
