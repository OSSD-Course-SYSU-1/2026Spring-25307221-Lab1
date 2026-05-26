import { PinyinUtils } from '../pages/utils/PinyinUtils';

export class Contact {
  id: string
  name: string
  avatar: Resource
  constructor(id: string, name: string, avatar: Resource) {
    this.id = id;
    this.name = name;
    this.avatar = avatar;
  }
}

// 所有联系人（未排序）
const allContactsRaw: Contact[] = [
  new Contact('1', '张三', $r('app.media.app_icon')),
  new Contact('2', '李四', $r('app.media.app_icon')),
  new Contact('3', '王五', $r('app.media.app_icon')),
  new Contact('4', '赵六', $r('app.media.app_icon'))
];

// 所有联系人（按首字母排序）
export const allContacts: Contact[] = allContactsRaw.slice().sort((a, b) => {
  return PinyinUtils.compareByFirstLetter(a.name, b.name);
});

// 最近联系人（模拟消息列表用）
export const recentContacts: Contact[] = [
  allContacts[0],
  allContacts[1]
];
