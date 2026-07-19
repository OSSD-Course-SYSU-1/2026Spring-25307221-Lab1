/**
 * Harmony Life OS — Agent 核心模型
 *
 * 一个 Agent 是拥有技能、工作流、记忆的完整 AI 单元。
 * 按模块组织，支持后续无限扩展。
 */

// ==================== 分类 ====================

export type AgentCategory = '学习' | '工作' | '生活' | '娱乐' | '心理' | '创作'

export const AGENT_CATEGORIES: AgentCategory[] = [
  '学习', '工作', '生活', '娱乐', '心理', '创作'
]

// ==================== 技能 ====================

export interface AgentSkill {
  id: string
  name: string
  description: string
  inputType: 'text' | 'file' | 'voice' | 'image' | 'mixed'
  outputType: 'text' | 'document' | 'structured' | 'void'
}

// ==================== 工作流 ====================

export interface WorkflowStep {
  id: string
  name: string
  skillId: string
  description: string
}

export interface AgentWorkflow {
  id: string
  name: string
  description: string
  steps: WorkflowStep[]
  trigger: 'manual' | 'scheduled' | 'event'
}

// ==================== 记忆 ====================

export interface AgentMemory {
  enabled: boolean
  maxTurns: number            // 最大记忆轮数
  persistAcrossSessions: boolean  // 跨会话持久化
  rememberUserProfile: boolean    // 记住用户偏好
}

// ==================== 元信息 ====================

export interface AgentMeta {
  author: string
  version: string
  createdAt: string           // ISO date string
  updatedAt: string           // ISO date string
  license: string             // 'MIT' | 'Apache-2.0' | 'internal'
}

// ==================== 评分 ====================

export interface AgentRating {
  score: number               // 1.0 - 5.0
  reviewCount: number
  usageCount: number
}

// ==================== 外观 ====================

export interface AgentAppearance {
  emoji: string
  iconColor: string           // '#4A90D9'
  bgColor: string             // '#EEF4FB'
  darkIconColor?: string      // 深色模式
  darkBgColor?: string        // 深色模式
}

// ==================== 交互 ====================

export type AgentInterface = 'chat' | 'interactive' | 'tool'

export interface AgentInteraction {
  interfaceType: AgentInterface
  greeting: string
  quickActions: string[]      // 快捷操作文本
  customUI?: string           // 自定义UI组件引用
}

// ==================== 社交信息 ====================

export interface AgentSocial {
  tags: string[]
  likeCount: number
  shareCount: number
  isOfficial: boolean         // 是否官方Agent
  isVerified: boolean         // 是否已认证
}

// ==================== 运行时 ====================

export interface AgentRuntime {
  model: string               // LLM模型名
  temperature: number         // 0.0 - 2.0
  maxTokens: number
  topP: number
  streamEnabled: boolean
}

// ==================== Agent 主接口 ====================

export interface Agent {
  // 身份
  id: string
  name: string
  description: string
  category: AgentCategory

  // 提示词
  systemPrompt: string

  // 子模块
  skills: AgentSkill[]
  workflows: AgentWorkflow[]
  memory: AgentMemory

  // 外观
  appearance: AgentAppearance

  // 交互
  interaction: AgentInteraction

  // 评分
  rating: AgentRating

  // 社交
  social: AgentSocial

  // 元信息
  meta: AgentMeta

  // 运行时（可选，使用默认值）
  runtime?: AgentRuntime
}

// ==================== 工厂函数 ====================

/**
 * 创建默认 Agent 配置（方便快速定义新 Agent）
 */
export function createAgentDefaults(overrides: Partial<Agent>): Agent {
  return {
    id: overrides.id || '',
    name: overrides.name || '',
    description: overrides.description || '',
    category: overrides.category || '生活',
    systemPrompt: overrides.systemPrompt || '',
    skills: overrides.skills || [],
    workflows: overrides.workflows || [],
    memory: overrides.memory || {
      enabled: true,
      maxTurns: 20,
      persistAcrossSessions: false,
      rememberUserProfile: true
    },
    appearance: overrides.appearance || {
      emoji: '🤖',
      iconColor: '#666',
      bgColor: '#F5F5F5'
    },
    interaction: overrides.interaction || {
      interfaceType: 'chat',
      greeting: '你好！',
      quickActions: []
    },
    rating: overrides.rating || {
      score: 0,
      reviewCount: 0,
      usageCount: 0
    },
    social: overrides.social || {
      tags: [],
      likeCount: 0,
      shareCount: 0,
      isOfficial: false,
      isVerified: false
    },
    meta: overrides.meta || {
      author: 'Harmony Life OS',
      version: '1.0.0',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      license: 'internal'
    },
    runtime: overrides.runtime
  }
}
