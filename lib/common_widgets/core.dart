


import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class Core{
  ExtendedImage getNetworkImageFillWidth(String url,String placeHolder, double width, double? height,BoxFit fit) {
    return ExtendedImage.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Image.asset(placeHolder,fit: BoxFit.fill,
            );
          case LoadState.completed:
            return null;
          case LoadState.failed:
            return GestureDetector(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(placeHolder,fit: BoxFit.fill
                  ),
                  const Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Text(
                      " ",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
            break;
          default:
            return null;
        }
      },
    );
}
}

class VerticalSpace extends SizedBox {
  const VerticalSpace({super.key, double height = 8.0}) : super(height: height);
}

class HorizontalSpace extends SizedBox {
  const HorizontalSpace({super.key, double width = 8.0}) : super(width: width);
}
deviceWidth(context) => MediaQuery.of(context).size.width;
deviceHeight(context) => MediaQuery.of(context).size.height;

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

