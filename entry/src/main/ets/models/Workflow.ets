/**
 * Harmony Life OS — Workflow 系统
 *
 * Workflow 是多个 Skill 的有序执行链。
 * 支持暂停/恢复/重试/历史记录。
 */

import { Skill, SkillInputType, SkillOutputType } from './Skill'
import { StringMap } from './SharedTypes'

// ==================== 步骤状态 ====================

export type StepStatus =
  | 'pending'      // 等待执行
  | 'running'      // 执行中
  | 'paused'       // 已暂停
  | 'completed'    // 已完成
  | 'failed'       // 执行失败
  | 'skipped'      // 被跳过（条件不满足）

// ==================== 步骤输入来源 ====================

export type StepInputSource =
  | 'user'         // 用户提供
  | 'previous'     // 上一步的输出
  | 'step'         // 指定步骤的输出 { stepId: string }
  | 'external'     // 外部数据

// ==================== 步骤定义 ====================

export interface WorkflowStepDef {
  id: string
  name: string
  description: string
  skillId: string
  inputSource: StepInputSource
  inputStepId?: string        // 当 inputSource 为 'step' 时指定源步骤
  inputMapping?: string       // 输入数据的 key 映射
  timeout: number             // 超时时间（秒），0 表示不限制
  retryCount: number          // 失败重试次数
  retryDelay: number          // 重试间隔（秒）
  condition?: string          // 执行条件（暂预留）
  onError: 'stop' | 'skip' | 'retry'  // 错误处理策略
}

// ==================== 步骤运行时 ====================

export interface WorkflowStepRun {
  def: WorkflowStepDef
  status: StepStatus
  input: string               // 实际输入数据
  output: string              // 实际输出数据
  startedAt: string           // ISO time
  completedAt: string         // ISO time
  retryAttempt: number        // 当前重试次数
  error?: string              // 错误信息
}

// ==================== Workflow 状态 ====================

export type WorkflowStatus =
  | 'draft'       // 草稿
  | 'ready'       // 就绪，等待启动
  | 'running'     // 运行中
  | 'paused'      // 已暂停
  | 'completed'   // 已完成
  | 'failed'      // 执行失败
  | 'cancelled'   // 已取消

// ==================== 触发方式 ====================

export type WorkflowTrigger =
  | 'manual'       // 手动触发
  | 'scheduled'    // 定时触发（cron）
  | 'event'        // 事件触发
  | 'context'      // 上下文触发（检测到特定条件）

// ==================== 定时配置 ====================

export interface ScheduleConfig {
  cron: string               // cron 表达式
  timezone: string           // 时区，如 'Asia/Shanghai'
  skipIfMissed: boolean      // 错过是否补执行
}

// ==================== 事件触发配置 ====================

export interface EventTriggerConfig {
  eventType: string          // 事件类型名
  eventSource: string        // 事件来源
  filterExpression: string   // 事件过滤条件
}

// ==================== Workflow 实例 ====================

export interface WorkflowRun {
  // 身份
  runId: string              // 本次运行的唯一ID
  workflowDefId: string      // 对应的 Workflow 模板 ID

  // 状态
  status: WorkflowStatus
  currentStepIndex: number   // 当前执行到第几步

  // 步骤运行时列表
  steps: WorkflowStepRun[]

  // 输入输出
  initialInput: string       // 用户初始输入
  finalOutput: string        // 最终输出

  // 时间
  createdAt: string
  startedAt: string
  pausedAt: string
  resumedAt: string
  completedAt: string

  // 统计
  totalSteps: number
  completedSteps: number
  failedSteps: number
  totalDuration: number      // 总耗时（秒）

  // 暂停信息
  pauseReason: string
  canResume: boolean
}

// ==================== Workflow 执行上下文 ====================

export interface WorkflowContext {
  runId: string
  userId: string
  agentId: string            // 执行此 Workflow 的 Agent
  variables: StringMap  // 上下文变量
}

// ==================== 历史记录条目 ====================

export interface WorkflowHistoryEntry {
  runId: string
  workflowName: string
  status: WorkflowStatus
  startedAt: string
  completedAt: string
  totalDuration: number
  stepCount: number
  result: string             // 最终结果摘要
}

// ==================== Workflow 模板定义 ====================

export interface WorkflowDef {
  // 身份
  id: string
  name: string
  emoji: string
  description: string

  // 分类
  category: string           // 学习 | 工作 | 生活 | 娱乐

  // 触发
  trigger: WorkflowTrigger
  schedule?: ScheduleConfig
  eventTrigger?: EventTriggerConfig

  // 步骤链
  steps: WorkflowStepDef[]

  // 元信息
  estimatedTotalTime: number // 预估总耗时（秒）
  author: string
  version: string
  tags: string[]
}

// ==================== 暂停/恢复结果 ====================

export interface WorkflowPauseResult {
  success: boolean
  runId: string
  pausedAt: string
  pauseReason: string
  currentStep: number
}

export interface WorkflowResumeResult {
  success: boolean
  runId: string
  resumedAt: string
  resumeFromStep: number
}

// ==================== 工厂函数 ====================

export function createWorkflowRun(def: WorkflowDef, userInput: string): WorkflowRun {
  let runId = 'wf_' + Date.now().toString();
  let steps: WorkflowStepRun[] = [];

  for (let i = 0; i < def.steps.length; i++) {
    let s = def.steps[i];
    let step: WorkflowStepRun = {
      def: s,
      status: 'pending',
      input: '',
      output: '',
      startedAt: '',
      completedAt: '',
      retryAttempt: 0
    };
    steps.push(step);
  }

  return {
    runId: runId,
    workflowDefId: def.id,
    status: 'ready',
    currentStepIndex: 0,
    steps: steps,
    initialInput: userInput,
    finalOutput: '',
    createdAt: new Date().toISOString(),
    startedAt: '',
    pausedAt: '',
    resumedAt: '',
    completedAt: '',
    totalSteps: def.steps.length,
    completedSteps: 0,
    failedSteps: 0,
    totalDuration: 0,
    pauseReason: '',
    canResume: false
  };
}

export function isWorkflowActive(status: WorkflowStatus): boolean {
  return status === 'running' || status === 'paused';
}

export function isWorkflowTerminal(status: WorkflowStatus): boolean {
  return status === 'completed' || status === 'failed' || status === 'cancelled';
}
