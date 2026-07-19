/**
 * Harmony Life OS — 首页 Dashboard
 *
 * 布局：天气日期 → 今日任务 → AI提醒 → 建议卡片 → 快捷Agent
 * 风格：蓝白科技风 · HarmonyOS 设计语言
 */

import router from '@ohos.router';

// ---- 接口定义 ----
interface WeatherData {
  temp: number;
  condition: string;
  icon: string;
  city: string;
  high: number;
  low: number;
}

interface DateData {
  weekday: string;
  date: string;
  lunar: string;
}

interface TaskData {
  id: string;
  title: string;
  type: string;
  done: boolean;
  time: string;
}

interface ReminderData {
  id: string;
  text: string;
  icon: string;
}

interface QuickAgentData {
  id: string;
  name: string;
  emoji: string;
  color: string;
}

// ---- 模拟数据（后续从Service层获取） ----
const MOCK_WEATHER: WeatherData = { temp: 26, condition: '晴', icon: '☀️', city: '北京', high: 30, low: 22 }
const MOCK_DATE: DateData = { weekday: '星期二', date: '2026年6月17日', lunar: '农历五月初三' }
const MOCK_TASKS: TaskData[] = [
  { id: 't1', title: '线代第六章习题', type: '学习', done: false, time: '14:00' },
  { id: 't2', title: '投递字节跳动简历', type: '工作', done: false, time: '16:00' },
  { id: 't3', title: '健身房练腿', type: '生活', done: true, time: '19:00' }
]
const MOCK_REMINDERS: ReminderData[] = [
  { id: 'r1', text: '明天上午10点有模电考试，记得带计算器', icon: '📝' },
  { id: 'r2', text: '你设定的Python学习计划今天该复习列表推导式了', icon: '💻' }
]
const MOCK_QUICK_AGENTS: QuickAgentData[] = [
  { id: 'ai_teacher', name: '学习导师', emoji: '🎓', color: '#4A90D9' },
  { id: 'ai_coder', name: '编程助手', emoji: '💻', color: '#22A699' },
  { id: 'ai_interview', name: '面试教练', emoji: '💼', color: '#2C3E6B' },
  { id: 'ai_emotion', name: '心理咨询师', emoji: '💜', color: '#C77DFF' },
  { id: 'ai_stylist', name: '穿搭顾问', emoji: '👗', color: '#E8658A' },
  { id: 'ai_tarot', name: '塔罗师', emoji: '🔮', color: '#7B2D8E' },
]

@Entry
@Component
export struct HomePage {
  // 后续替换为从 Service 获取的数据
  @State weatherTemp: number = MOCK_WEATHER.temp
  @State weatherIcon: string = MOCK_WEATHER.icon
  @State weatherCity: string = MOCK_WEATHER.city
  @State weatherHigh: number = MOCK_WEATHER.high
  @State weatherLow: number = MOCK_WEATHER.low
  @State dateWeekday: string = MOCK_DATE.weekday
  @State dateFull: string = MOCK_DATE.date
  @State dateLunar: string = MOCK_DATE.lunar
  @State greeting: string = ''

  aboutToAppear() {
    let hour = new Date().getHours()
    if (hour < 9) this.greeting = '早上好'
    else if (hour < 12) this.greeting = '上午好'
    else if (hour < 14) this.greeting = '中午好'
    else if (hour < 18) this.greeting = '下午好'
    else this.greeting = '晚上好'
  }

  build() {
    Scroll() {
      Column() {

        // ============ 顶部渐变Header ============
        Column() {
          // 问候语
          Row() {
            Text(this.greeting + '，Sherry')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Blank()
            Text('🔔')
              .fontSize(20)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12 })

          // 日期 + 天气行
          Row() {
            // 日期区
            Column() {
              Text(this.dateWeekday)
                .fontSize(14)
                .fontColor('#BBDEFB')
              Text(this.dateFull)
                .fontSize(12)
                .fontColor('#90CAF9')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            // 天气区
            Row() {
              Text(this.weatherIcon)
                .fontSize(28)
              Column() {
                Text(this.weatherTemp.toString() + '°')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                Text(this.weatherHigh.toString() + '° / ' + this.weatherLow.toString() + '°')
                  .fontSize(10)
                  .fontColor('#BBDEFB')
              }
              .margin({ left: 6 })
              .alignItems(HorizontalAlign.Start)
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(255,255,255,0.12)')
            .borderRadius(12)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 18 })
        }
        .width('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#1565C0', 0], ['#1E88E5', 0.4], ['#42A5F5', 1]]
        })
        .borderRadius({ bottomLeft: 24, bottomRight: 24 })

        // ============ 今日任务 ============
        Column() {
          Row() {
            Text('📋 今日任务')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
            Blank()
            Text(MOCK_TASKS.filter(t => !t.done).length.toString() + '项待完成')
              .fontSize(12)
              .fontColor('#999')
          }
          .width('100%')
          .margin({ bottom: 10 })

          ForEach(MOCK_TASKS, (task: TaskData) => {
            Row() {
              // 完成状态
              Column() {
                Text(task.done ? '✅' : '⭕')
                  .fontSize(16)
                  .opacity(task.done ? 1 : 0.3)
              }
              .width(32).height(32)
              .borderRadius(16)
              .backgroundColor(task.done ? '#E8F5E9' : '#F5F5F5')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              // 任务内容
              Column() {
                Text(task.title)
                  .fontSize(14)
                  .fontColor(task.done ? '#aaa' : '#333')
                  .decoration({ type: task.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                Text(this.getTaskTypeLabel(task.type) + ' · ' + task.time)
                  .fontSize(11)
                  .fontColor('#999')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
          }, (task: TaskData) => task.id)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 20 })

        // ============ AI 提醒 ============
        Column() {
          Row() {
            Text('🤖 AI 提醒')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
          }
          .width('100%')
          .margin({ bottom: 10 })

          ForEach(MOCK_REMINDERS, (r: ReminderData) => {
            Row() {
              Text(r.icon)
                .fontSize(20)
              Text(r.text)
                .fontSize(13)
                .fontColor('#555')
                .lineHeight(18)
                .layoutWeight(1)
                .margin({ left: 10 })
            }
            .width('100%')
            .padding({ top: 8, bottom: 8, left: 12, right: 12 })
            .backgroundColor('#F5F9FF')
            .borderRadius(10)
            .margin({ bottom: 6 })
          }, (r: ReminderData) => r.id)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 12 })

        // ============ 建议卡片（学习·生活·情绪 三列） ============
        Row() {
          // 学习建议
          Column() {
            Text('📚')
              .fontSize(28)
              .margin({ bottom: 6 })
            Text('学习建议')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .margin({ bottom: 4 })
            Text('今天适合复习\n数学公式和定理')
              .fontSize(10)
              .fontColor('#888')
              .lineHeight(14)
              .textAlign(TextAlign.Center)
              .maxLines(2)
          }
          .width('30%')
          .padding({ top: 14, bottom: 14, left: 8, right: 8 })
          .backgroundColor('#F0F7FF')
          .borderRadius(14)
          .alignItems(HorizontalAlign.Center)

          // 生活建议
          Column() {
            Text('🧘')
              .fontSize(28)
              .margin({ bottom: 6 })
            Text('生活建议')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .margin({ bottom: 4 })
            Text('午后散步20分钟\n缓解久坐疲劳')
              .fontSize(10)
              .fontColor('#888')
              .lineHeight(14)
              .textAlign(TextAlign.Center)
              .maxLines(2)
          }
          .width('30%')
          .padding({ top: 14, bottom: 14, left: 8, right: 8 })
          .backgroundColor('#FFF8F0')
          .borderRadius(14)
          .alignItems(HorizontalAlign.Center)
          .margin({ left: '5%', right: '5%' })

          // 情绪建议
          Column() {
            Text('💜')
              .fontSize(28)
              .margin({ bottom: 6 })
            Text('情绪建议')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .margin({ bottom: 4 })
            Text('听听轻音乐\n给心情放个假')
              .fontSize(10)
              .fontColor('#888')
              .lineHeight(14)
              .textAlign(TextAlign.Center)
              .maxLines(2)
          }
          .width('30%')
          .padding({ top: 14, bottom: 14, left: 8, right: 8 })
          .backgroundColor('#F8F0FF')
          .borderRadius(14)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12 })
        .justifyContent(FlexAlign.SpaceBetween)

        // ============ 快捷 Agent ============
        Column() {
          Row() {
            Text('⚡ 快捷 Agent')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
            Blank()
            Text('查看全部 ›')
              .fontSize(12)
              .fontColor('#1E88E5')
          }
          .width('100%')
          .margin({ bottom: 10 })

          Grid() {
            ForEach(MOCK_QUICK_AGENTS, (agent: QuickAgentData) => {
              GridItem() {
                Column() {
                  Text(agent.emoji)
                    .fontSize(30)
                  Text(agent.name)
                    .fontSize(11)
                    .fontColor('#555')
                    .margin({ top: 6 })
                }
                .width('100%')
                .padding({ top: 14, bottom: 14 })
                .backgroundColor(Color.White)
                .borderRadius(14)
                .border({ width: 1, color: '#E8EEF4' })
                .alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ChatPage',
                    params: {
                      contactId: agent.id,
                      contactName: agent.name,
                      isAI: true
                    }
                  })
                })
              }
            }, (agent: QuickAgentData) => agent.id)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 12, bottom: 20 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8')
    .scrollBar(BarState.Off)
  }

  getTaskTypeLabel(type: string): string {
    if (type === '学习') return '📚 学习'
    if (type === '工作') return '💼 工作'
    return '🧘 生活'
  }
}
