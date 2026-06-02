/*
 * Copyright (C) 2024  即时通讯网(52im.net) & Jack Jiang.
 * The MobileIMSDK-鸿蒙Next客户端 Project. All rights reserved.
 *
 * 联系邮件：jack.jiang@52im.net
 * 联系微信：hellojackjiang
 * 联系QQ： 413980957
 * 技术社区：http://www.52im.net
 */

import { ClientCoreSDK } from "mobileimsdk/Index";
import ToolKits from "../utils/ToolKits";

/**
 * 聊天界面的自定义标题栏组件。
 *
 * @author Jack Jiang(http://www.52im.net/thread-2792-1-1.html)
 */
@Preview
@Component
export struct CustomeTitleBar {

  // 连接状态：false 连接断开、true 连接正常
  @Prop connectStatus: boolean;

  @Prop keepAliveStatus: boolean;

  // 返回按钮图片
  backImg: Resource = $r("app.media.widget_title_btn_back_normal");

  // 返回按钮点击回调
  onBackClick?: () => void;

  // 是否显示返回按钮
  @Prop showBackButton: boolean = false;

  build() {

    Column() {
      Row() {
        // 返回按钮
        if (this.showBackButton) {
          Row() {
            Image(this.backImg)
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.onBackClick) {
              this.onBackClick();
            }
          })
        }

        Row() {
          Text('HarmonyChat')
            .textAlign(TextAlign.Start)
            .fontSize(22)
            .maxLines(1)
            .fontColor(Color.Black)
            .fontWeight(500)
            .ellipsisMode(EllipsisMode.CENTER)
            .textOverflow({overflow: TextOverflow.Ellipsis})

          Text('鸿蒙')
            .fontFamily('HarmonyHeiTi')
            .fontColor(Color.White)
            .fontSize(11)
            .fontWeight(400)
            .backgroundColor(Color.Black)
            .padding({top:3, bottom:3, left: 4, right: 4})
            .borderRadius(5)
            .margin({left: 3})

          Text('v1.0')
            .fontSize(10)
            .fontColor('#999')
            .margin({left: 5})
        }
        .layoutWeight(1)

        Row() {
          Text()
            .width(12)
            .height(12)
            .borderRadius(6)
            .margin({right: 5})
            .backgroundColor(this.connectStatus ? (this.keepAliveStatus ? '#f1f515': '#00de7a') : '#ff8c6f')
            .border({width: 1, color: (this.connectStatus ? (this.keepAliveStatus ? '#d1d505': '#00c86e') : '#f26c4f'), radius: 6})
            .shadow({
              radius: 15,
              color: this.keepAliveStatus ? "#59f1f515" : '#00ffffff',
              offsetX: 0,
              offsetY: 15
              })

          Text('UID:')
            .textAlign(TextAlign.Start)
            .fontSize(13)
            .maxLines(1)
            .fontColor(Color.Black)
            .fontWeight(500)
            .margin({right: 2})

          Text(ClientCoreSDK.getInstance().currentLoginInfo?.loginUserId)
            .constraintSize({maxWidth: 42})
            .fontSize(13)
            .fontColor('#505256')
            .maxLines(2)
            .ellipsisMode(EllipsisMode.CENTER)
            .textOverflow({overflow: TextOverflow.Ellipsis})
        }
      }
      .height(58)
      .padding({left: 10, right: 10})

      this.BottomLine()

      Row() {
        LoadingProgress().width(20).height(20).margin({ right: 8 }).color('#ff6434')
        Text('网络不给力，正在努力恢复中…')
          .maxLines(1)
          .ellipsisMode(EllipsisMode.CENTER)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor('#ff6434')
          .fontSize(14)
      }
      .width('100%')
      .height(40)
      .backgroundColor('#fff0eb')
      .justifyContent(FlexAlign.Center)
      .visibility(this.connectStatus ? Visibility.None : Visibility.Visible)
      .animation({
        duration: 250,
        curve: Curve.EaseInOut,
        iterations: 1,
        playMode: PlayMode.Normal
      })
    }
    .width('100%')
    .backgroundColor(ToolKits.chat_page_title_background_color)
  }


  @Builder
  BottomLine() {
    Line()
      .height('1px')
      .width('100%')
      .backgroundColor('#dbdbdb')
  }
}
