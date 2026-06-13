/**
 * 工具箱数据模型 — AI工具和功能入口。
 */

export interface AITool {
  id: string;
  name: string;
  emoji: string;
  description: string;
  color: string;
  bgColor: string;
  // 操作类型：'chat' 跳转聊天 | 'tarot' 抽牌 | 'book' 答案之书 | 'none' 占位
  action: string;
  // chat 类型的 AI 角色 id（对应 AICharacterData 或自定义 prompt）
  targetId?: string;
  // 自定义系统提示词（适用于无对应角色的工具）
  customPrompt?: string;
  // 自定义问候语
  customGreeting?: string;
}

export const aiTools: AITool[] = [
  {
    id: 'tool_pdf',
    name: 'PDF总结',
    emoji: '📄',
    description: '上传PDF文档，AI帮你提炼要点',
    color: '#E67E22',
    bgColor: '#FDF2E9',
    action: 'chat',
    targetId: 'tool_pdf',
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
    customGreeting: '你好，我是PDF总结助手。请把你要总结的文档内容发给我，我会帮你快速提炼要点。'
  },
  {
    id: 'tool_exam',
    name: 'AI出题',
    emoji: '📝',
    description: '输入知识点，自动生成练习题',
    color: '#3498DB',
    bgColor: '#EBF5FB',
    action: 'chat',
    targetId: 'tool_exam',
    customPrompt: `你是智能出题专家。用户提供一个知识点或科目，你需要：
1. 出3道选择题 + 2道填空题 + 1道简答题
2. 题目难度递进
3. 给出答案和解析
4. 标注考察的知识点

格式：
【选择题】
1. ...  A.... B.... C.... D....  答案：X  解析：...
【填空题】
【简答题】
【考察知识点总结】`,
    customGreeting: '你好，我是AI出题助手。告诉我你想练习的知识点，我帮你出题。例如：「高中数学三角函数」「Python列表操作」'
  },
  {
    id: 'tool_answerbook',
    name: '答案之书',
    emoji: '📖',
    description: '心中默问，翻开一页，得到答案',
    color: '#C8A45C',
    bgColor: '#FDF8F0',
    action: 'book'
  },
  {
    id: 'tool_fortune',
    name: '运势测试',
    emoji: '🌟',
    description: '今日运势、星座解读、趣味预测',
    color: '#9B59B6',
    bgColor: '#F5EEF8',
    action: 'chat',
    targetId: 'tool_fortune',
    customPrompt: `你是一位风趣幽默的占星师。

要求：
1. 根据用户的星座或问题生成当日/本周运势
2. 包含：整体运势、爱情、事业、财运、幸运色/数字
3. 风格轻松幽默，带点神秘感
4. 明确标注"仅供娱乐"

格式：
🌟 **今日/本周运势**
💕 爱情运：...
💼 事业运：...
💰 财运：...
🎨 幸运色：...  🔢 幸运数字：...
💫 一句话提醒：...

⚠️ 仅供娱乐，请理性看待。`,
    customGreeting: '你好，我是运势小助手。告诉我你的星座，我帮你看看今天的运势～例如：「我是天秤座」'
  },
  {
    id: 'tool_tarot',
    name: '塔罗牌',
    emoji: '🃏',
    description: '78张真牌随机抽 · 互动选牌',
    color: '#7B2D8E',
    bgColor: '#F8F0FA',
    action: 'tarot'
  },
  {
    id: 'tool_resume',
    name: '简历优化',
    emoji: '📋',
    description: '分析简历，给出修改建议',
    color: '#2ECC71',
    bgColor: '#EAFBF0',
    action: 'chat',
    targetId: 'tool_resume',
    customPrompt: `你是资深HR兼简历优化专家。

要求：
1. 分析用户提供的简历内容
2. 指出格式、措辞、结构问题
3. 给出具体修改建议和示范
4. 根据目标岗位定制优化方向
5. 强调STAR法则（情境-任务-行动-结果）

格式：
【整体评估】
【问题清单】
  1. ... → 建议改为：...
【亮点强化】
【格式优化】
【关键词优化（针对ATS筛选）】`,
    customGreeting: '你好，我是简历优化助手。把你的简历内容发给我，或者告诉我你想投递的岗位，我帮你把简历打磨到最佳状态。'
  },
  {
    id: 'tool_mockinterview',
    name: '面试模拟',
    emoji: '🎯',
    description: '模拟真实面试，追问+评分',
    color: '#E74C3C',
    bgColor: '#FDEDEC',
    action: 'chat',
    targetId: 'tool_mockinterview',
    customPrompt: `你是严格的模拟面试官。

要求：
1. 根据用户应聘的岗位出题
2. 包含技术题、行为题、情景题
3. 每次只问一个问题，根据回答追问
4. 面试结束后给出综合评分和改进建议
5. 模拟真实面试的压力感

格式：
【岗位】: ...
【面试环节】: 技术面 / 行为面 / ...
🎯 **第X题**：...
（用户回答后）
✅ 评价：...
🔍 追问：...

面试结束后：
【综合评分】/10
【亮点】
【待改进】
【针对性练习建议】`,
    customGreeting: '你好，我是模拟面试官。请告诉我你要面试的岗位，我们开始模拟。例如：「前端开发」「产品经理」'
  }
];
