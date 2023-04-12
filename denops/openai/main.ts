import { encode } from "./GPT-3-Encoder/encoder.ts";
import {
  batch,
  ChatCompletionOptions,
  Denops,
  // fn,
  // _op,
  // vars,
  ensureString,
  // ensureObject,
  // ensureNumber,
  OpenAI,
} from "./deps.ts";

const MAX_TOKENS = 4097

const SYSTEM_PROMPT = `
You are an excellent AI assistant source code commenter Bot.
Please output your response message according to following format.

# Summary
<the summary of a code>

# Details
<the details of the flow of a code>

Let's begin.
`

const ASYSTANT_PROMPT = `Sure, I'd be happy to help! Please provide me with the code you would like me to comment on.`

export async function main(denops: Denops) {
  let openAI: OpenAI

  denops.dispatcher = {
    initialize(argApiKey: unknown): Promise<void> {
      const apiKey = ensureString(argApiKey)
      openAI = new OpenAI(apiKey)
      return Promise.resolve();
    },

    async explain(argRemoteUrl: unknown, argFilePath: unknown, argContent: unknown): Promise<void> {
      await checkInitialized()

      const remoteUrl = ensureString(argRemoteUrl)
      const filePath = ensureString(argFilePath)
      const content = ensureString(argContent)

      const isPublicGit = await denops.call("openai#util#is_public_git", remoteUrl) === 1;

      if (!isPublicGit) {
        await denops.call("openai#error", `Can't send private git repo to OpenAI. ${remoteUrl}`)
        return Promise.reject()
      }

      const messages: ChatCompletionOptions["messages"] = [
        {
          "role": "system",
          "content": SYSTEM_PROMPT
        },
        {
          "role": "assistant",
          "content": ASYSTANT_PROMPT
        },
        {
          "role": "user",
          "content": `This code is part of the ${filePath} file located at ${remoteUrl}.`
        },
        {
          "role": "user",
          "content": `Please explain the following code.

code: """
${content}
"""
`
        }
      ]

      const chatCompletion = await openAI.createChatCompletion({
        model: "gpt-3.5-turbo",
        messages,
      });

      console.dir(chatCompletion, { depth: 10 })
      const text = chatCompletion.choices[0].message.content

      await denops.call("openai#window#dispatch", text);

      return Promise.resolve()
    },
  };

  async function checkInitialized() {
    if (!openAI) {
      throw new Error("OpenAI not initialized")
    }
  }

  await batch(denops, async (_denops: Denops) => {
    // initialize
  });
}
