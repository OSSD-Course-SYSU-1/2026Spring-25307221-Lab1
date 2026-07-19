/**
 * Harmony Life OS — Skill 注册中心 + Agent-Skill 绑定
 *
 * 所有 Skill 在此注册。Agent 通过 AgentSkillBinding 关联 Skill。
 */

import { Skill, AgentSkillBinding } from '../../models/Skill'

// ==================== Skill Registry ====================

export const SKILL_REGISTRY: Skill[] = [

  // ====== 文档处理 ======
  {
    id: 'doc_summary',
    name: '文档总结',
    emoji: '📄',
    description: '上传PDF/Word/PPT，AI提炼核心要点',
    group: '文档处理',
    inputType: 'file',
    outputType: 'structured',
    uiMode: 'split',
    params: [
      { key: 'detail', label: '详细程度', type: 'select', required: false, defaultValue: '适中', options: ['简洁', '适中', '详细'] },
      { key: 'lang', label: '输出语言', type: 'select', required: false, defaultValue: '中文', options: ['中文', 'English'] }
    ],
    examples: [
      { input: '上传《信号与系统》第三章课件', output: '【核心总结】第三章讲解了...【关键知识点】1. 傅里叶变换...', description: '课件总结' }
    ],
    promptTemplate: `你是文档分析专家。请总结以下文档内容：

要求：
1. 用3-5句话概括核心内容
2. 列出5个以上关键知识点
3. 标注重点和易错点
4. 输出详细程度：{detail}

文档内容：
{input}`,
    estimatedTime: 15,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'doc_translate',
    name: '文档翻译',
    emoji: '🌐',
    description: '多语言文档翻译，保留原文格式',
    group: '文档处理',
    inputType: 'file',
    outputType: 'document',
    uiMode: 'split',
    params: [
      { key: 'target_lang', label: '目标语言', type: 'select', required: true, options: ['中文', 'English', '日本語', '한국어', 'Français', 'Deutsch'] }
    ],
    examples: [
      { input: '上传英文论文摘要', output: '中文翻译版摘要...', description: '论文翻译' }
    ],
    promptTemplate: `翻译以下内容为{target_lang}，保留原文结构和专业术语：
{input}`,
    estimatedTime: 20,
    requiresNetwork: true,
    isAsync: false
  },

  // ====== 知识学习 ======
  {
    id: 'knowledge_summary',
    name: '知识总结',
    emoji: '📚',
    description: '输入知识点，生成结构化知识框架',
    group: '知识学习',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [
      { key: 'subject', label: '学科', type: 'string', required: false, placeholder: '如：高等数学' },
      { key: 'depth', label: '深度', type: 'select', required: false, defaultValue: '适中', options: ['入门', '适中', '进阶'] }
    ],
    examples: [
      { input: '总结高等数学中的多元函数微分学', output: '【知识框架】一、多元函数基础...二、偏导数...三、全微分...', description: '高数知识总结' }
    ],
    promptTemplate: `你是{subject}专业导师。请对以下知识点进行结构化总结：

深度要求：{depth}

知识点：
{input}

输出格式：
【知识框架】（树状图结构）
【核心概念】（逐个解释）
【公式定理】（关键公式汇总）
【常见题型】
【易错提醒】`,
    estimatedTime: 20,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'mind_map',
    name: '思维导图',
    emoji: '🧠',
    description: '将知识点转化为思维导图结构',
    group: '知识学习',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '计算机网络OSI七层模型', output: '中心：OSI模型\n├── 物理层\n│   ├── 双绞线\n│   └── ...', description: 'OSI模型导图' }
    ],
    promptTemplate: `将以下内容转化为思维导图结构。用缩进层级表示父子关系：

{input}

格式：
· 中心主题
  ├── 一级分支1
  │   ├── 二级分支1.1
  │   └── 二级分支1.2
  └── 一级分支2`,
    estimatedTime: 15,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'exam_gen',
    name: 'AI出题',
    emoji: '📝',
    description: '根据知识点自动生成练习题',
    group: '知识学习',
    inputType: 'text',
    outputType: 'text',
    uiMode: 'chat',
    params: [
      { key: 'count', label: '题目数量', type: 'select', required: false, defaultValue: '6', options: ['3', '6', '10'] },
      { key: 'difficulty', label: '难度', type: 'select', required: false, defaultValue: '中等', options: ['简单', '中等', '困难', '混合'] }
    ],
    examples: [
      { input: '初中物理浮力', output: '【选择题】1. 体积相同的木块和铁块...', description: '物理出题' }
    ],
    promptTemplate: `你是智能出题老师。请根据以下知识点出{count}道题，难度{difficulty}：

知识点：
{input}

要求：
- {count}道题 = 选择题 + 填空题 + 简答题
- 每道题标注答案和详细解析
- 题目表述完整通顺

输出格式：
### 一、选择题（每题4个选项，标注正确答案+解析）
### 二、填空题
### 三、简答题`,
    estimatedTime: 25,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'exam_plan',
    name: '考试规划',
    emoji: '📅',
    description: '根据考试日期和科目制定复习计划',
    group: '知识学习',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [
      { key: 'exam_date', label: '考试日期', type: 'string', required: true, placeholder: '如：2026-07-15' },
      { key: 'daily_hours', label: '每日学习时长', type: 'select', required: false, defaultValue: '4小时', options: ['2小时', '4小时', '6小时', '8小时'] }
    ],
    examples: [
      { input: '科目：高等数学、大学英语、信号与系统，考试日期：7月15日', output: '【复习计划】第一阶段（基础巩固）...', description: '期末复习规划' }
    ],
    promptTemplate: `你是考试规划师。请根据以下信息制定复习计划：

考试日期：{exam_date}
每日可用时间：{daily_hours}
考试科目：{input}

输出：
【总体时间分配】
【阶段一：基础巩固】（教材+笔记）
【阶段二：强化练习】（刷题+错题）
【阶段三：冲刺模拟】（真题+模拟考）
【每日时间表】
【重点突破建议】`,
    estimatedTime: 20,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'knowledge_graph',
    name: '知识图谱',
    emoji: '🕸️',
    description: '分析知识点之间的关联，构建知识网络',
    group: '知识学习',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '数字信号处理核心概念', output: '【知识图谱】时域分析→频域分析→FFT→滤波器设计→...', description: 'DSP知识图谱' }
    ],
    promptTemplate: `分析以下知识点之间的关联关系，构建知识图谱：

{input}

输出格式：
【知识图谱】（用 → 表示依赖关系，用 ⇄ 表示相互关联）
【前置知识】（学习前需要掌握的）
【核心路径】（推荐学习顺序）
【薄弱点预警】（容易卡住的地方）`,
    estimatedTime: 25,
    requiresNetwork: true,
    isAsync: false
  },

  // ====== 分析诊断 ======
  {
    id: 'mock_interview',
    name: '模拟面试',
    emoji: '🎯',
    description: '根据岗位模拟真实面试场景',
    group: '分析诊断',
    inputType: 'text',
    outputType: 'text',
    uiMode: 'chat',
    params: [
      { key: 'position', label: '目标岗位', type: 'string', required: true, placeholder: '如：前端开发工程师' }
    ],
    examples: [
      { input: '岗位：产品经理', output: '【面试官】请做一下自我介绍...', description: '产品经理模拟面试' }
    ],
    promptTemplate: `你是资深面试官。用户应聘{position}，请进行模拟面试。

规则：
1. 每次只问一个问题
2. 根据回答追问
3. 包含技术面和行为面
4. 面试结束给出综合评分

开始面试：`,
    estimatedTime: 300,  // 5分钟
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'resume_optimize',
    name: '简历优化',
    emoji: '📋',
    description: '分析简历内容，给出专业修改建议',
    group: '分析诊断',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '粘贴简历内容...', output: '【整体评估】7/10\n【问题1】...建议改为...', description: '简历优化' }
    ],
    promptTemplate: `你是资深HR兼简历优化专家。请分析以下简历：

{input}

输出：
【整体评估】（1-10分）
【亮点】
【问题清单】（每条：原文 → 建议改为）
【格式建议】
【关键词优化】（针对ATS系统）
【STAR法则改写示范】`,
    estimatedTime: 30,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'position_analysis',
    name: '岗位分析',
    emoji: '🔍',
    description: '分析岗位要求，给出准备建议',
    group: '分析诊断',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '字节跳动后端开发工程师JD...', output: '【岗位拆解】核心技术栈：Go/Python...【准备建议】1...', description: 'JD分析' }
    ],
    promptTemplate: `分析以下岗位JD，给出求职准备建议：

{input}

输出：
【岗位拆解】（核心要求 + 加分项）
【技能匹配】（你已有的 vs 需要补充的）
【面试重点】（这个岗位大概率会问什么）
【准备清单】（具体的行动步骤）`,
    estimatedTime: 20,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'interview_score',
    name: '面试评分',
    emoji: '⭐',
    description: '对面试回答进行综合评分和反馈',
    group: '分析诊断',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '粘贴面试回答...', output: '【综合评分】7.5/10\n【内容】8分...【表达】7分...', description: '回答评分' }
    ],
    promptTemplate: `你是面试评分官。请对以下面试回答评分：

{input}

评分维度（每项1-10分）：
1. 内容质量（是否答到点子上）
2. 逻辑结构（是否清晰有条理）
3. 表达能力（是否简洁有力）
4. 亮点展示（是否有让人印象深刻的点）

输出：
【综合评分】
【各项得分 + 评语】
【改进建议】（具体可操作）`,
    estimatedTime: 15,
    requiresNetwork: true,
    isAsync: false
  },

  // ====== 内容创作 ======
  {
    id: 'ppt_outline',
    name: 'PPT大纲',
    emoji: '📊',
    description: '输入主题，生成PPT大纲框架',
    group: '内容创作',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'split',
    params: [
      { key: 'slides', label: '页数', type: 'select', required: false, defaultValue: '10', options: ['5', '10', '15', '20'] }
    ],
    examples: [
      { input: '大学生创新创业项目答辩', output: '【PPT大纲】第1页：封面...第2页：项目背景...', description: '答辩PPT' }
    ],
    promptTemplate: `你是PPT制作顾问。请为以下主题设计{slides}页PPT大纲：

主题：{input}

每页输出：
- 页面标题
- 核心要点（一句话）
- 排版建议（图文比例）
- 过渡语（连接下一页）

最后给出：
- 建议配色方案
- 开场白和结束语
- 预估总时长`,
    estimatedTime: 20,
    requiresNetwork: true,
    isAsync: false
  },

  // ====== 翻译交流 ======
  {
    id: 'realtime_translate',
    name: '实时翻译',
    emoji: '🌐',
    description: '自动识别源语言并翻译',
    group: '翻译交流',
    inputType: 'text',
    outputType: 'text',
    uiMode: 'split',
    params: [
      { key: 'target_lang', label: '目标语言', type: 'select', required: false, defaultValue: '中文', options: ['中文', 'English', '日本語', '한국어'] }
    ],
    examples: [
      { input: 'Hello, how are you today?', output: '今天你好吗？', description: '英译中' }
    ],
    promptTemplate: `你是翻译助手。将以下文本翻译为{target_lang}。

保持原文风格和语气。

原文：{input}`,
    estimatedTime: 5,
    requiresNetwork: true,
    isAsync: false
  },

  // ====== 生活服务 ======
  {
    id: 'style_diagnosis',
    name: '风格诊断',
    emoji: '👗',
    description: '根据身材肤色推荐穿搭风格',
    group: '生活服务',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '梨形身材，暖白皮，喜欢简约风', output: '【风格诊断】推荐风格：法式简约...【避雷】避免紧身包臀裙...', description: '穿搭诊断' }
    ],
    promptTemplate: `你是穿搭顾问。请根据以下信息给出风格诊断：

{input}

输出：
【风格定位】
【推荐单品】（上装/下装/连衣裙/外套/鞋子/配饰各推荐1-2件）
【避雷清单】
【配色建议】
【品牌推荐】`,
    estimatedTime: 15,
    requiresNetwork: true,
    isAsync: false
  },

  // ====== 趣味互动 ======
  {
    id: 'tarot_draw',
    name: '塔罗占卜',
    emoji: '🔮',
    description: '78张真牌随机抽3张并AI解读',
    group: '趣味互动',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'fullscreen',
    params: [],
    examples: [
      { input: '我的感情运势怎么样？', output: '【过去】圣杯二正位...【现在】...【未来】...', description: '塔罗占卜' }
    ],
    promptTemplate: `（由 TarotService 动态提供）`,
    estimatedTime: 30,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'fortune_test',
    name: '运势测试',
    emoji: '🌟',
    description: '今日/本周星座运势解读',
    group: '趣味互动',
    inputType: 'text',
    outputType: 'text',
    uiMode: 'chat',
    params: [
      { key: 'sign', label: '星座', type: 'select', required: true, options: ['白羊座','金牛座','双子座','巨蟹座','狮子座','处女座','天秤座','天蝎座','射手座','摩羯座','水瓶座','双鱼座'] }
    ],
    examples: [
      { input: '我是天秤座', output: '【今日运势】整体：⭐⭐⭐⭐...爱情：⭐⭐⭐...', description: '今日运势' }
    ],
    promptTemplate: `你是风趣的占星师。请为{sign}生成今日运势：

输出：
🌟 整体运势（1-5星）
💕 爱情运
💼 事业运
💰 财运
🎨 幸运色 / 🔢 幸运数字
💫 今日提醒

⚠️ 仅供娱乐`,
    estimatedTime: 10,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'zhouyi_divine',
    name: '周易算卦',
    emoji: '☯️',
    description: '六爻起卦，只算小事不涉命运',
    group: '趣味互动',
    inputType: 'text',
    outputType: 'text',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '今天出门要不要带伞？', output: '【卦象】水天需...【动爻】初九...【建议】带上伞...', description: '小事问卦' }
    ],
    promptTemplate: `你是精通周易六爻的先生。只算小事（出门/吃饭/买东西），拒绝算大命。

用户问题：{input}

随机起卦（64卦之一），给出：
☯️ 卦象名称和符号
📖 动爻位置和爻辞
💡 白话解读（结合用户问题）
🎋 一句话建议

⚠️ 卦象为趣，人生由己。`,
    estimatedTime: 15,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'answer_book',
    name: '答案之书',
    emoji: '📖',
    description: '心中默问，翻开书页得到答案',
    group: '趣味互动',
    inputType: 'text',
    outputType: 'text',
    uiMode: 'dialog',
    params: [],
    examples: [
      { input: '翻开', output: '「 勇敢一点 」', description: '随机答案' }
    ],
    promptTemplate: `（由前端本地随机生成，不调AI）`,
    estimatedTime: 3,
    requiresNetwork: false,
    isAsync: false
  },

  // ====== 创意设计 ======
  {
    id: 'brainstorm',
    name: '头脑风暴',
    emoji: '💡',
    description: '围绕主题生成创意点子列表',
    group: '创意设计',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [
      { key: 'count', label: '点子数量', type: 'select', required: false, defaultValue: '10', options: ['5', '10', '20'] }
    ],
    examples: [
      { input: '校园App的新功能点子', output: '1. AI课表智能排课\n2. 二手书交换平台\n3...', description: '创意生成' }
    ],
    promptTemplate: `围绕以下主题，生成{count}个创意点子。要求新颖、可行、具体。

主题：{input}

每个点子包含：
- 一句话描述
- 为什么值得做
- 大概怎么做

格式：编号. 点子名称 — 描述 — 理由 — 方法`,
    estimatedTime: 20,
    requiresNetwork: true,
    isAsync: false
  },

  {
    id: 'color_advice',
    name: '配色建议',
    emoji: '🎨',
    description: '根据场景推荐配色方案',
    group: '创意设计',
    inputType: 'text',
    outputType: 'structured',
    uiMode: 'chat',
    params: [],
    examples: [
      { input: '科技公司官网配色', output: '【主色】#1E88E5 科技蓝\n【辅色】#42A5F5\n...', description: '网站配色' }
    ],
    promptTemplate: `根据以下场景，推荐配色方案：

{input}

输出：
【主色】色号 + 名称 + 使用位置
【辅色】色号 + 名称
【强调色】色号 + 名称
【背景色】
【文字色】
【配色原理】（为什么这样搭配好看）`,
    estimatedTime: 10,
    requiresNetwork: true,
    isAsync: false
  }
]

// ==================== Agent-Skill 绑定 ====================

export const AGENT_SKILL_BINDINGS: AgentSkillBinding[] = [
  // 学习导师
  { agentId: 'ai_teacher', skillId: 'knowledge_summary', isDefault: true, order: 1 },
  { agentId: 'ai_teacher', skillId: 'mind_map', isDefault: true, order: 2 },
  { agentId: 'ai_teacher', skillId: 'exam_gen', isDefault: true, order: 3 },
  { agentId: 'ai_teacher', skillId: 'exam_plan', isDefault: true, order: 4 },
  { agentId: 'ai_teacher', skillId: 'knowledge_graph', isDefault: false, order: 5 },

  // 编程助手
  { agentId: 'ai_coder', skillId: 'doc_summary', isDefault: false, order: 1 },
  { agentId: 'ai_coder', skillId: 'brainstorm', isDefault: true, order: 2 },

  // 面试官
  { agentId: 'ai_interview', skillId: 'mock_interview', isDefault: true, order: 1 },
  { agentId: 'ai_interview', skillId: 'position_analysis', isDefault: true, order: 2 },
  { agentId: 'ai_interview', skillId: 'resume_optimize', isDefault: true, order: 3 },
  { agentId: 'ai_interview', skillId: 'interview_score', isDefault: true, order: 4 },

  // 心理咨询师
  { agentId: 'ai_emotion', skillId: 'brainstorm', isDefault: false, order: 1 },

  // 塔罗师
  { agentId: 'ai_tarot', skillId: 'tarot_draw', isDefault: true, order: 1 },
  { agentId: 'ai_tarot', skillId: 'fortune_test', isDefault: false, order: 2 },

  // 穿搭顾问
  { agentId: 'ai_stylist', skillId: 'style_diagnosis', isDefault: true, order: 1 },
  { agentId: 'ai_stylist', skillId: 'color_advice', isDefault: false, order: 2 },

  // 游戏教练
  { agentId: 'ai_gamecoach', skillId: 'brainstorm', isDefault: false, order: 1 },

  // AI Idol
  { agentId: 'ai_idol', skillId: 'fortune_test', isDefault: false, order: 1 }
]

// ==================== 查询方法 ====================

export function getSkillById(id: string): Skill | undefined {
  for (let skill of SKILL_REGISTRY) {
    if (skill.id === id) {
      return skill;
    }
  }
  return undefined;
}

export function getSkillsByGroup(group: string): Skill[] {
  let result: Skill[] = [];
  for (let skill of SKILL_REGISTRY) {
    if (skill.group === group) {
      result.push(skill);
    }
  }
  return result;
}

export function getAgentSkills(agentId: string): Skill[] {
  let bindings: AgentSkillBinding[] = [];
  for (let b of AGENT_SKILL_BINDINGS) {
    if (b.agentId === agentId) {
      bindings.push(b);
    }
  }
  // 按 order 排序
  for (let i = 0; i < bindings.length - 1; i++) {
    for (let j = i + 1; j < bindings.length; j++) {
      if (bindings[i].order > bindings[j].order) {
        let temp = bindings[i];
        bindings[i] = bindings[j];
        bindings[j] = temp;
      }
    }
  }
  let result: Skill[] = [];
  for (let b of bindings) {
    let skill = getSkillById(b.skillId);
    if (skill) {
      result.push(skill);
    }
  }
  return result;
}

export function getAllSkills(): Skill[] {
  return SKILL_REGISTRY;
}
