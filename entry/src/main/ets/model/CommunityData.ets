/**
 * 社区数据模型 — 动态帖子 + 学习打卡。
 */

// 帖子
export interface CommunityPost {
  id: string;
  userName: string;
  userAvatar: string;  // emoji 头像
  content: string;
  topic: string;       // 话题标签
  topicColor: string;
  likeCount: number;
  commentCount: number;
  timeAgo: string;     // 如 "3分钟前"
  isLiked: boolean;
}

// 打卡用户
export interface CheckInUser {
  name: string;
  emoji: string;
  streak: number;      // 连续打卡天数
  rank: number;
}

// 模拟社区动态
export const communityPosts: CommunityPost[] = [
  {
    id: 'p1',
    userName: '代码诗人',
    userAvatar: '🧑‍💻',
    content: '用HarmonyOS NEXT写了一周的代码，终于把自定义组件搞明白了。ArkTS虽然限制多，但习惯了反而觉得很清晰。分享一个心得：@Builder 里面不能用 let，所有数据要提前放到组件状态里。',
    topic: '编程',
    topicColor: '#22A699',
    likeCount: 128,
    commentCount: 23,
    timeAgo: '5分钟前',
    isLiked: false
  },
  {
    id: 'p2',
    userName: '考研上岸中',
    userAvatar: '📚',
    content: '今天刷完了李永乐的线性代数第六章，做了30道题，错了5道。把错题整理了一下，发现主要卡在特征值和特征向量那块。有没有一起打卡的？互相监督！',
    topic: '学习打卡',
    topicColor: '#4A90D9',
    likeCount: 89,
    commentCount: 15,
    timeAgo: '18分钟前',
    isLiked: true
  },
  {
    id: 'p3',
    userName: '穿搭小能手',
    userAvatar: '👗',
    content: '最近发现了一个万能公式：白色衬衫 + 高腰阔腿裤 + 细腰带 = 秒变气质小姐姐。面试、约会、通勤都能穿。关键是衬衫要塞进去，腰线决定一切！',
    topic: '穿搭',
    topicColor: '#E8658A',
    likeCount: 256,
    commentCount: 42,
    timeAgo: '32分钟前',
    isLiked: false
  },
  {
    id: 'p4',
    userName: '神秘占星师',
    userAvatar: '🔮',
    content: '今天帮三位朋友抽了塔罗牌。第一位抽到"星星"正位——最近会有好消息。第二位"高塔"逆位，要注意人际关系中的误会。第三位太神奇了，三张全是圣杯牌组，感情运爆棚！',
    topic: '塔罗',
    topicColor: '#7B2D8E',
    likeCount: 67,
    commentCount: 9,
    timeAgo: '1小时前',
    isLiked: false
  },
  {
    id: 'p5',
    userName: '产品经理日记',
    userAvatar: '📋',
    content: '面试了5家公司，总结一下高频问题：1. 你怎么做需求优先级排序？2. 说一个你推动的最难的项目。3. 如何看待AI对产品经理的影响？建议大家提前准备STAR法则的回答模板，真的有用。',
    topic: '求职',
    topicColor: '#2C3E6B',
    likeCount: 312,
    commentCount: 56,
    timeAgo: '2小时前',
    isLiked: true
  },
  {
    id: 'p6',
    userName: '英语学习bot',
    userAvatar: '🌍',
    content: '今日双语金句："The only way to do great work is to love what you do." — Steve Jobs\n\n做伟大工作的唯一途径是热爱你所做的事。\n\n大家早安，今天也要加油呀 ✨',
    topic: '学习打卡',
    topicColor: '#4A90D9',
    likeCount: 445,
    commentCount: 38,
    timeAgo: '3小时前',
    isLiked: false
  },
  {
    id: 'p7',
    userName: '健身狂魔',
    userAvatar: '💪',
    content: '坚持健身第87天。分享一下今天的训练：俯卧撑100个 + 卷腹200个 + 跑步5公里。最大的感受不是身材变化，是精力变好了，上课不容易犯困。真的推荐大家试试运动。',
    topic: '生活',
    topicColor: '#E67E22',
    likeCount: 198,
    commentCount: 27,
    timeAgo: '4小时前',
    isLiked: false
  },
  {
    id: 'p8',
    userName: '读书笔记',
    userAvatar: '📖',
    content: '刚读完《认知觉醒》，一句话总结：焦虑的本质是"想同时做很多事又想立即看到效果"。破解方法很简单——一次只做一件事，先完成再完美。这本书推荐给所有大学生。',
    topic: '学习打卡',
    topicColor: '#4A90D9',
    likeCount: 534,
    commentCount: 89,
    timeAgo: '5小时前',
    isLiked: true
  }
];

// 话题列表
export interface Topic {
  name: string;
  color: string;
}

export const topics: Topic[] = [
  { name: '全部', color: '#333333' },
  { name: '学习打卡', color: '#4A90D9' },
  { name: '编程', color: '#22A699' },
  { name: '穿搭', color: '#E8658A' },
  { name: '塔罗', color: '#7B2D8E' },
  { name: '求职', color: '#2C3E6B' },
  { name: '生活', color: '#E67E22' }
];

// 模拟打卡排行
export const checkInRanking: CheckInUser[] = [
  { name: '考研上岸中', emoji: '📚', streak: 47, rank: 1 },
  { name: '健身狂魔', emoji: '💪', streak: 87, rank: 1 },
  { name: '代码诗人', emoji: '🧑‍💻', streak: 32, rank: 3 },
  { name: '英语学习bot', emoji: '🌍', streak: 28, rank: 4 },
  { name: '读书笔记', emoji: '📖', streak: 21, rank: 5 },
  { name: '产品经理日记', emoji: '📋', streak: 15, rank: 6 },
  { name: '穿搭小能手', emoji: '👗', streak: 12, rank: 7 },
  { name: '神秘占星师', emoji: '🔮', streak: 9, rank: 8 }
];
