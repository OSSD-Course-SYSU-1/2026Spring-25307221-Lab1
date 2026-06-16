/**
 * 社区数据模型 — AI朋友圈 + 心情日记 + 树洞 + 打卡。
 */

// 帖子
export interface CommunityPost {
  id: string;
  userName: string;
  userAvatar: string;
  content: string;
  likeCount: number;
  commentCount: number;
  timeAgo: string;
  isLiked: boolean;
}

// 心情选项
export interface MoodOption {
  emoji: string;
  label: string;
}

export const moodOptions: MoodOption[] = [
  { emoji: '😊', label: '开心' },
  { emoji: '😢', label: '难过' },
  { emoji: '😤', label: '生气' },
  { emoji: '😴', label: '疲惫' },
  { emoji: '🤩', label: '兴奋' },
  { emoji: '😰', label: '焦虑' },
  { emoji: '😌', label: '平静' },
  { emoji: '🥳', label: '超棒' }
];

// 心情记录
export interface MoodRecord {
  date: string;
  emoji: string;
  label: string;
}

// 树洞帖子
export interface TreeHolePost {
  id: string;
  content: string;
  mood: string;
  timeAgo: string;
  likeCount: number;
  isLiked: boolean;
}

// AI朋友（export 以消除 arkts-no-obj-literals-as-types）
export interface AIFriend {
  name: string;
  emoji: string;
  personality: string;
}

// 心情帖子条目
interface MoodPostEntry {
  friend: AIFriend;
  content: string;
}

const aiFriends: AIFriend[] = [
  { name: '代码诗人', emoji: '🧑‍💻', personality: '技术宅，喜欢分享编程心得' },
  { name: '考研上岸中', emoji: '📚', personality: '勤奋的考研党，每天打卡学习' },
  { name: '穿搭小能手', emoji: '👗', personality: '时尚达人，分享穿搭灵感' },
  { name: '咖啡与书', emoji: '☕', personality: '文艺青年，喜欢读书和思考' },
  { name: '健身狂魔', emoji: '💪', personality: '自律健身爱好者，充满正能量' },
  { name: '小太阳', emoji: '🌻', personality: '乐观开朗，总能看到事情好的一面' },
  { name: '深夜画师', emoji: '🎨', personality: '感性细腻，用画笔记录生活' },
  { name: '产品经理日记', emoji: '📋', personality: '职场新人，分享求职和成长心得' }
];

// 心情相关的帖子模板（根据用户心情选择）
function getMoodPosts(userMood: string): MoodPostEntry[] {
  let posts: MoodPostEntry[] = [];

  // 通用帖子（始终出现）
  let p1: MoodPostEntry = { friend: aiFriends[0], content: '写了三天的HarmonyOS组件终于跑通了！ArkTS虽然规矩多，但写着写着就习惯了。分享一个坑：@Builder里不能声明变量，记住这个少走很多弯路。' };
  let p2: MoodPostEntry = { friend: aiFriends[1], content: '今日学习打卡 ☑️ 线代刷完第六章，正确率比上周高了。坚持真的有用，给自己加个鸡腿 🍗' };
  let p3: MoodPostEntry = { friend: aiFriends[3], content: '读到一句很喜欢的话："种一棵树最好的时间是十年前，其次是现在。" 与其焦虑未来，不如做好当下能做的事。' };
  posts.push(p1);
  posts.push(p2);
  posts.push(p3);

  // 根据心情添加对应帖子（自然融入，不直接提及用户）
  if (userMood === '😢' || userMood === '😰' || userMood === '😤') {
    let p4: MoodPostEntry = { friend: aiFriends[5], content: '今天看到一句话，想分享给需要的人："没有不会好的伤，没有不会停的雨。" 如果今天不开心，就早点休息吧，明天又是新的一天 🌤️' };
    let p5: MoodPostEntry = { friend: aiFriends[4], content: '跑步的时候发现一个规律：最累的时候再坚持一下，过了那个点就轻松了。生活好像也是这样 🤔' };
    let p6: MoodPostEntry = { friend: aiFriends[6], content: '画了一幅小画：一只猫在窗台上晒太阳。有时候最简单的画面反而最治愈。希望看到的人也能感受到一点温暖 🐱☀️' };
    posts.push(p4);
    posts.push(p5);
    posts.push(p6);
  } else if (userMood === '🤩' || userMood === '🥳') {
    let p4: MoodPostEntry = { friend: aiFriends[2], content: '今天逛到一条超好看的碎花裙！分享一下今天的OOTD：碎花裙+小白鞋+草编包，春天感拉满 👗✨' };
    let p5: MoodPostEntry = { friend: aiFriends[5], content: '生活小确幸：地铁上有人给我让座（虽然我只是背了个大包😂）、买到了最后一杯限定奶茶、夕阳特别美。开心的事虽小，但攒起来就是一整天的好心情～' };
    posts.push(p4);
    posts.push(p5);
  } else {
    let p4: MoodPostEntry = { friend: aiFriends[2], content: '发现一个穿搭bug：横条纹显胖是真的！今天试了一件横条纹T恤，果断放下换了竖条纹的，视觉差起码5斤 😂' };
    let p5: MoodPostEntry = { friend: aiFriends[7], content: '面了第五家公司，终于收到offer了！分享一下经验：STAR法则准备充分真的太重要了，面试官说我的项目经历讲得很清晰。' };
    posts.push(p4);
    posts.push(p5);
  }

  let p7: MoodPostEntry = { friend: aiFriends[4], content: 'Day 95 健身打卡 💪 今天练腿，差点爬着出健身房。但想想已经坚持快100天了，不能断！' };
  let p8: MoodPostEntry = { friend: aiFriends[7], content: '发现一个提高效率的方法：番茄工作法 + 手机放另一个房间 = 生产力翻倍。今天一口气搞完3个任务，爽！' };
  posts.push(p7);
  posts.push(p8);

  return posts;
}

// 树洞相关的帖子模板（用户发树洞后，AI朋友发相关但不直指的内容）
function getTreeHoleResponsePosts(treeHoleContent: string): MoodPostEntry[] {
  let posts: MoodPostEntry[] = [];
  let content = treeHoleContent.toLowerCase();

  if (content.includes('考试') || content.includes('成绩') || content.includes('复习')) {
    let p: MoodPostEntry = { friend: aiFriends[1], content: '关于考试，我最大的感悟是：不要和别人比进度，按自己的节奏来。每个人都有自己的时区，慢慢来反而比较快。' };
    posts.push(p);
  }
  if (content.includes('吵架') || content.includes('朋友') || content.includes('室友')) {
    let p: MoodPostEntry = { friend: aiFriends[5], content: '人与人之间的关系真的很微妙。有时候退一步不是认输，是给彼此空间。真正在乎的人，冷静下来都会理解的。' };
    posts.push(p);
  }
  if (content.includes('迷茫') || content.includes('未来') || content.includes('工作')) {
    let p: MoodPostEntry = { friend: aiFriends[3], content: '迷茫的时候怎么办？我的方法是：先做好手头最小的一件事。整理桌面、写一行代码、读一页书——行动是焦虑的解药。' };
    posts.push(p);
  }
  if (content.includes('累') || content.includes('压力') || content.includes('忙')) {
    let p: MoodPostEntry = { friend: aiFriends[4], content: '累了就歇歇，没什么大不了的。机器都需要休息，何况是人。今天不打卡也没关系，明天继续就好 ❤️' };
    posts.push(p);
  }

  let last: MoodPostEntry = { friend: aiFriends[6], content: '画了一下午水彩，虽然画得很烂但过程超解压。推荐给所有想放松的朋友——不用画得好，享受过程就行 🎨' };
  posts.push(last);

  return posts;
}

/**
 * 生成AI朋友圈动态流。
 * @param userMood 用户今日心情emoji（空字符串表示未设置）
 * @param treeHolePosts 用户最近的树洞帖子
 */
export function generateAIFeed(userMood: string, treeHolePosts: TreeHolePost[]): CommunityPost[] {
  let moods: MoodPostEntry[] = getMoodPosts(userMood || '😊');
  let posts: CommunityPost[] = [];

  for (let i = 0; i < moods.length; i++) {
    let m: MoodPostEntry = moods[i];
    let cp: CommunityPost = {
      id: 'mp' + i.toString(),
      userName: m.friend.name,
      userAvatar: m.friend.emoji,
      content: m.content,
      likeCount: Math.floor(Math.random() * 300) + 20,
      commentCount: Math.floor(Math.random() * 40) + 3,
      timeAgo: (i * 12 + 3).toString() + '分钟前',
      isLiked: i === 0
    };
    posts.push(cp);
  }

  let treeHoleResponses: CommunityPost[] = [];
  if (treeHolePosts.length > 0) {
    let lastTreeHole: TreeHolePost = treeHolePosts[0];
    let responses: MoodPostEntry[] = getTreeHoleResponsePosts(lastTreeHole.content);
    for (let i = 0; i < responses.length; i++) {
      let r: MoodPostEntry = responses[i];
      let thr: CommunityPost = {
        id: 'thr' + i.toString(),
        userName: r.friend.name,
        userAvatar: r.friend.emoji,
        content: r.content,
        likeCount: Math.floor(Math.random() * 200) + 10,
        commentCount: Math.floor(Math.random() * 20) + 1,
        timeAgo: (i * 25 + 8).toString() + '分钟前',
        isLiked: false
      };
      treeHoleResponses.push(thr);
    }
  }

  let allPosts: CommunityPost[] = [];
  let ti: number = 0;
  let mi: number = 0;
  if (posts.length > 0) {
    allPosts.push(posts[mi]);
    mi++;
  }
  if (posts.length > 1) {
    allPosts.push(posts[mi]);
    mi++;
  }
  while (ti < treeHoleResponses.length) {
    allPosts.push(treeHoleResponses[ti]);
    ti++;
  }
  while (mi < posts.length) {
    allPosts.push(posts[mi]);
    mi++;
  }

  return allPosts;
}

// 打卡排行（保持不变）
export interface CheckInUser {
  name: string;
  emoji: string;
  streak: number;
  rank: number;
}

export const checkInRanking: CheckInUser[] = [
  { name: '考研上岸中', emoji: '📚', streak: 47, rank: 1 },
  { name: '健身狂魔', emoji: '💪', streak: 87, rank: 1 },
  { name: '代码诗人', emoji: '🧑‍💻', streak: 32, rank: 3 },
  { name: '咖啡与书', emoji: '☕', streak: 28, rank: 4 },
  { name: '小太阳', emoji: '🌻', streak: 21, rank: 5 },
];
