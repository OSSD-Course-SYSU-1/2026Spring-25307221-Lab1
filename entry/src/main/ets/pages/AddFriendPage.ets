import router from '@ohos.router';

@Entry
@Component
struct AddFriendPage {
  @State searchId: string = ''; // 用户输入的ID

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

      // 输入ID区域
      Column() {
        Text('输入好友ID')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 12 })
          .width('100%')

        Row() {
          TextInput({ placeholder: '请输入好友ID', text: this.searchId })
            .width('100%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .onChange((value: string) => {
              this.searchId = value;
            })
            .layoutWeight(1)
        }
        .width('100%')

        // 搜索按钮
        Button('搜索')
          .width('100%')
          .height(40)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#07C160')
          .borderRadius(4)
          .margin({ top: 16 })
          .enabled(this.searchId.length > 0)
          .onClick(() => {
            // TODO: 实现搜索好友功能
            console.info('搜索好友ID: ' + this.searchId);
          })
      }
      .width('100%')
      .padding(16)
      .margin({ top: 16 })

      // 提示信息
      Column() {
        Text('提示：请输入好友的唯一ID进行搜索添加')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 32 })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
