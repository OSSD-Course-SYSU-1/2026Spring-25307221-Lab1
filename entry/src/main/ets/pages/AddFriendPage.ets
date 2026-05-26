import router from '@ohos.router';

@Entry
@Component
struct AddFriendPage {
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.app_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('添加朋友')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 搜索框
      Row() {
        Image($r('app.media.app_icon'))
          .width(20)
          .height(20)
          .margin({ right: 8 })

        Text('微信号/手机号')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F5F5F5')
      .borderRadius(4)
      .margin({ top: 16, left: 16, right: 16 })

      // 功能列表
      List({ space: 1 }) {
        ListItem() {
          this.FeatureItemBuilder(
            '扫一扫',
            '扫描二维码名片',
            () => {
              // TODO: 实现扫一扫功能
            }
          )
        }

        ListItem() {
          this.FeatureItemBuilder(
            '手机联系人',
            '添加通讯录的朋友',
            () => {
              // TODO: 实现手机联系人功能
            }
          )
        }

        ListItem() {
          this.FeatureItemBuilder(
            '微信联系人',
            '通过手机号搜索微信用户',
            () => {
              // TODO: 实现微信联系人功能
            }
          )
        }
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 16 })

      // 底部二维码名片
      Column() {
        Text('我的二维码名片')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        // 二维码占位
        Column() {
          Image($r('app.media.app_icon'))
            .width(120)
            .height(120)
        }
        .width(160)
        .height(160)
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)
        .borderRadius(8)

        Text('微信号：wxid_123456789')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 16 })
      }
      .width('100%')
      .padding(32)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  // 功能项构建器
  @Builder FeatureItemBuilder(title: string, description: string, onClick: () => void) {
    Row() {
      // 图标
      Column() {
        Image($r('app.media.app_icon'))
          .width(40)
          .height(40)
      }
      .width(50)
      .height(50)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })

      // 文字描述
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)

        Text(description)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 箭头
      Image($r('app.media.app_icon'))
        .width(20)
        .height(20)
        .opacity(0.3)
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .onClick(onClick)
  }
}
