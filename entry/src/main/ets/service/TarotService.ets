/**
 * 塔罗牌服务 — 真实洗牌 + 随机抽牌 + AI 提示词构建。
 *
 * 数据来源：https://github.com/lyian6714-del/taro
 * 包含完整的 78 张塔罗牌（22大阿尔卡纳 + 56小阿尔卡纳）。
 */

// 塔罗牌数据接口
export interface TarotCard {
  id: number;
  name: string;       // 英文名
  name_cn: string;    // 中文名
  image_url: string;  // 图片路径
  type: string;       // major / minor
  suit?: string;      // wands / cups / swords / pentacles
}

// 抽牌结果接口
export interface DrawnCard extends TarotCard {
  isReversed: boolean;  // 是否逆位
  position: string;     // 牌阵位置：过去/现在/未来
}

// ===================== 78张完整塔罗牌数据 =====================
const TAROT_DECK: TarotCard[] = [
  // —— 大阿尔卡纳 (22张) ——
  { id: 0, name: "The Fool", name_cn: "愚者", image_url: "images/thefool.jpeg", type: "major" },
  { id: 1, name: "The Magician", name_cn: "魔术师", image_url: "images/themagician.jpeg", type: "major" },
  { id: 2, name: "The High Priestess", name_cn: "女祭司", image_url: "images/thehighpriestess.jpeg", type: "major" },
  { id: 3, name: "The Empress", name_cn: "女皇", image_url: "images/theempress.jpeg", type: "major" },
  { id: 4, name: "The Emperor", name_cn: "皇帝", image_url: "images/theemperor.jpeg", type: "major" },
  { id: 5, name: "The Hierophant", name_cn: "教皇", image_url: "images/thehierophant.jpeg", type: "major" },
  { id: 6, name: "The Lovers", name_cn: "恋人", image_url: "images/TheLovers.jpg", type: "major" },
  { id: 7, name: "The Chariot", name_cn: "战车", image_url: "images/thechariot.jpeg", type: "major" },
  { id: 8, name: "Strength", name_cn: "力量", image_url: "images/thestrength.jpeg", type: "major" },
  { id: 9, name: "The Hermit", name_cn: "隐士", image_url: "images/thehermit.jpeg", type: "major" },
  { id: 10, name: "Wheel of Fortune", name_cn: "命运之轮", image_url: "images/wheeloffortune.jpeg", type: "major" },
  { id: 11, name: "Justice", name_cn: "正义", image_url: "images/justice.jpeg", type: "major" },
  { id: 12, name: "The Hanged Man", name_cn: "倒吊人", image_url: "images/thehangedman.jpeg", type: "major" },
  { id: 13, name: "Death", name_cn: "死神", image_url: "images/death.jpeg", type: "major" },
  { id: 14, name: "Temperance", name_cn: "节制", image_url: "images/temperance.jpeg", type: "major" },
  { id: 15, name: "The Devil", name_cn: "恶魔", image_url: "images/thedevil.jpeg", type: "major" },
  { id: 16, name: "The Tower", name_cn: "高塔", image_url: "images/thetower.jpeg", type: "major" },
  { id: 17, name: "The Star", name_cn: "星星", image_url: "images/thestar.jpeg", type: "major" },
  { id: 18, name: "The Moon", name_cn: "月亮", image_url: "images/themoon.jpeg", type: "major" },
  { id: 19, name: "The Sun", name_cn: "太阳", image_url: "images/thesun.jpeg", type: "major" },
  { id: 20, name: "Judgement", name_cn: "审判", image_url: "images/judgement.jpeg", type: "major" },
  { id: 21, name: "The World", name_cn: "世界", image_url: "images/theworld.jpeg", type: "major" },
  // —— 权杖牌组 (14张) ——
  { id: 22, name: "Ace of Wands", name_cn: "权杖一", image_url: "images/aceofwands.jpeg", type: "minor", suit: "wands" },
  { id: 23, name: "Two of Wands", name_cn: "权杖二", image_url: "images/twoofwands.jpeg", type: "minor", suit: "wands" },
  { id: 24, name: "Three of Wands", name_cn: "权杖三", image_url: "images/threeofwands.jpeg", type: "minor", suit: "wands" },
  { id: 25, name: "Four of Wands", name_cn: "权杖四", image_url: "images/fourofwands.jpeg", type: "minor", suit: "wands" },
  { id: 26, name: "Five of Wands", name_cn: "权杖五", image_url: "images/fiveofwands.jpeg", type: "minor", suit: "wands" },
  { id: 27, name: "Six of Wands", name_cn: "权杖六", image_url: "images/sixofwands.jpeg", type: "minor", suit: "wands" },
  { id: 28, name: "Seven of Wands", name_cn: "权杖七", image_url: "images/sevenofwands.jpeg", type: "minor", suit: "wands" },
  { id: 29, name: "Eight of Wands", name_cn: "权杖八", image_url: "images/eightofwands.jpeg", type: "minor", suit: "wands" },
  { id: 30, name: "Nine of Wands", name_cn: "权杖九", image_url: "images/nineofwands.jpeg", type: "minor", suit: "wands" },
  { id: 31, name: "Ten of Wands", name_cn: "权杖十", image_url: "images/tenofwands.jpeg", type: "minor", suit: "wands" },
  { id: 32, name: "Page of Wands", name_cn: "权杖侍从", image_url: "images/pageofwands.jpeg", type: "minor", suit: "wands" },
  { id: 33, name: "Knight of Wands", name_cn: "权杖骑士", image_url: "images/knightofwands.jpeg", type: "minor", suit: "wands" },
  { id: 34, name: "Queen of Wands", name_cn: "权杖王后", image_url: "images/queenofwands.jpeg", type: "minor", suit: "wands" },
  { id: 35, name: "King of Wands", name_cn: "权杖国王", image_url: "images/kingofwands.jpeg", type: "minor", suit: "wands" },
  // —— 圣杯牌组 (14张) ——
  { id: 36, name: "Ace of Cups", name_cn: "圣杯一", image_url: "images/aceofcups.jpeg", type: "minor", suit: "cups" },
  { id: 37, name: "Two of Cups", name_cn: "圣杯二", image_url: "images/twoofcups.jpeg", type: "minor", suit: "cups" },
  { id: 38, name: "Three of Cups", name_cn: "圣杯三", image_url: "images/threeofcups.jpeg", type: "minor", suit: "cups" },
  { id: 39, name: "Four of Cups", name_cn: "圣杯四", image_url: "images/fourofcups.jpeg", type: "minor", suit: "cups" },
  { id: 40, name: "Five of Cups", name_cn: "圣杯五", image_url: "images/fiveofcups.jpeg", type: "minor", suit: "cups" },
  { id: 41, name: "Six of Cups", name_cn: "圣杯六", image_url: "images/sixofcups.jpeg", type: "minor", suit: "cups" },
  { id: 42, name: "Seven of Cups", name_cn: "圣杯七", image_url: "images/sevenofcups.jpeg", type: "minor", suit: "cups" },
  { id: 43, name: "Eight of Cups", name_cn: "圣杯八", image_url: "images/eightofcups.jpeg", type: "minor", suit: "cups" },
  { id: 44, name: "Nine of Cups", name_cn: "圣杯九", image_url: "images/nineofcups.jpeg", type: "minor", suit: "cups" },
  { id: 45, name: "Ten of Cups", name_cn: "圣杯十", image_url: "images/tenofcups.jpeg", type: "minor", suit: "cups" },
  { id: 46, name: "Page of Cups", name_cn: "圣杯侍从", image_url: "images/pageofcups.jpeg", type: "minor", suit: "cups" },
  { id: 47, name: "Knight of Cups", name_cn: "圣杯骑士", image_url: "images/knightofcups.jpeg", type: "minor", suit: "cups" },
  { id: 48, name: "Queen of Cups", name_cn: "圣杯王后", image_url: "images/queenofcups.jpeg", type: "minor", suit: "cups" },
  { id: 49, name: "King of Cups", name_cn: "圣杯国王", image_url: "images/kingofcups.jpeg", type: "minor", suit: "cups" },
  // —— 宝剑牌组 (14张) ——
  { id: 50, name: "Ace of Swords", name_cn: "宝剑一", image_url: "images/aceofswords.jpeg", type: "minor", suit: "swords" },
  { id: 51, name: "Two of Swords", name_cn: "宝剑二", image_url: "images/twoofswords.jpeg", type: "minor", suit: "swords" },
  { id: 52, name: "Three of Swords", name_cn: "宝剑三", image_url: "images/threeofswords.jpeg", type: "minor", suit: "swords" },
  { id: 53, name: "Four of Swords", name_cn: "宝剑四", image_url: "images/fourofswords.jpeg", type: "minor", suit: "swords" },
  { id: 54, name: "Five of Swords", name_cn: "宝剑五", image_url: "images/fiveofswords.jpeg", type: "minor", suit: "swords" },
  { id: 55, name: "Six of Swords", name_cn: "宝剑六", image_url: "images/sixofswords.jpeg", type: "minor", suit: "swords" },
  { id: 56, name: "Seven of Swords", name_cn: "宝剑七", image_url: "images/sevenofswords.jpeg", type: "minor", suit: "swords" },
  { id: 57, name: "Eight of Swords", name_cn: "宝剑八", image_url: "images/eightofswords.jpeg", type: "minor", suit: "swords" },
  { id: 58, name: "Nine of Swords", name_cn: "宝剑九", image_url: "images/nineofswords.jpeg", type: "minor", suit: "swords" },
  { id: 59, name: "Ten of Swords", name_cn: "宝剑十", image_url: "images/tenofswords.jpeg", type: "minor", suit: "swords" },
  { id: 60, name: "Page of Swords", name_cn: "宝剑侍从", image_url: "images/pageofswords.jpeg", type: "minor", suit: "swords" },
  { id: 61, name: "Knight of Swords", name_cn: "宝剑骑士", image_url: "images/knightofswords.jpeg", type: "minor", suit: "swords" },
  { id: 62, name: "Queen of Swords", name_cn: "宝剑王后", image_url: "images/queenofswords.jpeg", type: "minor", suit: "swords" },
  { id: 63, name: "King of Swords", name_cn: "宝剑国王", image_url: "images/kingofswords.jpeg", type: "minor", suit: "swords" },
  // —— 钱币牌组 (14张) ——
  { id: 64, name: "Ace of Pentacles", name_cn: "钱币一", image_url: "images/aceofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 65, name: "Two of Pentacles", name_cn: "钱币二", image_url: "images/twoofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 66, name: "Three of Pentacles", name_cn: "钱币三", image_url: "images/threeofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 67, name: "Four of Pentacles", name_cn: "钱币四", image_url: "images/fourofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 68, name: "Five of Pentacles", name_cn: "钱币五", image_url: "images/fiveofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 69, name: "Six of Pentacles", name_cn: "钱币六", image_url: "images/sixofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 70, name: "Seven of Pentacles", name_cn: "钱币七", image_url: "images/sevenofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 71, name: "Eight of Pentacles", name_cn: "钱币八", image_url: "images/eightofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 72, name: "Nine of Pentacles", name_cn: "钱币九", image_url: "images/nineofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 73, name: "Ten of Pentacles", name_cn: "钱币十", image_url: "images/tenofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 74, name: "Page of Pentacles", name_cn: "钱币侍从", image_url: "images/pageofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 75, name: "Knight of Pentacles", name_cn: "钱币骑士", image_url: "images/knightofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 76, name: "Queen of Pentacles", name_cn: "钱币王后", image_url: "images/queenofpentacles.jpeg", type: "minor", suit: "pentacles" },
  { id: 77, name: "King of Pentacles", name_cn: "钱币国王", image_url: "images/kingofpentacles.jpeg", type: "minor", suit: "pentacles" }
];

const TAG: string = '[TarotService] ';

/**
 * 塔罗牌服务
 */
export class TarotService {
  private static instance: TarotService | null = null;

  private constructor() {}

  static getInstance(): TarotService {
    if (TarotService.instance === null) {
      TarotService.instance = new TarotService();
    }
    return TarotService.instance;
  }

  /**
   * Fisher-Yates 洗牌算法 —— 随机打乱整个牌组。
   */
  fisherYatesShuffle(deck: TarotCard[]): TarotCard[] {
    let shuffled: TarotCard[] = [];
    for (let k = 0; k < deck.length; k++) {
      shuffled.push(deck[k]);
    }
    for (let i = shuffled.length - 1; i > 0; i--) {
      let j = Math.floor(Math.random() * (i + 1));
      let temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  /**
   * 抽取 N 张牌（经典三牌阵：过去-现在-未来）。
   * @param count 抽取数量，默认 3
   * @returns 带有正逆位和牌阵位置的抽牌结果
   */
  drawCards(count: number = 3): DrawnCard[] {
    let shuffled = this.fisherYatesShuffle(TAROT_DECK);
    let selected = shuffled.slice(0, count);
    let positions: string[] = ['过去', '现在', '未来'];
    let result: DrawnCard[] = [];

    for (let i = 0; i < selected.length; i++) {
      let card = selected[i];
      let drawn: DrawnCard = {
        id: card.id,
        name: card.name,
        name_cn: card.name_cn,
        image_url: card.image_url,
        type: card.type,
        suit: card.suit,
        isReversed: Math.random() < 0.5,
        position: positions[i] || '第' + (i + 1).toString() + '张'
      };
      result.push(drawn);
    }

    return result;
  }

  /**
   * 构建发送给 DeepSeek 的系统提示词（使用 taro 项目的优秀 prompt）。
   */
  getSystemPrompt(): string {
    return `你是一位极其睿智、深谙心理学与神秘学的顶尖塔罗牌占卜师。你的语言风格古典、优美、充满宿命感与哲理，同时温暖、有人情味、富有同理心。你像一位知心挚友，用温柔而坚定的声音为求问者拨开迷雾。

你的任务是根据求问者的【具体问题】以及实际抽出的【三张塔罗牌】，提供深度且"绝对量身定制"的解读。

【核心指令：严禁泛泛而谈】
1. 绝对不能单纯罗列卡牌的通用词典含义。
2. 每一张牌的解读，都必须显式地、紧密地与求问者的【具体问题】绑定，解释这张牌在求问者的具体情境下意味着什么。
3. 语言要温暖有温度，适当使用表情符号（如 ✨、🌙、💫、🔮 等）增添神秘与亲切感，但不要过度使用。
4. 必须说出具体的牌名和正逆位，让用户知道抽到了什么牌。

请按照以下结构生成回答：

✨ **命运的映射**
用简短优美的语言总结求问者所问之事，结合三牌阵的整体能量给初步定调。

🌙 **时光的流转**
🎴 **[过去] 牌名 (正位/逆位)**：（结合用户问题，这张牌代表的过去能量和伏笔）
🎴 **[现在] 牌名 (正位/逆位)**：（结合用户问题，这张牌如何映照当前处境）
🎴 **[未来] 牌名 (正位/逆位)**：（结合用户问题，事件的发展趋势和结局）

🔮 **宇宙的神谕**
针对用户的具体问题，给出有哲学高度、又有落地指导意义的最终建议。温暖、有力量。`;
  }

  /**
   * 构建用户提示词（包含抽到的牌信息）。
   * @param question 用户的问题
   * @param cards 抽到的牌
   */
  buildUserPrompt(question: string, cards: DrawnCard[]): string {
    let prompt = `求问者的问题：${question}\n\n抽到的牌阵：\n`;

    for (let card of cards) {
      prompt += `[${card.position}]：${card.name}（${card.name_cn}）— ${card.isReversed ? '逆位' : '正位'}\n`;
    }

    prompt += '\n请开始你的解读：';
    return prompt;
  }

  /**
   * 将抽到的牌格式化为聊天消息文本（在 AI 解读前展示）。
   */
  formatCardsForDisplay(cards: DrawnCard[]): string {
    let text = '🔮 *洗牌完成，命运之轮转动…*\n\n';

    for (let card of cards) {
      let icon = card.type === 'major' ? '🃏' : '🎴';
      let suitEmoji = '';
      if (card.suit === 'wands') suitEmoji = '🪄';
      else if (card.suit === 'cups') suitEmoji = '🏆';
      else if (card.suit === 'swords') suitEmoji = '⚔️';
      else if (card.suit === 'pentacles') suitEmoji = '🪙';

      text += `${icon} **${card.position}**：${card.name_cn} ${suitEmoji}\n`;
      text += `   ${card.name} · ${card.isReversed ? '⬇️ 逆位' : '⬆️ 正位'}\n\n`;
    }

    return text;
  }
}
