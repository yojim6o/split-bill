import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/cubit/bill_cubit.dart';
import 'package:split_bill/src/models/item_group.dart';
import 'package:split_bill/src/pages/bill_splitter_page.dart';
import 'package:split_bill/src/widgets/custom_draggable_item.dart';

class DraggableScrollableSheetResponse extends StatefulWidget {
  DraggableScrollableSheetResponse({
    super.key,
    required this.items,
  }) : itemGroupList = [
          ...items.map((value) {
            return ItemGroup.fromJson(value);
          })
        ];

  final List items;
  late List<ItemGroup> itemGroupList;

  @override
  State<DraggableScrollableSheetResponse> createState() =>
      _DraggableScrollableSheetResponseState();
}

class _DraggableScrollableSheetResponseState
    extends State<DraggableScrollableSheetResponse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..forward();
    _animation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: DraggableScrollableSheet(
        minChildSize: .08,
        expand: true,
        snap: true,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(250),
                border: Border(top: BorderSide(width: .3)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 32, bottom: 32),
                          height: 3,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: FlexColor.greyLawDarkTertiaryContainer,
                          )),
                      Container(
                          margin: EdgeInsets.only(bottom: 32),
                          child: Text(
                            "Revisar y continuar",
                            style: TextStyle(fontSize: 32),
                          ))
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      for (var value in widget.itemGroupList)
                        CustomDraggableItem(itemGroup: value),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                    child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.all(32),
                  child: FloatingActionButton(
                      shape: CircleBorder(),
                      child: Icon(Icons.navigate_next_sharp),
                      onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                    create: (_) =>
                                        BillCubit(widget.itemGroupList),
                                    child: BillSplitterPage())),
                          )),
                ))
              ],
            ),
          );
        },
      ),
    );
  }
}
