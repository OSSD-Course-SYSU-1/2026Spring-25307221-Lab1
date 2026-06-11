import http from '@ohos.net.http';
import { ApiConfig } from '../pages/common/ApiConfig';

const TAG: string = '[DeepSeekService] ';

// DeepSeek API 配置
const DEEPSEEK_API_URL = 'https://api.deepseek.com/v1/chat/completions';

// 消息结构
export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

// 请求体结构
interface DeepSeekRequestBody {
  model: string;
  messages: ChatMessage[];
  stream: boolean;
}

// API 响应结构
interface DeepSeekResponseMessage {
  role: string;
  content: string;
}

interface DeepSeekResponseChoice {
  message: DeepSeekResponseMessage;
  finish_reason: string;
}

interface DeepSeekResponse {
  choices: DeepSeekResponseChoice[];
}

// HTTP 请求头
interface HttpRequestHeader {
  'Content-Type': string;
  'Authorization': string;
}

// HTTP 请求选项
interface HttpRequestOptions {
  method: http.RequestMethod;
  header: HttpRequestHeader;
  extraData: string;
  connectTimeout: number;
  readTimeout: number;
}

/**
 * DeepSeek AI 服务
 */
export class DeepSeekService {
  private static instance: DeepSeekService | null = null;
  private httpRequest: http.HttpRequest | null = null;

  private constructor() {}

  static getInstance(): DeepSeekService {
    if (DeepSeekService.instance === null) {
      DeepSeekService.instance = new DeepSeekService();
    }
    return DeepSeekService.instance;
  }

  /**
   * 获取或创建 HTTP 请求对象（复用连接）。
   */
  private getHttpRequest(): http.HttpRequest {
    if (this.httpRequest === null) {
      this.httpRequest = http.createHttp();
    }
    return this.httpRequest;
  }

  /**
   * 发送聊天消息到 DeepSeek
   * @param messages 聊天消息列表
   * @returns AI 回复内容
   */
  async chat(messages: ChatMessage[]): Promise<string> {
    try {
      // 构建请求体
      const requestBody: DeepSeekRequestBody = {
        model: 'deepseek-chat',
        messages: messages,
        stream: false
      };

      console.info(TAG + '发送请求到 DeepSeek: ' + JSON.stringify(requestBody));

      // 构建请求头
      const requestHeader: HttpRequestHeader = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ApiConfig.DEEPSEEK_API_KEY}`
      };

      // 构建请求选项
      const options: HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: requestHeader,
        extraData: JSON.stringify(requestBody),
        connectTimeout: 60000,
        readTimeout: 60000
      };

      // 发送 POST 请求（复用 HTTP 连接）
      const response = await this.getHttpRequest().request(DEEPSEEK_API_URL, options);

      console.info(TAG + '收到响应: ' + JSON.stringify(response));

      // 检查响应状态
      if (response.responseCode === 200) {
        const result: DeepSeekResponse = JSON.parse(response.result as string) as DeepSeekResponse;

        if (result.choices && result.choices.length > 0) {
          const content = result.choices[0].message.content;
          console.info(TAG + 'AI 回复: ' + content);
          return content;
        } else {
          throw new Error('DeepSeek 响应中没有找到有效内容');
        }
      } else {
        throw new Error(`DeepSeek API 请求失败，状态码: ${response.responseCode}`);
      }
    } catch (error) {
      console.error(TAG + '调用 DeepSeek 失败: ' + JSON.stringify(error));
      throw new Error('DeepSeek API 调用失败');
    }
  }

  /**
   * 构建聊天消息列表
   * @param systemPrompt 系统提示词
   * @param userMessage 用户消息
   * @returns 聊天消息列表
   */
  buildMessages(systemPrompt: string, userMessage: string): ChatMessage[] {
    const messages: ChatMessage[] = [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userMessage }
    ];
    return messages;
  }
}
