import { allContacts, recentContacts, Contact } from '../model/ContactModel';
import router from '@ohos.router';
import { aiCharacters, AICharacter } from '../model/AICharacterData'
import { aiTools, AITool } from '../model/ToolData'
import { communityPosts, CommunityPost, topics, checkInRanking, moodOptions, MoodRecord, TreeHolePost, getInitialMoodHistory } from '../model/CommunityData'
import { BreakpointType, getBreakpoint } from './common/BreakpointSystem';
import { window } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State isMenuVisible: boolean = false;
  @State currentBreakpoint: BreakpointType = BreakpointType.SM;
  private windowWidth: number = 360;
  // 社区状态
  @State communitySelectedTopic: string = '全部';
  @State userStreak: number = 0;           // 连续打卡天数
  @State checkedInToday: boolean = false;  // 今天是否已打卡
  @State todayMood: string = '';           // 今日心情 emoji
  @State moodNote: string = '';            // 心情备注
  @State moodHistory: MoodRecord[] = getInitialMoodHistory();
  @State treeHolePosts: TreeHolePost[] = [];
  @State posts: CommunityPost[] = communityPosts;
  @State showTreeHoleInput: boolean = false;
  @State treeHoleDraft: string = '';
  private todayStr: string = new Date().getFullYear().toString() + '-' +
    ((new Date().getMonth() + 1).toString().padStart(2, '0')) + '-' +
    (new Date().getDate().toString().padStart(2, '0'));

  aboutToAppear() {
    let windowClass = window.getLastWindow(getContext(this));
    windowClass.then((win) => {
      let props = win.getWindowProperties();
      this.windowWidth = props.windowRect.width;
      this.currentBreakpoint = getBreakpoint(this.windowWidth);
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {}.width('100%').height(0)
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.windowWidth = newValue.width as number;
          this.currentBreakpoint = getBreakpoint(this.windowWidth);
        })

      Column() {
        Tabs({ index: this.currentIndex }) {
          // ==================== Tab 1: 消息 ====================
          TabContent() {
            Column() {
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
          .tabBar(this.TabBuilder('消息', 0, '💬'))
          .align(Alignment.Top)

          // ==================== Tab 2: AI广场 ====================
          TabContent() {
            Column() {
              Column() {
                Text('AI广场')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                Text('选择你的AI伙伴，开始对话')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 16, top: 12, bottom: 8 })

              // 角色卡片列表
              Grid() {
                ForEach(aiCharacters, (ai: AICharacter) => {
                  GridItem() {
                    this.aiItem(ai)
                  }
                }, (ai: AICharacter) => ai.id)
              }
              .columnsTemplate('1fr')
              .rowsGap(12)
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 14, right: 14, top: 8 })
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.TabBuilder('AI广场', 1, '🤖'))
          .align(Alignment.Top)

          // ==================== Tab 3: 工具箱 ====================
          TabContent() {
            Column() {
              Column() {
                Text('工具箱')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                Text('AI实用工具，一键直达')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 16, top: 12, bottom: 8 })

              Grid() {
                ForEach(aiTools, (tool: AITool) => {
                  GridItem() {
                    this.toolItem(tool)
                  }
                }, (tool: AITool) => tool.id)
              }
              .columnsTemplate('1fr')
              .rowsGap(12)
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 14, right: 14, top: 8 })
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.TabBuilder('工具箱', 2, '🧰'))
          .align(Alignment.Top)

          // ==================== Tab 4: 社区 ====================
          TabContent() {
            Column() {
              // 标题栏
              Row() {
                Text('社区')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                Text('🌳')
                  .fontSize(20)
                  .onClick(() => {
                    this.showTreeHoleInput = !this.showTreeHoleInput;
                  })
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })

              // 打卡卡片（每日限一次）
              Row() {
                Column() {
                  Text(this.userStreak > 0 ? '🔥' : '🕯️')
                    .fontSize(22)
                  Text(this.userStreak > 0 ? '已坚持' : '开始打卡')
                    .fontSize(11)
                    .fontColor('#999')
                }
                .margin({ right: 12 })

                Text(this.userStreak.toString())
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.checkedInToday ? '#CCC' : '#E67E22')
                  .margin({ right: 6 })

                Text('天')
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 12 })

                Blank()

                Button(this.checkedInToday ? '今日已打卡 ✓' : '今日打卡')
                  .fontSize(13)
                  .fontColor(this.checkedInToday ? '#AAA' : Color.White)
                  .backgroundColor(this.checkedInToday ? '#E8E8E8' : '#E67E22')
                  .borderRadius(18)
                  .height(34)
                  .padding({ left: 16, right: 16 })
                  .enabled(!this.checkedInToday)
                  .onClick(() => {
                    if (!this.checkedInToday) {
                      this.userStreak++;
                      this.checkedInToday = true;
                      promptAction.showToast({ message: '✅ 打卡成功！已坚持 ' + this.userStreak.toString() + ' 天' });
                    }
                  })
              }
              .width('90%')
              .padding({ top: 14, bottom: 14, left: 18, right: 18 })
              .backgroundColor(Color.White)
              .borderRadius(14)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 8 })

              // 心情日记 + 树洞入口行
              Row() {
                // 心情日记卡片
                Column() {
                  Row() {
                    Text('📔 心情日记')
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                    Blank()
                    Text(this.todayStr)
                      .fontSize(11)
                      .fontColor('#999')
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  if (this.todayMood) {
                    // 已记录今日心情
                    Row() {
                      Text(this.todayMood)
                        .fontSize(36)
                      Text('今天心情不错！')
                        .fontSize(13)
                        .fontColor('#666')
                        .margin({ left: 10 })
                    }
                    .margin({ bottom: 6 })
                    .onClick(() => { this.todayMood = ''; })  // 点击可修改
                  } else {
                    // 选择心情
                    Row() {
                      ForEach(moodOptions.slice(0, 8), (m: import('../model/CommunityData').MoodOption) => {
                        Text(m.emoji)
                          .fontSize(28)
                          .margin({ right: 6 })
                          .onClick(() => {
                            this.todayMood = m.emoji;
                            // 更新心情历史
                            for (let r of this.moodHistory) {
                              if (r.date === this.todayStr) {
                                r.emoji = m.emoji;
                                r.label = m.label;
                                return;
                              }
                            }
                            this.moodHistory.push({
                              date: this.todayStr,
                              emoji: m.emoji,
                              label: m.label,
                              note: ''
                            });
                            promptAction.showToast({ message: '今日心情：' + m.label });
                          })
                      })
                    }
                  }
                }
                .width('55%')
                .padding(12)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 1 })

                // 树洞入口
                Column() {
                  Text('🌳')
                    .fontSize(32)
                    .margin({ bottom: 2 })
                  Text('树洞')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                  Text('说点悄悄话')
                    .fontSize(10)
                    .fontColor('#999')
                }
                .width('38%')
                .height('100%')
                .padding(12)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 1 })
                .onClick(() => {
                  this.showTreeHoleInput = !this.showTreeHoleInput;
                })
              }
              .width('90%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 8 })

              // 历史心情条
              if (this.moodHistory.length > 0) {
                Row() {
                  ForEach(this.moodHistory.slice(-7), (r: MoodRecord) => {
                    Text(r.emoji)
                      .fontSize(16)
                      .margin({ right: 8 })
                  })
                }
                .width('90%')
                .padding({ top: 4, bottom: 4 })
              }

              // 树洞输入区
              if (this.showTreeHoleInput) {
                Column() {
                  TextInput({ placeholder: '写点什么扔进树洞吧…（匿名）', text: this.treeHoleDraft })
                    .width('100%')
                    .height(60)
                    .backgroundColor('#F8F4FF')
                    .borderRadius(10)
                    .border({ width: 1, color: '#E0D8F0' })
                    .padding(10)
                    .fontSize(14)
                    .onChange((value: string) => { this.treeHoleDraft = value; })

                  Row() {
                    Blank()
                    Button('取消')
                      .fontSize(12)
                      .backgroundColor('#EEE')
                      .borderRadius(14)
                      .height(30)
                      .onClick(() => { this.showTreeHoleInput = false; this.treeHoleDraft = ''; })
                    Button('匿名发布 🌳')
                      .fontSize(12)
                      .fontColor(Color.White)
                      .backgroundColor('#7B68AE')
                      .borderRadius(14)
                      .height(30)
                      .margin({ left: 10 })
                      .onClick(() => { this.submitTreeHole(); })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .width('90%')
                .padding(12)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 8 })
              }

              // 话题标签栏
              Row() {
                Scroll() {
                  Row() {
                    ForEach(topics, (t: import('../model/CommunityData').Topic) => {
                      Text(t.name)
                        .fontSize(12)
                        .fontColor(this.communitySelectedTopic === t.name ? Color.White : t.color)
                        .backgroundColor(this.communitySelectedTopic === t.name ? t.color : '#F0F0F0')
                        .borderRadius(14)
                        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                        .margin({ right: 8 })
                        .onClick(() => {
                          this.communitySelectedTopic = t.name;
                          if (t.name === '全部') {
                            this.posts = communityPosts;
                          } else {
                            this.posts = communityPosts.filter(p => p.topic === t.name);
                          }
                        })
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 6, bottom: 10 })

              // 动态列表
              List({ space: 10 }) {
                // 树洞帖子
                ForEach(this.treeHolePosts, (tp: TreeHolePost) => {
                  ListItem() {
                    this.treeHoleCard(tp)
                  }
                }, (tp: TreeHolePost) => tp.id)

                // 社区帖子
                ForEach(this.posts, (post: CommunityPost) => {
                  ListItem() {
                    this.postCard(post)
                  }
                }, (post: CommunityPost) => post.id)
              }
              .width('100%')
              .layoutWeight(1)
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#F0F0F0')
          }
          .tabBar(this.TabBuilder('社区', 3, '🌐'))
          .align(Alignment.Top)

          // ==================== Tab 5: 我的 ====================
          TabContent() {
            Column() {
              Row() {
                Text('我的')
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
                  this.ListMenuItemBuilder('历史记录', $r('app.media.app_icon'))
                }
                ListItem() {
                  this.ListMenuItemBuilder('设置', $r('app.media.app_icon'))
                }
              }
              .width('100%')

              Blank()
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#F5F5F5')
          }
          .tabBar(this.TabBuilder('我的', 4, '👤'))
          .align(Alignment.Top)
        }
        .layoutWeight(1)
        .barPosition(BarPosition.End)
        .barHeight(56)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')

      // 弹出菜单
      if (this.isMenuVisible) {
        Column() {
          this.PopupMenuItemBuilder('添加好友', () => {
            this.isMenuVisible = false;
            router.pushUrl({
              url: 'pages/AddFriendPage'
            });
          })
          this.PopupMenuItemBuilder('发起群聊', () => {
            this.isMenuVisible = false;
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
      if (this.isMenuVisible) {
        this.isMenuVisible = false;
      }
    })
  }

  // ==================== Builders ====================

  @Builder TabBuilder(title: string, index: number, emoji: string) {
    Column() {
      Text(emoji)
        .fontSize(20)
        .opacity(this.currentIndex === index ? 1.0 : 0.5)
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#07C160' : '#999999')
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

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

  @Builder ListMenuItemBuilder(title: string, icon: Resource) {
    Row() {
      Image(icon).width(24).height(24).margin({ right: 16 })
      Text(title).fontSize(16).layoutWeight(1)
      Image($r('app.media.app_icon')).width(16).height(16).opacity(0.3)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  // 联系人条目
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
          contactName: contact.name,
          isAI: false
        }
      });
    })
  }

  // AI角色卡片
  @Builder aiItem(ai: AICharacter) {
    Row() {
      Column() {
        Text(ai.emoji).fontSize(32)
      }
      .width(56).height(56)
      .borderRadius(16)
      .backgroundColor(ai.bgColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Row() {
          Text(ai.name)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
          Text(ai.role)
            .fontSize(10)
            .fontColor(ai.color)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(ai.bgColor)
            .borderRadius(4)
            .margin({ left: 8 })
        }
        Text(ai.description)
          .fontSize(13)
          .fontColor('#888888')
          .margin({ top: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(ai.personality)
          .fontSize(11)
          .fontColor('#aaaaaa')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 14, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(14)
    .border({ width: 1, color: '#F0F0F0' })
    .shadow({ radius: 6, color: '#0000000a', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          contactId: ai.id,
          contactName: ai.name,
          greeting: ai.greeting,
          isAI: true
        }
      });
    })
  }

  // 工具卡片
  @Builder toolItem(tool: AITool) {
    Row() {
      Column() {
        Text(tool.emoji).fontSize(28)
      }
      .width(52).height(52)
      .borderRadius(14)
      .backgroundColor(tool.bgColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(tool.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')
        Text(tool.description)
          .fontSize(12)
          .fontColor('#888888')
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 14, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(14)
    .border({ width: 1, color: '#F0F0F0' })
    .shadow({ radius: 6, color: '#0000000a', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.onToolClick(tool);
    })
  }

  // 发布树洞帖子
  submitTreeHole() {
    if (this.treeHoleDraft.trim().length === 0) {
      return;
    }
    let newPost: TreeHolePost = {
      id: 'th' + Date.now().toString(),
      content: this.treeHoleDraft,
      mood: this.todayMood || '😶',
      timeAgo: '刚刚',
      likeCount: 0,
      isLiked: false
    };
    let newList: TreeHolePost[] = [newPost];
    for (let p of this.treeHolePosts) {
      newList.push(p);
    }
    this.treeHolePosts = newList;
    this.treeHoleDraft = '';
    this.showTreeHoleInput = false;
    promptAction.showToast({ message: '已匿名发布到树洞 🌳' });
  }

  // 树洞帖子卡片
  @Builder treeHoleCard(tp: TreeHolePost) {
    Column() {
      Row() {
        Text('🌳')
          .fontSize(18)
        Text('树洞')
          .fontSize(12)
          .fontColor('#7B68AE')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 4 })
        Text('· 匿名')
          .fontSize(11)
          .fontColor('#999')
          .margin({ left: 6 })
        Blank()
        Text(tp.timeAgo)
          .fontSize(11)
          .fontColor('#999')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(tp.content)
        .fontSize(14)
        .fontColor('#444')
        .lineHeight(20)
        .margin({ bottom: 8 })

      Row() {
        Text(tp.mood)
          .fontSize(14)
          .margin({ right: 8 })
        Text(tp.isLiked ? '💜' : '🤍')
          .fontSize(14)
          .onClick(() => {
            tp.isLiked = !tp.isLiked;
            if (tp.isLiked) { tp.likeCount++; } else { tp.likeCount--; }
          })
        Text(tp.likeCount > 0 ? tp.likeCount.toString() : '')
          .fontSize(12)
          .fontColor('#999')
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 14, right: 14 })
    .backgroundColor('#F8F4FF')
    .borderRadius(12)
    .border({ width: 1, color: '#E8E0F0' })
  }

  // 社区帖子卡片
  @Builder postCard(post: CommunityPost) {
    Column() {
      // 用户信息行
      Row() {
        Text(post.userAvatar)
          .fontSize(32)
        Column() {
          Text(post.userName)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
          Text(post.timeAgo)
            .fontSize(11)
            .fontColor('#999')
        }
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 话题标签
        Text(post.topic)
          .fontSize(10)
          .fontColor(post.topicColor)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(post.topicColor + '18')
          .borderRadius(8)
      }
      .width('100%')

      // 帖子内容
      Text(post.content)
        .fontSize(14)
        .fontColor('#333')
        .lineHeight(20)
        .margin({ top: 10, bottom: 12 })
        .maxLines(5)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 底部互动行
      Row() {
        Row() {
          Text(post.isLiked ? '❤️' : '🤍')
            .fontSize(14)
          Text(post.likeCount.toString())
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 4 })
        }
        .onClick(() => {
          post.isLiked = !post.isLiked;
          if (post.isLiked) {
            post.likeCount++;
          } else {
            post.likeCount--;
          }
        })

        Row() {
          Text('💬')
            .fontSize(14)
          Text(post.commentCount.toString())
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 4 })
        }
        .margin({ left: 24 })
        .onClick(() => {
          AlertDialog.show({ message: '评论功能即将上线！' });
        })

        Blank()

        Text('分享')
          .fontSize(11)
          .fontColor('#999')
      }
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 14, right: 14 })
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  // 工具点击处理
  onToolClick(tool: AITool) {
    if (tool.action === 'tarot') {
      // 打开塔罗抽牌
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          contactId: 'ai_tarot',
          contactName: '塔罗牌',
          greeting: '🔮 请在心里默念你的问题，然后告诉我…',
          isAI: true
        }
      });
    } else if (tool.action === 'book') {
      // 打开答案之书
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          contactId: 'ai_answerbook',
          contactName: '答案之书',
          greeting: '📖 请在心里默念你的问题，然后告诉我"翻开"…',
          isAI: true,
          toolAction: 'book'
        }
      });
    } else if (tool.action === 'chat' && tool.customPrompt) {
      // 打开自定义工具聊天
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          contactId: tool.targetId || tool.id,
          contactName: tool.name,
          greeting: tool.customGreeting || '',
          isAI: true,
          customPrompt: tool.customPrompt
        }
      });
    }
  }
}
