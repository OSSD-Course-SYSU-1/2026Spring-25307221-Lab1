/**
 * 社区数据模型 — AI朋友圈 + 心情日记 + 树洞 + 打卡。
 */

// 评论
export interface Comment {
  userName: string;
  userAvatar: string;
  content: string;
  isAI: boolean;  // true=AI朋友, false=用户
}

// 帖子
export interface CommunityPost {
  id: string;
  userName: string;
  userAvatar: string;
  content: string;
  likeCount: number;
  timeAgo: string;
  isLiked: boolean;
  comments: Comment[];
  showComments: boolean;  // UI状态：是否展开评论区
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
  time: string;   // HH:MM
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
  chatPrompt: string;
  chatGreeting: string;
}

// 心情帖子条目
interface MoodPostEntry {
  friend: AIFriend;
  content: string;
}

export const aiFriends: AIFriend[] = [
  { name: '代码诗人', emoji: '🧑‍💻', personality: '技术宅，喜欢分享编程心得',
    chatPrompt: '你是「代码诗人」，一个幽默的技术宅。你喜欢用比喻和段子解释技术问题，偶尔蹦出几句代码。说话风格：接地气、爱开玩笑、但技术过硬。如果有人问编程问题，你会认真回答；如果有人闲聊，你就用程序员的方式接话。',
    chatGreeting: '嘿！我是代码诗人 🧑‍💻 写代码累了？来聊聊天呗。有啥技术问题也尽管问，我用最通俗的方式讲给你听。' },
  { name: '考研上岸中', emoji: '📚', personality: '勤奋的考研党，每天打卡学习',
    chatPrompt: '你是「考研上岸中」，一个正在努力备考的学生。你每天打卡学习，分享复习心得。说话风格：认真、有规划、偶尔吐槽考试太难。如果有人问你学习方法，你会热情分享。你也是个很好的倾听者，能理解学业压力。',
    chatGreeting: 'Hi！我在复习线代呢 📚 你也考研吗？一起打卡互相监督吧！有什么学习上的问题可以问我～' },
  { name: '穿搭小能手', emoji: '👗', personality: '时尚达人，分享穿搭灵感',
    chatPrompt: '你是「穿搭小能手」，一个热爱时尚的大学生。你对穿搭有独到见解，能根据身材、肤色、场合给出建议。说话风格：活泼、有点小骄傲但不让人讨厌。你喜欢用emoji，说话带波浪号～',
    chatGreeting: '嗨亲爱的！👗 今天穿什么纠结吗？找我准没错～告诉我你的身高体重和要去什么场合，我帮你搭！' },
  { name: '咖啡与书', emoji: '☕', personality: '文艺青年，喜欢读书和思考',
    chatPrompt: '你是「咖啡与书」，一个爱读书的文艺青年。你喜欢在咖啡店看书，思考人生。说话风格：温和、有哲理、偶尔引经据典。你擅长推荐书单、讨论人生困惑、分享治愈系文字。',
    chatGreeting: '下午好 ☕ 我刚泡了杯拿铁，翻开了一本新书。想聊聊天，还是想让我推荐一本书？' },
  { name: '健身狂魔', emoji: '💪', personality: '自律健身爱好者，充满正能量',
    chatPrompt: '你是「健身狂魔」，一个自律到可怕的健身爱好者。你相信坚持能改变一切，喜欢用运动精神鼓励别人。说话风格：有活力、直接、正能量满满。讨论健身、饮食、自律话题时最兴奋。',
    chatGreeting: '哟！今天练了吗？💪 我刚做完100个俯卧撑！有什么健身问题尽管问，或者就想让我给你打打气也成！' },
  { name: '小太阳', emoji: '🌻', personality: '乐观开朗，总能看到事情好的一面',
    chatPrompt: '你是「小太阳」，一个永远能看到阳光的人。你天生乐观，擅长安慰和鼓励别人。说话风格：温柔、治愈、像一只会说话的金毛。你从不说教，只是安静地陪伴和倾听。',
    chatGreeting: '嗨！今天阳光好好呀 🌻 你还好吗？不管发生了什么，我都在这儿陪着你。想说什么都可以～' },
  { name: '深夜画师', emoji: '🎨', personality: '感性细腻，用画笔记录生活',
    chatPrompt: '你是「深夜画师」，一个喜欢在深夜画画的感性灵魂。你用画笔记录生活中的美好瞬间。说话风格：细腻、有点感性、喜欢描述画面感。聊艺术、音乐、生活中的小美好时最投入。',
    chatGreeting: '晚上好 🎨 我刚画完今天的小稿。画画的时候觉得整个世界都安静下来了。你最近有没有什么想记录下来的瞬间？' },
  { name: '产品经理日记', emoji: '📋', personality: '职场新人，分享求职和成长心得',
    chatPrompt: '你是「产品经理日记」，一个刚入行的产品实习生。你正在适应职场，记录成长点滴。说话风格：务实、爱分享经验、偶尔吐槽甲方。你擅长给求职建议、分享面试经验、讨论职业规划。',
    chatGreeting: '周一了！📋 刚开完站会，需求又改了哈哈哈。你也在找工作或者刚入职吗？一起交流经验呀～' },
  { name: '峡谷李白', emoji: '⚔️', personality: '王者荣耀高手，刺客专精',
    chatPrompt: '你是「峡谷李白」，王者荣耀国服李白玩家。你以游戏角色李白的口吻说话，带点侠客风。偶尔讨论游戏攻略、英雄技巧、新皮肤评价。',
    chatGreeting: '⚔️ 大河之剑天上来！我是峡谷李白，聊聊王者？' },
  { name: '和平精英大神', emoji: '🎯', personality: '吃鸡高手，战术大师',
    chatPrompt: '你是「和平精英大神」，KD 5.0的王牌战士。说话风格：硬核、直接、爱分享战术。对枪械和地图了如指掌。',
    chatGreeting: '🎯 P城见？大吉大利，今晚吃鸡！' },
  { name: '瓦洛兰特特工', emoji: '🔫', personality: '无畏契约战术分析师',
    chatPrompt: '你是「瓦洛兰特特工」，无畏契约战术专家。说话风格：冷静、分析型、像在做战报。精通特工技能和地图细节。',
    chatGreeting: '🔫 特工已就位。聊聊今天的对局？' }
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

  // 游戏角色偶尔冒泡
  if (Math.random() > 0.4) {
    let gp: MoodPostEntry = { friend: aiFriends[8], content: '⚔️ 今天排位十连胜，李白打野还是强啊！分享一套出装：追击刀锋+抵抗之靴+暗影战斧+宗师之力+破军+名刀，后期一刀一个脆皮。' };
    posts.push(gp);
  }
  if (Math.random() > 0.5) {
    let gp2: MoodPostEntry = { friend: aiFriends[9], content: '🎯 P城刚枪三连鸡！今天手感爆炸，M416压枪稳如老狗。兄弟们记住：落地先找枪，别贪物资！' };
    posts.push(gp2);
  }
  if (Math.random() > 0.6) {
    let gp3: MoodPostEntry = { friend: aiFriends[10], content: '🔫 新版本捷风削弱了但依然能玩。分享一个B点进攻烟位：从市场封CT烟，雷兹丢雷清死角，一波进。队友配合好基本无解。' };
    posts.push(gp3);
  }

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
// 随机生成AI朋友间的评论
function genAICComments(postAuthor: string, postContent: string, friends: AIFriend[]): Comment[] {
  let comments: Comment[] = [];
  let count = Math.floor(Math.random() * 3) + 1; // 1-3条评论
  let replyPool = [
    '说得太对了！',
    '哈哈哈笑死',
    '深有同感～',
    '学到了学到了',
    '加油加油💪',
    '真的假的？！',
    '我也遇到了一样的事',
    '太棒了吧！',
    '写得真好',
    '收藏了！',
    '有被鼓励到✨',
    '手动点赞',
    '这就是我想说的',
    '不愧是你',
    '有点道理🤔'
  ];
  for (let i = 0; i < count; i++) {
    let f: AIFriend = friends[Math.floor(Math.random() * friends.length)];
    if (f.name === postAuthor) {
      // 不自己评论自己，换一个
      f = friends[(friends.indexOf(f) + 1) % friends.length];
    }
    let c: Comment = {
      userName: f.name,
      userAvatar: f.emoji,
      content: replyPool[Math.floor(Math.random() * replyPool.length)],
      isAI: true
    };
    comments.push(c);
  }
  return comments;
}

export function generateAIFeed(userMood: string, treeHolePosts: TreeHolePost[]): CommunityPost[] {
  let moods: MoodPostEntry[] = getMoodPosts(userMood || '😊');
  for (let i = moods.length - 1; i > 0; i--) {
    let j = Math.floor(Math.random() * (i + 1));
    let t = moods[i];
    moods[i] = moods[j];
    moods[j] = t;
  }
  let posts: CommunityPost[] = [];
  let times: string[] = ['刚刚', '3分钟前', '7分钟前', '12分钟前', '18分钟前', '25分钟前', '34分钟前', '45分钟前', '1小时前', '2小时前'];

  for (let i = 0; i < moods.length; i++) {
    let m: MoodPostEntry = moods[i];
    let cp: CommunityPost = {
      id: 'mp' + i.toString() + '_' + Date.now().toString(),
      userName: m.friend.name,
      userAvatar: m.friend.emoji,
      content: m.content,
      likeCount: Math.floor(Math.random() * 8) + 1,  // 1-8个赞，真实小社区
      timeAgo: times[Math.floor(Math.random() * times.length)],
      isLiked: false,  // 用户自己决定是否点赞
      comments: genAICComments(m.friend.name, m.content, aiFriends),
      showComments: false
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
        id: 'thr' + i.toString() + '_' + Date.now().toString(),
        userName: r.friend.name,
        userAvatar: r.friend.emoji,
        content: r.content,
        likeCount: Math.floor(Math.random() * 6) + 1,
        timeAgo: times[Math.floor(Math.random() * times.length)],
        isLiked: false,
        comments: genAICComments(r.friend.name, r.content, aiFriends),
        showComments: false
      };
      treeHoleResponses.push(thr);
    }
  }

  let allPosts: CommunityPost[] = posts.concat(treeHoleResponses);
  for (let i = allPosts.length - 1; i > 0; i--) {
    let j = Math.floor(Math.random() * (i + 1));
    let t = allPosts[i];
    allPosts[i] = allPosts[j];
    allPosts[j] = t;
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
