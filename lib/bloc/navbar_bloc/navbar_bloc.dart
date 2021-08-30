import 'package:flutter_bloc/flutter_bloc.dart';
part 'navbar_event.dart';
part 'navbar_state.dart';

class NavbarBloc extends Bloc<NavbarEvent, NavbarState> {
  NavbarBloc(NavbarState initialState) : super(initialState);

  NavbarState get initialState => initialState;

  @override
  Stream<NavbarState> mapEventToState(NavbarEvent event) async* {
    if (event is BlankEvent) yield BlankState();
    if (event is DefaultEvent) yield DefaultState();
    if (event is ViewItemEvent) yield ViewItemState();
    if (event is ViewDistributorEvent) yield ViewDistributorState();
    if (event is ViewOrderEvent) yield ViewOrderState();
    if (event is MakeOrderEvent) yield MakeOrderState();
    if (event is ViewCategoryEvent) yield ViewCategoryState();
    if (event is ViewSettingsEvent) yield ViewSettingsState();
    if (event is ViewFormulaEvent) yield ViewFormulaState();
    
  }
}
