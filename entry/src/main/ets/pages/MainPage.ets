import { allContacts, recentContacts, Contact } from '../model/ContactModel';
import router from '@ohos.router';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        // 消息 Tab：显示最近联系人
        TabContent() {
          List({ space: 2 }) {
            ForEach(recentContacts, (contact: Contact) => {
              ListItem() {
                this.contactItem(contact)
              }
            }, (contact: Contact) => contact.id)
          }.width('100%')
        }.tabBar('消息')

        // 联系人 Tab：显示全部联系人
        TabContent() {
          List({ space: 2 }) {
            ForEach(allContacts, (contact: Contact) => {
              ListItem() {
                this.contactItem(contact)
              }
            }, (contact: Contact) => contact.id)
          }.width('100%')
        }.tabBar('联系人')
      }
    }.width('100%').height('100%')
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