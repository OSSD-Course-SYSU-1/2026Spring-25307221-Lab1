/**
 * 休闲小游戏 — 6款可玩游戏。
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
        GridItem() { this.GameCard('🎯', '打地鼠', '30秒眼疾手快', '#FF6B6B') }
        GridItem() { this.GameCard('🐍', '贪吃蛇', '经典重现', '#4ECDC4') }
        GridItem() { this.GameCard('🧱', '俄罗斯方块', '消除得分', '#45B7D1') }
        GridItem() { this.GameCard('🏓', '乒乓球', '对战胜AI', '#F7DC6F') }
        GridItem() { this.GameCard('🃏', '记忆翻牌', '找出配对', '#BB8FCE') }
        GridItem() { this.GameCard('🎰', '老虎机', '拉杆拼运气', '#F0B27A') }
      }
      .columnsTemplate('1fr 1fr').columnsGap(12).rowsGap(12).width('100%')
    }
    .width('100%').padding(16)
  }

  @Builder GameCard(e: string, n: string, d: string, c: string) {
    Column() {
      Text(e).fontSize(40)
      Text(n).fontSize(14).fontWeight(FontWeight.Bold).margin({ top: 6 })
      Text(d).fontSize(11).fontColor('#999').margin({ top: 2 })
    }
    .width('100%').padding({ top: 18, bottom: 18 })
    .backgroundColor(c + '22').borderRadius(16).border({ width: 1, color: c + '44' })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => { if (this.onPlay) { this.onPlay(n); } })
  }
}

// ==================== 游戏说明弹窗 ====================
@Component
export struct GameIntro {
  @Prop gameName: string = '';
  @Prop highScore: number = 0;
  onStart?: () => void;
  onBack?: () => void;

  getDesc(): string {
    switch (this.gameName) {
      case '打地鼠': return '🐹地鼠从洞里随机冒出，眼疾手快点它！\n⏱ 限时30秒，敲到越多分越高';
      case '贪吃蛇': return '🐍方向键操控蛇的方向，吃🍎变长。\n💀 撞墙或撞到自己就结束';
      case '俄罗斯方块': return '🧱左右移动+旋转方块，填满一行消除。\n⬆旋转 ⬅➡移动 ⬇加速下落';
      case '乒乓球': return '🏓 滑动挡板接球，漏掉就丢分。\n先得5分者获胜';
      case '记忆翻牌': return '🃏翻开两张牌，相同则消除。\n🧠 记住位置，最少步数完成';
      case '老虎机': return '🎰 点击旋转，三列相同即中奖。\n🍒🍋🍇 试试你的运气！';
      default: return '';
    }
  }

  build() {
    Column() {
      Text('←').fontSize(24).width('100%').padding(14)
        .onClick(() => { if (this.onBack) { this.onBack(); } })

      Text(this.gameName).fontSize(28).fontWeight(FontWeight.Bold).margin({ top: 20 })

      Text(this.getDesc()).fontSize(15).fontColor('#555').lineHeight(22)
        .width('80%').margin({ top: 16, bottom: 8 }).textAlign(TextAlign.Center)

      Text('🏆 最高分：' + this.highScore.toString())
        .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#F0A500').margin({ top: 8, bottom: 30 })

      Button('开始游戏').fontSize(18).fontColor(Color.White)
        .backgroundColor('#07C160').borderRadius(24).width('60%').height(48)
        .onClick(() => { if (this.onStart) { this.onStart(); } })

      Blank()
    }
    .width('100%').height('100%').backgroundColor('#FAFAFA')
  }
}

// ==================== 打地鼠 ====================
@Component
export struct WhackAMole {
  @State holes: boolean[] = [false,false,false,false,false,false,false,false,false];
  @State score: number = 0; @State timeLeft: number = 30;
  @State playing: boolean = false; @State gameOver: boolean = false;
  private moleTimer: number = -1; private cdTimer: number = -1;
  @StorageProp('high_whack') highScore: number = 0;
  onBack?: () => void;

  start(): void { this.score=0; this.timeLeft=30; this.playing=true; this.gameOver=false;
    this.holes=[false,false,false,false,false,false,false,false,false];
    this.cdTimer=setInterval(()=>{this.timeLeft--; if(this.timeLeft<=0)this.stop();},1000);
    this.pop(); }
  stop(): void { this.playing=false; this.gameOver=true; clearInterval(this.moleTimer); clearInterval(this.cdTimer);
    this.holes=[false,false,false,false,false,false,false,false,false];
    if(this.score>this.highScore){AppStorage.setOrCreate<number>('high_whack',this.score); this.highScore=this.score;} }
  pop(): void { if(!this.playing)return; let i=Math.floor(Math.random()*9); this.holes[i]=true; this.holes=[...this.holes];
    this.moleTimer=setTimeout(()=>{this.holes[i]=false;this.holes=[...this.holes];
    if(this.playing)setTimeout(()=>this.pop(),300+Math.random()*600);},600+Math.random()*400); }
  hit(i:number): void {if(!this.playing||!this.holes[i])return; this.holes[i]=false; this.holes=[...this.holes]; this.score++;}

  aboutToDisappear(): void {clearInterval(this.moleTimer);clearInterval(this.cdTimer);}

  build(){Column(){
    Row(){Text('←').fontSize(24).onClick(()=>{this.stop();if(this.onBack)this.onBack();}) Blank()
      Text('🎯 打地鼠').fontSize(18).fontWeight(FontWeight.Bold); Blank(); Text('←').fontSize(24).fontColor(Color.Transparent)}
    .width('100%').padding(14)
    Row(){Text('得分：'+this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
      Blank(); Text('🏆'+this.highScore.toString()).fontSize(13).fontColor('#F0A500')
      Blank(); Text('⏱'+this.timeLeft.toString()+'s').fontSize(16).fontColor(this.timeLeft<=5?'#F44':'#333')}
    .width('88%').margin({bottom:20})
    Grid(){ForEach(['0','1','2','3','4','5','6','7','8'],(id:string,idx:number)=>{GridItem(){
      Column(){Text(this.holes[idx]?'🐹':'🕳️').fontSize(44).opacity(this.holes[idx]?1:0.3)}
      .width('100%').height(90).backgroundColor(this.holes[idx]?'#FFF3CD':'#F5F5F5')
      .borderRadius(12).justifyContent(FlexAlign.Center).onClick(()=>{this.hit(idx);})
    }},(id:string)=>id)}.columnsTemplate('1fr 1fr 1fr').columnsGap(10).rowsGap(10).width('88%')
    Blank()
    if(!this.playing&&!this.gameOver){Button('开始游戏').fontSize(18).fontColor(Color.White)
      .backgroundColor('#FF6B6B').borderRadius(24).width('60%').height(48).onClick(()=>this.start()).margin({bottom:60})}
    if(this.gameOver){Column(){Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold);
      Text('得分：'+this.score.toString()).fontSize(16).fontColor('#FF6B6B').margin({top:4});
      if(this.score>=this.highScore){Text('🎉 新纪录！').fontSize(14).fontColor('#F0A500');}
      Button('再来一局').fontSize(16).fontColor(Color.White).backgroundColor('#FF6B6B').borderRadius(20).width('50%').height(40).margin({top:12}).onClick(()=>this.start());}
    .margin({bottom:50})}
  }.width('100%').height('100%').backgroundColor('#FFFAFA')}
}

// ==================== 贪吃蛇 ====================
@Component
export struct SnakeGame {
  @State snake: number[][] = [[7,7],[7,8],[7,9]]; @State food: number[] = [3,5];
  @State dir: string = 'UP'; @State score: number = 0;
  @State playing: boolean = false; @State over: boolean = false;
  private timer: number = -1; private gridSize: number = 15;
  private rows: string[] = ['0','1','2','3','4','5','6','7','8','9','10','11','12','13','14'];
  private cols: string[] = ['0','1','2','3','4','5','6','7','8','9','10','11','12','13','14'];
  @StorageProp('high_snake') highScore: number = 0;
  onBack?: () => void;

  start(): void { this.snake=[[7,7],[7,8],[7,9]]; this.dir='UP'; this.score=0; this.playing=true; this.over=false;
    this.spawn(); this.timer=setInterval(()=>this.move(),200); }
  spawn(): void { let r=0,c=0; for(let t=0;t<100;t++){r=Math.floor(Math.random()*this.gridSize);c=Math.floor(Math.random()*this.gridSize);if(!this.onSnake(r,c))break;} this.food=[r,c]; }
  onSnake(r:number,c:number):boolean{for(let i=0;i<this.snake.length;i++){let s=this.snake[i];if(s[0]===r&&s[1]===c)return true;}return false;}
  move(): void {let h=this.snake[0];let nh=[h[0],h[1]];
    if(this.dir==='UP')nh[0]--;if(this.dir==='DOWN')nh[0]++;if(this.dir==='LEFT')nh[1]--;if(this.dir==='RIGHT')nh[1]++;
    if(nh[0]<0||nh[1]<0||nh[0]>=this.gridSize||nh[1]>=this.gridSize||this.onSnake(nh[0],nh[1])){this.die();return;}
    let ns=[nh];for(let i=0;i<this.snake.length-1;i++)ns.push(this.snake[i]);
    if(nh[0]===this.food[0]&&nh[1]===this.food[1]){ns.push(this.snake[this.snake.length-1]);this.score+=10;this.spawn();}
    this.snake=ns;}
  die(): void {this.playing=false;this.over=true;clearInterval(this.timer);
    if(this.score>this.highScore){AppStorage.setOrCreate<number>('high_snake',this.score);this.highScore=this.score;}}
  handleKey(k:string): void {if(!this.playing)return;if(k==='UP'&&this.dir!=='DOWN')this.dir='UP';if(k==='DOWN'&&this.dir!=='UP')this.dir='DOWN';if(k==='LEFT'&&this.dir!=='RIGHT')this.dir='LEFT';if(k==='RIGHT'&&this.dir!=='LEFT')this.dir='RIGHT';}
  aboutToDisappear(): void {clearInterval(this.timer);}

  build(){Column(){
    Row(){Text('←').fontSize(24).onClick(()=>{this.die();if(this.onBack)this.onBack();})Blank()
      Text('🐍 贪吃蛇').fontSize(18).fontWeight(FontWeight.Bold);Blank();Text('←').fontSize(24).fontColor(Color.Transparent)}
    .width('100%').padding(14)
    Row(){Text('得分：'+this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
      Blank();Text('🏆'+this.highScore.toString()).fontSize(13).fontColor('#F0A500')}.width('88%').margin({bottom:8})
    Column(){ForEach(this.rows,(r:string,ri:number)=>{Row(){ForEach(this.cols,(c:string,ci:number)=>{
      Text(this.snake.length>0&&this.snake[0][0]===ri&&this.snake[0][1]===ci?'🟢':(this.onSnake(ri,ci)?'🟩':(this.food[0]===ri&&this.food[1]===ci?'🍎':'·')))
        .fontSize((this.snake.length>0&&this.snake[0][0]===ri&&this.snake[0][1]===ci)||(this.food[0]===ri&&this.food[1]===ci)?14:8)
        .width(20).height(20).textAlign(TextAlign.Center)
    },(c:string)=>c)}},(r:string)=>r)}.padding(4).backgroundColor('#E8F5E9').borderRadius(8)
    Blank()
    if(this.playing){Column(){Row(){this.Btn('⬆️','UP')}Row(){this.Btn('⬅️','LEFT');Text('   ').fontSize(24);this.Btn('➡️','RIGHT')}Row(){this.Btn('⬇️','DOWN')}}.margin({bottom:30})}
    if(!this.playing&&!this.over){Button('开始游戏').fontSize(18).fontColor(Color.White).backgroundColor('#4ECDC4').borderRadius(24).width('60%').height(48).onClick(()=>this.start()).margin({bottom:60})}
    if(this.over){Column(){Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold);Text('得分：'+this.score.toString()).fontSize(16).fontColor('#4ECDC4').margin({top:4})
      if(this.score>=this.highScore){Text('🎉 新纪录！').fontSize(14).fontColor('#F0A500')}
      Button('再来一局').fontSize(16).fontColor(Color.White).backgroundColor('#4ECDC4').borderRadius(20).width('50%').height(40).margin({top:12}).onClick(()=>this.start())}.margin({bottom:50})}
  }.width('100%').height('100%').backgroundColor('#FAFFFA')}

  @Builder Btn(l:string,k:string){Text(l).fontSize(32).width(60).height(56).backgroundColor('#E0F0E0').borderRadius(12).textAlign(TextAlign.Center).onClick(()=>this.handleKey(k))}
}

// ==================== 老虎机 ====================
@Component
export struct SlotMachine {
  @State reels: string[] = ['🍒','🍒','🍒']; @State spinning: boolean = false;
  @State score: number = 100; @State msg: string = '点击旋转开始！';
  private icons: string[] = ['🍒','🍋','🍇','🍊','🍉','⭐','💎','7️⃣'];
  private anim: number = -1;
  @StorageProp('high_slot') highScore: number = 0;
  onBack?: () => void;

  spin(): void { if(this.spinning||this.score<10)return; this.spinning=true; this.score-=10; this.msg='旋转中…';
    let cnt=0; this.anim=setInterval(()=>{this.reels=[this.rnd(),this.rnd(),this.rnd()];cnt++;
    if(cnt>=12){clearInterval(this.anim);this.stopSpin();}},120); }
  rnd():string{return this.icons[Math.floor(Math.random()*this.icons.length)];}
  stopSpin(): void {this.spinning=false;
    if(this.reels[0]===this.reels[1]&&this.reels[1]===this.reels[2]){let win=this.reels[0]==='7️⃣'?200:this.reels[0]==='💎'?150:this.reels[0]==='⭐'?100:50;
      this.score+=win;this.msg='🎉 中奖！+'+win.toString();}
    else if(this.reels[0]===this.reels[1]||this.reels[1]===this.reels[2]||this.reels[0]===this.reels[2]){this.score+=20;this.msg='👍 小奖 +20';}
    else{this.msg='再试一次！';}
    if(this.score>this.highScore){AppStorage.setOrCreate<number>('high_slot',this.score);this.highScore=this.score;}}

  aboutToDisappear(){clearInterval(this.anim);}

  build(){Column(){
    Row(){Text('←').fontSize(24).onClick(()=>{if(this.onBack)this.onBack();})Blank()
      Text('🎰 老虎机').fontSize(18).fontWeight(FontWeight.Bold);Blank();Text('←').fontSize(24).fontColor(Color.Transparent)}
    .width('100%').padding(14)
    Row(){Text('💰金币：'+this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
      Blank();Text('🏆'+this.highScore.toString()).fontSize(13).fontColor('#F0A500')}.width('88%').margin({bottom:16})
    Column(){Text(this.msg).fontSize(14).fontColor('#F0A500').margin({bottom:16})}.width('100%').alignItems(HorizontalAlign.Center)
    Row(){ForEach(this.reels,(r:string)=>{Text(r).fontSize(56).width(80).height(100).backgroundColor('#FFF8E1').borderRadius(12).textAlign(TextAlign.Center).margin({left:6,right:6})},(r:string,i:number)=>r+i.toString())}
    .width('100%').justifyContent(FlexAlign.Center).margin({bottom:24})
    Row(){Button(this.spinning?'...':'🎰 旋转 (消耗10金币)').fontSize(16).fontColor(Color.White)
      .backgroundColor(this.spinning||this.score<10?'#CCC':'#F0A500').borderRadius(24).height(48).padding({left:24,right:24})
      .enabled(!this.spinning&&this.score>=10).onClick(()=>this.spin())}
    .width('100%').justifyContent(FlexAlign.Center)
    Blank()
    Row(){Text('🍒x3=+50 | ⭐x3=+100 | 💎x3=+150 | 7️⃣x3=+200').fontSize(11).fontColor('#999')}.margin({bottom:30})
  }.width('100%').height('100%').backgroundColor('#FFFDF5')}
}

// ==================== 记忆翻牌 ====================
@Component
export struct MemoryMatch {
  @State cards: string[] = []; @State revealed: boolean[] = []; @State matched: boolean[] = [];
  @State first: number = -1; @State moves: number = 0; @State pairs: number = 0;
  @State playing: boolean = false; @State won: boolean = false;
  private emojis: string[] = ['🍎','🍊','🍋','🍇','🍉','🍒','🥝','🍑'];
  private totalPairs: number = 8;
  @StorageProp('high_memory') highScore: number = 0;
  onBack?: () => void;

  start() {
    let deck: string[] = []; for(let e of this.emojis){deck.push(e);deck.push(e);}
    for(let i=deck.length-1;i>0;i--){let j=Math.floor(Math.random()*(i+1));let t=deck[i];deck[i]=deck[j];deck[j]=t;}
    this.cards=deck; this.revealed=[]; this.matched=[];
    for(let k=0;k<16;k++){this.revealed.push(false);this.matched.push(false);}
    this.first=-1; this.moves=0; this.pairs=0; this.playing=true; this.won=false;
  }

  flip(i:number){
    if(!this.playing||this.revealed[i]||this.matched[i])return;
    this.revealed[i]=true; this.revealed=[...this.revealed];
    if(this.first===-1){this.first=i;return;}
    this.moves++;
    if(this.cards[i]===this.cards[this.first]){
      this.matched[i]=true; this.matched[this.first]=true; this.matched=[...this.matched];
      this.pairs++; this.first=-1;
      if(this.pairs>=this.totalPairs){this.playing=false;this.won=true;
        let bonus=Math.max(0,200-this.moves*5);
        if(bonus>this.highScore){AppStorage.setOrCreate<number>('high_memory',bonus);this.highScore=bonus;}}
    }else{
      let prev=this.first; this.first=-1;
      setTimeout(()=>{this.revealed[i]=false;this.revealed[prev]=false;this.revealed=[...this.revealed];},600);
    }
  }

  build(){Column(){
    Row(){Text('←').fontSize(24).onClick(()=>{if(this.onBack)this.onBack();})Blank()
      Text('🃏 记忆翻牌').fontSize(18).fontWeight(FontWeight.Bold);Blank();Text('←').fontSize(24).fontColor(Color.Transparent)}
    .width('100%').padding(14)
    Row(){Text('步数：'+this.moves.toString()).fontSize(14).fontWeight(FontWeight.Bold)
      Blank();Text('🏆'+this.highScore.toString()).fontSize(13).fontColor('#F0A500')}.width('88%').margin({bottom:12})
    Grid(){ForEach(this.cards,(c:string,i:number)=>{GridItem(){
      Column(){Text(this.revealed[i]||this.matched[i]?c:'❓').fontSize(32)}
      .width('100%').height(68).backgroundColor(this.matched[i]?'#E8F5E9':(this.revealed[i]?'#FFF9C4':'#F0E6F6'))
      .borderRadius(10).justifyContent(FlexAlign.Center).onClick(()=>this.flip(i))
    }},(c:string,i:number)=>i.toString())}
    .columnsTemplate('1fr 1fr 1fr 1fr').columnsGap(8).rowsGap(8).width('92%')
    Blank()
    if(!this.playing&&!this.won){Button('开始游戏').fontSize(18).fontColor(Color.White)
      .backgroundColor('#BB8FCE').borderRadius(24).width('60%').height(48).onClick(()=>this.start()).margin({bottom:60})}
    if(this.won){Column(){Text('🎉 全部找到！').fontSize(20).fontWeight(FontWeight.Bold)
      Text('用了'+this.moves.toString()+'步').fontSize(16).fontColor('#BB8FCE').margin({top:4})
      Text('得分：'+(200-this.moves*5).toString()).fontSize(14).fontColor('#F0A500')
      Button('再来一局').fontSize(16).fontColor(Color.White).backgroundColor('#BB8FCE').borderRadius(20).width('50%').height(40).margin({top:12}).onClick(()=>this.start())}.margin({bottom:50})}
  }.width('100%').height('100%').backgroundColor('#FEFAFE')}
}

// ==================== 乒乓球 ====================
@Component
export struct PongGame {
  @State ballX: number = 150; @State ballY: number = 200;
  @State paddleY: number = 300; @State aiY: number = 300;
  @State playerScore: number = 0; @State aiScore: number = 0;
  @State playing: boolean = false; @State over: boolean = false; @State msg: string = '';
  private bx: number = 2; private by: number = 3; private timer: number = -1;
  private canvasW: number = 320; private canvasH: number = 520;
  @StorageProp('high_pong') highScore: number = 0;
  onBack?: () => void;

  start(){this.playerScore=0;this.aiScore=0;this.ballX=150;this.ballY=200;this.paddleY=300;this.aiY=300;
    this.bx=3;this.by=2;this.playing=true;this.over=false;this.msg='';
    this.timer=setInterval(()=>this.tick(),30);}
  tick(){
    this.ballX+=this.bx;this.ballY+=this.by;
    if(this.ballY<=0||this.ballY>=this.canvasH)this.by=-this.by;
    if(this.ballX<=30&&this.ballY>=this.paddleY&&this.ballY<=this.paddleY+80){this.bx=-this.bx;this.ballX=35;}
    if(this.ballX>=this.canvasW-30&&this.ballY>=this.aiY&&this.ballY<=this.aiY+80){this.bx=-this.bx;this.ballX=this.canvasW-35;}
    if(this.ballX<0){this.aiScore++;this.resetBall();}
    if(this.ballX>this.canvasW){this.playerScore++;this.resetBall();}
    if(this.playerScore>=5||this.aiScore>=5){this.playing=false;this.over=true;clearInterval(this.timer);
      if(this.playerScore>this.aiScore&&this.playerScore>this.highScore){AppStorage.setOrCreate<number>('high_pong',this.playerScore);this.highScore=this.playerScore;}
      this.msg=this.playerScore>this.aiScore?'🎉 你赢了！':'😢 AI赢了！';}
    // AI移动
    let target=this.ballY-40; this.aiY+=(target-this.aiY)*0.08;
  }
  resetBall(){this.ballX=150;this.ballY=200;this.bx=(Math.random()>0.5?3:-3);this.by=(Math.random()>0.5?2:-2);}
  movePaddle(y:number){this.paddleY=y-40;if(this.paddleY<0)this.paddleY=0;if(this.paddleY>this.canvasH-80)this.paddleY=this.canvasH-80;}
  aboutToDisappear(){clearInterval(this.timer);}

  build(){Column(){
    Row(){Text('←').fontSize(24).onClick(()=>{clearInterval(this.timer);if(this.onBack)this.onBack();})Blank()
      Text('🏓 乒乓球').fontSize(18).fontWeight(FontWeight.Bold);Blank();Text('←').fontSize(24).fontColor(Color.Transparent)}
    .width('100%').padding(14)
    Row(){Text('你：'+this.playerScore.toString()).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FF6B6B')
      Blank();Text('🏆'+this.highScore.toString()).fontSize(13).fontColor('#F0A500')
      Blank();Text('AI：'+this.aiScore.toString()).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#4ECDC4')}
    .width('88%').margin({bottom:12})
    Stack(){
      // 球
      Text('🏓').fontSize(24).position({x:this.ballX,y:this.ballY})
      // 玩家挡板
      Column().width(8).height(80).backgroundColor('#FF6B6B').borderRadius(4).position({x:20,y:this.paddleY})
      // AI挡板
      Column().width(8).height(80).backgroundColor('#4ECDC4').borderRadius(4).position({x:this.canvasW-28,y:this.aiY})
    }
    .width(this.canvasW).height(this.canvasH).backgroundColor('#1a1a2e').borderRadius(12)
    .onTouch((e:TouchEvent)=>{if(e.touches.length>0){this.movePaddle(e.touches[0].y-100);}})
    Blank()
    if(this.over){Column(){Text(this.msg).fontSize(20).fontWeight(FontWeight.Bold)
      Text('你 '+this.playerScore.toString()+' : '+this.aiScore.toString()+' AI').fontSize(16).fontColor('#666').margin({top:4})
      Button('再来一局').fontSize(16).fontColor(Color.White).backgroundColor('#07C160').borderRadius(20).width('50%').height(40).margin({top:12}).onClick(()=>this.start())}.margin({bottom:50})}
    if(!this.playing&&!this.over){Button('开始游戏').fontSize(18).fontColor(Color.White)
      .backgroundColor('#07C160').borderRadius(24).width('60%').height(48).onClick(()=>this.start()).margin({bottom:60})}
  }.width('100%').height('100%').backgroundColor('#F5F5F5')}
}

// ==================== 俄罗斯方块 ====================
@Component
export struct TetrisGame {
  @State grid: number[][] = []; @State piece: number[][] = [];
  @State pieceCol: number = 3; @State pieceRow: number = 0;
  @State score: number = 0; @State playing: boolean = false; @State over: boolean = false;
  private timer: number = -1; private cols: number = 10; private rows: number = 18;
  private shapes: number[][][] = [[[1,1,1,1]],[[1,1],[1,1]],[[0,1,0],[1,1,1]],[[1,0,0],[1,1,1]],[[0,0,1],[1,1,1]],[[1,1,0],[0,1,1]],[[0,1,1],[1,1,0]]];
  @StorageProp('high_tetris') highScore: number = 0;
  onBack?: () => void;

  start(){
    this.grid=[]; for(let r=0;r<this.rows;r++){let row:number[]=[];for(let c=0;c<this.cols;c++)row.push(0);this.grid.push(row);}
    this.score=0; this.playing=true; this.over=false; this.spawnPiece(); this.timer=setInterval(()=>this.down(),600); }
  spawnPiece(){let s=this.shapes[Math.floor(Math.random()*this.shapes.length)]; this.piece=s; this.pieceRow=0; this.pieceCol=3;
    if(this.collide()){this.playing=false;this.over=true;clearInterval(this.timer);
      if(this.score>this.highScore){AppStorage.setOrCreate<number>('high_tetris',this.score);this.highScore=this.score;}} }
  collide():boolean{for(let r=0;r<this.piece.length;r++)for(let c=0;c<this.piece[r].length;c++)
    if(this.piece[r][c]){let gr=this.pieceRow+r;let gc=this.pieceCol+c;if(gr<0||gr>=this.rows||gc<0||gc>=this.cols||this.grid[gr][gc])return true;}return false;}
  lock(){for(let r=0;r<this.piece.length;r++)for(let c=0;c<this.piece[r].length;c++)
    if(this.piece[r][c])this.grid[this.pieceRow+r][this.pieceCol+c]=1;
    this.clearLines();this.spawnPiece();}
  clearLines(){let cleared=0;
    for(let r=this.rows-1;r>=0;r--){if(this.grid[r].every((v:number)=>v===1)){this.grid.splice(r,1);let nr:number[]=[];for(let c=0;c<this.cols;c++)nr.push(0);this.grid.unshift(nr);cleared++;r++;}}
    if(cleared>0){this.score+=cleared*100;}}
  down(){this.pieceRow++;if(this.collide()){this.pieceRow--;this.lock();}}
  rot(){let rot:number[][]=[];for(let c=0;c<this.piece[0].length;c++){let nr:number[]=[];for(let r=this.piece.length-1;r>=0;r--)nr.push(this.piece[r][c]);rot.push(nr);}
    let old=this.piece;this.piece=rot;if(this.collide())this.piece=old;}
  left(){this.pieceCol--;if(this.collide())this.pieceCol++;}
  right(){this.pieceCol++;if(this.collide())this.pieceCol--;}
  drop(){while(!this.collide())this.pieceRow++;this.pieceRow--;this.lock();}
  aboutToDisappear(){clearInterval(this.timer);}

  cellColor(v:number, r:number, c:number):string{
    if(v)return '#45B7D1';
    for(let pr=0;pr<this.piece.length;pr++)for(let pc=0;pc<this.piece[pr].length;pc++)
      if(this.piece[pr][pc]&&this.pieceRow+pr===r&&this.pieceCol+pc===c)return '#FF6B6B';
    return '#1a1a2e';
  }

  build(){Column(){
    Row(){Text('←').fontSize(24).onClick(()=>{clearInterval(this.timer);if(this.onBack)this.onBack();})Blank()
      Text('🧱 俄罗斯方块').fontSize(18).fontWeight(FontWeight.Bold);Blank();Text('←').fontSize(24).fontColor(Color.Transparent)}
    .width('100%').padding(14)
    Row(){Text('得分：'+this.score.toString()).fontSize(16).fontWeight(FontWeight.Bold)
      Blank();Text('🏆'+this.highScore.toString()).fontSize(13).fontColor('#F0A500')}.width('88%').margin({bottom:8})
    Column(){ForEach(this.grid,(row:number[],ri:number)=>{Row(){ForEach(row,(cell:number,ci:number)=>{
      Column().width(18).height(18).margin(1).backgroundColor(this.cellColor(cell,ri,ci)).borderRadius(2)
    },(cell:number,ci:number)=>ci.toString())}},(row:number[],ri:number)=>ri.toString())}
    .padding(4).backgroundColor('#0a0a1e').borderRadius(8)
    Blank()
    if(this.playing){Column(){Row(){this.TBtn('⬅️','L');this.TBtn('⬇️','D');this.TBtn('➡️','R');this.TBtn('🔄','ROT');this.TBtn('⏬','DROP')}}.margin({bottom:20})}
    if(!this.playing&&!this.over){Button('开始游戏').fontSize(18).fontColor(Color.White)
      .backgroundColor('#45B7D1').borderRadius(24).width('60%').height(48).onClick(()=>this.start()).margin({bottom:60})}
    if(this.over){Column(){Text('游戏结束！').fontSize(20).fontWeight(FontWeight.Bold)
      Text('得分：'+this.score.toString()).fontSize(16).fontColor('#45B7D1').margin({top:4})
      if(this.score>=this.highScore){Text('🎉 新纪录！').fontSize(14).fontColor('#F0A500')}
      Button('再来一局').fontSize(16).fontColor(Color.White).backgroundColor('#45B7D1').borderRadius(20).width('50%').height(40).margin({top:12}).onClick(()=>this.start())}.margin({bottom:50})}
  }.width('100%').height('100%').backgroundColor('#F0F8FA')}

  @Builder TBtn(l:string,a:string){Text(l).fontSize(24).width(50).height(44).backgroundColor('#E0F0F8').borderRadius(10)
    .textAlign(TextAlign.Center).margin({left:4,right:4})
    .onClick(()=>{if(a==='L')this.left();if(a==='R')this.right();if(a==='D')this.down();if(a==='ROT')this.rot();if(a==='DROP')this.drop();})}
}
