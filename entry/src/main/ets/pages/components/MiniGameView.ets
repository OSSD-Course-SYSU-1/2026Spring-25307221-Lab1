/**
 * 休闲小游戏 — 打地鼠 + 贪吃蛇。
 */

// ==================== 游戏选择菜单 ====================
@Component
export struct GameMenu {
  onSelect?: (game: string) => void;

  build() {
    Column() {
      Text('🎮 休闲一刻')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 4 })
      Text('学习累了，来放松一下吧')
        .fontSize(13)
        .fontColor('#999')
        .margin({ bottom: 20 })

      Grid() {
        GridItem() { this.GameCard('🎯', '打地鼠', '眼疾手快', '#FF6B6B', '#FFF0F0') }
        GridItem() { this.GameCard('🐍', '贪吃蛇', '经典重现', '#4ECDC4', '#F0FAFA') }
        GridItem() { this.GameCard('🧱', '俄罗斯方块', '即将上线', '#45B7D1', '#F0F7FA') }
        GridItem() { this.GameCard('🏓', '乒乓球', '即将上线', '#F7DC6F', '#FFFEF5') }
        GridItem() { this.GameCard('🕹️', '抓娃娃', '即将上线', '#BB8FCE', '#F8F0FA') }
        GridItem() { this.GameCard('🎰', '老虎机', '即将上线', '#F0B27A', '#FFF8F0') }
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
    }
    .width('100%')
    .padding(16)
  }

  @Builder GameCard(emoji: string, name: string, desc: string, color: string, bg: string) {
    Column() {
      Text(emoji).fontSize(42)
      Text(name).fontSize(15).fontWeight(FontWeight.Bold).margin({ top: 6 })
      Text(desc).fontSize(11).fontColor('#999').margin({ top: 2 })
    }
    .width('100%')
    .padding({ top: 18, bottom: 18 })
    .backgroundColor(bg)
    .borderRadius(16)
    .border({ width: 1, color: color + '44' })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.onSelect && name !== '俄罗斯方块' && name !== '乒乓球' && name !== '抓娃娃' && name !== '老虎机') {
        this.onSelect(name);
      }
    })
  }
}

// ==================== 打地鼠 ====================
@Component
export struct WhackAMole {
  @State holes: boolean[] = [false, false, false, false, false, false, false, false, false];
  @State score: number = 0;
  @State timeLeft: number = 30;
  @State playing: boolean = false;
  @State gameOver: boolean = false;
  private moleTimer: number = -1;
  private countdownTimer: number = -1;
  onBack?: () => void;

  startGame() {
    this.score = 0;
    this.timeLeft = 30;
    this.playing = true;
    this.gameOver = false;
    this.holes = [false, false, false, false, false, false, false, false, false];

    // 倒计时
    this.countdownTimer = setInterval(() => {
      this.timeLeft--;
      if (this.timeLeft <= 0) {
        this.stopGame();
      }
    }, 1000);

    // 出地鼠
    this.spawnMole();
  }

  stopGame() {
    this.playing = false;
    this.gameOver = true;
    clearInterval(this.moleTimer);
    clearInterval(this.countdownTimer);
    this.holes = [false, false, false, false, false, false, false, false, false];
  }

  spawnMole() {
    if (!this.playing) return;
    // 随机选一个洞出地鼠
    let idx = Math.floor(Math.random() * 9);
    this.holes[idx] = true;
    this.holes = [...this.holes]; // 触发渲染

    this.moleTimer = setTimeout(() => {
      this.holes[idx] = false;
      this.holes = [...this.holes];
      if (this.playing) {
        // 随机间隔再出下一只
        setTimeout(() => { this.spawnMole(); }, 300 + Math.random() * 600);
      }
    }, 600 + Math.random() * 400);
  }

  whack(index: number) {
    if (!this.playing || !this.holes[index]) return;
    this.holes[index] = false;
    this.holes = [...this.holes];
    this.score++;
  }

  aboutToDisappear() {
    clearInterval(this.moleTimer);
    clearInterval(this.countdownTimer);
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text('←').fontSize(24).onClick(() => { this.stopGame(); if (this.onBack) this.onBack(); })
        Blank()
        Text('🎯 打地鼠').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      // 分数 + 倒计时
      Row() {
        Text('得分：' + this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
        Blank()
        Text('⏱ ' + this.timeLeft.toString() + 's')
          .fontSize(16)
          .fontColor(this.timeLeft <= 5 ? '#FF4444' : '#333')
      }
      .width('88%').margin({ bottom: 20 })

      // 3x3 地鼠洞网格
      Grid() {
        ForEach(['1','2','3','4','5','6','7','8','9'], (id: string, index: number) => {
          GridItem() {
            Column() {
              if (this.holes[index]) {
                Text('🐹').fontSize(44)
              } else {
                Text('🕳️').fontSize(36).opacity(0.4)
              }
            }
            .width('100%').height(90)
            .backgroundColor(this.holes[index] ? '#FFF3CD' : '#F5F5F5')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .onClick(() => { this.whack(index); })
          }
        }, (id: string) => id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(10).rowsGap(10)
      .width('88%')

      Blank()

      if (!this.playing && !this.gameOver) {
        Button('开始游戏').fontSize(18).fontColor(Color.White)
          .backgroundColor('#FF6B6B').borderRadius(24).width('60%').height(48)
          .onClick(() => { this.startGame(); })
          .margin({ bottom: 60 })
      }
      if (this.gameOver) {
        Column() {
          Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold)
          Text('得分：' + this.score.toString()).fontSize(16).fontColor('#FF6B6B').margin({ top: 4 })
          Button('再来一局').fontSize(16).fontColor(Color.White)
            .backgroundColor('#FF6B6B').borderRadius(20).width('50%').height(40).margin({ top: 12 })
            .onClick(() => { this.startGame(); })
        }
        .margin({ bottom: 50 })
      }
    }
    .width('100%').height('100%').backgroundColor('#FFFAFA')
  }
}

// ==================== 贪吃蛇 ====================
@Component
export struct SnakeGame {
  @State snake: number[][] = [[5, 7], [5, 8], [5, 9]];  // [row, col]
  @State food: number[] = [3, 5];
  @State direction: string = 'UP';
  @State score: number = 0;
  @State playing: boolean = false;
  @State gameOver: boolean = false;
  private gameTimer: number = -1;
  private gridSize: number = 15;
  onBack?: () => void;

  startGame() {
    this.snake = [[7, 7], [7, 8], [7, 9]];
    this.direction = 'UP';
    this.score = 0;
    this.playing = true;
    this.gameOver = false;
    this.spawnFood();

    this.gameTimer = setInterval(() => {
      this.move();
    }, 200);
  }

  spawnFood() {
    let row: number, col: number;
    do {
      row = Math.floor(Math.random() * this.gridSize);
      col = Math.floor(Math.random() * this.gridSize);
    } while (this.isOnSnake(row, col));
    this.food = [row, col];
  }

  isOnSnake(row: number, col: number): boolean {
    for (let s of this.snake) {
      if (s[0] === row && s[1] === col) return true;
    }
    return false;
  }

  move() {
    let head = this.snake[0];
    let newHead: number[] = [head[0], head[1]];

    if (this.direction === 'UP') newHead[0]--;
    if (this.direction === 'DOWN') newHead[0]++;
    if (this.direction === 'LEFT') newHead[1]--;
    if (this.direction === 'RIGHT') newHead[1]++;

    // 撞墙
    if (newHead[0] < 0 || newHead[1] < 0 || newHead[0] >= this.gridSize || newHead[1] >= this.gridSize) {
      this.endGame();
      return;
    }
    // 撞自己
    if (this.isOnSnake(newHead[0], newHead[1])) {
      this.endGame();
      return;
    }

    let newSnake: number[][] = [newHead];
    for (let i = 0; i < this.snake.length - 1; i++) {
      newSnake.push(this.snake[i]);
    }

    // 吃到食物
    if (newHead[0] === this.food[0] && newHead[1] === this.food[1]) {
      newSnake.push(this.snake[this.snake.length - 1]);
      this.score += 10;
      this.spawnFood();
    }

    this.snake = newSnake;
  }

  endGame() {
    this.playing = false;
    this.gameOver = true;
    clearInterval(this.gameTimer);
  }

  handleKey(key: string) {
    if (!this.playing) return;
    if (key === 'UP' && this.direction !== 'DOWN') this.direction = 'UP';
    if (key === 'DOWN' && this.direction !== 'UP') this.direction = 'DOWN';
    if (key === 'LEFT' && this.direction !== 'RIGHT') this.direction = 'LEFT';
    if (key === 'RIGHT' && this.direction !== 'LEFT') this.direction = 'RIGHT';
  }

  aboutToDisappear() {
    clearInterval(this.gameTimer);
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).onClick(() => { this.endGame(); if (this.onBack) this.onBack(); })
        Blank()
        Text('🐍 贪吃蛇').fontSize(18).fontWeight(FontWeight.Bold)
        Blank()
        Text('←').fontSize(24).fontColor(Color.Transparent)
      }
      .width('100%').padding(14)

      Text('得分：' + this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold).width('88%').margin({ bottom: 8 })

      // 游戏盘
      Column() {
        ForEach(Array.from({length: this.gridSize}, (_, r: number) => r.toString()), (r: string) => {
          Row() {
            ForEach(Array.from({length: this.gridSize}, (_, c: number) => c.toString()), (c: string) => {
              let ri = parseInt(r);
              let ci = parseInt(c);
              let isSnake = this.isOnSnake(ri, ci);
              let isFood = this.food[0] === ri && this.food[1] === ci;
              let isHead = this.snake.length > 0 && this.snake[0][0] === ri && this.snake[0][1] === ci;

              Text(isHead ? '🟢' : isSnake ? '🟩' : isFood ? '🍎' : '·')
                .fontSize(isHead || isFood ? 14 : 8)
                .width(20).height(20)
                .textAlign(TextAlign.Center)
            }, (c: string) => c)
          }
        }, (r: string) => r)
      }
      .padding(4)
      .backgroundColor('#E8F5E9')
      .borderRadius(8)

      Blank()

      // 方向键
      if (this.playing) {
        Column() {
          Row() {
            this.DirButton('⬆️', 'UP')
          }
          Row() {
            this.DirButton('⬅️', 'LEFT')
            Text('   ').fontSize(24)
            this.DirButton('➡️', 'RIGHT')
          }
          Row() {
            this.DirButton('⬇️', 'DOWN')
          }
        }
        .margin({ bottom: 30 })
      }

      if (!this.playing && !this.gameOver) {
        Button('开始游戏').fontSize(18).fontColor(Color.White)
          .backgroundColor('#4ECDC4').borderRadius(24).width('60%').height(48)
          .onClick(() => { this.startGame(); })
          .margin({ bottom: 60 })
      }
      if (this.gameOver) {
        Column() {
          Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold)
          Text('得分：' + this.score.toString()).fontSize(16).fontColor('#4ECDC4').margin({ top: 4 })
          Button('再来一局').fontSize(16).fontColor(Color.White)
            .backgroundColor('#4ECDC4').borderRadius(20).width('50%').height(40).margin({ top: 12 })
            .onClick(() => { this.startGame(); })
        }
        .margin({ bottom: 50 })
      }
    }
    .width('100%').height('100%').backgroundColor('#FAFFFA')
  }

  @Builder DirButton(label: string, dir: string) {
    Text(label)
      .fontSize(32)
      .width(60).height(56)
      .backgroundColor('#E0F0E0')
      .borderRadius(12)
      .textAlign(TextAlign.Center)
      .onClick(() => { this.handleKey(dir); })
  }
}
