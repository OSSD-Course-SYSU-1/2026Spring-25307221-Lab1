import router from '@ohos.router';
import { aiCharacters, AICharacter } from '../model/AICharacterData'
import { aiTools, AITool } from '../model/ToolData'
import { CommunityPost, Comment, moodOptions, MoodRecord, TreeHolePost, generateAIFeed } from '../model/CommunityData'
import { BreakpointType, getBreakpoint } from './common/BreakpointSystem';
import { window } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { GameMenu, GuessNumber, SnakeGame, SlotMachine, ReactionTest, PongGame, TetrisGame } from './components/MiniGameView';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State isMenuVisible: boolean = false;
  @State currentBreakpoint: BreakpointType = BreakpointType.SM;
  private windowWidth: number = 360;
  // 社区状态
  @State userStreak: number = 0;
  @State checkedInToday: boolean = false;
  @State todayMood: string = '';
  @State todayMoodTime: string = '';
  @State moodHistory: MoodRecord[] = [];
  @State treeHolePosts: TreeHolePost[] = [];
  @State posts: CommunityPost[] = [];
  @State showMoodPicker: boolean = false;
  @State showTreeHoleInput: boolean = false;
  @State treeHoleDraft: string = '';
  @State currentGame: string = '';
  // 个人中心
  @State userNickname: string = 'HarmonyChat用户';
  @State editingNickname: boolean = false;
  @State nicknameDraft: string = '';
  @State isDarkMode: boolean = false;
  @State fontSize: number = 14;
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
    // 初始化AI朋友圈
    this.refreshFeed();
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
          // ==================== Tab 0: AI广场 ====================
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
          .tabBar(this.TabBuilder('AI广场', 0, '🤖'))
          .align(Alignment.Top)

          // ==================== Tab 1: 工具箱 ====================
          TabContent() {
            Scroll() {
              Column() {
                Text('工具箱')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 4 })

                // 学习工作
                Text('📚 学习工作')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#555')
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 8, bottom: 4 })

                Grid() {
                  ForEach(aiTools.filter((t: AITool) => t.category === '学习工作'), (tool: AITool) => {
                    GridItem() { this.toolIcon(tool) }
                  }, (tool: AITool) => tool.id)
                }
                .columnsTemplate('1fr').rowsGap(8)
                .width('100%').padding({ left: 14, right: 14, bottom: 12 })

                // 趣味生活
                Text('🎯 趣味生活')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#555')
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 16, bottom: 4 })

                Grid() {
                  ForEach(aiTools.filter((t: AITool) => t.category === '趣味生活'), (tool: AITool) => {
                    GridItem() { this.toolIcon(tool) }
                  }, (tool: AITool) => tool.id)
                }
                .columnsTemplate('1fr').rowsGap(8)
                .width('100%').padding({ left: 14, right: 14, bottom: 16 })
              }
              .width('100%')
            }
            .width('100%').height('100%')
          }
          .tabBar(this.TabBuilder('工具箱', 1, '🧰'))
          .align(Alignment.Top)

          // ==================== Tab 4: 社区 ====================
          TabContent() {
            Column() {
              // 标题栏 + 打卡
              Row() {
                Text('社区')
                  .fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1)

                Text('🔄').fontSize(18).margin({ right: 10 })
                  .onClick(() => { this.refreshFeed(); })

                // 迷你打卡
                Row() {
                  Text(this.checkedInToday ? '🔥' : '🕯️')
                    .fontSize(16)
                  Text(this.checkedInToday ? '已打卡' : '打卡')
                    .fontSize(11)
                    .fontColor(this.checkedInToday ? '#AAA' : '#E67E22')
                    .margin({ left: 2 })
                  Text(this.userStreak.toString())
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.checkedInToday ? '#CCC' : '#E67E22')
                    .margin({ left: 6 })
                  Text('天')
                    .fontSize(11)
                    .fontColor('#999')
                    .margin({ left: 1 })
                }
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Color.White)
                .borderRadius(14)
                .onClick(() => {
                  if (!this.checkedInToday) {
                    this.userStreak++;
                    this.checkedInToday = true;
                    promptAction.showToast({ message: '✅ 打卡成功！已坚持 ' + this.userStreak.toString() + ' 天' });
                  }
                })
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })

              // 心情 + 树洞 迷你卡片行
              Row() {
                // 心情迷你卡
                Row() {
                  Text(this.todayMood || '📔')
                    .fontSize(22)
                  Text(this.todayMood ? this.todayMoodTime + ' ' + this.getMoodLabel() : '记录心情')
                    .fontSize(12)
                    .fontColor(this.todayMood ? '#333' : '#999')
                    .margin({ left: 6 })
                }
                .padding({ left: 12, right: 16, top: 10, bottom: 10 })
                .backgroundColor(Color.White)
                .borderRadius(20)
                .shadow({ radius: 2, color: '#00000006', offsetX: 0, offsetY: 1 })
                .onClick(() => { this.showMoodPicker = !this.showMoodPicker; })

                Blank()

                // 树洞迷你卡
                Row() {
                  Text('🌳')
                    .fontSize(22)
                  Text('树洞')
                    .fontSize(12)
                    .fontColor('#999')
                    .margin({ left: 6 })
                }
                .padding({ left: 12, right: 16, top: 10, bottom: 10 })
                .backgroundColor(Color.White)
                .borderRadius(20)
                .shadow({ radius: 2, color: '#00000006', offsetX: 0, offsetY: 1 })
                .onClick(() => { this.showTreeHoleInput = !this.showTreeHoleInput; })
              }
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 6 })

              // 心情选择器（点击展开）
              if (this.showMoodPicker) {
                Row() {
                  ForEach(moodOptions, (m: import('../model/CommunityData').MoodOption) => {
                    Column() {
                      Text(m.emoji)
                        .fontSize(26)
                        .opacity(this.todayMood === m.emoji ? 1 : 0.6)
                      Text(m.label)
                        .fontSize(9)
                        .fontColor(this.todayMood === m.emoji ? '#333' : '#999')
                    }
                    .padding(6)
                    .borderRadius(8)
                    .backgroundColor(this.todayMood === m.emoji ? '#F0F0F0' : Color.Transparent)
                    .onClick(() => {
                      this.todayMood = m.emoji;
                      let now = new Date();
                      this.todayMoodTime = now.getHours().toString().padStart(2, '0') + ':' +
                        now.getMinutes().toString().padStart(2, '0');
                      this.moodHistory.push({
                        date: this.todayStr,
                        time: this.todayMoodTime,
                        emoji: m.emoji,
                        label: m.label
                      });
                      this.showMoodPicker = false;
                      this.refreshFeed();
                      promptAction.showToast({ message: this.todayMoodTime + ' 心情：' + m.label });
                    })
                  })
                }
                .width('94%')
                .padding(10)
                .backgroundColor(Color.White)
                .borderRadius(14)
                .margin({ left: 12, right: 12, bottom: 6 })
                .justifyContent(FlexAlign.SpaceEvenly)
              }

              // 今日心情时间线
              if (this.moodHistory.filter((r: MoodRecord) => r.date === this.todayStr).length > 0) {
                Row() {
                  ForEach(this.moodHistory.filter((r: MoodRecord) => r.date === this.todayStr), (r: MoodRecord, idx: number) => {
                    Row() {
                      Text(r.emoji).fontSize(14)
                      Text(r.time).fontSize(9).fontColor('#aaa').margin({ left: 3 })
                    }
                    .margin({ right: idx < this.moodHistory.length - 1 ? 10 : 0 })
                  }, (r: MoodRecord, idx: number) => r.time + idx.toString())
                }
                .width('90%')
                .padding({ top: 2, bottom: 6, left: 4 })
              }

              // 树洞输入区（点击展开）
              if (this.showTreeHoleInput) {
                Column() {
                  TextInput({ placeholder: '匿名说点什么…', text: this.treeHoleDraft })
                    .width('100%')
                    .height(44)
                    .backgroundColor('#F8F4FF')
                    .borderRadius(10)
                    .border({ width: 1, color: '#E0D8F0' })
                    .padding({ left: 10, right: 10 })
                    .fontSize(14)
                    .onChange((value: string) => { this.treeHoleDraft = value; })
                  Row() {
                    Blank()
                    Button('取消').fontSize(11).backgroundColor('#EEE').borderRadius(12).height(28)
                      .onClick(() => { this.showTreeHoleInput = false; this.treeHoleDraft = ''; })
                    Button('匿名发布').fontSize(11).fontColor(Color.White).backgroundColor('#7B68AE').borderRadius(12).height(28)
                      .margin({ left: 8 })
                      .onClick(() => { this.submitTreeHole(); })
                  }
                  .width('100%')
                  .margin({ top: 6 })
                }
                .width('94%')
                .padding(10)
                .backgroundColor(Color.White)
                .borderRadius(14)
                .margin({ left: 12, right: 12, bottom: 6 })
              }

              // === AI 朋友圈动态流 ===
              List({ space: 10 }) {
                // 用户自己的树洞帖子
                ForEach(this.treeHolePosts, (tp: TreeHolePost) => {
                  ListItem() {
                    this.treeHoleCard(tp)
                  }
                }, (tp: TreeHolePost) => tp.id)

                // AI朋友动态
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
          .tabBar(this.TabBuilder('社区', 2, '🌐'))
          .align(Alignment.Top)

          // ==================== Tab 3: 游戏 ====================
          TabContent() {
            Stack() {
              if (this.currentGame === '') {
                Column() {
                  GameMenu({
                    onPlay: (gameId: string) => { this.currentGame = gameId; }
                  })
                }
                .width('100%').height('100%').backgroundColor('#FAFAFA')
              } else if (this.currentGame === '猜数字') {
                GuessNumber({ onBack: () => { this.currentGame = ''; } })
              } else if (this.currentGame === '贪吃蛇') {
                SnakeGame({ onBack: () => { this.currentGame = ''; } })
              } else if (this.currentGame === '老虎机') {
                SlotMachine({ onBack: () => { this.currentGame = ''; } })
              } else if (this.currentGame === '反应测试') {
                ReactionTest({ onBack: () => { this.currentGame = ''; } })
              } else if (this.currentGame === '乒乓球') {
                PongGame({ onBack: () => { this.currentGame = ''; } })
              } else if (this.currentGame === '俄罗斯方块') {
                TetrisGame({ onBack: () => { this.currentGame = ''; } })
              }
            }
            .width('100%').height('100%')
          }
          .tabBar(this.TabBuilder('游戏', 3, '🎮'))
          .align(Alignment.Top)

          // ==================== Tab 4: 我的 ====================
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
                Column() {
                  Text('😊')
                    .fontSize(32)
                }
                .width(60).height(60)
                .borderRadius(30)
                .backgroundColor('#E3F2FD')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .margin({ right: 16 })

                Column() {
                  if (this.editingNickname) {
                    TextInput({ text: this.nicknameDraft, placeholder: '输入新昵称' })
                      .fontSize(16).width('80%').height(36).backgroundColor('#F5F5F5').borderRadius(8)
                      .padding({ left: 8, right: 8 })
                      .onChange((value: string) => { this.nicknameDraft = value; })
                  } else {
                    Text(this.userNickname)
                      .fontSize(18).fontWeight(FontWeight.Bold)
                    Text('点击修改昵称')
                      .fontSize(13).fontColor('#999').margin({ top: 4 })
                  }
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)

                if (this.editingNickname) {
                  Text('保存').fontSize(14).fontColor('#07C160').fontWeight(FontWeight.Bold)
                    .onClick(() => {
                      if (this.nicknameDraft.trim().length > 0) {
                        this.userNickname = this.nicknameDraft.trim();
                      }
                      this.editingNickname = false;
                    })
                } else {
                  Text('›').fontSize(24).fontColor('#CCC')
                }
              }
              .width('100%').padding(16).backgroundColor(Color.White).margin({ bottom: 10 })
              .onClick(() => {
                if (!this.editingNickname) {
                  this.editingNickname = true;
                  this.nicknameDraft = this.userNickname;
                }
              })

              // 功能列表
              List({ space: 1 }) {
                ListItem() {
                  Row() {
                    Text('🌙').fontSize(18).margin({ right: 14 })
                    Text('深色模式').fontSize(16).layoutWeight(1)
                    Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
                      .onChange((value: boolean) => {
                        this.isDarkMode = value;
                        promptAction.showToast({ message: value ? '深色模式已开启' : '浅色模式已开启' });
                      })
                  }
                  .width('100%').height(56).padding({ left: 16, right: 16 }).backgroundColor(Color.White)
                }
                ListItem() {
                  Row() {
                    Text('🔤').fontSize(18).margin({ right: 14 })
                    Text('字体大小：' + this.fontSize.toString() + 'px').fontSize(16).layoutWeight(1)
                    Text('A+').fontSize(13).fontColor('#07C160').margin({ right: 6 })
                      .onClick(() => { if (this.fontSize < 20) { this.fontSize = this.fontSize + 1; } })
                    Text('A-').fontSize(13).fontColor('#FF6B6B')
                      .onClick(() => { if (this.fontSize > 10) { this.fontSize = this.fontSize - 1; } })
                  }
                  .width('100%').height(56).padding({ left: 16, right: 16 }).backgroundColor(Color.White)
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
          if (index === 2) {
            this.refreshFeed();
          }
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
  @Builder toolIcon(tool: AITool) {
    Row() {
      Column() {
        Text(tool.emoji).fontSize(30)
      }
      .width(48).height(48)
      .borderRadius(14)
      .backgroundColor(tool.bgColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(tool.name)
          .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1a1a1a')
        Text(tool.description)
          .fontSize(11).fontColor('#999').margin({ top: 2 })
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 12 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 12, right: 14 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width: 0.5, color: '#F0F0F0' })
    .onClick(() => { this.onToolClick(tool); })
  }

  // 刷新AI朋友圈动态
  refreshFeed() {
    this.posts = generateAIFeed(this.todayMood, this.treeHolePosts);
  }

  // 获取心情标签文字
  getMoodLabel(): string {
    for (let m of moodOptions) {
      if (m.emoji === this.todayMood) return m.label;
    }
    return '';
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
    this.refreshFeed();  // 刷新动态（AI朋友会自然回应）
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

  // AI朋友圈帖子卡片
  @Builder postCard(post: CommunityPost) {
    Column() {
      Row() {
        Text(post.userAvatar).fontSize(34)
        Column() {
          Text(post.userName).fontSize(14).fontWeight(FontWeight.Bold)
          Text(post.timeAgo).fontSize(11).fontColor('#999')
        }
        .margin({ left: 10 }).alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Text(post.content).fontSize(14).fontColor('#333').lineHeight(20)
        .margin({ top: 8, bottom: 10 }).maxLines(6)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 点赞+评论按钮
      Row() {
        Row() {
          Text(post.isLiked ? '❤️' : '🤍').fontSize(14)
          Text(post.likeCount > 0 ? post.likeCount.toString() : '').fontSize(12).fontColor('#999').margin({ left: 2 })
        }
        .onClick(() => { post.isLiked = !post.isLiked; post.isLiked ? post.likeCount++ : post.likeCount--; })

        Row() {
          Text('💬').fontSize(14)
          Text(post.comments.length > 0 ? post.comments.length.toString() : '').fontSize(12).fontColor('#999').margin({ left: 2 })
        }
        .margin({ left: 24 })
        .onClick(() => { post.showComments = !post.showComments; })
      }

      // 评论区
      if (post.showComments) {
        Column() {
          // AI评论
          ForEach(post.comments, (c: Comment) => {
            Row() {
              Text(c.userAvatar).fontSize(18)
              Text(c.userName).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#555').margin({ left: 6 })
              Text('：' + c.content).fontSize(12).fontColor('#666').maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
            }
            .width('100%').padding({ top: 3, bottom: 3 })
          }, (c: Comment, i: number) => c.userName + i.toString())

          Divider().strokeWidth(0.5).color('#EEE').margin({ top: 4, bottom: 4 })

          // 快捷回复
          Row() {
            Text('回复：').fontSize(11).fontColor('#999')
            Text('👍').fontSize(16).margin({ left: 6 })
              .onClick(() => { post.comments.push({ userName: '我', userAvatar: '👤', content: '👍', isAI: false }); })
            Text('❤️').fontSize(16).margin({ left: 6 })
              .onClick(() => { post.comments.push({ userName: '我', userAvatar: '👤', content: '❤️', isAI: false }); })
            Text('💪').fontSize(16).margin({ left: 6 })
              .onClick(() => { post.comments.push({ userName: '我', userAvatar: '👤', content: '💪', isAI: false }); })
            Text('✨').fontSize(16).margin({ left: 6 })
              .onClick(() => { post.comments.push({ userName: '我', userAvatar: '👤', content: '✨', isAI: false }); })
          }
          .margin({ top: 4 })
        }
        .width('100%').margin({ top: 8 }).padding({ top: 8, left: 4, right: 4 })
        .backgroundColor('#FAFAFA').borderRadius(8)
      }
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 14, right: 14 })
    .backgroundColor(Color.White).borderRadius(12)
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
