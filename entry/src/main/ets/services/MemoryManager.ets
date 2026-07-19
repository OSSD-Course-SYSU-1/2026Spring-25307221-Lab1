/**
 * Harmony Life OS — MemoryManager
 *
 * 记忆的创建、查询、更新、删除、快照生成。
 * 当前使用内存存储，后续可替换为 Preferences/数据库。
 */

import {
  MemoryEntry, MemoryType, MemorySnapshot, MemoryQuery,
  MemoryStats, MemoryEvent, ChatSummary
} from '../models/Memory'

// ==================== MemoryManager ====================

export class MemoryManager {
  private static instance: MemoryManager | null = null
  private entries: MemoryEntry[] = []
  private listeners: ((event: MemoryEvent) => void)[] = []

  private constructor() {
    this.initDefaultMemories()
  }

  static getInstance(): MemoryManager {
    if (!MemoryManager.instance) {
      MemoryManager.instance = new MemoryManager()
    }
    return MemoryManager.instance
  }

  // ==================== CRUD ====================

  /**
   * 创建一条记忆
   */
  create(
    type: MemoryType,
    title: string,
    content: string,
    options?: {
      tags?: string[], importance?: number, source?: string,
      agentId?: string, expiresAt?: string, metadata?: Record<string, string>
    }
  ): MemoryEntry {
    let entry: MemoryEntry = {
      id: 'mem_' + Date.now().toString() + '_' + Math.floor(Math.random() * 1000).toString(),
      type: type,
      title: title,
      content: content,
      tags: options?.tags || [],
      importance: options?.importance || 5,
      source: options?.source || 'user_input',
      agentId: options?.agentId || 'system',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      expiresAt: options?.expiresAt || '',
      metadata: options?.metadata || {}
    }
    this.entries.push(entry)
    this.notify({ type: 'created', entry: entry, timestamp: entry.createdAt })
    return entry
  }

  /**
   * 更新一条记忆
   */
  update(id: string, updates: Partial<MemoryEntry>): MemoryEntry | null {
    for (let entry of this.entries) {
      if (entry.id === id) {
        if (updates.title !== undefined) { entry.title = updates.title }
        if (updates.content !== undefined) { entry.content = updates.content }
        if (updates.tags !== undefined) { entry.tags = updates.tags }
        if (updates.importance !== undefined) { entry.importance = updates.importance }
        if (updates.metadata !== undefined) { entry.metadata = updates.metadata }
        entry.updatedAt = new Date().toISOString()
        this.notify({ type: 'updated', entry: entry, timestamp: entry.updatedAt })
        return entry
      }
    }
    return null
  }

  /**
   * 删除一条记忆
   */
  delete(id: string): boolean {
    for (let i = 0; i < this.entries.length; i++) {
      if (this.entries[i].id === id) {
        let removed = this.entries[i]
        this.entries.splice(i, 1)
        this.notify({ type: 'deleted', entry: removed, timestamp: new Date().toISOString() })
        return true
      }
    }
    return false
  }

  /**
   * 按ID获取
   */
  get(id: string): MemoryEntry | undefined {
    for (let entry of this.entries) {
      if (entry.id === id) { return entry }
    }
    return undefined
  }

  // ==================== 查询 ====================

  /**
   * 灵活查询记忆
   */
  query(params: MemoryQuery): MemoryEntry[] {
    let result: MemoryEntry[] = []

    for (let entry of this.entries) {
      // 类型过滤
      if (params.types && params.types.length > 0) {
        let match = false
        for (let t of params.types) {
          if (entry.type === t) { match = true; break }
        }
        if (!match) { continue }
      }
      // 标签过滤
      if (params.tags && params.tags.length > 0) {
        let match = false
        for (let t of params.tags) {
          for (let et of entry.tags) {
            if (et === t) { match = true; break }
          }
          if (match) { break }
        }
        if (!match) { continue }
      }
      // Agent过滤
      if (params.agentId && entry.agentId !== params.agentId) { continue }
      // 关键词搜索
      if (params.keyword) {
        let kw = params.keyword.toLowerCase()
        if (!entry.title.toLowerCase().includes(kw) &&
            !entry.content.toLowerCase().includes(kw)) {
          continue
        }
      }
      // 重要性过滤
      if (params.minImportance && entry.importance < params.minImportance) { continue }
      result.push(entry)
    }

    // 排序
    let sortKey = params.sortBy || 'updatedAt'
    let order = params.sortOrder || 'desc'
    for (let i = 0; i < result.length - 1; i++) {
      for (let j = i + 1; j < result.length; j++) {
        let a = result[i][sortKey] as string
        let b = result[j][sortKey] as string
        if ((order === 'desc' && a < b) || (order === 'asc' && a > b)) {
          let temp = result[i]
          result[i] = result[j]
          result[j] = temp
        }
      }
    }

    // 限制数量
    if (params.limit && result.length > params.limit) {
      result = result.slice(0, params.limit)
    }

    return result
  }

  /**
   * 获取某类型的全部记忆
   */
  getByType(type: MemoryType): MemoryEntry[] {
    return this.query({ types: [type], sortBy: 'updatedAt', sortOrder: 'desc' })
  }

  /**
   * 获取高重要性记忆
   */
  getImportant(minImportance: number = 8): MemoryEntry[] {
    return this.query({ minImportance: minImportance, sortBy: 'importance' })
  }

  /**
   * 关键词搜索
   */
  search(keyword: string, limit: number = 10): MemoryEntry[] {
    return this.query({ keyword: keyword, limit: limit, sortBy: 'updatedAt' })
  }

  // ==================== 快捷记忆方法 ====================

  /**
   * 记录专业信息
   */
  rememberMajor(major: string, courses: string[]): MemoryEntry[] {
    let results: MemoryEntry[] = []
    results.push(this.create('major', '主修专业', major, { importance: 9, source: 'user_input' }))
    for (let course of courses) {
      results.push(this.create('major', '课程', course, {
        tags: ['课程', major], importance: 7, source: 'user_input'
      }))
    }
    return results
  }

  /**
   * 记录考试信息
   */
  rememberExam(subject: string, date: string, notes: string): MemoryEntry {
    return this.create('exam', subject + '考试', '日期：' + date + '\n备注：' + notes, {
      tags: ['考试', subject], importance: 10, source: 'user_input',
      metadata: { examDate: date, subject: subject }
    })
  }

  /**
   * 记录目标
   */
  rememberGoal(title: string, description: string, deadline: string): MemoryEntry {
    return this.create('goal', title, description, {
      tags: ['目标'], importance: 9, source: 'user_input',
      metadata: { deadline: deadline }
    })
  }

  /**
   * 记录兴趣爱好
   */
  rememberInterest(interest: string): MemoryEntry {
    return this.create('interest', interest, '用户对' + interest + '感兴趣', {
      tags: ['爱好'], importance: 6, source: 'user_input'
    })
  }

  /**
   * 记录偏好
   */
  rememberPreference(key: string, value: string): MemoryEntry {
    return this.create('preference', key, value, { importance: 7, source: 'user_input' })
  }

  /**
   * 保存聊天总结
   */
  saveChatSummary(summary: ChatSummary): MemoryEntry {
    let content = '话题：' + summary.topic + '\n' +
                  '摘要：' + summary.summary + '\n' +
                  '关键收获：' + summary.keyTakeaways.join('；') + '\n' +
                  '用户情绪：' + summary.userMood + '\n' +
                  '待办：' + summary.actionItems.join('；')

    return this.create('chat_summary', '对话总结 - ' + summary.topic, content, {
      tags: ['对话', summary.agentId],
      importance: 8,
      source: 'agent_infer',
      agentId: summary.agentId,
      metadata: {
        conversationId: summary.conversationId,
        messageCount: summary.messageCount.toString(),
        startedAt: summary.startedAt,
        endedAt: summary.endedAt
      }
    })
  }

  /**
   * 记录重要节点
   */
  rememberMilestone(title: string, description: string): MemoryEntry {
    return this.create('milestone', title, description, {
      importance: 8, source: 'system', tags: ['里程碑']
    })
  }

  // ==================== Agent 上下文生成 ====================

  /**
   * 生成记忆快照 — 可注入 Agent systemPrompt
   */
  generateSnapshot(agentId?: string): MemorySnapshot {
    let profile = ''
    let recentChats = ''
    let keyFacts = ''
    let activeGoals = ''
    let preferences = ''
    let contextPrompt = ''

    // 个人档案
    let profileEntries = this.query({ types: ['profile'], limit: 3 })
    for (let e of profileEntries) {
      profile += '- ' + e.title + '：' + e.content + '\n'
    }

    // 专业
    let majorEntries = this.query({ types: ['major'], limit: 10 })
    for (let e of majorEntries) {
      profile += '- ' + e.title + '：' + e.content + '\n'
    }

    // 最近对话
    let chatSummaries = this.query({ types: ['chat_summary'], limit: 5 })
    for (let e of chatSummaries) {
      recentChats += '- [' + e.title + '] ' + e.content.split('\n')[1] + '\n'
    }

    // 关键信息（高重要性）
    let important = this.query({ minImportance: 8, limit: 10 })
    for (let e of important) {
      keyFacts += '- [' + e.type + '] ' + e.title + '：' + e.content.substring(0, 100) + '\n'
    }

    // 活跃目标
    let goals = this.query({ types: ['goal'], limit: 5 })
    for (let e of goals) {
      activeGoals += '- ' + e.title + '（截止：' + (e.metadata['deadline'] || '未设定') + '）\n'
    }

    // 偏好
    let prefs = this.query({ types: ['preference'], limit: 10 })
    for (let e of prefs) {
      preferences += '- ' + e.title + '：' + e.content + '\n'
    }

    // 构建注入 prompt
    contextPrompt = this.buildContextPrompt(profile, recentChats, keyFacts, activeGoals, preferences)

    return {
      profile: profile,
      recentChats: recentChats,
      keyFacts: keyFacts,
      activeGoals: activeGoals,
      preferences: preferences,
      contextPrompt: contextPrompt
    }
  }

  /**
   * 构建可注入 systemPrompt 的记忆上下文
   */
  private buildContextPrompt(
    profile: string, chats: string, facts: string, goals: string, prefs: string
  ): string {
    let parts: string[] = []

    if (profile.trim()) {
      parts.push('## 用户档案\n' + profile.trim())
    }
    if (facts.trim()) {
      parts.push('## 重要信息\n' + facts.trim())
    }
    if (goals.trim()) {
      parts.push('## 当前目标\n' + goals.trim())
    }
    if (prefs.trim()) {
      parts.push('## 用户偏好\n' + prefs.trim())
    }
    if (chats.trim()) {
      parts.push('## 最近对话\n' + chats.trim())
    }

    if (parts.length === 0) {
      return ''
    }

    return '\n\n---\n以下是你关于这位用户的记忆，请在对话中自然运用这些信息：\n\n' +
           parts.join('\n\n') +
           '\n\n注意：不要刻意强调"我记得你之前说过..."，自然地融入对话即可。'
  }

  // ==================== 统计 ====================

  /**
   * 获取记忆统计
   */
  getStats(): MemoryStats {
    let byType: Record<string, number> = {}
    let byAgent: Record<string, number> = {}
    let oldest = ''
    let newest = ''

    for (let entry of this.entries) {
      // 按类型统计
      if (byType[entry.type]) {
        byType[entry.type] = byType[entry.type] + 1
      } else {
        byType[entry.type] = 1
      }
      // 按Agent统计
      if (byAgent[entry.agentId]) {
        byAgent[entry.agentId] = byAgent[entry.agentId] + 1
      } else {
        byAgent[entry.agentId] = 1
      }
      // 最旧/最新
      if (!oldest || entry.createdAt < oldest) { oldest = entry.createdAt }
      if (!newest || entry.createdAt > newest) { newest = entry.createdAt }
    }

    return {
      totalEntries: this.entries.length,
      byType: byType,
      byAgent: byAgent,
      oldestEntry: oldest,
      newestEntry: newest
    }
  }

  /**
   * 清空所有记忆
   */
  clear(): void {
    this.entries = []
  }

  // ==================== 事件监听 ====================

  /**
   * 注册记忆变更监听
   */
  onMemoryChange(listener: (event: MemoryEvent) => void): void {
    this.listeners.push(listener)
  }

  private notify(event: MemoryEvent): void {
    for (let l of this.listeners) {
      l(event)
    }
  }

  // ==================== 初始化默认记忆 ====================

  private initDefaultMemories(): void {
    // 预置一些示例记忆，展示系统的能力
    this.create('profile', '身份', '在校大学生，电子信息工程专业', {
      importance: 10, source: 'system', tags: ['身份', '学生']
    })
    this.create('major', '核心课程', '高等数学、线性代数、模电数电、信号与系统、DSP、C语言、Python、嵌入式', {
      importance: 9, source: 'system', tags: ['课程', 'EE']
    })
    this.create('goal', '短期目标', '期末考试成绩达到85分以上', {
      importance: 9, source: 'system', tags: ['目标', '学习'],
      metadata: { deadline: '2026-07-15' }
    })
    this.create('preference', '学习时间', '晚上8点到11点效率最高', {
      importance: 7, source: 'system', tags: ['偏好', '作息']
    })
    this.create('interest', '游戏', '喜欢王者荣耀和无畏契约', {
      importance: 6, source: 'system', tags: ['爱好', '游戏']
    })
  }
}
