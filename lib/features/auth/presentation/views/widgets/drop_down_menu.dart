import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/auth/data/models/drop_down_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomDropDownMenu extends StatefulWidget {
  const CustomDropDownMenu({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
  });
  final List<DropDownMenuItem> items;
  final Function(String?) onChanged;
  final String? initialValue;

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  late DropDownMenuItem selectedItem;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      selectedItem = widget.items.firstWhere(
        (item) => item.text == widget.initialValue,
        orElse: () => _getDefaultItem(),
      );
    } else {
      selectedItem = _getDefaultItem();
    }
  }

  DropDownMenuItem _getDefaultItem() {
    return widget.items.firstWhere(
      (item) => item.text == 'None' || item.text == 'No',
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
                      if (selectedItem.icon != null)
                        SvgPicture.asset(
                          selectedItem.icon!,
                          color: kPrimary700,
                          width: w * 0.04,
                        ),
                      SizedBox(width: selectedItem.icon != null ? w * 0.01 : 0),
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
              height: h * 0.11,
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
                  physics: const BouncingScrollPhysics(),
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
                            widget.onChanged(menuItem.text);
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
                              if (menuItem.icon != null)
                                SvgPicture.asset(
                                  menuItem.icon!,
                                  width: w * 0.04,
                                ),
                              SizedBox(
                                width: menuItem.icon != null ? w * 0.01 : 0,
                              ),
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
