/**
 * 塔罗牌抽牌交互组件 — 12张牌面朝下，用户凭直觉点击3张翻牌。
 *
 * 使用方式：
 *   TarotDrawView({ onComplete: (cards) => { ... } })
 */

import { TarotCard, DrawnCard, TarotService } from '../../service/TarotService';

// 单张展示用的卡片
interface DisplayCard {
  card: TarotCard;
  isReversed: boolean;
  isSelected: boolean;   // 是否被选中
  isRevealed: boolean;   // 是否已翻开
}

@Component
export struct TarotDrawView {
  @State displayCards: DisplayCard[] = [];
  @State selectedCount: number = 0;
  @State phase: string = 'drawing'; // 'drawing' | 'complete'
  @State drawResult: DrawnCard[] = [];

  onComplete?: (cards: DrawnCard[]) => void;

  aboutToAppear() {
    this.initCards();
  }

  initCards() {
    // 从牌库中随机抽12张候选牌
    let shuffled = TarotService.getInstance().fisherYatesShuffle(
      TarotService.getInstance().getAllCards()
    );
    let candidates = shuffled.slice(0, 12);

    this.displayCards = [];
    for (let c of candidates) {
      let dc: DisplayCard = {
        card: c,
        isReversed: Math.random() < 0.5,
        isSelected: false,
        isRevealed: false
      };
      this.displayCards.push(dc);
    }
    this.selectedCount = 0;
    this.phase = 'drawing';
    this.drawResult = [];
  }

  /**
   * 处理点击卡片
   */
  handleCardTap(index: number) {
    if (this.phase !== 'drawing') return;
    let dc = this.displayCards[index];
    if (dc.isSelected) return; // 已选中

    // 翻牌
    dc.isSelected = true;
    dc.isRevealed = true;
    this.selectedCount++;
    this.displayCards[index] = dc; // 触发状态更新

    // 记录抽牌结果
    let drawn: DrawnCard = {
      id: dc.card.id,
      name: dc.card.name,
      name_cn: dc.card.name_cn,
      image_url: dc.card.image_url,
      type: dc.card.type,
      suit: dc.card.suit,
      isReversed: dc.isReversed,
      position: ['过去', '现在', '未来'][this.drawResult.length] || '第' + (this.drawResult.length + 1).toString() + '张'
    };
    this.drawResult.push(drawn);

    // 选满3张，延迟后完成
    if (this.selectedCount >= 3) {
      this.phase = 'complete';
      setTimeout(() => {
        if (this.onComplete) {
          this.onComplete(this.drawResult);
        }
      }, 800);
    }
  }

  build() {
    // 全屏遮罩
    Column() {
      // 标题区
      Column() {
        Text('🔮 凭直觉选择3张牌')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#e8d5f5')
          .margin({ bottom: 4 })

        Text(this.phase === 'drawing'
          ? '已选 ' + this.selectedCount.toString() + ' / 3 张'
          : '✨ 命运已揭示 ✨')
          .fontSize(15)
          .fontColor(this.selectedCount >= 3 ? '#f0c040' : '#b8a0cc')
          .animation({ duration: 300 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 60, bottom: 24 })

      // 牌阵网格 (4列 × 3行)
      Grid() {
        ForEach(this.displayCards, (dc: DisplayCard, index: number) => {
          GridItem() {
            this.CardItem(dc, index)
          }
        }, (dc: DisplayCard, index: number) => dc.card.id.toString())
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(10)
      .width('92%')
      .layoutWeight(1)
      .padding({ left: 8, right: 8 })

      // 底部提示
      if (this.phase === 'drawing') {
        Text('深呼吸，跟随你的直觉…')
          .fontSize(13)
          .fontColor('#9078a8')
          .margin({ bottom: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(10, 5, 30, 0.95)')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#1a0a30', 0], ['#0d0620', 0.5], ['#0a0518', 1]]
    })
  }

  /**
   * 单张卡片组件
   */
  @Builder
  CardItem(dc: DisplayCard, index: number) {
    Column() {
      if (dc.isRevealed) {
        // === 已翻开：显示卡面 ===
        Stack() {
          // 卡图
          Image($rawfile('tarot/' + dc.card.image_url.split('/').pop()!.toLowerCase()))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .borderRadius(8)

          // 正逆位标签
          Column() {
            Text(dc.isReversed ? '逆位' : '正位')
              .fontSize(10)
              .fontColor(Color.White)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(dc.isReversed ? '#884444' : '#448866')
              .borderRadius(4)
          }
          .position({ x: 4, y: 4 })

          // 选中标记
          Column() {
            Text('✦')
              .fontSize(16)
              .fontColor('#f0c040')
          }
          .position({ x: '85%', y: 4 })
        }
        .width('100%')
        .aspectRatio(0.68)
        .borderRadius(8)
        .shadow({ radius: 8, color: dc.isSelected ? '#f0c04066' : '#00000033', offsetX: 0, offsetY: 2 })
      } else {
        // === 未翻开：显示牌背 ===
        Column() {
          Text('✦')
            .fontSize(22)
            .fontColor('#c8a8e8')
            .opacity(0.7)

          Text('?')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#b090d0')
            .margin({ top: 8, bottom: 8 })

          Text('✦')
            .fontSize(14)
            .fontColor('#c8a8e8')
            .opacity(0.5)
        }
        .width('100%')
        .aspectRatio(0.68)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .borderRadius(8)
        .border({ width: 1.5, color: '#6040a0' })
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#2a1050', 0], ['#1a0840', 0.5], ['#150838', 1]]
        })
        .shadow({ radius: 6, color: '#40208044', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          this.handleCardTap(index);
        })
      }
    }
    .width('100%')
    .onClick(() => {
      if (!dc.isRevealed) {
        this.handleCardTap(index);
      }
    })
    .animation({ duration: 350, curve: Curve.EaseOut })
  }
}
