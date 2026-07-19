/**
 * Harmony Life OS — Workflow 注册中心
 *
 * 所有预定义 Workflow 模板在此注册。
 * 每个 Workflow 是多个 Skill 的有序执行链。
 */

import { WorkflowDef } from '../../models/Workflow'

// ==================== Workflow Registry ====================

export const WORKFLOW_REGISTRY: WorkflowDef[] = [

  // ====== 学习类 Workflows ======

  {
    id: 'wf_exam_prep',
    name: '考试备战全流程',
    emoji: '📚',
    description: '上传课件 → AI解析 → 知识总结 → 思维导图 → 知识图谱 → 自动出题 → 生成学习计划 → 每日提醒',
    category: '学习',
    trigger: 'manual',
    steps: [
      {
        id: 's1', name: '上传学习资料', description: '上传PDF/Word课件或输入知识点',
        skillId: 'doc_summary', inputSource: 'user', timeout: 60, retryCount: 1, retryDelay: 5, onError: 'stop'
      },
      {
        id: 's2', name: '知识总结', description: 'AI提炼核心要点和知识框架',
        skillId: 'knowledge_summary', inputSource: 'previous', timeout: 30, retryCount: 1, retryDelay: 5, onError: 'stop'
      },
      {
        id: 's3', name: '生成思维导图', description: '将知识框架转化为思维导图',
        skillId: 'mind_map', inputSource: 'previous', timeout: 20, retryCount: 1, retryDelay: 5, onError: 'skip'
      },
      {
        id: 's4', name: '构建知识图谱', description: '分析知识点关联关系',
        skillId: 'knowledge_graph', inputSource: 'step', inputStepId: 's2', timeout: 30, retryCount: 1, retryDelay: 5, onError: 'skip'
      },
      {
        id: 's5', name: '自动出题', description: '根据知识点生成练习题',
        skillId: 'exam_gen', inputSource: 'step', inputStepId: 's2', timeout: 30, retryCount: 2, retryDelay: 10, onError: 'retry'
      },
      {
        id: 's6', name: '生成学习计划', description: '制定每日复习计划',
        skillId: 'exam_plan', inputSource: 'previous', timeout: 30, retryCount: 1, retryDelay: 5, onError: 'skip'
      },
      {
        id: 's7', name: '每日提醒', description: '根据计划设置每日学习提醒',
        skillId: 'exam_plan', inputSource: 'previous', timeout: 10, retryCount: 0, retryDelay: 0, onError: 'skip'
      }
    ],
    estimatedTotalTime: 180,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['学习', '考试', '复习', '知识管理']
  },

  {
    id: 'wf_quick_study',
    name: '快速学习一个知识点',
    emoji: '⚡',
    description: '输入知识点 → 总结 → 出3道题 → 解析',
    category: '学习',
    trigger: 'manual',
    steps: [
      {
        id: 's1', name: '知识总结', description: '快速总结该知识点',
        skillId: 'knowledge_summary', inputSource: 'user', timeout: 20, retryCount: 0, retryDelay: 0, onError: 'stop'
      },
      {
        id: 's2', name: '出题自测', description: '生成3道练习题',
        skillId: 'exam_gen', inputSource: 'previous', timeout: 20, retryCount: 1, retryDelay: 5, onError: 'skip'
      }
    ],
    estimatedTotalTime: 40,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['学习', '快速', '自测']
  },

  {
    id: 'wf_daily_review',
    name: '每日学习提醒',
    emoji: '🔔',
    description: '每天早上8点推送今日学习建议和复习提醒',
    category: '学习',
    trigger: 'scheduled',
    schedule: { cron: '0 8 * * *', timezone: 'Asia/Shanghai', skipIfMissed: false },
    steps: [
      {
        id: 's1', name: '回顾昨日学习', description: '根据学习记录生成回顾',
        skillId: 'knowledge_summary', inputSource: 'external', timeout: 15, retryCount: 0, retryDelay: 0, onError: 'skip'
      },
      {
        id: 's2', name: '今日学习建议', description: '推荐今日学习内容',
        skillId: 'exam_plan', inputSource: 'previous', timeout: 10, retryCount: 0, retryDelay: 0, onError: 'skip'
      }
    ],
    estimatedTotalTime: 25,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['学习', '每日', '自动']
  },

  // ====== 工作类 Workflows ======

  {
    id: 'wf_job_hunt',
    name: '求职准备全流程',
    emoji: '💼',
    description: '岗位分析 → 简历优化 → 模拟面试 → 面试评分 → 改进建议',
    category: '工作',
    trigger: 'manual',
    steps: [
      {
        id: 's1', name: '岗位分析', description: '分析目标岗位JD',
        skillId: 'position_analysis', inputSource: 'user', timeout: 30, retryCount: 0, retryDelay: 0, onError: 'stop'
      },
      {
        id: 's2', name: '简历优化', description: '根据岗位要求优化简历',
        skillId: 'resume_optimize', inputSource: 'step', inputStepId: 's1', timeout: 30, retryCount: 1, retryDelay: 5, onError: 'stop'
      },
      {
        id: 's3', name: '模拟面试', description: '模拟真实面试场景',
        skillId: 'mock_interview', inputSource: 'step', inputStepId: 's1', timeout: 300, retryCount: 1, retryDelay: 10, onError: 'stop'
      },
      {
        id: 's4', name: '面试评分', description: '对面试表现评分',
        skillId: 'interview_score', inputSource: 'previous', timeout: 20, retryCount: 0, retryDelay: 0, onError: 'skip'
      },
      {
        id: 's5', name: '改进建议', description: '根据评分给出改进清单',
        skillId: 'interview_score', inputSource: 'previous', timeout: 20, retryCount: 0, retryDelay: 0, onError: 'skip'
      }
    ],
    estimatedTotalTime: 420,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['求职', '面试', '简历', '工作']
  },

  {
    id: 'wf_doc_pipeline',
    name: '文档处理流水线',
    emoji: '📄',
    description: '上传文档 → 总结 → 翻译 → 生成PPT大纲',
    category: '工作',
    trigger: 'manual',
    steps: [
      {
        id: 's1', name: '文档总结', description: '提炼核心要点',
        skillId: 'doc_summary', inputSource: 'user', timeout: 30, retryCount: 1, retryDelay: 5, onError: 'stop'
      },
      {
        id: 's2', name: '文档翻译', description: '翻译为英文',
        skillId: 'doc_translate', inputSource: 'previous', timeout: 30, retryCount: 1, retryDelay: 5, onError: 'skip'
      },
      {
        id: 's3', name: '生成PPT大纲', description: '基于总结生成演示大纲',
        skillId: 'ppt_outline', inputSource: 'step', inputStepId: 's1', timeout: 25, retryCount: 0, retryDelay: 0, onError: 'skip'
      }
    ],
    estimatedTotalTime: 85,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['文档', '翻译', 'PPT', '工作']
  },

  // ====== 生活类 Workflows ======

  {
    id: 'wf_morning_brief',
    name: '早安简报',
    emoji: '🌅',
    description: '每天早上自动推送天气、日程、运势、学习建议',
    category: '生活',
    trigger: 'scheduled',
    schedule: { cron: '0 7 * * *', timezone: 'Asia/Shanghai', skipIfMissed: false },
    steps: [
      {
        id: 's1', name: '今日运势', description: '获取今日星座运势',
        skillId: 'fortune_test', inputSource: 'external', timeout: 10, retryCount: 0, retryDelay: 0, onError: 'skip'
      },
      {
        id: 's2', name: '学习建议', description: '根据学习记录推荐今日学习',
        skillId: 'exam_plan', inputSource: 'external', timeout: 15, retryCount: 0, retryDelay: 0, onError: 'skip'
      },
      {
        id: 's3', name: '生活提醒', description: '运动和饮食小贴士',
        skillId: 'style_diagnosis', inputSource: 'external', timeout: 10, retryCount: 0, retryDelay: 0, onError: 'skip'
      }
    ],
    estimatedTotalTime: 35,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['每日', '自动', '生活']
  },

  // ====== 创作类 Workflows ======

  {
    id: 'wf_creative_storm',
    name: '创意工坊',
    emoji: '💡',
    description: '头脑风暴 → 筛选最佳点子 → 配色建议 → 生成提案大纲',
    category: '工作',
    trigger: 'manual',
    steps: [
      {
        id: 's1', name: '头脑风暴', description: '生成20个创意点子',
        skillId: 'brainstorm', inputSource: 'user', timeout: 30, retryCount: 0, retryDelay: 0, onError: 'stop'
      },
      {
        id: 's2', name: '配色建议', description: '为方案推荐配色',
        skillId: 'color_advice', inputSource: 'step', inputStepId: 's1', timeout: 15, retryCount: 0, retryDelay: 0, onError: 'skip'
      },
      {
        id: 's3', name: '生成PPT大纲', description: '将最佳点子整理为演示大纲',
        skillId: 'ppt_outline', inputSource: 'step', inputStepId: 's1', timeout: 25, retryCount: 0, retryDelay: 0, onError: 'skip'
      }
    ],
    estimatedTotalTime: 70,
    author: 'Harmony Life OS',
    version: '1.0.0',
    tags: ['创意', '设计', '提案']
  }
]

// ==================== 查询方法 ====================

export function getWorkflowById(id: string): WorkflowDef | undefined {
  for (let wf of WORKFLOW_REGISTRY) {
    if (wf.id === id) {
      return wf;
    }
  }
  return undefined;
}

export function getWorkflowsByCategory(category: string): WorkflowDef[] {
  let result: WorkflowDef[] = [];
  for (let wf of WORKFLOW_REGISTRY) {
    if (wf.category === category) {
      result.push(wf);
    }
  }
  return result;
}

export function getWorkflowsByTag(tag: string): WorkflowDef[] {
  let result: WorkflowDef[] = [];
  for (let wf of WORKFLOW_REGISTRY) {
    for (let t of wf.tags) {
      if (t === tag) {
        result.push(wf);
        break;
      }
    }
  }
  return result;
}

export function getAllWorkflows(): WorkflowDef[] {
  return WORKFLOW_REGISTRY;
}
