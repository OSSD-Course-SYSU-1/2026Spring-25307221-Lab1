/**
 * 答案之书翻页动画组件 — 书页翻动、停留、揭示答案。
 *
 * 使用方式：
 *   AnswerBookView({ question: '...', answer: '...', onClose: () => {} })
 */

@Component
export struct AnswerBookView {
  @State phase: number = 0;        // 0=翻开中 1=答案呈现 2=完成
  @State flipText: string = '';    // 当前翻页中的文字
  @State flipCount: number = 0;    // 翻页计数
  @Prop question: string = '';
  @Prop answer: string = '';
  @State showAnswer: boolean = false;

  onClose?: () => void;

  private flipTimer: number = -1;
  private flipWords: string[] = [
    '或许吧…', '再等等…', '换个角度…', '跟随内心…',
    '时机未到…', '勇敢一点…', '别着急…', '相信直觉…',
    '答案在路上…', '放下执念…', '你已知道…', '保持耐心…',
    '是的…', '不是…', '也许吧…', '回头看看…'
  ];

  aboutToAppear() {
    this.startFlipAnimation();
  }

  aboutToDisappear() {
    if (this.flipTimer !== -1) {
      clearInterval(this.flipTimer);
      this.flipTimer = -1;
    }
  }

  /**
   * 启动翻页动画
   */
  startFlipAnimation() {
    let totalFlips = 14;  // 翻14次后停下
    let speed = 80;       // 初始速度（ms）

    this.flipTimer = setInterval(() => {
      this.flipCount++;

      // 随机切换文字，模拟翻页
      let wordIndex = Math.floor(Math.random() * this.flipWords.length);
      this.flipText = this.flipWords[wordIndex];

      // 越往后越慢（模拟书页减速）
      if (this.flipCount >= totalFlips - 3) {
        clearInterval(this.flipTimer);
        this.flipTimer = setInterval(() => {
          this.flipCount++;
          let idx = Math.floor(Math.random() * this.flipWords.length);
          this.flipText = this.flipWords[idx];

          if (this.flipCount >= totalFlips) {
            // 翻页结束，揭示答案
            clearInterval(this.flipTimer);
            this.flipTimer = -1;
            this.phase = 1;
            setTimeout(() => {
              this.showAnswer = true;
            }, 400);
          }
        }, 180);
      }
    }, speed);
  }

  build() {
    Column() {
      // 顶部装饰
      Text('📖')
        .fontSize(44)
        .margin({ top: 50 })
        .animation({ duration: 600 })

      Text('答案之书')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#e8d5bc')
        .margin({ top: 8, bottom: 30 })

      // === 书本区域 ===
      Row() {
        // 左页 — 问题
        Column() {
          Text('你的问题')
            .fontSize(11)
            .fontColor('#a09080')
            .margin({ bottom: 12 })

          Text(this.question || '默念的问题…')
            .fontSize(14)
            .fontColor('#c8b898')
            .fontStyle(FontStyle.Italic)
            .maxLines(3)
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 14, right: 14 })
        }
        .width('42%')
        .aspectRatio(0.75)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#3a2a18')
        .borderRadius({ topLeft: 8, bottomLeft: 8 })
        .border({ width: 1, color: '#5a4030' })
        .shadow({ radius: 4, color: '#00000044', offsetX: 2, offsetY: 2 })

        // 书脊
        Column()
          .width(6)
          .height('100%')
          .backgroundColor('#2a1a0a')

        // 右页 — 答案
        Stack() {
          Column() {
            if (this.phase === 0) {
              // === 翻页中 ===
              Text(this.flipText)
                .fontSize(18)
                .fontColor('#c8a878')
                .fontWeight(FontWeight.Medium)
                .animation({ duration: 60 })

              Text('翻页中…')
                .fontSize(12)
                .fontColor('#806850')
                .margin({ top: 16 })
            } else {
              // === 答案呈现 ===
              Text('属于你的答案')
                .fontSize(10)
                .fontColor('#a09080')
                .margin({ bottom: 10 })

              Text(this.answer || '...')
                .fontSize(15)
                .fontColor('#f0d8a0')
                .fontWeight(FontWeight.Bold)
                .fontStyle(FontStyle.Italic)
                .textAlign(TextAlign.Center)
                .maxLines(5)
                .padding({ left: 12, right: 12 })
                .opacity(this.showAnswer ? 1 : 0)
                .animation({ duration: 800, curve: Curve.EaseOut })
            }
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)

          // 页脚装饰
          Text('✦')
            .fontSize(10)
            .fontColor('#5a4030')
            .position({ x: '50%', y: '88%' })
        }
        .width('42%')
        .aspectRatio(0.75)
        .backgroundColor('#4a3828')
        .borderRadius({ topRight: 8, bottomRight: 8 })
        .border({ width: 1, color: '#5a4030' })
        .shadow({ radius: 4, color: '#00000044', offsetX: -2, offsetY: 2 })
      }
      .width('88%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Blank()

      // 关闭按钮（答案呈现后显示）
      if (this.phase === 1 && this.showAnswer) {
        Button('收起书本')
          .fontSize(15)
          .fontColor('#c8a878')
          .backgroundColor('#3a2a18')
          .border({ width: 1, color: '#5a4030', radius: 20 })
          .padding({ left: 28, right: 28, top: 10, bottom: 10 })
          .margin({ bottom: 50 })
          .opacity(this.showAnswer ? 1 : 0)
          .animation({ duration: 400 })
          .onClick(() => {
            if (this.onClose) {
              this.onClose();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(8, 4, 16, 0.97)')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#101010', 0], ['#1a1410', 0.5], ['#0e0a06', 1]]
    })
  }
}
