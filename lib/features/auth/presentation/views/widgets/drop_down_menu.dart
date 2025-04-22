import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/auth/data/models/drop_down_menu_item.dart';
import 'package:flutter/material.dart';

class CustomDropDownMenu extends StatefulWidget {
  const CustomDropDownMenu({super.key, required this.items});
  final List<DropDownMenuItem> items;

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  late DropDownMenuItem selectedItem;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.items.firstWhere(
      (item) => item.text == 'None',
      orElse: () => widget.items.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: w * 0.42,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isDropdownOpen = !isDropdownOpen;
              });
            },
            child: Container(
              padding: EdgeInsets.only(
                left: w * 0.026,
                right: w * 0.02,
                top: h * 0.01,
                bottom: h * 0.01,
              ),
              decoration: BoxDecoration(
                color: kNeutral100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Icon(selectedItem.icon, color: Colors.black54),
                      SizedBox(width: w * 0.01),
                      Text(
                        selectedItem.text,
                        style: Styles.textStyle14(
                          context,
                        ).copyWith(color: kPrimary700),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02,
                      vertical: h * 0.002,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary700,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      isDropdownOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: kNeutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isDropdownOpen)
            Container(
              margin: EdgeInsets.symmetric(horizontal: w * 0.026),
              decoration: const BoxDecoration(
                color: kPrimary700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final menuItem = widget.items[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedItem = menuItem;
                            isDropdownOpen = false;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: h * 0.011,
                            bottom: h * 0.011,
                            left: w * 0.026,
                          ),
                          child: Row(
                            children: [
                              // Icon(menuItem.icon, color: kNeutral500),
                              SizedBox(width: w * 0.01),
                              Text(
                                menuItem.text,
                                style: Styles.textStyle14(
                                  context,
                                ).copyWith(color: kNeutral500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
