import logging

from fastmcp import FastMCP
from langchain.chat_models import init_chat_model
from langchain_core.prompts import PromptTemplate
from langchain_mcp_adapters.client import MultiServerMCPClient
from langgraph.prebuilt import create_react_agent

logger = logging.getLogger("uvicorn")



MODEL = "openai:gpt-4.1"
CLIENT = MultiServerMCPClient(
    {
        "fetch": {"command": "uvx", "args": ["mcp-server-fetch"], "transport": "stdio"},
    }
)

model = init_chat_model(MODEL)

mcp = FastMCP(name="Demo")

@mcp.tool(
    name="fetch",
    description="Request data from the internet, can be used to retrieve weather information and news",
)
async def fetch(prompt: str) -> str:
    tools = await CLIENT.get_tools()
    logger.info(f"Loaded tools: {tools}")

    template = """
    Answer the following questions as best you can. You have access to
    the following tools:

    {tools}

    Use the following format:

    Question: the input question you must answer
    Thought: you should always think about what to do
    Action: the action to take, should be one of [{tool_names}]
    Action Input: the input to the action
    Observation: the result of the action
    ... (this Thought/Action/Action Input/Observation can repeat N times)
    Thought: I now know the final answer
    Final Answer: the final answer to the original input question

    Begin!

    Question: {input}
    Thought:{agent_scratchpad}
    """

    PROMPT = PromptTemplate.from_template(template)

    agent_executor = create_react_agent(model, tools)

    input_message = {
        "role": "user",
        "content": prompt,
    }

    response = []
    async for step in agent_executor.astream(
        {"messages": [input_message]}, stream_mode="values"
    ):
        response.append(step["messages"][-1].content)

    response = "\n".join(response)


    return response


if __name__ == "__main__":
    mcp.run()
