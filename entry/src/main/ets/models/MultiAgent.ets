/**
 * Harmony Life OS — Multi-Agent 协作系统
 *
 * 多个 Agent 组成团队，围绕共同目标分工协作。
 * 一个 Agent 可以委派任务给其他 Agent。
 */

import { Agent } from './Agent'
import { StringMap } from './SharedTypes'

// ==================== Agent 角色 ====================

export type AgentRole =
  | 'coordinator'   // 协调者：分配任务、管理进度
  | 'executor'      // 执行者：完成具体工作
  | 'reviewer'      // 审查者：检查质量
  | 'communicator'  // 沟通者：对外汇报

// ==================== 团队状态 ====================

export type TeamStatus =
  | 'forming'       // 组建中
  | 'planning'      // 规划中
  | 'executing'     // 执行中
  | 'reviewing'     // 审查中
  | 'completed'     // 已完成
  | 'paused'        // 已暂停
  | 'failed'        // 失败

// ==================== 任务 ====================

export type SubtaskStatus =
  | 'pending'       // 待分配
  | 'assigned'      // 已分配
  | 'in_progress'   // 进行中
  | 'blocked'       // 被阻塞
  | 'done'          // 已完成
  | 'rejected'      // 被打回

export interface Subtask {
  id: string
  title: string
  description: string
  assignedTo: string         // agentId
  assignedRole: AgentRole
  status: SubtaskStatus
  priority: number           // 1-10
  dependencies: string[]     // 依赖的 subtask id 列表
  deliverables: string[]     // 交付物描述
  deadline: string           // ISO time
  startedAt: string
  completedAt: string
  result: string             // 完成结果
  reviewFeedback: string     // 审查反馈
  reviewAgent: string        // 审查者 agentId
}

// ==================== 团队定义 ====================

export interface AgentTeam {
  // 身份
  id: string
  name: string
  goal: string               // 团队目标
  description: string

  // 成员
  coordinator: string        // 协调者 agentId
  members: TeamMember[]

  // 任务
  subtasks: Subtask[]

  // 状态
  status: TeamStatus

  // 共享上下文
  sharedContext: TeamContext

  // 时间线
  createdAt: string
  startedAt: string
  completedAt: string
  deadline: string

  // 元信息
  tags: string[]
}

export interface TeamMember {
  agentId: string
  role: AgentRole
  joinedAt: string
  assignedSubtasks: string[]  // subtask id 列表
}

// ==================== 团队上下文 ====================

export interface TeamContext {
  // 项目信息
  projectName: string
  projectDescription: string
  requirements: string[]     // 需求列表
  constraints: string[]      // 约束条件
  references: string[]       // 参考资料

  // 共享知识
  sharedKnowledge: string    // 所有成员需要知道的信息
  terminology: StringMap  // 术语表

  // 进度
  progressReport: string     // 最新进度报告
  lastMeetingAt: string
  meetingNotes: string
}

// ==================== Agent 消息 ====================

export type MessageType =
  | 'delegate'      // 委派任务
  | 'query'         // 询问信息
  | 'response'      // 回复
  | 'review'        // 审查反馈
  | 'update'        // 进度更新
  | 'alert'         // 告警
  | 'broadcast'     // 广播

export interface AgentMessage {
  id: string
  type: MessageType
  fromAgent: string
  toAgent: string            // 'all' 表示广播
  subtaskId: string
  content: string
  timestamp: string
  attachments: string[]      // 附件引用
}

// ==================== 团队事件 ====================

export type TeamEventType =
  | 'team_created'
  | 'member_joined'
  | 'subtask_assigned'
  | 'subtask_completed'
  | 'subtask_rejected'
  | 'review_passed'
  | 'phase_changed'
  | 'team_completed'
  | 'team_failed'

export interface TeamEvent {
  id: string
  type: TeamEventType
  teamId: string
  agentId: string
  subtaskId: string
  description: string
  timestamp: string
}

// ==================== 团队模板 ====================

export interface TeamRoleDef {
  role: AgentRole
  agentId: string
  responsibility: string
  deliverable: string
}

export interface SubtaskTemplateDef {
  title: string
  description: string
  assignedRole: AgentRole
  priority: number
  dependsOn: number[]
}

export interface TeamTemplate {
  id: string
  name: string
  description: string
  agentRoles: TeamRoleDef[]
  subtaskTemplate: SubtaskTemplateDef[]
  estimatedDuration: number
  tags: string[]
}

// ==================== 编排结果 ====================

export interface OrchestrationResult {
  teamId: string
  goal: string
  subtaskCount: number
  agentCount: number
  estimatedDuration: number
  criticalPath: string[]     // 关键路径上的 subtask id
  warnings: string[]         // 风险预警
}
