/**
 * Harmony Life OS — Skill 系统
 *
 * Skill 是 Agent 的原子能力单元。
 * 每个 Skill 可独立执行，也可组合成 Workflow。
 */

// ==================== 输入/输出类型 ====================

export type SkillInputType =
  | 'text'        // 纯文本
  | 'file'        // 文件（PDF/Word/PPT/图片）
  | 'voice'       // 语音
  | 'image'       // 图片
  | 'link'        // 链接/URL
  | 'mixed'       // 混合输入

export type SkillOutputType =
  | 'text'        // 纯文本
  | 'markdown'    // Markdown格式
  | 'document'    // 结构化文档
  | 'table'       // 表格数据
  | 'chart'       // 图表
  | 'image'       // 图片
  | 'code'        // 代码
  | 'structured'  // 结构化JSON
  | 'void'        // 无输出（仅执行）

// ==================== UI 模式 ====================

export type SkillUIMode =
  | 'chat'        // 聊天对话中内联
  | 'split'       // 左右/上下分屏
  | 'fullscreen'  // 全屏覆盖
  | 'dialog'      // 弹窗
  | 'inline'      // 行内展示

// ==================== Skill 参数 ====================

export interface SkillParam {
  key: string
  label: string
  type: 'string' | 'number' | 'boolean' | 'select' | 'file'
  required: boolean
  defaultValue?: string
  options?: string[]  // select 类型的选项
  placeholder?: string
  description?: string
}

// ==================== Skill 示例 ====================

export interface SkillExample {
  input: string
  output: string
  description: string
}

// ==================== Skill 定义 ====================

export interface Skill {
  // 身份
  id: string
  name: string
  emoji: string
  description: string

  // 分类
  group: SkillGroup

  // 输入输出
  inputType: SkillInputType
  outputType: SkillOutputType

  // UI
  uiMode: SkillUIMode

  // 参数
  params: SkillParam[]

  // 示例
  examples: SkillExample[]

  // 提示词模板（{input} 会被替换为用户输入）
  promptTemplate: string

  // 元信息
  estimatedTime: number    // 预估耗时（秒）
  requiresNetwork: boolean // 是否需要网络
  isAsync: boolean         // 是否异步执行
}

// ==================== Skill 分组 ====================

export type SkillGroup =
  | '文档处理'
  | '知识学习'
  | '内容创作'
  | '分析诊断'
  | '翻译交流'
  | '生活服务'
  | '趣味互动'
  | '创意设计'

export const SKILL_GROUPS: SkillGroup[] = [
  '文档处理', '知识学习', '内容创作', '分析诊断',
  '翻译交流', '生活服务', '趣味互动', '创意设计'
]

// ==================== Agent-Skill 关联 ====================

export interface AgentSkillBinding {
  agentId: string
  skillId: string
  isDefault: boolean     // 是否默认启用
  customPrompt?: string  // 可选：覆盖 Skill 默认 prompt
  order: number          // 在 Agent 页面的展示顺序
}
