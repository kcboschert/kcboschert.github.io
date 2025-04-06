+++
date = '2025-04-05T17:46:01-05:00'
draft = false
tags = ["ai", "llm", "neovim", "vim", "terminal"]
title = 'AI Tooling at the Terminal'
+++

## Introduction

I was originally hesitant to adopt AI coding tools. Some of that was my own stubbornness. I enjoy writing code. Implementing my own ideas and seeing them come to life is fun. I didn't want to do less of the things I liked best about being a software engineer.

I had tried ChatGPT and ran some models locally with [Ollama](https://ollama.com), but I wasn't impressed and fell out of the loop. I later read how other people were successfully using large language models, and a lot of it seemed useful for greenfield projects, but less so for existing codebases. Then again, I was finding it more common to hear from friends and colleagues about it, so I decided it was finally time to take it seriously.

Now that I've found some tools I enjoy using, I don't feel like the parts of my job that I love are in danger. I spend a little more time reviewing code, but it's in small/manageable chunks.

Below are the tools I have begun to use. This is not an exhaustive list of the tools I have tried, but of the ones I have found most useful. Everything in the AI space is evolving quickly, so I may have a completely different list of tools I'm using a month from now.

I prefer to run LLMs locally as a way to control costs and because I like knowing how the code I share with these tools is used. This limits my options, since some tools only work with specific providers.

## CodeCompanion.nvim

I began my search for AI tools looking specifically for Neovim plugins. The copy-paste workflow with browser-based LLMs and Ollama was slow and not what I wanted my job to become. Having something built into my editor would be ideal, and [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) is the first tool that I enjoy using. Some of the things I like about it:

- It's compatible with Ollama (and many remote providers if that's your thing).
- There is a built-in [chat buffer](https://codecompanion.olimorris.dev/usage/chat-buffer/) in Neovim.
- It has a pre-populated, customizable [prompt library](https://codecompanion.olimorris.dev/usage/action-palette.html). Highlight a section of code and a keyboard shortcut will add it to the chat and ask the LLM to explain what it's doing.
- It supports [slash commands](https://codecompanion.olimorris.dev/usage/chat-buffer/slash-commands) and [variables](https://codecompanion.olimorris.dev/usage/chat-buffer/variables.html) for easily adding context via symbols, files, or URLs. It's a fun experiment to ask about a topic, clear the chat history, `/fetch https://about.tld/your-topic`, and ask it the same exact question.
- It has [workflows](https://codecompanion.olimorris.dev/extending/workflows.html) for iterating on a task. One of the built-in workflows is an `edit -> test` prompt that modifies code until the tests are passing.
- There are [tools](https://codecompanion.olimorris.dev/usage/chat-buffer/agents.html) that allow the agent to run commands, interact with files, and edit buffers upon confirmation. `Use the @editor tool to refactor the code in #buffer`. I haven't had much luck getting this functionality to work consistently. That could be due to the model I'm using or CodeCompanion's use of XML schema for invoking tools. The author is close to moving to function calling ([function calling](https://github.com/olimorris/codecompanion.nvim/pull/1141)), so I'm curious if I'll see an improvement once that's released.

## Aider

[Aider](https://aider.chat) is a CLI agent that gave me my lightbulb moment. I was working on generating a world map for a C#/Godot project of mine (more on that in a later post), and I had an idea of the code I wanted to write. I asked Aider to modify a method, describing what I wanted it to do as if I were pair programming with another engineer.

Not only did it give me the exact code I intended to write, but it also:

- Used a helper method that I had previously written in a different file.
- Created an intermediary object to hold the data I needed to pass to the helper method.

This was when it became clear to me how powerful LLMs can be if you [properly manage context](https://simonwillison.net/2025/Mar/11/using-llms-for-code/#context-is-king).

Aider does a few things to automatically manage context for you. It uses a [repository map](https://aider.chat/docs/repomap.html) to quickly gain a high-level overview of a codebase. This map has a list of the files in the repository, along with their key classes and functions. If a file or URL is mentioned in the chat, Aider will automatically ask to add the contents of that file/webpage to its context. Files can be automatically loaded as read-only to ensure Aider follows any [coding conventions](https://aider.chat/docs/usage/conventions.html) the codebase may have.

Aider has a *ton* of [configuration options](https://aider.chat/docs/config/options.html). It can be configured to automatically [lint and test](https://aider.chat/docs/usage/lint-test.html) the code it writes. If tests fail, Aider will add the test output to its context and pre-populate a modifiable prompt, asking the LLM to fix the implementation so that the tests pass. This is a more seamless version of CodeCompanion's workflows.

There are several [chat modes](https://aider.chat/docs/usage/modes.html) that can be used depending on the task at hand:

- `code` - Aider will modify files based on the prompt.
- `architect` - Similar to code, but the prompt will be given to an architect model to propose changes before handing it to the code/"editor" model. Combining different architect/code models has resulted in [improved benchmarks](https://aider.chat/2024/09/26/architect.html) compared to a single code model.
- `ask` - Free-form chat where Aider will answer questions without modifying files.

Overall, Aider has been the most consistently helpful tool so far. It's similar to CodeCompanion in many ways, but the methods it uses to add context tend to get me where I want to go faster.

## llama.vim / llama.vscode

[llama.vim](https://github.com/ggml-org/llama.vim) is another Vim plugin (and there's a [VSCode version](https://github.com/ggml-org/llama.vscode)!) that provides local LLM-assisted text completion. It's been purpose-built for one thing: to provide quality suggestions on consumer-grade hardware. llama.vim makes suggestions in the moment while I'm coding, and I can switch to chatting with Aider or CodeCompanion if needed.

Again, how this tool manages context is what makes it so powerful. A ring buffer is used to ensure the context never grows too large, which also ensures it can provide suggestions quickly. Context is automatically supplied from around the cursor when entering, leaving, yanking from, or saving a Vim buffer, and old/duplicate/similar context is removed whenever new context is added. The [original pull request](https://github.com/ggml-org/llama.cpp/pull/9787) does a great job describing this in-depth.

This is the tool I have the least experience with in this list, but I've already found it helps me stay focused in the terminal longer. For languages I use less frequently (e.g. bash), the autocomplete often answers syntax questions for me before I've even considered searching. For repetitive tasks, it "catches on" and does a lot of the boring work for me.

## Ollama & Backend Models

All of the previously mentioned tools abstract away a lot of the context management, but there are times where I still prefer to interact directly with an LLM to control the context myself. In those cases, Ollama is my go-to, with the following models being the most commonly used:

- [qwen-2.5](https://ollama.com/library/qwen2.5) - Chat, Aider's "architect" mode
- [qwen-2.5-coder](https://ollama.com/library/qwen2.5-coder) - CodeCompanion, Aider's "code" mode, and llama.vim's completion
- [llama3.2](https://ollama.com/library/llama3.2) - Summarization, writing commit messages

## Final Thoughts

Each of these tools has its own strengths and use cases. CodeCompanion.nvim is great for interactive coding sessions within Neovim, Aider excels at the command line with a good balance of automated and manual context management, and llama.vim offers real-time context-aware text completion. My approach has been to use these tools in an ascending order of context control: `llama.vim -> Aider/CodeCompanion -> Ollama`, escalating if I need to provide more direction.

I encourage readers to explore these tools and find the ones that best fit their workflow!
