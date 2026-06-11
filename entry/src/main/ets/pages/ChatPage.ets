/*
 * Copyright (C) 2024  即时通讯网(52im.net) & Jack Jiang.
 * The MobileIMSDK-鸿蒙Next客户端 Project. All rights reserved.
 *
 * 联系邮件：jack.jiang@52im.net
 * 联系微信：hellojackjiang
 * 联系QQ： 413980957
 * 技术社区：http://www.52im.net
 */

import {ErrorCode, ClientCoreSDK, PKickoutInfo} from 'mobileimsdk/Index'
import { ChatInputView } from './components/ChatInputView';
import { CustomeTitleBar } from './components/ChatTitleBar'
import { MsgView_normal } from './components/msg_view/NormalMsgView';
import { MsgView_system } from './components/msg_view/SystemMsgView';
import Message from './model/Message';
import MsgType from './constants/MsgType';
import MsgSendStatus from './constants/MsgSendStatus';
import MessagesDataSource from './model/MessagesDataSource';
import IMClientManager from '../IMClientManager';
import UIEvent from './constants/UIEvent';
import {router } from '@kit.ArkUI';
import ToolKits from './utils/ToolKits';
import { common } from '@kit.AbilityKit';
import { MsgTimeView } from './components/msg_view/MsgTimeView';
import { DeepSeekService, ChatMessage } from '../service/DeepSeekService';
import { aiCharacters } from '../model/AICharacterData';
import { BreakpointType, getBreakpoint, isTabletOrLarger } from './common/BreakpointSystem';
import { TarotService } from '../service/TarotService';

const TAG: string = '[ChatPage] '

/**
 * 主界面（聊天单页）。
 *
 * @author Jack Jiang(http://www.52im.net/thread-2792-1-1.html)
 */
@Entry
@Component
struct ChatPage {
  /** 聊天列表的滚动条组件 */
  private scroller: Scroller = new Scroller();

  /** 连接状态：false 连接断开、true 连接正常 */
  @State connectStatus: boolean = ClientCoreSDK.getInstance().connectedToServer;
  /** 心跳状态：true表示刚刚已发送心跳包，本心跳状态仅仅是为了在ui界面上实现心跳呼吸灯效果 */
  @State keepAliveStatus: boolean = false;

  /** 聊天消息列表对应的数据源对象（本对象与MessageProvider配合，用于实现UI界面与数据组的解偶）*/
  messagesDataSource: MessagesDataSource = new MessagesDataSource();

  /** 事件回调：增加了聊天消息 */
  meessageAddedEventCallback?: Function;
  /** 事件回调：更新了聊天消息（单条聊天消息） */
  meessageUpdateEventCallback?: Function;
  /** 事件回调：更新了聊天消息（多条聊天消息） */
  meessagesUpdateEventCallback?: Function;
  /** 事件回调：掉线重连完成 */
  loginCompleteEventCallback?: Function;
  /** 事件回调：掉线了 */
  disconnectedEventCallback?: Function;
  /** 事件回调：心跳了一次 */
  keepAliveEventCallback?: Function;
  /** 事件回调：你被踢了 */
  kickoutEventCallback?: Function;

  @State showSearch: boolean = false;  // 控制搜索框显隐
  @State searchKeyword: string = '';   // 搜索关键词
  @State contactId: string = '';
  @State contactName: string = '';
  @State inputText: string = '';  // 输入框文本
  @State greeting: string = '';  // AI问候语
  @State aiPrompt: string = '';  // AI角色的系统提示词
  @State isAILoading: boolean = false;  // AI是否正在响应
  @State isAIChat: boolean = false;  // 是否为AI聊天模式
  @State currentBreakpoint: BreakpointType = BreakpointType.SM;  // 当前断点
  // 气泡最大宽度（响应式，通过 AppStorage 传递给子组件）
  private bubbleMaxWidth: number = 320;

  /**
   * 生命周期中只被调用一次，类似于iOS中的viewDidLoad、Android中的onCreate.
   */
  aboutToAppear() {
    // 添加事件监听
    this.addEvents();

    // 设置初始气泡宽度
    this.updateBubbleMaxWidth();

    let params = router.getParams() as Record<string, Object>;
    if (params) {
      this.contactId = (params['contactId'] as string) || '';
      this.contactName = (params['contactName'] as string) || '';
      this.greeting = (params['greeting'] as string) || '';
      this.isAIChat = (params['isAI'] as boolean) || false;

      if (this.isAIChat) {
        // AI 模式：清空旧消息，加载 greeting
        IMClientManager.getInstance().getMessageProvider().clear();

        // 查找对应的 AI 角色，获取 prompt
        const aiCharacter = aiCharacters.find(ai => ai.id === this.contactId);
        if (aiCharacter) {
          this.aiPrompt = aiCharacter.prompt;
        }

        // 通过 MessagesProvider 加入 greeting 消息
        let greetingText = this.greeting || `你好，我是${this.contactName}`;
        let greetingMsg = new Message(this.contactId, this.contactName, Date.now(), greetingText, MsgType.TYPE_TEXT);
        IMClientManager.getInstance().getMessageProvider().putMessage(greetingMsg);

        // 刷新 DataSource 以触发 UI 更新
        this.messagesDataSource.notifyDataReload();
      }
    }
  }

  /**
   * 发送消息到 DeepSeek AI（带多轮对话上下文）。
   * 塔罗角色会先真抽牌，再送 AI 解读。
   * @param userMessage 用户消息内容
   */
  async sendMessageToAI(userMessage: string) {
    if (!this.aiPrompt || this.isAILoading) {
      return;
    }

    try {
      this.isAILoading = true;
      let localUid = ToolKits.getLocalUserUid() || 'me';
      let msgProvider = IMClientManager.getInstance().getMessageProvider();
      let isTarot = (this.contactId === 'ai_tarot');

      // 1. 添加用户消息到全局消息缓存
      let userMsg = new Message(localUid, '我', Date.now(), userMessage, MsgType.TYPE_TEXT);
      userMsg.sendStatus = MsgSendStatus.beReceived;
      msgProvider.putMessage(userMsg);

      // 2. 构建聊天消息
      let chatMessages: ChatMessage[] = [];

      if (isTarot) {
        // === 塔罗特殊流程：真抽牌 + 展示牌面 + AI 解读 ===
        let drawnCards = TarotService.getInstance().drawCards(3);

        // 展示抽到的牌（系统消息）
        let cardDisplay = TarotService.getInstance().formatCardsForDisplay(drawnCards);
        IMClientManager.getInstance().getMessageProvider().addSystemMessage(cardDisplay);

        // 使用 tarot 专用系统提示词
        chatMessages.push({ role: 'system', content: TarotService.getInstance().getSystemPrompt() });

        // 用户消息 = 问题 + 真实抽到的牌
        let tarotUserPrompt = TarotService.getInstance().buildUserPrompt(userMessage, drawnCards);
        chatMessages.push({ role: 'user', content: tarotUserPrompt });
      } else {
        // === 普通 AI 流程：带多轮上下文 ===
        chatMessages.push({ role: 'system', content: this.aiPrompt });

        let recentMessages = msgProvider.getRecentMessages(20);
        for (let m of recentMessages) {
          if (m.senderId === localUid) {
            chatMessages.push({ role: 'user', content: m.content });
          } else if (m.senderId === this.contactId) {
            chatMessages.push({ role: 'assistant', content: m.content });
          }
        }
      }

      // 3. 调用 DeepSeek API
      const aiResponse = await DeepSeekService.getInstance().chat(chatMessages);

      // 4. 添加 AI 回复到全局消息缓存
      let aiMsg = new Message(this.contactId, this.contactName, Date.now(), aiResponse, MsgType.TYPE_TEXT);
      msgProvider.putMessage(aiMsg);

      // 5. 滚动到底部
      this.scrollToBottom();

    } catch (error) {
      console.error(TAG + '发送消息到 AI 失败: ' + JSON.stringify(error));
      ToolKits.showToast('AI 响应失败，请稍后重试');
    } finally {
      this.isAILoading = false;
    }
  }

  /**
   * 界面被销毁时被调用。
   */
  aboutToDisappear() {
    // 取消事件通知
    this.removeEvents();
  }

  /**
   * 界面显示时被调用。
   */
  onPageShow(): void {
    // 本界面显示时，将输入法软键盘避让模式设置为KeyboardAvoidMode.RESIZE（即压缩窗体，而不是将窗体整体上移）
    ToolKits.setKeyboardAvoidModeToRESIZE(this.getUIContext(), true);
    // 设置全面屏状态栏颜色
    ToolKits.setStatusBarColor(getContext(this), ToolKits.chat_page_title_color, ToolKits.chat_page_title_background_color);
  }

  /**
   * 界面隐藏时被调用。
   */
  onPageHide(): void {
    // 本界面不显示时，将输入法软键盘避让模式还原为系统默认的KeyboardAvoidMode.OFFSET
    ToolKits.setKeyboardAvoidModeToRESIZE(this.getUIContext(), false);
  }

  /**
   * 添加事件监听。
   */
  addEvents() {
    // 【1】增加了聊天消息
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_messageAdded, this.meessageAddedEventCallback = (index: number) => {
      // 通知ListView的数据源，刷新消息显示
      this.messagesDataSource.notifyDataAdd(index);
      // 滚动消息列表至底部（以备显示最新消息）
      this.scrollToBottom();
    });

    // 【2】更新了聊天消息（单条聊天消息）
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_messageUpdate, this.meessageUpdateEventCallback = (index: number) => {
      // 通知ListView的数据源，刷新消息显示
      this.messagesDataSource.notifyDataChange(index);
    });

    // 【3】更新了聊天消息（多条聊天消息）
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_messagesUpdate, this.meessagesUpdateEventCallback = (updateIndexes: number[]) => {
      // 通知ListView的数据源，刷新消息显示（多条消息就直接reload，这样简单直接）
      this.messagesDataSource.notifyDataReload();
    });

    // 【4】掉线重连完成
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMAfterLoginComplete, this.loginCompleteEventCallback = (code: number) => {
      // 登陆或重连成功
      if(code == ErrorCode.COMMON_CODE_OK) {
        this.refreshConnecteStatus();
      }
    });

    // 【5】掉线了
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMDisconnected, this.disconnectedEventCallback = () => {
      this.refreshConnecteStatus();
    });

    // 【6】心跳了一次
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onIMPing, this.keepAliveEventCallback = () => {
      this.keepAliveStatus = true;
      setTimeout(() => {
        this.keepAliveStatus = false;
      }, 500);
    });

    // 【7】你被踢了
    IMClientManager.getInstance().getEmitter().on(UIEvent.UIEVENT_onKickout, this.kickoutEventCallback = (kickoutInfo: PKickoutInfo) => {
      this.beKickout(kickoutInfo);
    });
  }

  /**
   * 取消事件监听。
   */
  removeEvents() {
    // 【1】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_messageAdded, this.meessageAddedEventCallback);
    // 【2】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_messageUpdate, this.meessageUpdateEventCallback);
    // 【3】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_messagesUpdate, this.meessagesUpdateEventCallback);
    // 【4】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMAfterLoginComplete, this.loginCompleteEventCallback);
    // 【5】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMDisconnected, this.disconnectedEventCallback);
    // 【6】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onIMPing, this.keepAliveEventCallback);
    // 【7】
    IMClientManager.getInstance().getEmitter().off(UIEvent.UIEVENT_onKickout, this.kickoutEventCallback);
  }

  /**
   * 滚动消息列表到最底部，以备显示最新消息。
   */
  scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom);
  }

  /**
   * 更新气泡最大宽度（响应式 — 手机 320vp，平板 480vp）。
   */
  updateBubbleMaxWidth() {
    let tablet = isTabletOrLarger(this.currentBreakpoint);
    this.bubbleMaxWidth = tablet ? 480 : 320;
    AppStorage.setOrCreate<number>('bubbleMaxWidth', this.bubbleMaxWidth);
  }

  /**
   * 刷新连接状态。
   */
  refreshConnecteStatus() {
    this.connectStatus = ClientCoreSDK.getInstance().connectedToServer;
  }

  /**
   * 被踢的处理逻辑。
   */
  beKickout(kickoutInfo: PKickoutInfo) {
    // 首先释放IM所占资源
    IMClientManager.getInstance().releaseMobileIMSDK();

    // 提示信息
    let alertContent: string = '';
    if (kickoutInfo.code === PKickoutInfo.KICKOUT_FOR_DUPLICATE_LOGIN) {
      alertContent = '账号已在其它地方登陆，当前会话已断开，请退出后重新登陆！';
    } else if (kickoutInfo.code === PKickoutInfo.KICKOUT_FOR_ADMIN) {
      alertContent = '已被管理员强行踢出聊天，当前会话已断开！';
    } else {
      alertContent = '你已被踢出聊天，当前会话已断开（kickoutInfo=' + JSON.stringify(kickoutInfo) + '）！';
    }

    ClientCoreSDK.Log.error(TAG + alertContent);

    // 确认Action
    let primaryAction: Callback<void> = () => {
      this.switchToLoginPage();
    };

    // 取消Action
    let secondaryAction: Callback<void> = () => {
      let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      ToolKits.exitSystem(context);
    };

    // 显示对话框
    ToolKits.showAlertDialog(alertContent, '重新登录', undefined, primaryAction,'退出应用', $r('sys.color.ohos_id_color_badge_red'), secondaryAction);
  }

  /**
   * 切换到登陆界面。
   */
  switchToLoginPage() {
    // init MobileIMSDK first（必须保证此代码被调用，否则IM框架无法完成IM服务器的连接等工作）
    IMClientManager.getInstance().initMobileIMSDK(getContext(this).getApplicationContext(), getContext(this).eventHub);
    // goto login page!
    router.replaceUrl({ url: 'pages/LoginPage', });
  }

  build() {
    Column() {
      // 监听窗口宽度变化，更新断点和气泡宽度
      Column() {}.width('100%').height(0)
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let w = vp2px(newValue.width as number);
          let widthVp = px2vp(w);
          let bp = getBreakpoint(widthVp);
          if (bp !== this.currentBreakpoint) {
            this.currentBreakpoint = bp;
            this.updateBubbleMaxWidth();
          }
        })

      // 聊天界面自定义标题栏
      CustomeTitleBar({ 
        connectStatus: this.connectStatus, 
        keepAliveStatus: this.keepAliveStatus,
        showBackButton: true,
        onBackClick: () => {
          router.back();
        }
      })
      // 标题栏 Row，比如：
      Row() {
        // 返回按钮
        Image($r('app.media.app_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('聊天').fontSize(20).fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
          .layoutWeight(1)
        
        Button({ type: ButtonType.Circle }) {
          // 如果没有图标，直接用文字
          Text('🔍').fontSize(24)
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showSearch = !this.showSearch;
          this.searchKeyword = '';
        })
      }
      .width('100%').padding(10)
      if (this.showSearch) {
        TextInput({ placeholder: '搜索聊天记录...', text: this.searchKeyword })
          .width('90%')
          .margin(10)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
      }
      // 聊天界面内容区（AI 与 IM 统一使用 MessagesDataSource + LazyForEach）
      Column() {
        // List性能需极致优化的情况下，还可使用"组件复用"技术，详见官方资料：
        // https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-best-practices-long-list-V5#section36781044162218
        List({ scroller: this.scroller, space: 8 }) {
          LazyForEach(this.messagesDataSource, (m: Message, index: number) => {
            if (this.searchKeyword.length > 0 && !m.content.toLowerCase().includes(this.searchKeyword.toLowerCase())) {
              ListItem() {}.visibility(Visibility.None).height(0)
            } else {
              ListItem() {
                Column() {
                  MsgTimeView({ message: m })
                  if (m.msgType === MsgType.TYPE_TEXT) {
                    MsgView_normal({ message: m })
                  } else {
                    MsgView_system({ message: m })
                  }
                }
                // 高亮：匹配关键词的消息添加淡黄色背景
                .backgroundColor(
                  this.searchKeyword.length > 0 && m.content.toLowerCase().includes(this.searchKeyword.toLowerCase())
                    ? '#FFF3CD' : Color.Transparent
                )
              }
            }
          }, (m: Message, index: number) => MessagesDataSource.messageItemKey(m))
        }
        // 监听组件触屏事件，确保触碰聊天列表时，能自动收起输入法软键盘，提升用户体验
        .onTouch((event: TouchEvent) => {
          // 收起软键盘
          ToolKits.hideSoftInputMethod(this.getUIContext());
        })
        // 监听组件大小变化事件（用于实现当软键盘显示时，列表高度被压缩后，消息不能自动显示最后一条的问题）
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          let oldHeight = oldValue.height, newHeight = newValue.height;
          oldHeight = (oldHeight === undefined ? 0 : oldHeight);
          newHeight = (newHeight === undefined ? 0 : newHeight);
          // 列表高度变小，可以认为是软键盘显示了
          let toBeSmall = (newHeight > 0 && newHeight < oldHeight);
          if (toBeSmall) {
            // 消息列表滚动到底部，确保最新一条消息被显示
            this.scrollToBottom();
          }
        })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width("100%")
        .height('100%')
        .layoutWeight(1)
        .listDirection(Axis.Vertical)
      }
      .backgroundColor("#f0f2f6")
      .layoutWeight(1)

      // AI 思考中指示器
      if (this.isAIChat && this.isAILoading) {
        Row() {
          LoadingProgress()
            .width(16)
            .height(16)
            .color('#999999')
          Text(this.contactId === 'ai_tarot' ? '🔮 正在洗牌抽牌…' : '🤔 正在思考…')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 6 })
        }
        .width('100%')
        .padding({ left: 16, top: 6, bottom: 6 })
        .backgroundColor('#f0f2f6')
      }

      // 底部消息输入区
      ChatInputView({
        isAI: this.isAIChat,
        receiverId: this.contactId,
        onSendMessage: this.isAIChat ? (message: string) => {
          this.sendMessageToAI(message);
        } : undefined
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    // 适配流海屏（顶部状态栏透明并穿过，并透过底部上划操作区）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
