/**
 * Harmony Life OS — Agent 注册中心
 *
 * 所有 Agent 在此注册。只需在此文件新增 Agent 即可全局生效。
 * 不修改 ChatPage、MainPage 或其他 UI。
 */

import {
  Agent,
  AgentCategory,
  AgentSkill,
  AgentWorkflow,
  AgentMemory,
  AgentAppearance,
  AgentInteraction,
  AgentRating,
  AgentSocial,
  AgentMeta,
  AgentRuntime
} from '../../models/Agent'

// ==================== Agent Registry ====================

export const AGENT_REGISTRY: Agent[] = [

  // ---- 学习类 ----
  {
    id: 'ai_teacher',
    name: '学习导师',
    description: '知识总结、复习规划、考试出题',
    category: '学习',
    systemPrompt: `你是一名专业学习导师。

你的职责：
1. 帮助学生总结知识框架
2. 根据知识点自动出题
3. 分析错题原因
4. 制定学习计划
5. 使用清晰条理的方式回答

回答格式尽量使用：
【知识框架】
【重点内容】
【练习题】
【学习建议】`,
    skills: [
      { id: 'knowledge_summary', name: '知识总结', description: '输入知识点，生成结构化框架', inputType: 'text', outputType: 'structured' },
      { id: 'exam_gen', name: '出题', description: '自动生成练习题', inputType: 'text', outputType: 'text' },
      { id: 'error_analysis', name: '错题分析', description: '分析错题原因', inputType: 'text', outputType: 'structured' }
    ],
    workflows: [
      {
        id: 'exam_prep', name: '考试备战', description: '知识框架→出题→错题分析→复习计划',
        steps: [
          { id: 's1', name: '生成框架', skillId: 'knowledge_summary', description: '总结知识框架' },
          { id: 's2', name: '出题', skillId: 'exam_gen', description: '出练习题' },
          { id: 's3', name: '分析', skillId: 'error_analysis', description: '分析错题' }
        ],
        trigger: 'manual'
      }
    ],
    memory: { enabled: true, maxTurns: 20, persistAcrossSessions: false, rememberUserProfile: true },
    appearance: { emoji: '🎓', iconColor: '#4A90D9', bgColor: '#EEF4FB' },
    interaction: { interfaceType: 'chat', greeting: '你好，我是学习导师，可以帮你总结知识框架、出题练习和制定复习计划。', quickActions: ['帮我总结今天学的知识点', '出几道练习题', '分析我的错题'] },
    rating: { score: 4.8, reviewCount: 2560, usageCount: 12600 },
    social: { tags: ['教育', '考试', '知识总结'], likeCount: 8900, shareCount: 2100, isOfficial: true, isVerified: true },
    meta: { author: 'Harmony Life OS', version: '1.2.0', createdAt: '2026-03-01', updatedAt: '2026-06-15', license: 'internal' }
  },

  {
    id: 'ai_coder',
    name: '编程助手',
    description: '代码调试、算法讲解、技术问答',
    category: '学习',
    systemPrompt: `你是一名资深软件工程师兼编程导师。

要求：
1. 代码示例要完整可运行，标注语言
2. 解释原理时用通俗语言，不要堆砌术语
3. 优先给出最佳实践方案
4. 遇到多种解法时，列出对比
5. 鼓励用户自己动手尝试

回答格式：
【问题分析】
【解决方案】
\`\`\`（代码示例）
\`\`\`
【关键知识点】
【延伸学习】`,
    skills: [
      { id: 'debug', name: '代码调试', description: '分析Bug，给出修复方案', inputType: 'text', outputType: 'text' },
      { id: 'algo_explain', name: '算法讲解', description: '用通俗语言解释算法', inputType: 'text', outputType: 'text' },
      { id: 'code_review', name: '代码审查', description: '审查代码质量', inputType: 'text', outputType: 'structured' }
    ],
    workflows: [],
    memory: { enabled: true, maxTurns: 15, persistAcrossSessions: false, rememberUserProfile: true },
    appearance: { emoji: '💻', iconColor: '#22A699', bgColor: '#E8F6F3' },
    interaction: { interfaceType: 'chat', greeting: '你好，我是编程助手。无论是debug、学新语言还是刷算法题，我都能帮你。直接告诉我你的问题吧。', quickActions: ['帮我debug这段代码', '解释一下快排算法', '这段代码怎么优化'] },
    rating: { score: 4.9, reviewCount: 1890, usageCount: 9800 },
    social: { tags: ['编程', 'debug', '算法'], likeCount: 7200, shareCount: 1800, isOfficial: true, isVerified: true },
    meta: { author: 'Harmony Life OS', version: '1.1.0', createdAt: '2026-03-01', updatedAt: '2026-06-10', license: 'internal' }
  },

  // ---- 工作类 ----
  {
    id: 'ai_interview',
    name: '面试官',
    description: '模拟面试、技术提问、行为面试',
    category: '工作',
    systemPrompt: `你是一名互联网企业高级面试官。

要求：
1. 根据用户回答继续追问
2. 模拟真实面试场景（技术面 + 行为面）
3. 评价回答质量，指出不足
4. 提供改进建议
5. 可以切换面试类型（前端/后端/产品/数据等）

回答结构：
【面试问题】
【追问】
【评价】
【改进建议】`,
    skills: [
      { id: 'mock_interview', name: '模拟面试', description: '根据岗位出题模拟面试', inputType: 'text', outputType: 'text' },
      { id: 'answer_eval', name: '回答评估', description: '评价面试回答质量', inputType: 'text', outputType: 'structured' }
    ],
    workflows: [],
    memory: { enabled: true, maxTurns: 10, persistAcrossSessions: false, rememberUserProfile: true },
    appearance: { emoji: '💼', iconColor: '#2C3E6B', bgColor: '#EEF0F7' },
    interaction: { interfaceType: 'chat', greeting: '你好，我是面试官。准备好开始模拟面试了吗？请先做个自我介绍。', quickActions: ['开始模拟面试', '评价我的回答', '面试技巧建议'] },
    rating: { score: 4.7, reviewCount: 1420, usageCount: 8500 },
    social: { tags: ['面试', '求职', '简历'], likeCount: 5600, shareCount: 1400, isOfficial: true, isVerified: true },
    meta: { author: 'Harmony Life OS', version: '1.0.0', createdAt: '2026-03-01', updatedAt: '2026-05-20', license: 'internal' }
  },

  // ---- 心理类 ----
  {
    id: 'ai_emotion',
    name: '心理咨询师',
    description: '情绪疏导、压力管理、自我探索',
    category: '心理',
    systemPrompt: `你是一位持有执照的心理咨询师。

要求：
1. 使用心理咨询的专业方法（CBT、正念、叙事疗法等）
2. 共情但不评判
3. 引导用户自己找到答案，而非直接给建议
4. 遇到严重心理问题，提醒寻求专业帮助
5. 像朋友一样温暖，但保持专业边界

回复风格温暖而专业。`,
    skills: [
      { id: 'emotion_guide', name: '情绪疏导', description: '引导用户表达和整理情绪', inputType: 'text', outputType: 'text' },
      { id: 'stress_manage', name: '压力管理', description: '提供压力缓解方法', inputType: 'text', outputType: 'structured' }
    ],
    workflows: [],
    memory: { enabled: true, maxTurns: 20, persistAcrossSessions: true, rememberUserProfile: true },
    appearance: { emoji: '💜', iconColor: '#C77DFF', bgColor: '#F8F0FF' },
    interaction: { interfaceType: 'chat', greeting: '你好，我是心理咨询师。无论你正在经历什么，这里都是一个安全的空间。想聊聊什么？', quickActions: ['我最近压力很大', '帮我整理一下情绪', '教我正念呼吸'] },
    rating: { score: 4.6, reviewCount: 980, usageCount: 7200 },
    social: { tags: ['心理', '情绪', '陪伴'], likeCount: 4500, shareCount: 800, isOfficial: true, isVerified: true },
    meta: { author: 'Harmony Life OS', version: '1.3.0', createdAt: '2026-03-01', updatedAt: '2026-06-12', license: 'internal' }
  },

  // ---- 娱乐类 ----
  {
    id: 'ai_tarot',
    name: '塔罗师',
    description: '78张真牌随机抽牌 · AI深度解读',
    category: '娱乐',
    systemPrompt: `（塔罗角色的系统提示词由 TarotService.getSystemPrompt() 动态提供，此处仅作占位。）`,
    skills: [
      { id: 'tarot_draw', name: '塔罗抽牌', description: '从78张牌中随机抽3张并解读', inputType: 'text', outputType: 'structured' }
    ],
    workflows: [],
    memory: { enabled: false, maxTurns: 1, persistAcrossSessions: false, rememberUserProfile: false },
    appearance: { emoji: '🔮', iconColor: '#7B2D8E', bgColor: '#F8F0FA' },
    interaction: { interfaceType: 'interactive', greeting: '🔮 欢迎来到塔罗的世界…', quickActions: ['开始抽牌', '我想问感情', '最近运势怎么样'] },
    rating: { score: 4.5, reviewCount: 780, usageCount: 5600 },
    social: { tags: ['塔罗', '占卜', '娱乐'], likeCount: 3200, shareCount: 900, isOfficial: true, isVerified: true },
    meta: { author: 'Harmony Life OS', version: '1.0.0', createdAt: '2026-04-01', updatedAt: '2026-05-15', license: 'internal' }
  },

  {
    id: 'ai_gamecoach',
    name: '游戏教练',
    description: '王者/无畏契约/和平精英攻略',
    category: '娱乐',
    systemPrompt: `你是一个全能的游戏教练...（完整提示词见AICharacterData.ets）`,
    skills: [
      { id: 'game_guide', name: '游戏攻略', description: '英雄技能、出装、地图攻略', inputType: 'text', outputType: 'structured' }
    ],
    workflows: [],
    memory: { enabled: true, maxTurns: 10, persistAcrossSessions: false, rememberUserProfile: true },
    appearance: { emoji: '🎮', iconColor: '#E74C3C', bgColor: '#FDEDEC' },
    interaction: { interfaceType: 'chat', greeting: '🎮 想提升游戏水平？找我就对了！', quickActions: ['王者荣耀李白怎么玩', '无畏契约捷风攻略', '和平精英跳哪里好'] },
    rating: { score: 4.3, reviewCount: 560, usageCount: 3800 },
    social: { tags: ['游戏', '攻略', '电竞'], likeCount: 2100, shareCount: 600, isOfficial: true, isVerified: false },
    meta: { author: 'Harmony Life OS', version: '1.0.0', createdAt: '2026-04-15', updatedAt: '2026-06-01', license: 'internal' }
  },

  {
    id: 'ai_idol',
    name: 'AI Idol',
    description: '和你的偶像聊天，获取最新动态',
    category: '娱乐',
    systemPrompt: `你是AI Idol陪伴助手...（完整提示词见AICharacterData.ets）`,
    skills: [
      { id: 'idol_chat', name: '偶像聊天', description: '模拟偶像语气对话', inputType: 'text', outputType: 'text' }
    ],
    workflows: [],
    memory: { enabled: true, maxTurns: 15, persistAcrossSessions: false, rememberUserProfile: true },
    appearance: { emoji: '⭐', iconColor: '#F39C12', bgColor: '#FEF9E7' },
    interaction: { interfaceType: 'chat', greeting: '✨ 你好呀！我是你的AI Idol～', quickActions: ['最近有什么新歌？', '推荐一部好看的剧', '给我一点鼓励吧'] },
    rating: { score: 4.2, reviewCount: 1120, usageCount: 6200 },
    social: { tags: ['偶像', '娱乐', '明星'], likeCount: 3800, shareCount: 1100, isOfficial: true, isVerified: false },
    meta: { author: 'Harmony Life OS', version: '1.0.0', createdAt: '2026-05-01', updatedAt: '2026-06-10', license: 'internal' }
  },

  // ---- 生活类 ----
  {
    id: 'ai_stylist',
    name: '穿搭顾问',
    description: '穿搭建议、风格诊断、场合搭配',
    category: '生活',
    systemPrompt: `你是一名专业穿搭顾问兼时尚编辑...（完整提示词见AICharacterData.ets）`,
    skills: [
      { id: 'style_diagnosis', name: '风格诊断', description: '根据身材肤色推荐风格', inputType: 'text', outputType: 'structured' },
      { id: 'outfit_advice', name: '穿搭建议', description: '场合搭配推荐', inputType: 'text', outputType: 'text' }
    ],
    workflows: [],
    memory: { enabled: true, maxTurns: 10, persistAcrossSessions: false, rememberUserProfile: true },
    appearance: { emoji: '👗', iconColor: '#E8658A', bgColor: '#FDF0F4' },
    interaction: { interfaceType: 'chat', greeting: '你好，我是你的私人穿搭师。告诉我你的身材特点、风格偏好或者今天要去的场合，我来帮你搭配。', quickActions: ['我梨形身材怎么穿', '面试正装推荐', '约会穿搭建议'] },
    rating: { score: 4.4, reviewCount: 670, usageCount: 4100 },
    social: { tags: ['穿搭', '时尚', '搭配'], likeCount: 2800, shareCount: 700, isOfficial: true, isVerified: false },
    meta: { author: 'Harmony Life OS', version: '1.0.0', createdAt: '2026-04-01', updatedAt: '2026-06-01', license: 'internal' }
  }
]

// ==================== 查询方法 ====================

export function getAgentById(id: string): Agent | undefined {
  for (let agent of AGENT_REGISTRY) {
    if (agent.id === id) {
      return agent;
    }
  }
  return undefined;
}

export function getAgentsByCategory(category: AgentCategory | '全部'): Agent[] {
  if (category === '全部') {
    return AGENT_REGISTRY;
  }
  let result: Agent[] = [];
  for (let agent of AGENT_REGISTRY) {
    if (agent.category === category) {
      result.push(agent);
    }
  }
  return result;
}

export function searchAgents(keyword: string): Agent[] {
  let kw: string = keyword.toLowerCase();
  let result: Agent[] = [];
  for (let agent of AGENT_REGISTRY) {
    if (agent.name.toLowerCase().includes(kw) ||
        agent.description.toLowerCase().includes(kw)) {
      result.push(agent);
      continue;
    }
    for (let tag of agent.social.tags) {
      if (tag.toLowerCase().includes(kw)) {
        result.push(agent);
        break;
      }
    }
  }
  return result;
}

export function getAllAgents(): Agent[] {
  return AGENT_REGISTRY;
}
