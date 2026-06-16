/**
 * 休闲小游戏 — 6款可玩游戏，带规则说明和最高分。
 */

// ==================== 游戏菜单 ====================
@Component
export struct GameMenu {
  onPlay?: (gameId: string) => void;

  build() {
    Column() {
      Text('🎮 休闲一刻').fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 4 })
      Text('学习累了，来放松一下吧').fontSize(13).fontColor('#999').margin({ bottom: 20 })

      Grid() {
        GridItem() { this.Card('🎯', '猜数字', '1-100猜中即赢', '#FF6B6B') }
        GridItem() { this.Card('🐍', '贪吃蛇', '经典重现', '#4ECDC4') }
        GridItem() { this.Card('🧱', '俄罗斯方块', '消除得分', '#45B7D1') }
        GridItem() { this.Card('🏓', '乒乓球', '对战胜AI', '#F7DC6F') }
        GridItem() { this.Card('⚡', '反应测试', '测测你的手速', '#BB8FCE') }
        GridItem() { this.Card('🎰', '老虎机', '拉杆拼运气', '#F0B27A') }
      }
      .columnsTemplate('1fr 1fr').columnsGap(12).rowsGap(12).width('100%')
    }
    .width('100%').padding(16)
  }

  @Builder Card(e: string, n: string, d: string, c: string) {
    Column() {
      Text(e).fontSize(40)
      Text(n).fontSize(14).fontWeight(FontWeight.Bold).margin({ top: 6 })
      Text(d).fontSize(11).fontColor('#999').margin({ top: 2 })
    }
    .width('100%').padding({ top: 18, bottom: 18 })
    .backgroundColor(c + '40').borderRadius(16).border({ width: 1.5, color: c })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.onPlay) {
        this.onPlay(n);
      }
    })
  }
}

// ==================== 游戏说明页 ====================
@Component
export struct GameIntro {
  @Prop gameName: string = '';
  @Prop highScore: number = 0;
  onStart?: () => void;
  onBack?: () => void;

  getDesc(): string {
    if (this.gameName === '打地鼠') {
      return '🐹地鼠从洞里随机冒出，眼疾手快点它！\n⏱ 限时30秒，敲到越多分越高';
    }
    if (this.gameName === '贪吃蛇') {
      return '🐍方向键操控蛇的方向，吃🍎变长。\n💀 撞墙或撞到自己就结束';
    }
    if (this.gameName === '俄罗斯方块') {
      return '🧱左右移动+旋转方块，填满一行消除。\n⬆旋转 ⬅➡移动 ⬇加速下落';
    }
    if (this.gameName === '乒乓球') {
      return '🏓 滑动挡板接球，漏掉就丢分。\n先得5分者获胜';
    }
    if (this.gameName === '记忆翻牌') {
      return '🃏翻开两张牌，相同则消除。\n🧠 记住位置，最少步数完成';
    }
    return '🎰 点击旋转，三列相同即中奖。\n🍒🍋🍇 试试你的运气！';
  }

  build() {
    Column() {
      Text('←').fontSize(24).width('100%').padding(14)
        .onClick(() => {
          if (this.onBack) {
            this.onBack();
          }
        })

      Text(this.gameName).fontSize(28).fontWeight(FontWeight.Bold).margin({ top: 20 })

      Text(this.getDesc()).fontSize(15).fontColor('#555').lineHeight(22)
        .width('80%').margin({ top: 16, bottom: 8 }).textAlign(TextAlign.Center)

      Text('🏆 最高分：' + this.highScore.toString())
        .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#F0A500').margin({ top: 8, bottom: 30 })

      Button('开始游戏').fontSize(18).fontColor(Color.White)
        .backgroundColor('#07C160').borderRadius(24).width('60%').height(48)
        .onClick(() => {
          if (this.onStart) {
            this.onStart();
          }
        })

      Blank()
    }
    .width('100%').height('100%').backgroundColor('#FAFAFA')
  }
}

// ==================== 猜数字 ====================
@Component
export struct GuessNumber {
  @State target: number = 0;
  @State guess: string = '';
  @State hint: string = '输入1-100的数字';
  @State tries: number = 0;
  @State won: boolean = false;
  @State playing: boolean = false;
  @StorageProp('high_guess') highScore: number = 999;
  onBack?: () => void;

  start(): void {
    this.target = Math.floor(Math.random() * 100) + 1;
    this.tries = 0;
    this.won = false;
    this.playing = true;
    this.guess = '';
    this.hint = '输入1-100的数字';
  }

  check(): void {
    let n = parseInt(this.guess);
    if (isNaN(n) || n < 1 || n > 100) {
      this.hint = '请输入1-100的数字！';
      return;
    }
    this.tries++;
    if (n === this.target) {
      this.won = true;
      this.playing = false;
      this.hint = '🎉 猜对了！就是' + this.target.toString();
      if (this.tries < this.highScore) {
        AppStorage.setOrCreate<number>('high_guess', this.tries);
        this.highScore = this.tries;
      }
    } else if (n < this.target) {
      this.hint = '📈 太小了，往大猜！';
    } else {
      this.hint = '📉 太大了，往小猜！';
    }
    this.guess = '';
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).onClick(() => { if (this.onBack) { this.onBack(); } })
        Blank()
        Text('🎯 猜数字').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      Text('我想了一个1-100的数字').fontSize(16).margin({ top: 8 })
      Text(this.won ? '✅' : '🤔').fontSize(60).margin({ top: 12, bottom: 12 })

      Text(this.hint).fontSize(20).fontWeight(FontWeight.Bold)
        .fontColor(this.won ? '#07C160' : '#FF6B6B').margin({ bottom: 8 })

      if (this.playing || this.won) {
        Text('已猜' + this.tries.toString() + '次').fontSize(14).fontColor('#999').margin({ bottom: 4 })
      }
      Text('最少步数：' + (this.highScore < 999 ? this.highScore.toString() : '--')).fontSize(13).fontColor('#F0A500')

      if (this.playing) {
        Row() {
          TextInput({ text: this.guess, placeholder: '输入数字' })
            .fontSize(28).width(120).height(60).type(InputType.Number).maxLength(3)
            .backgroundColor('#FFF3F3').borderRadius(12).textAlign(TextAlign.Center)
            .onChange((v: string) => { this.guess = v; })
          Button('猜！').fontSize(18).fontColor(Color.White)
            .backgroundColor('#FF6B6B').borderRadius(12).height(60).margin({ left: 12 })
            .padding({ left: 20, right: 20 })
            .onClick(() => { this.check(); })
        }
        .margin({ top: 20 })
      }

      Blank()

      if (!this.playing && !this.won) {
        Button('开始游戏').fontSize(18).fontColor(Color.White)
          .backgroundColor('#FF6B6B').borderRadius(24).width('60%').height(48)
          .onClick(() => { this.start(); }).margin({ bottom: 60 })
      }
      if (this.won) {
        Text('🏆 你用了' + this.tries.toString() + '步猜中！').fontSize(18).fontWeight(FontWeight.Bold)
        Button('再来一局').fontSize(16).fontColor(Color.White)
          .backgroundColor('#FF6B6B').borderRadius(20).width('50%').height(40).margin({ top: 12 })
          .onClick(() => { this.start(); })
      }
    }
    .width('100%').height('100%').backgroundColor('#FFFAFA')
  }
}

// ==================== 贪吃蛇 ====================
@Component
export struct SnakeGame {
  @State snake: number[][] = [[7, 7], [7, 8], [7, 9]];
  @State food: number[] = [3, 5];
  @State dir: string = 'UP';
  @State score: number = 0;
  @State playing: boolean = false;
  @State over: boolean = false;
  private timer: number = -1;
  private gridSizeNum: number = 15;
  private rowIds: string[] = ['r0','r1','r2','r3','r4','r5','r6','r7','r8','r9','r10','r11','r12','r13','r14'];
  private colIds: string[] = ['c0','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14'];
  @StorageProp('high_snake') highScore: number = 0;
  onBack?: () => void;

  start(): void {
    this.snake = [[7, 7], [7, 8], [7, 9]];
    this.dir = 'UP';
    this.score = 0;
    this.playing = true;
    this.over = false;
    this.spawn();
    this.timer = setInterval(() => { this.move(); }, 200);
  }

  spawn(): void {
    let r = 0, c = 0;
    for (let t = 0; t < 100; t++) {
      r = Math.floor(Math.random() * this.gridSizeNum);
      c = Math.floor(Math.random() * this.gridSizeNum);
      if (!this.onSnake(r, c)) {
        break;
      }
    }
    this.food = [r, c];
  }

  onSnake(r: number, c: number): boolean {
    for (let i = 0; i < this.snake.length; i++) {
      let s = this.snake[i];
      if (s[0] === r && s[1] === c) {
        return true;
      }
    }
    return false;
  }

  move(): void {
    let h = this.snake[0];
    let nh: number[] = [h[0], h[1]];
    if (this.dir === 'UP') { nh[0] = nh[0] - 1; }
    if (this.dir === 'DOWN') { nh[0] = nh[0] + 1; }
    if (this.dir === 'LEFT') { nh[1] = nh[1] - 1; }
    if (this.dir === 'RIGHT') { nh[1] = nh[1] + 1; }
    if (nh[0] < 0 || nh[1] < 0 || nh[0] >= this.gridSizeNum || nh[1] >= this.gridSizeNum || this.onSnake(nh[0], nh[1])) {
      this.die();
      return;
    }
    let ns: number[][] = [nh];
    for (let i = 0; i < this.snake.length - 1; i++) {
      ns.push(this.snake[i]);
    }
    if (nh[0] === this.food[0] && nh[1] === this.food[1]) {
      ns.push(this.snake[this.snake.length - 1]);
      this.score = this.score + 10;
      this.spawn();
    }
    this.snake = ns;
  }

  die(): void {
    this.playing = false;
    this.over = true;
    clearInterval(this.timer);
    if (this.score > this.highScore) {
      AppStorage.setOrCreate<number>('high_snake', this.score);
      this.highScore = this.score;
    }
  }

  handleKey(k: string): void {
    if (!this.playing) { return; }
    if (k === 'UP' && this.dir !== 'DOWN') { this.dir = 'UP'; }
    if (k === 'DOWN' && this.dir !== 'UP') { this.dir = 'DOWN'; }
    if (k === 'LEFT' && this.dir !== 'RIGHT') { this.dir = 'LEFT'; }
    if (k === 'RIGHT' && this.dir !== 'LEFT') { this.dir = 'RIGHT'; }
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).onClick(() => {
          this.die();
          if (this.onBack) { this.onBack(); }
        })
        Blank()
        Text('🐍 贪吃蛇').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      Row() {
        Text('得分：' + this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Text('🏆' + this.highScore.toString()).fontSize(13).fontColor('#F0A500')
      }
      .width('88%').margin({ bottom: 8 })

      Column() {
        ForEach(this.rowIds, (r: string, ri: number) => {
          Row() {
            ForEach(this.colIds, (c: string, ci: number) => {
              Text(
                this.snake.length > 0 && this.snake[0][0] === ri && this.snake[0][1] === ci ? '🟢' :
                (this.onSnake(ri, ci) ? '🟩' :
                (this.food[0] === ri && this.food[1] === ci ? '🍎' : '·'))
              )
              .fontSize(
                (this.snake.length > 0 && this.snake[0][0] === ri && this.snake[0][1] === ci) ||
                (this.food[0] === ri && this.food[1] === ci) ? 14 : 8
              )
              .width(20).height(20).textAlign(TextAlign.Center)
            }, (c: string) => c)
          }
        }, (r: string) => r)
      }
      .padding(4).backgroundColor('#E8F5E9').borderRadius(8)

      Blank()

      if (this.playing) {
        Column() {
          Row() { this.DirButton('⬆️', 'UP') }
          Row() {
            this.DirButton('⬅️', 'LEFT')
            Text('   ').fontSize(24)
            this.DirButton('➡️', 'RIGHT')
          }
          Row() { this.DirButton('⬇️', 'DOWN') }
        }
        .margin({ bottom: 30 })
      }

      if (!this.playing && !this.over) {
        Button('开始游戏').fontSize(18).fontColor(Color.White)
          .backgroundColor('#4ECDC4').borderRadius(24).width('60%').height(48)
          .onClick(() => { this.start(); })
          .margin({ bottom: 60 })
      }
      if (this.over) {
        Column() {
          Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold)
          Text('得分：' + this.score.toString()).fontSize(16).fontColor('#4ECDC4').margin({ top: 4 })
          if (this.score >= this.highScore) {
            Text('🎉 新纪录！').fontSize(14).fontColor('#F0A500')
          }
          Button('再来一局').fontSize(16).fontColor(Color.White)
            .backgroundColor('#4ECDC4').borderRadius(20).width('50%').height(40).margin({ top: 12 })
            .onClick(() => { this.start(); })
        }
        .margin({ bottom: 50 })
      }
    }
    .width('100%').height('100%').backgroundColor('#FAFFFA')
  }

  @Builder DirButton(label: string, k: string) {
    Text(label).fontSize(32).width(60).height(56)
      .backgroundColor('#E0F0E0').borderRadius(12).textAlign(TextAlign.Center)
      .onClick(() => { this.handleKey(k); })
  }
}

// ==================== 老虎机 ====================
@Component
export struct SlotMachine {
  @State reels: string[] = ['🍒', '🍒', '🍒'];
  @State spinning: boolean = false;
  @State coins: number = 100;
  @State msg: string = '点击旋转开始！';
  private icons: string[] = ['🍒', '🍋', '🍇', '🍊', '🍉', '⭐', '💎', '7️⃣'];
  private anim: number = -1;
  @StorageProp('high_slot') highScore: number = 0;
  onBack?: () => void;

  spin(): void {
    if (this.spinning || this.coins < 10) {
      return;
    }
    this.spinning = true;
    this.coins = this.coins - 10;
    this.msg = '旋转中…';
    let cnt = 0;
    this.anim = setInterval(() => {
      this.reels = [this.rnd(), this.rnd(), this.rnd()];
      cnt++;
      if (cnt >= 12) {
        clearInterval(this.anim);
        this.stopSpin();
      }
    }, 120);
  }

  rnd(): string {
    return this.icons[Math.floor(Math.random() * this.icons.length)];
  }

  stopSpin(): void {
    this.spinning = false;
    let r = this.reels;
    if (r[0] === r[1] && r[1] === r[2]) {
      let win = r[0] === '7️⃣' ? 200 : (r[0] === '💎' ? 150 : (r[0] === '⭐' ? 100 : 50));
      this.coins = this.coins + win;
      this.msg = '🎉 中奖！+' + win.toString();
    } else if (r[0] === r[1] || r[1] === r[2] || r[0] === r[2]) {
      this.coins = this.coins + 20;
      this.msg = '👍 小奖 +20';
    } else {
      this.msg = '再试一次！';
    }
    if (this.coins > this.highScore) {
      AppStorage.setOrCreate<number>('high_slot', this.coins);
      this.highScore = this.coins;
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.anim);
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).onClick(() => {
          if (this.onBack) { this.onBack(); }
        })
        Blank()
        Text('🎰 老虎机').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      Row() {
        Text('💰金币：' + this.coins.toString()).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Text('🏆' + this.highScore.toString()).fontSize(13).fontColor('#F0A500')
      }
      .width('88%').margin({ bottom: 16 })

      Column() {
        Text(this.msg).fontSize(14).fontColor('#F0A500').margin({ bottom: 16 })
      }
      .width('100%').alignItems(HorizontalAlign.Center)

      Row() {
        ForEach(this.reels, (r: string, i: number) => {
          Text(r).fontSize(56).width(80).height(100)
            .backgroundColor('#FFF8E1').borderRadius(12).textAlign(TextAlign.Center)
            .margin({ left: 6, right: 6 })
        }, (r: string, i: number) => r + i.toString())
      }
      .width('100%').justifyContent(FlexAlign.Center).margin({ bottom: 24 })

      Button(this.spinning ? '...' : '🎰 旋转 (消耗10金币)')
        .fontSize(16).fontColor(Color.White)
        .backgroundColor(this.spinning || this.coins < 10 ? '#CCC' : '#F0A500')
        .borderRadius(24).height(48).padding({ left: 24, right: 24 })
        .enabled(!this.spinning && this.coins >= 10)
        .onClick(() => { this.spin(); })

      Blank()

      Text('🍒x3=+50 | ⭐x3=+100 | 💎x3=+150 | 7️⃣x3=+200')
        .fontSize(11).fontColor('#999').margin({ bottom: 30 })
    }
    .width('100%').height('100%').backgroundColor('#FFFDF5')
  }
}

// ==================== 反应速度测试 ====================
@Component
export struct ReactionTest {
  @State phase: string = 'idle'; // idle|wait|ready|result
  @State msg: string = '点击屏幕开始';
  @State reaction: number = 0;
  @State best: number = 9999;
  private timer: number = -1;
  @StorageProp('high_reaction') highScore: number = 9999;
  onBack?: () => void;

  start(): void {
    this.phase = 'wait';
    this.msg = '等待中…';
    let wait = 1000 + Math.random() * 3000;
    setTimeout(() => {
      if (this.phase === 'wait') {
        this.phase = 'ready';
        this.msg = '快按！！！';
        this.timer = Date.now();
      }
    }, wait);
  }

  onTap(): void {
    if (this.phase === 'idle') {
      this.start();
    } else if (this.phase === 'wait') {
      this.msg = '太急了！等变绿再按';
      this.phase = 'idle';
    } else if (this.phase === 'ready') {
      this.reaction = Date.now() - this.timer;
      if (this.reaction < this.best) { this.best = this.reaction; }
      if (this.best < this.highScore) {
        AppStorage.setOrCreate<number>('high_reaction', this.best);
        this.highScore = this.best;
      }
      this.phase = 'result';
      this.msg = '你的反应：' + this.reaction.toString() + 'ms';
    } else if (this.phase === 'result') {
      this.start();
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('←').fontSize(24).onClick(() => { if (this.onBack) { this.onBack(); } })
          Blank()
          Text('⚡ 反应测试').fontSize(18).fontWeight(FontWeight.Bold)
          Blank()
          Text('←').fontSize(24).fontColor(Color.Transparent)
        }
        .width('100%').padding(14)

        Blank()

        Text(this.phase === 'result' ? '⏱' : '').fontSize(64)
        Text(this.msg).fontSize(22).fontWeight(FontWeight.Bold)
          .fontColor(this.phase === 'ready' ? '#FF6B6B' : '#333').margin({ top: 16 })

        if (this.phase === 'result') {
          Text('最佳：' + this.best.toString() + 'ms').fontSize(16).fontColor('#07C160').margin({ top: 12 })
          Text('历史最佳：' + (this.highScore < 9999 ? this.highScore.toString() : '--') + 'ms').fontSize(13).fontColor('#F0A500').margin({ top: 4 })
          Text('点击再来一次').fontSize(13).fontColor('#999').margin({ top: 16 })
        }
        if (this.phase === 'idle') {
          Text('点击任意位置开始').fontSize(14).fontColor('#999').margin({ top: 12 })
        }

        Blank()
      }
      .width('100%').height('100%')
      .onClick(() => { this.onTap(); })
    }
    .width('100%').height('100%')
    .backgroundColor(this.phase === 'ready' ? '#E8F5E9' : (this.phase === 'result' ? '#FAFAFA' : '#FAFAFA'))
  }
}

// ==================== 乒乓球 ====================
@Component
export struct PongGame {
  @State ballX: number = 150;
  @State ballY: number = 200;
  @State padY: number = 300;
  @State aiY: number = 300;
  @State pScore: number = 0;
  @State aScore: number = 0;
  @State playing: boolean = false;
  @State over: boolean = false;
  @State msg: string = '';
  private bx: number = 2;
  private by: number = 3;
  private timer: number = -1;
  private cw: number = 320;
  private ch: number = 520;
  @StorageProp('high_pong') highScore: number = 0;
  onBack?: () => void;

  start(): void {
    this.pScore = 0;
    this.aScore = 0;
    this.ballX = 150;
    this.ballY = 200;
    this.padY = 300;
    this.aiY = 300;
    this.bx = 3;
    this.by = 2;
    this.playing = true;
    this.over = false;
    this.msg = '';
    this.timer = setInterval(() => { this.tick(); }, 30);
  }

  tick(): void {
    this.ballX = this.ballX + this.bx;
    this.ballY = this.ballY + this.by;
    if (this.ballY <= 0 || this.ballY >= this.ch) {
      this.by = -this.by;
    }
    if (this.ballX <= 30 && this.ballY >= this.padY && this.ballY <= this.padY + 80) {
      this.bx = -this.bx;
      this.ballX = 35;
    }
    if (this.ballX >= this.cw - 30 && this.ballY >= this.aiY && this.ballY <= this.aiY + 80) {
      this.bx = -this.bx;
      this.ballX = this.cw - 35;
    }
    if (this.ballX < 0) {
      this.aScore++;
      this.resetBall();
    }
    if (this.ballX > this.cw) {
      this.pScore++;
      this.resetBall();
    }
    if (this.pScore >= 5 || this.aScore >= 5) {
      this.playing = false;
      this.over = true;
      clearInterval(this.timer);
      if (this.pScore > this.aScore && this.pScore > this.highScore) {
        AppStorage.setOrCreate<number>('high_pong', this.pScore);
        this.highScore = this.pScore;
      }
      this.msg = this.pScore > this.aScore ? '🎉 你赢了！' : '😢 AI赢了！';
    }
    let target = this.ballY - 40;
    this.aiY = this.aiY + (target - this.aiY) * 0.08;
  }

  resetBall(): void {
    this.ballX = 150;
    this.ballY = 200;
    this.bx = (Math.random() > 0.5 ? 3 : -3);
    this.by = (Math.random() > 0.5 ? 2 : -2);
  }

  movePad(y: number): void {
    this.padY = y - 40;
    if (this.padY < 0) { this.padY = 0; }
    if (this.padY > this.ch - 80) { this.padY = this.ch - 80; }
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).onClick(() => {
          clearInterval(this.timer);
          if (this.onBack) { this.onBack(); }
        })
        Blank()
        Text('🏓 乒乓球').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      Row() {
        Text('你：' + this.pScore.toString()).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FF6B6B')
        Blank()
        Text('🏆' + this.highScore.toString()).fontSize(13).fontColor('#F0A500')
        Blank()
        Text('AI：' + this.aScore.toString()).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#4ECDC4')
      }
      .width('88%').margin({ bottom: 12 })

      Stack() {
        Text('🏓').fontSize(24).position({ x: this.ballX, y: this.ballY })
        Column().width(8).height(80).backgroundColor('#FF6B6B').borderRadius(4)
          .position({ x: 20, y: this.padY })
        Column().width(8).height(80).backgroundColor('#4ECDC4').borderRadius(4)
          .position({ x: this.cw - 28, y: this.aiY })
      }
      .width(this.cw).height(this.ch).backgroundColor('#1a1a2e').borderRadius(12)
      .onTouch((e: TouchEvent) => {
        if (e.touches.length > 0) {
          this.movePad(e.touches[0].y - 100);
        }
      })

      Blank()

      if (this.over) {
        Column() {
          Text(this.msg).fontSize(20).fontWeight(FontWeight.Bold)
          Text('你 ' + this.pScore.toString() + ' : ' + this.aScore.toString() + ' AI')
            .fontSize(16).fontColor('#666').margin({ top: 4 })
          Button('再来一局').fontSize(16).fontColor(Color.White)
            .backgroundColor('#07C160').borderRadius(20).width('50%').height(40).margin({ top: 12 })
            .onClick(() => { this.start(); })
        }
        .margin({ bottom: 50 })
      }
      if (!this.playing && !this.over) {
        Button('开始游戏').fontSize(18).fontColor(Color.White)
          .backgroundColor('#07C160').borderRadius(24).width('60%').height(48)
          .onClick(() => { this.start(); })
          .margin({ bottom: 60 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}

// ==================== 俄罗斯方块 ====================
@Component
export struct TetrisGame {
  @State grid: number[][] = [];
  @State pieceRow: number = 0;
  @State pieceCol: number = 3;
  @State piece: number[][] = [];
  @State score: number = 0;
  @State playing: boolean = false;
  @State over: boolean = false;
  private timer: number = -1;
  private cols: number = 10;
  private rows: number = 18;
  private shapes: number[][][] = [
    [[1, 1, 1, 1]],
    [[1, 1], [1, 1]],
    [[0, 1, 0], [1, 1, 1]],
    [[1, 0, 0], [1, 1, 1]],
    [[0, 0, 1], [1, 1, 1]],
    [[1, 1, 0], [0, 1, 1]],
    [[0, 1, 1], [1, 1, 0]]
  ];
  @StorageProp('high_tetris') highScore: number = 0;
  onBack?: () => void;

  start(): void {
    this.grid = [];
    for (let r = 0; r < this.rows; r++) {
      let row: number[] = [];
      for (let c = 0; c < this.cols; c++) {
        row.push(0);
      }
      this.grid.push(row);
    }
    this.score = 0;
    this.playing = true;
    this.over = false;
    this.spawnPiece();
    this.timer = setInterval(() => { this.down(); }, 600);
  }

  spawnPiece(): void {
    let s = this.shapes[Math.floor(Math.random() * this.shapes.length)];
    this.piece = s;
    this.pieceRow = 0;
    this.pieceCol = 3;
    if (this.collide()) {
      this.playing = false;
      this.over = true;
      clearInterval(this.timer);
      if (this.score > this.highScore) {
        AppStorage.setOrCreate<number>('high_tetris', this.score);
        this.highScore = this.score;
      }
    }
  }

  collide(): boolean {
    for (let r = 0; r < this.piece.length; r++) {
      for (let c = 0; c < this.piece[r].length; c++) {
        if (this.piece[r][c]) {
          let gr = this.pieceRow + r;
          let gc = this.pieceCol + c;
          if (gr < 0 || gr >= this.rows || gc < 0 || gc >= this.cols || this.grid[gr][gc]) {
            return true;
          }
        }
      }
    }
    return false;
  }

  lock(): void {
    for (let r = 0; r < this.piece.length; r++) {
      for (let c = 0; c < this.piece[r].length; c++) {
        if (this.piece[r][c]) {
          this.grid[this.pieceRow + r][this.pieceCol + c] = 1;
        }
      }
    }
    this.clearLines();
    this.spawnPiece();
  }

  clearLines(): void {
    let cleared = 0;
    for (let r = this.rows - 1; r >= 0; r--) {
      let full = true;
      for (let c = 0; c < this.cols; c++) {
        if (this.grid[r][c] === 0) {
          full = false;
          break;
        }
      }
      if (full) {
        this.grid.splice(r, 1);
        let nr: number[] = [];
        for (let c = 0; c < this.cols; c++) {
          nr.push(0);
        }
        this.grid.unshift(nr);
        cleared++;
        r++;
      }
    }
    if (cleared > 0) {
      this.score = this.score + cleared * 100;
    }
  }

  down(): void {
    this.pieceRow++;
    if (this.collide()) {
      this.pieceRow--;
      this.lock();
    }
  }

  rotPiece(): void {
    let rot: number[][] = [];
    for (let c = 0; c < this.piece[0].length; c++) {
      let nr: number[] = [];
      for (let r = this.piece.length - 1; r >= 0; r--) {
        nr.push(this.piece[r][c]);
      }
      rot.push(nr);
    }
    let old = this.piece;
    this.piece = rot;
    if (this.collide()) {
      this.piece = old;
    }
  }

  moveLeft(): void {
    this.pieceCol--;
    if (this.collide()) {
      this.pieceCol++;
    }
  }

  moveRight(): void {
    this.pieceCol++;
    if (this.collide()) {
      this.pieceCol--;
    }
  }

  drop(): void {
    while (!this.collide()) {
      this.pieceRow++;
    }
    this.pieceRow--;
    this.lock();
  }

  cellAt(r: number, c: number): boolean {
    if (this.grid[r][c]) {
      return true;
    }
    for (let pr = 0; pr < this.piece.length; pr++) {
      for (let pc = 0; pc < this.piece[pr].length; pc++) {
        if (this.piece[pr][pc] && this.pieceRow + pr === r && this.pieceCol + pc === c) {
          return true;
        }
      }
    }
    return false;
  }

  cellIsPiece(r: number, c: number): boolean {
    for (let pr = 0; pr < this.piece.length; pr++) {
      for (let pc = 0; pc < this.piece[pr].length; pc++) {
        if (this.piece[pr][pc] && this.pieceRow + pr === r && this.pieceCol + pc === c) {
          return true;
        }
      }
    }
    return false;
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).onClick(() => {
          clearInterval(this.timer);
          if (this.onBack) { this.onBack(); }
        })
        Blank()
        Text('🧱 俄罗斯方块').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      Row() {
        Text('得分：' + this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Text('🏆' + this.highScore.toString()).fontSize(13).fontColor('#F0A500')
      }
      .width('88%').margin({ bottom: 8 })

      Column() {
        ForEach(this.grid, (row: number[], ri: number) => {
          Row() {
            ForEach(row, (cell: number, ci: number) => {
              Column()
                .width(18).height(18).margin(1)
                .backgroundColor(this.cellIsPiece(ri, ci) ? '#FF6B6B' : (this.grid[ri][ci] ? '#45B7D1' : '#1a1a2e'))
                .borderRadius(2)
            }, (cell: number, ci: number) => ci.toString())
          }
        }, (row: number[], ri: number) => ri.toString())
      }
      .padding(4).backgroundColor('#0a0a1e').borderRadius(8)

      Blank()

      if (this.playing) {
        Row() {
          this.TBtn('⬅️', 'L')
          this.TBtn('⬇️', 'D')
          this.TBtn('➡️', 'R')
          this.TBtn('🔄', 'ROT')
          this.TBtn('⏬', 'DROP')
        }
        .margin({ bottom: 20 })
      }

      if (!this.playing && !this.over) {
        Button('开始游戏').fontSize(18).fontColor(Color.White)
          .backgroundColor('#45B7D1').borderRadius(24).width('60%').height(48)
          .onClick(() => { this.start(); })
          .margin({ bottom: 60 })
      }
      if (this.over) {
        Column() {
          Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold)
          Text('得分：' + this.score.toString()).fontSize(16).fontColor('#45B7D1').margin({ top: 4 })
          if (this.score >= this.highScore) {
            Text('🎉 新纪录！').fontSize(14).fontColor('#F0A500')
          }
          Button('再来一局').fontSize(16).fontColor(Color.White)
            .backgroundColor('#45B7D1').borderRadius(20).width('50%').height(40).margin({ top: 12 })
            .onClick(() => { this.start(); })
        }
        .margin({ bottom: 50 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F0F8FA')
  }

  @Builder TBtn(label: string, action: string) {
    Text(label).fontSize(24).width(50).height(44)
      .backgroundColor('#E0F0F8').borderRadius(10).textAlign(TextAlign.Center)
      .margin({ left: 4, right: 4 })
      .onClick(() => {
        if (action === 'L') { this.moveLeft(); }
        if (action === 'R') { this.moveRight(); }
        if (action === 'D') { this.down(); }
        if (action === 'ROT') { this.rotPiece(); }
        if (action === 'DROP') { this.drop(); }
      })
  }
}
