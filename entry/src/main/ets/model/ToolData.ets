/**
 * 工具箱数据模型 — AI工具和功能入口。
 * 分类：学习工作 / 趣味生活
 */

export interface AITool {
  id: string;
  name: string;
  emoji: string;
  description: string;
  color: string;
  bgColor: string;
  category: string;
  action: string;
  targetId?: string;
  customPrompt?: string;
  customGreeting?: string;
}

export const aiTools: AITool[] = [
  // ========== 学习工作 ==========
  {
    id: 'tool_doc',
    name: '文档总结',
    emoji: '📄',
    description: '提炼要点(PDF/Word/PPT)',
    color: '#E67E22',
    bgColor: '#FDF2E9',
    category: '学习工作',
    action: 'chat',
    targetId: 'tool_doc',
    customPrompt: `你是文档分析专家。用户会粘贴文档内容或要点，请帮用户：
1. 用3-5句话总结核心内容
2. 列出关键知识点
3. 标注重点和易错点
4. 给出复习建议

格式：
【核心总结】
【关键知识点】
【重点标注】
【复习建议】`,
    customGreeting: '你好，我是文档总结助手。支持PDF、Word、PPT内容提炼。把你要总结的内容发给我，我帮你快速抓住要点。'
  },
  {
    id: 'tool_exam',
    name: 'AI出题',
    emoji: '📝',
    description: '输入知识点，自动生成练习题',
    color: '#3498DB',
    bgColor: '#EBF5FB',
    category: '学习工作',
    action: 'chat',
    targetId: 'tool_exam',
    customPrompt: `（详见之前的长提示词——略，保持之前的即可）`,
    customGreeting: '你好，我是AI出题助手。告诉我科目和知识点，我帮你出一份练习卷。例如：「初中物理：浮力」「高中数学：三角函数」「Python：列表操作」'
  },
  {
    id: 'tool_ppt',
    name: 'PPT辅助',
    emoji: '📊',
    description: '输入主题,生成大纲和讲稿思路',
    color: '#E74C3C',
    bgColor: '#FDEDEC',
    category: '学习工作',
    action: 'chat',
    targetId: 'tool_ppt',
    customPrompt: `你是PPT制作顾问，像豆包(Doubao)一样帮用户理清思路。

## 能力
1. 根据主题生成PPT大纲（每页要点一句话）
2. 给出排版建议（图文比例、配色方向）
3. 设计开场白和结束语
4. 预估演讲时长

## 输出格式
🎯 **PPT主题**：（一句话概括）

📋 **大纲框架**（每页一句话要点）
第1页 - 封面：...
第2页 - 背景/问题：...
第3页 - 方案/核心内容：...
第4页 - 亮点/数据：...
第5页 - 总结/行动：...

🎨 **排版建议**
- 配色方向：...
- 图文比例：...

🎤 **演讲TIPS**
- 开场白：...
- 每页过渡语建议
- 结束语：...

⏱ 建议总时长：X分钟`,
    customGreeting: '你好，我是PPT制作助手 📊\n\n告诉我你要做什么主题的PPT，我帮你理清思路、设计大纲。\n\n例如：「大学生创新创业项目答辩」「Python入门教学」「校园社团招新宣讲」'
  },
  {
    id: 'tool_translate',
    name: '实时翻译',
    emoji: '🌐',
    description: '自动识别语言并翻译',
    color: '#1ABC9C',
    bgColor: '#E8F8F5',
    category: '学习工作',
    action: 'chat',
    targetId: 'tool_translate',
    customPrompt: `你是专业翻译助手。自动识别源语言并翻译。

## 规则
1. 自动检测用户输入的源语言
2. 默认翻译成中文；如果用户指定目标语言，按指定翻译
3. 保留原文语气和风格

## 输出格式
🔍 {源语言} → {目标语言}
🌐 翻译：（翻译结果）
💡 关键词：（如有术语，列出对照）`,
    customGreeting: '你好，我是翻译助手 🌐\n\n直接发需要翻译的文字给我，自动识别并翻译。\n• 发中文→译英文  • 发英文→译中文  • 指定目标：「翻译成日语：Hello」'
  },
  {
    id: 'tool_resume',
    name: '简历优化',
    emoji: '📋',
    description: '分析简历，给出修改建议',
    color: '#2ECC71',
    bgColor: '#EAFBF0',
    category: '学习工作',
    action: 'chat',
    targetId: 'tool_resume',
    customPrompt: `你是资深HR兼简历优化专家。帮用户分析简历并给出具体修改建议。强调STAR法则。`,
    customGreeting: '你好，我是简历优化助手。把你的简历内容发给我，我帮你打磨到最佳状态。'
  },
  {
    id: 'tool_mockinterview',
    name: '面试模拟',
    emoji: '🎯',
    description: '模拟真实面试，追问+评分',
    color: '#C0392B',
    bgColor: '#FDEDEC',
    category: '学习工作',
    action: 'chat',
    targetId: 'tool_mockinterview',
    customPrompt: `你是严格的模拟面试官。根据岗位出题，包含技术题、行为题。每次只问一题，根据回答追问。面试结束后给综合评分。`,
    customGreeting: '你好，我是模拟面试官。请告诉我你要面试的岗位，我们开始模拟。例如：「前端开发」「产品经理」'
  },

  // ========== 趣味生活 ==========
  {
    id: 'tool_answerbook',
    name: '答案之书',
    emoji: '📖',
    description: '心中默问，翻开一页，得到答案',
    color: '#C8A45C',
    bgColor: '#FDF8F0',
    category: '趣味生活',
    action: 'book'
  },
  {
    id: 'tool_fortune',
    name: '运势测试',
    emoji: '🌟',
    description: '今日运势、星座解读、趣味预测',
    color: '#9B59B6',
    bgColor: '#F5EEF8',
    category: '趣味生活',
    action: 'chat',
    targetId: 'tool_fortune',
    customPrompt: `你是风趣幽默的占星师。根据用户星座生成运势。包含爱情、事业、财运、幸运色。风格轻松幽默。⚠️仅供娱乐。`,
    customGreeting: '你好，运势小助手～告诉我你的星座，帮你看今日运势。例如：「我是天秤座」'
  },
  {
    id: 'tool_tarot',
    name: '塔罗牌',
    emoji: '🃏',
    description: '78张真牌随机抽·互动选牌',
    color: '#7B2D8E',
    bgColor: '#F8F0FA',
    category: '趣味生活',
    action: 'tarot'
  },
  {
    id: 'tool_zhouyi',
    name: '周易算卦',
    emoji: '☯️',
    description: '小事问卦，不涉命运',
    color: '#8B4513',
    bgColor: '#FDF5E6',
    category: '趣味生活',
    action: 'chat',
    targetId: 'tool_zhouyi',
    customPrompt: `你是精通周易六爻的先生。只算小事（出门、吃饭、买东西），拒绝算大命。随机起卦，结合用户小事解读。⚠️卦象为趣，人生由己。`,
    customGreeting: '☯️ 先生我走南闯北，卦不算大，只算小。日常小事拿不定主意？出门、吃饭、买东西——小事尽管问。'
  }
];
