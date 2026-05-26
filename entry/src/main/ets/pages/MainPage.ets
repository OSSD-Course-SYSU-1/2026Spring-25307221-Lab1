import { allContacts, recentContacts, Contact } from '../model/ContactModel';
import router from '@ohos.router';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State isMenuVisible: boolean = false;  // 控制菜单显示

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Tabs({ index: this.currentIndex }) {
          // 消息 Tab：显示最近联系人
          TabContent() {
            Column() {
              // 顶部标题栏
              Row() {
                Text('消息')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)

                Image($r('app.media.app_icon'))
                  .width(24)
                  .height(24)
                  .onClick(() => {
                    this.isMenuVisible = !this.isMenuVisible;
                  })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })

              // 消息列表
              List({ space: 2 }) {
                ForEach(recentContacts, (contact: Contact) => {
                  ListItem() {
                    this.contactItem(contact)
                  }
                }, (contact: Contact) => contact.id)
              }
              .width('100%')
              .layoutWeight(1)
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.TabBuilder('消息', 0, $r('app.media.app_icon')))
          .align(Alignment.Top)

          // 联系人 Tab：显示全部联系人
          TabContent() {
            Column() {
              // 顶部标题栏
              Row() {
                Text('联系人')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)

              // 联系人列表
              List({ space: 2 }) {
                ForEach(allContacts, (contact: Contact) => {
                  ListItem() {
                    this.contactItem(contact)
                  }
                }, (contact: Contact) => contact.id)
              }
              .width('100%')
              .layoutWeight(1)
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.TabBuilder('联系人', 1, $r('app.media.app_icon')))
          .align(Alignment.Top)

          // 发现 Tab
          TabContent() {
            this.DiscoveryContent()
          }
          .tabBar(this.TabBuilder('发现', 2, $r('app.media.app_icon')))

          // 自己 Tab
          TabContent() {
            this.ProfileContent()
          }
          .tabBar(this.TabBuilder('我', 3, $r('app.media.app_icon')))
        }
        .layoutWeight(1)
        .barPosition(BarPosition.End)  // 将 TabBar 放在底部
        .barHeight(56)  // 设置底部导航栏高度
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')

      // 弹出菜单
      if (this.isMenuVisible) {
        Column() {
          this.PopupMenuItemBuilder('扫一扫', () => {
            this.isMenuVisible = false;
            // TODO: 实现扫一扫功能
          })
          this.PopupMenuItemBuilder('添加好友', () => {
            this.isMenuVisible = false;
            router.pushUrl({
              url: 'pages/AddFriendPage'
            });
          })
          this.PopupMenuItemBuilder('发起群聊', () => {
            this.isMenuVisible = false;
            // TODO: 实现发起群聊功能
          })
        }
        .width(140)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .shadow({ radius: 10, color: '#33000000', offsetX: 0, offsetY: 2 })
        .margin({ top: 60, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      // 点击其他区域关闭菜单
      if (this.isMenuVisible) {
        this.isMenuVisible = false;
      }
    })
  }

  // Tab 导航项构建器
  @Builder TabBuilder(title: string, index: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .opacity(this.currentIndex === index ? 1.0 : 0.5)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#07C160' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 弹出菜单项构建器
  @Builder PopupMenuItemBuilder(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(Color.Black)
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.Start)
    .onClick(onClick)
  }

  // 发现页面内容
  @Builder DiscoveryContent() {
    Column() {
      // 顶部搜索栏
      Row() {
        Text('发现')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 功能列表
      List({ space: 1 }) {
        ListItem() {
          this.ListMenuItemBuilder('朋友圈', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('视频号', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('扫一扫', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('摇一摇', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('看一看', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('搜一搜', $r('app.media.app_icon'))
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 个人中心页面内容
  @Builder ProfileContent() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('我')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 个人信息卡片
      Row() {
        Image($r('app.media.app_icon'))
          .width(60)
          .height(60)
          .borderRadius(8)
          .margin({ right: 16 })

        Column() {
          Text('用户名')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('微信号：wxid_xxx')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('app.media.app_icon'))
          .width(20)
          .height(20)
          .opacity(0.5)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .margin({ bottom: 10 })

      // 功能列表
      List({ space: 1 }) {
        ListItem() {
          this.ListMenuItemBuilder('服务', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('收藏', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('朋友圈', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('卡包', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('表情', $r('app.media.app_icon'))
        }
        ListItem() {
          this.ListMenuItemBuilder('设置', $r('app.media.app_icon'))
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 列表菜单项构建器
  @Builder ListMenuItemBuilder(title: string, icon: Resource) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .margin({ right: 16 })

      Text(title)
        .fontSize(16)
        .layoutWeight(1)

      Image($r('app.media.app_icon'))
        .width(16)
        .height(16)
        .opacity(0.3)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  // 联系人条目组件
  @Builder contactItem(contact: Contact) {
    Row() {
      Image(contact.avatar)
        .width(48).height(48)
        .borderRadius(24)
        .margin(10)
      Text(contact.name)
        .fontSize(18)
        .margin(10)
    }
    .width('100%')
    .padding(5)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          contactId: contact.id,
          contactName: contact.name
        }
      });
    })
  }
}
