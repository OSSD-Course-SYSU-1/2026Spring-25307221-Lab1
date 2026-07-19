/**
 * Harmony Life OS — Team Orchestrator
 *
 * 多 Agent 编排引擎。
 * 接收用户目标 → 自动拆解任务 → 分配 Agent → 监控执行 → 协调交付。
 */

import {
  AgentTeam, TeamMember, Subtask, TeamContext,
  TeamStatus, SubtaskStatus, AgentRole,
  AgentMessage, MessageType,
  TeamEvent, TeamEventType,
  TeamTemplate, OrchestrationResult
} from '../models/MultiAgent'
import { Agent } from '../models/Agent'
import { getAgentById } from '../data/agents/AgentRegistry'

// ==================== Team Orchestrator ====================

export class TeamOrchestrator {
  private static instance: TeamOrchestrator | null = null
  private activeTeams: AgentTeam[] = []
  private completedTeams: AgentTeam[] = []
  private messageLog: AgentMessage[] = []
  private eventLog: TeamEvent[] = []
  private listeners: ((event: TeamEvent) => void)[] = []

  private constructor() {}

  static getInstance(): TeamOrchestrator {
    if (!TeamOrchestrator.instance) {
      TeamOrchestrator.instance = new TeamOrchestrator()
    }
    return TeamOrchestrator.instance
  }

  // ==================== 团队创建 ====================

  /**
   * 从模板创建团队
   */
  createTeamFromTemplate(
    templateId: string,
    goal: string,
    projectDescription: string
  ): AgentTeam | null {
    let template = getTemplateById(templateId)
    if (!template) { return null }

    let teamId = 'team_' + Date.now().toString()
    let members: TeamMember[] = []
    let subtasks: Subtask[] = []

    // 创建成员
    for (let roleDef of template.agentRoles) {
      let member: TeamMember = {
        agentId: roleDef.agentId,
        role: roleDef.role,
        joinedAt: new Date().toISOString(),
        assignedSubtasks: []
      }
      members.push(member)
    }

    // 创建子任务
    for (let i = 0; i < template.subtaskTemplate.length; i++) {
      let st = template.subtaskTemplate[i]
      let deps: string[] = []
      for (let depIdx of st.dependsOn) {
        if (depIdx < subtasks.length) {
          deps.push(subtasks[depIdx].id)
        }
      }

      // 找到对应角色的 Agent
      let assignee = ''
      for (let m of members) {
        if (m.role === st.assignedRole) {
          assignee = m.agentId
          m.assignedSubtasks.push('sub_' + (i + 1).toString())
          break
        }
      }

      let subtask: Subtask = {
        id: 'sub_' + (i + 1).toString(),
        title: st.title,
        description: st.description,
        assignedTo: assignee,
        assignedRole: st.assignedRole,
        status: 'pending',
        priority: st.priority,
        dependencies: deps,
        deliverables: [],
        deadline: '',
        startedAt: '',
        completedAt: '',
        result: '',
        reviewFeedback: '',
        reviewAgent: members.length > 0 ?
          (members[members.length - 1].role === 'reviewer' ?
            members[members.length - 1].agentId : '') : ''
      }
      subtasks.push(subtask)
    }

    // 创建团队上下文
    let context: TeamContext = {
      projectName: template.name,
      projectDescription: projectDescription || goal,
      requirements: [],
      constraints: [],
      references: [],
      sharedKnowledge: '',
      terminology: {},
      progressReport: '团队刚组建，准备开始规划',
      lastMeetingAt: '',
      meetingNotes: ''
    }

    let team: AgentTeam = {
      id: teamId,
      name: template.name + '团队',
      goal: goal,
      description: projectDescription,
      coordinator: members.length > 0 && members[0].role === 'coordinator' ?
        members[0].agentId : '',
      members: members,
      subtasks: subtasks,
      status: 'forming',
      sharedContext: context,
      createdAt: new Date().toISOString(),
      startedAt: '',
      completedAt: '',
      deadline: '',
      tags: template.tags
    }

    this.activeTeams.push(team)
    this.emit('team_created', team.id, '', '', '团队「' + team.name + '」已创建')
    return team
  }

  /**
   * 启动团队（开始执行）
   */
  startTeam(teamId: string): boolean {
    let team = this.getTeam(teamId)
    if (!team || team.status !== 'forming') { return false }

    team.status = 'planning'
    team.startedAt = new Date().toISOString()
    this.emit('phase_changed', teamId, '', '', '进入规划阶段')

    // 自定进入执行阶段
    team.status = 'executing'
    // 激活无依赖的任务
    this.activateReadySubtasks(team)

    this.emit('phase_changed', teamId, '', '', '进入执行阶段')
    return true
  }

  /**
   * 激活所有依赖已满足的待分配任务
   */
  private activateReadySubtasks(team: AgentTeam): void {
    for (let sub of team.subtasks) {
      if (sub.status === 'pending' || sub.status === 'assigned') {
        let depsMet = true
        for (let depId of sub.dependencies) {
          let dep = this.findSubtask(team, depId)
          if (!dep || dep.status !== 'done') {
            depsMet = false
            break
          }
        }
        if (depsMet && sub.status === 'pending') {
          sub.status = 'assigned'
          this.emit('subtask_assigned', team.id, sub.assignedTo, sub.id,
            '任务「' + sub.title + '」已分配给 Agent')
        }
      }
    }
  }

  // ==================== 任务操作 ====================

  /**
   * Agent 开始执行子任务
   */
  startSubtask(teamId: string, subtaskId: string): boolean {
    let sub = this.findSubtaskInTeam(teamId, subtaskId)
    if (!sub || sub.status !== 'assigned') { return false }

    sub.status = 'in_progress'
    sub.startedAt = new Date().toISOString()
    return true
  }

  /**
   * Agent 完成子任务
   */
  completeSubtask(teamId: string, subtaskId: string, result: string): boolean {
    let team = this.getTeam(teamId)
    if (!team) { return false }
    let sub = this.findSubtask(team, subtaskId)
    if (!sub || sub.status !== 'in_progress') { return false }

    sub.status = 'done'
    sub.completedAt = new Date().toISOString()
    sub.result = result

    this.emit('subtask_completed', teamId, sub.assignedTo, subtaskId,
      '任务「' + sub.title + '」已完成')

    // 检查是否所有任务完成
    this.activateReadySubtasks(team)
    this.checkTeamCompletion(team)

    return true
  }

  /**
   * 审查者打回任务
   */
  rejectSubtask(teamId: string, subtaskId: string, feedback: string): boolean {
    let sub = this.findSubtaskInTeam(teamId, subtaskId)
    if (!sub || sub.status !== 'done') { return false }

    sub.status = 'in_progress'
    sub.reviewFeedback = feedback
    this.emit('subtask_rejected', teamId, '', subtaskId,
      '任务被打回：' + feedback)
    return true
  }

  // ==================== 团队状态管理 ====================

  /**
   * 暂停团队
   */
  pauseTeam(teamId: string): boolean {
    let team = this.getTeam(teamId)
    if (!team || team.status !== 'executing') { return false }
    team.status = 'paused'
    this.emit('phase_changed', teamId, '', '', '团队已暂停')
    return true
  }

  /**
   * 恢复团队
   */
  resumeTeam(teamId: string): boolean {
    let team = this.getTeam(teamId)
    if (!team || team.status !== 'paused') { return false }
    team.status = 'executing'
    this.emit('phase_changed', teamId, '', '', '团队已恢复')
    return true
  }

  /**
   * 检查团队是否全部完成
   */
  private checkTeamCompletion(team: AgentTeam): void {
    let allDone = true
    for (let sub of team.subtasks) {
      if (sub.status !== 'done') {
        allDone = false
        break
      }
    }
    if (allDone) {
      team.status = 'completed'
      team.completedAt = new Date().toISOString()
      this.emit('team_completed', team.id, '', '', '🎉 团队任务全部完成！')

      // 移动到已完成列表
      for (let i = 0; i < this.activeTeams.length; i++) {
        if (this.activeTeams[i].id === team.id) {
          this.activeTeams.splice(i, 1)
          break
        }
      }
      this.completedTeams.push(team)
    }
  }

  // ==================== Agent 消息 ====================

  /**
   * Agent 之间发送消息
   */
  sendMessage(
    fromAgent: string, toAgent: string, type: MessageType,
    subtaskId: string, content: string
  ): AgentMessage {
    let msg: AgentMessage = {
      id: 'msg_' + Date.now().toString(),
      type: type,
      fromAgent: fromAgent,
      toAgent: toAgent,
      subtaskId: subtaskId,
      content: content,
      timestamp: new Date().toISOString(),
      attachments: []
    }
    this.messageLog.push(msg)
    return msg
  }

  /**
   * 查看 Agent 收件箱
   */
  getInbox(agentId: string): AgentMessage[] {
    let inbox: AgentMessage[] = []
    for (let msg of this.messageLog) {
      if (msg.toAgent === agentId || msg.toAgent === 'all') {
        inbox.push(msg)
      }
    }
    return inbox
  }

  // ==================== 查询 ====================

  getTeam(teamId: string): AgentTeam | undefined {
    for (let t of this.activeTeams) {
      if (t.id === teamId) { return t }
    }
    for (let t of this.completedTeams) {
      if (t.id === teamId) { return t }
    }
    return undefined
  }

  getActiveTeams(): AgentTeam[] { return this.activeTeams }

  getCompletedTeams(): AgentTeam[] { return this.completedTeams }

  getTeamSubtasks(teamId: string): Subtask[] {
    let team = this.getTeam(teamId)
    return team ? team.subtasks : []
  }

  private findSubtask(team: AgentTeam, id: string): Subtask | undefined {
    for (let s of team.subtasks) {
      if (s.id === id) { return s }
    }
    return undefined
  }

  private findSubtaskInTeam(teamId: string, subtaskId: string): Subtask | undefined {
    let team = this.getTeam(teamId)
    return team ? this.findSubtask(team, subtaskId) : undefined
  }

  getTeamProgress(teamId: string): string {
    let team = this.getTeam(teamId)
    if (!team) { return '团队不存在' }
    let done = 0
    for (let s of team.subtasks) {
      if (s.status === 'done') { done++ }
    }
    let total = team.subtasks.length
    let pct = total > 0 ? Math.round(done * 100 / total) : 0
    return '进度：' + done.toString() + '/' + total.toString() + '（' + pct.toString() + '%）状态：' + team.status
  }

  // ==================== 事件 ====================

  private emit(
    type: TeamEventType, teamId: string, agentId: string,
    subtaskId: string, description: string
  ): void {
    let event: TeamEvent = {
      id: 'evt_' + Date.now().toString(),
      type: type,
      teamId: teamId,
      agentId: agentId,
      subtaskId: subtaskId,
      description: description,
      timestamp: new Date().toISOString()
    }
    this.eventLog.push(event)
    for (let l of this.listeners) { l(event) }
  }

  onTeamEvent(listener: (event: TeamEvent) => void): void {
    this.listeners.push(listener)
  }

  getEventLog(teamId: string): TeamEvent[] {
    let result: TeamEvent[] = []
    for (let e of this.eventLog) {
      if (e.teamId === teamId) { result.push(e) }
    }
    return result
  }

  // ==================== 清理 ====================

  /**
   * 清空所有团队（开发调试用）
   */
  reset(): void {
    this.activeTeams = []
    this.completedTeams = []
    this.messageLog = []
    this.eventLog = []
  }
}

// ==================== 预定义团队模板 ====================

const TEMPLATES: TeamTemplate[] = [
  {
    id: 'tpl_challenge_cup',
    name: '挑战杯备战',
    description: '从项目规划到答辩的全流程多Agent协作',
    agentRoles: [
      { role: 'coordinator', agentId: 'ai_interview',
        responsibility: '项目经理：分解需求、制定计划、协调进度、风险管控',
        deliverable: '项目计划书 + 甘特图 + 风险清单' },
      { role: 'executor', agentId: 'ai_coder',
        responsibility: '技术负责人：架构设计、核心代码开发、技术文档',
        deliverable: '源码 + 技术文档 + 部署说明' },
      { role: 'executor', agentId: 'ai_teacher',
        responsibility: 'PPT设计师：制作答辩PPT、美化排版、设计动效',
        deliverable: '答辩PPT一套（15-20页）' },
      { role: 'executor', agentId: 'ai_teacher',
        responsibility: '论文主笔：撰写论文、整理参考文献、排版校对',
        deliverable: '论文完整稿 + 参考文献列表' },
      { role: 'executor', agentId: 'ai_interview',
        responsibility: '答辩教练：模拟答辩提问、优化回答、打磨台风',
        deliverable: '答辩Q&A清单 + 模拟答辩录像' },
      { role: 'reviewer', agentId: 'ai_teacher',
        responsibility: '质量审查：代码Review、PPT审查、论文审校',
        deliverable: '审查报告 + 修改建议' }
    ],
    subtaskTemplate: [
      { title: '项目需求分析', description: '明确项目目标、技术路线、创新点',
        assignedRole: 'coordinator', priority: 10, dependsOn: [] },
      { title: '制定项目计划', description: '分解任务、排期、分配人力',
        assignedRole: 'coordinator', priority: 10, dependsOn: [0] },
      { title: '核心技术开发', description: '实现核心功能模块',
        assignedRole: 'executor', priority: 9, dependsOn: [1] },
      { title: '技术文档撰写', description: '编写架构说明和API文档',
        assignedRole: 'executor', priority: 7, dependsOn: [2] },
      { title: '论文初稿', description: '撰写论文主体内容',
        assignedRole: 'executor', priority: 8, dependsOn: [2] },
      { title: 'PPT初版制作', description: '制作答辩PPT框架',
        assignedRole: 'executor', priority: 7, dependsOn: [2] },
      { title: '代码审查', description: 'Review代码质量和安全性',
        assignedRole: 'reviewer', priority: 6, dependsOn: [2] },
      { title: '论文审查', description: '审校论文内容和格式',
        assignedRole: 'reviewer', priority: 6, dependsOn: [4] },
      { title: 'PPT审查', description: '审查PPT内容和设计',
        assignedRole: 'reviewer', priority: 6, dependsOn: [5] },
      { title: '模拟答辩', description: '模拟真实答辩场景',
        assignedRole: 'executor', priority: 8, dependsOn: [5] },
      { title: '最终交付', description: '整合所有交付物',
        assignedRole: 'coordinator', priority: 10, dependsOn: [6,7,8,9] }
    ],
    estimatedDuration: 10080,  // 7天
    tags: ['竞赛', '创业', '答辩', '协作']
  },
  {
    id: 'tpl_group_project',
    name: '课程大作业',
    description: '小组课程项目的完整开发流程',
    agentRoles: [
      { role: 'coordinator', agentId: 'ai_teacher',
        responsibility: '组长：分工、排期、整合',
        deliverable: '分工表 + 时间计划' },
      { role: 'executor', agentId: 'ai_coder',
        responsibility: '开发：编码实现',
        deliverable: '完整代码' },
      { role: 'reviewer', agentId: 'ai_teacher',
        responsibility: '检查：代码Review + 报告审查',
        deliverable: '审查意见' }
    ],
    subtaskTemplate: [
      { title: '需求确认', description: '明确项目需求和评分标准',
        assignedRole: 'coordinator', priority: 10, dependsOn: [] },
      { title: '技术方案', description: '确定技术选型和架构',
        assignedRole: 'executor', priority: 9, dependsOn: [0] },
      { title: '编码实现', description: '完成核心功能开发',
        assignedRole: 'executor', priority: 9, dependsOn: [1] },
      { title: '代码审查', description: 'Review代码',
        assignedRole: 'reviewer', priority: 6, dependsOn: [2] },
      { title: '整合提交', description: '整理代码+文档提交',
        assignedRole: 'coordinator', priority: 10, dependsOn: [2,3] }
    ],
    estimatedDuration: 2880,  // 2天
    tags: ['课程', '小组', '开发']
  },
  {
    id: 'tpl_paper_writing',
    name: '论文写作',
    description: '从选题到终稿的学术论文写作流程',
    agentRoles: [
      { role: 'coordinator', agentId: 'ai_teacher',
        responsibility: '导师：选题指导、框架设计、定稿',
        deliverable: '选题确认 + 框架大纲' },
      { role: 'executor', agentId: 'ai_teacher',
        responsibility: '研究助理：文献综述、数据分析',
        deliverable: '文献综述 + 数据分析' },
      { role: 'executor', agentId: 'ai_interview',
        responsibility: '写作助手：正文撰写、排版',
        deliverable: '论文各章节初稿' },
      { role: 'reviewer', agentId: 'ai_teacher',
        responsibility: '审稿人：格式检查、逻辑审查',
        deliverable: '审稿意见' }
    ],
    subtaskTemplate: [
      { title: '选题确认', description: '确定研究方向和论文题目',
        assignedRole: 'coordinator', priority: 10, dependsOn: [] },
      { title: '文献综述', description: '查找并整理相关文献',
        assignedRole: 'executor', priority: 9, dependsOn: [0] },
      { title: '框架设计', description: '设计论文大纲和章节结构',
        assignedRole: 'coordinator', priority: 9, dependsOn: [1] },
      { title: '正文初稿', description: '撰写各章节内容',
        assignedRole: 'executor', priority: 9, dependsOn: [2] },
      { title: '格式排版', description: '按期刊要求排版',
        assignedRole: 'executor', priority: 5, dependsOn: [3] },
      { title: '审稿修改', description: '审查并提出修改意见',
        assignedRole: 'reviewer', priority: 8, dependsOn: [3] },
      { title: '定稿提交', description: '修改后定稿',
        assignedRole: 'coordinator', priority: 10, dependsOn: [4,5] }
    ],
    estimatedDuration: 5760,  // 4天
    tags: ['论文', '学术', '写作']
  }
]

export function getTemplateById(id: string): TeamTemplate | undefined {
  for (let t of TEMPLATES) {
    if (t.id === id) { return t }
  }
  return undefined
}

export function getAllTemplates(): TeamTemplate[] {
  return TEMPLATES
}
