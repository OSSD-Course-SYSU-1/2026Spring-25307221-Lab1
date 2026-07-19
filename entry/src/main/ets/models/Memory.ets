/**
 * Harmony Life OS — Memory 系统
 *
 * AI 长期记忆。跨会话持久化，Agent 据此提供个性化服务。
 * 记忆按类型分类，支持自动提取和手动编辑。
 */

// ==================== 记忆类型 ====================

export type MemoryType =
  | 'profile'       // 个人档案
  | 'major'         // 专业与课程
  | 'exam'          // 考试记录
  | 'project'       // 项目经历
  | 'goal'          // 目标与计划
  | 'interest'      // 兴趣爱好
  | 'preference'    // 偏好设置
  | 'chat_summary'  // 聊天总结
  | 'milestone'     // 重要节点
  | 'custom'        // 自定义

// ==================== 记忆条目 ====================

export interface MemoryEntry {
  id: string
  type: MemoryType
  title: string
  content: string            // 主要内容（可长可短）
  tags: string[]             // 标签，便于检索
  importance: number         // 重要性 1-10
  source: string             // 来源：'user_input' | 'agent_infer' | 'system'
  agentId: string            // 哪个 Agent 创建的
  createdAt: string          // ISO time
  updatedAt: string          // ISO time
  expiresAt: string          // 过期时间，空表示永不过期
  metadata: Record<string, string>  // 扩展字段
}

// ==================== 记忆快照（注入Agent上下文用） ====================

export interface MemorySnapshot {
  profile: string            // 用户档案摘要
  recentChats: string        // 最近聊天摘要
  keyFacts: string           // 关键信息
  activeGoals: string        // 当前目标
  preferences: string        // 偏好
  contextPrompt: string      // 可直接注入 systemPrompt 的文本
}

// ==================== 记忆更新事件 ====================

export interface MemoryEvent {
  type: 'created' | 'updated' | 'deleted'
  entry: MemoryEntry
  timestamp: string
}

// ==================== 记忆查询参数 ====================

export interface MemoryQuery {
  types?: MemoryType[]
  tags?: string[]
  agentId?: string
  keyword?: string
  minImportance?: number
  limit?: number
  sortBy?: 'createdAt' | 'updatedAt' | 'importance'
  sortOrder?: 'asc' | 'desc'
}

// ==================== 记忆统计 ====================

export interface MemoryStats {
  totalEntries: number
  byType: Record<string, number>
  byAgent: Record<string, number>
  oldestEntry: string
  newestEntry: string
}

// ==================== 聊天总结格式 ====================

export interface ChatSummary {
  conversationId: string
  agentId: string
  startedAt: string
  endedAt: string
  messageCount: number
  topic: string              // 对话主题（5字以内）
  summary: string            // 1-2句摘要
  keyTakeaways: string[]     // 关键收获
  userMood: string           // 对话中用户情绪
  actionItems: string[]      // 待办事项
}
